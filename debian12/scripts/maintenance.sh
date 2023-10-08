#!/usr/bin/env bash

# bash strict mode
set -euo pipefail

autoconfirm=      # can be set to 'yes' by command line option
killbyname=       # can be set to 'yes' by command line option (undocumented, only for use with backitup restore scripts)
healthcheck=/opt/.docker_config/.healthcheck      # path of healthcheck file
pkill_timeout=10      # timeout for stopping iobroker in seconds

# check for user root
if [ "$(id -u)" -eq 0 ]; then
  echo "WARNING! This script should be executed as user "iobroker"! Please switch user and try again."
  exit 1
fi

# display help text
display_help() {
  echo "This script helps you manage your ioBroker container!"
  echo " "
  echo "Usage: maintenance [ COMMAND ] [ OPTION ]"
  echo "       maint [ COMMAND ] [ OPTION ]"
  echo "       m [ COMMAND ] [ OPTION ]"
  echo " "
  echo "COMMANDS"
  echo "------------------"
  echo "       status     > reports the current state of maintenance mode"
  echo "       on         > switches mantenance mode ON"
  echo "       off        > switches mantenance mode OFF and stops or restarts the container"
  echo "       upgrade    > puts the container to maintenance mode and upgrades ioBroker"
  echo "       restart    > stops iobroker and stops or restarts the container"
  echo "       restore    > stops iobroker and restores the last backup"
  echo "       help       > shows this help"
  echo " "
  echo "OPTIONS"
  echo "------------------"
  echo "       -y|--yes   > confirms the used command without asking"
  echo "       -h|--help  > shows this help"
  echo " "
}

# check maintenance enabled
maintenance_enabled() {
  [[ -f "$healthcheck" && "$(cat "$healthcheck")" == maintenance ]]
}

# check status starting
check_starting() {
  [[ -f "$healthcheck" && "$(cat "$healthcheck")" == starting ]]
}

# display maintenance status
maintenance_status() {
  if maintenance_enabled; then
    echo "Maintenance mode is turned ON."
  else
    echo "Maintenance mode is turned OFF."
  fi
}

# enable maintenance mode
enable_maintenance() {
  if maintenance_enabled; then
    echo "Maintenance mode is already turned ON."
    return
  fi

  echo "You are now going to stop ioBroker and activate maintenance mode for this container."

  if [[ "$killbyname" != yes ]]; then
    if [[ "$autoconfirm" != yes ]]; then
      local reply

      read -rp 'Do you want to continue [yes/no]? ' reply
      if [[ "$reply" == y || "$reply" == Y || "$reply" == yes ]]; then
      : # continue
      else
        return 1
      fi
    fi
  fi

  echo "Activating maintenance mode..."
  echo "maintenance" > "$healthcheck"
  sleep 1
  echo -n "Stopping ioBroker..."
  stop_iob
}

# disable maintenance mode
disable_maintenance() {
  if ! maintenance_enabled; then
    echo "Maintenance mode is already turned OFF."
    return
  fi

  echo "You are now going to deactivate maintenance mode for this container."
  echo "Depending on the restart policy, your container will be stopped or restarted immediately."

  if [[ "$autoconfirm" != yes ]]; then
    local reply

    read -rp 'Do you want to continue [yes/no]? ' reply
    if [[ "$reply" == y || "$reply" == Y || "$reply" == yes ]]; then
      : # continue
    else
      return 1
    fi
  fi

  echo "Deactivating maintenance mode and forcing container to stop or restart..."
  echo "stopping" > "$healthcheck"
  pkill -u iobroker
  echo "Done."
}

# upgrade js-controller
upgrade_jscontroller() {
  echo "You are now going to upgrade your js-controller."
  echo "As this will change data in /opt/iobroker, make sure you have a backup!"
  echo "During the upgrade process, the container will automatically switch into maintenance mode and stop ioBroker."
  echo "Depending on the restart policy, your container will be stopped or restarted automatically after the upgrade."

  if [[ "$autoconfirm" != yes ]]; then
    local reply

    read -rp 'Do you want to continue [yes/no]? ' reply
    if [[ "$reply" == y || "$reply" == Y || "$reply" == yes ]]; then
      : # continue
    else
      return 1
    fi
  fi

  if ! maintenance_enabled > /dev/null; then
    autoconfirm=yes
    enable_maintenance
  fi

  echo "Upgrading js-controller..."
  iobroker update
  sleep 1
  iobroker upgrade self
  sleep 1
  echo "Done."

  echo "Container will be stopped or restarted in 5 seconds..."
  sleep 5
  echo "stopping" > "$healthcheck"
  pkill -u iobroker
}

# stop iobroker and wait until all processes stopped or pkill_timeout is reached
stop_iob() {
  local status timeout

  timeout="$(date --date="now + $pkill_timeout sec" +%s)"
  pkill -u iobroker -f 'iobroker.js-controller[^/]*$'
  status=$?
  if (( status >= 2 )); then      # syntax error or fatal error
    return 1
  elif (( status == 1 )); then      # no processes matched
    return
  fi

  if [[ "$killbyname" != yes ]]; then
    # pgrep exits with status 1 when there are no matches
    while pgrep -u iobroker -f 'io.' > /dev/null; (( $? != 1 )); do
      if (($(date +%s) > timeout)); then
        echo -e "\nTimeout reached. Killing remaining processes..."
        pgrep --list-full -u iobroker
        pkill --signal SIGKILL -u iobroker -f 'io.'
        echo "\nDone."
        return
      fi
      sleep 1
      echo -n "."
    done
  else
    for ((i=0; i<3; i++)); do
      sleep 1
      echo -n "."
    done
  fi

  echo -e "Done."
}

# restart container
restart_container() {
  echo "You are now going to call a restart of your container."
  echo "Restarting will work depending on the configured restart policy."

  if [[ "$autoconfirm" != yes ]]; then
    local reply

    read -rp 'Do you want to continue [yes/no]? ' reply
    if [[ "$reply" == y || "$reply" == Y || "$reply" == yes ]]; then
      : # continue
    else
      return 1
    fi
  fi

  if ! maintenance_enabled > /dev/null; then
    echo -n "Stopping ioBroker..."
    stop_iob
  fi

  echo "Container will be stopped or restarted in 5 seconds..."
  sleep 5
  echo "stopping" > "$healthcheck"
  pkill -u iobroker
}

# restore iobroker
restore_iobroker() {
  echo "You are now going to perform a restore of your iobroker."
  echo "During the restore process, the container will automatically switch into maintenance mode and stop ioBroker."
  echo "Depending on the restart policy, your container will be stopped or restarted automatically after the restore."

  if [[ "$autoconfirm" != yes ]]; then
    local reply

    read -rp 'Do you want to continue [yes/no]? ' reply
    if [[ "$reply" == y || "$reply" == Y || "$reply" == yes ]]; then
      : # continue
    else
      return 1
    fi
  fi

  if check_starting > /dev/null; then
    echo "Startup script is still running."
    echo "Please check container log and wait until ioBroker is sucessfully started."
    echo "Then try again."
    return 1
  fi

  if ! maintenance_enabled > /dev/null; then
    autoconfirm=yes
    enable_maintenance
  fi

  echo -n "Restoring ioBroker... "
  set +e
  bash iobroker restore 0 > /opt/iobroker/log/restore.log 2>&1
  return=$?
  set -e
  if [[ "$return" -ne 0 ]]; then
    echo "Failed."
    echo "For more details see \"/opt/iobroker/log/restore.log\"."
    echo "Please check backup file location and permissions and try again." 
    return 1
  fi
  echo "Done."
  echo " "
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "!!!!                             IMPORTANT NOTE                             !!!!"
  echo "!!!!      The maintenance script restored iobroker from a backup file.      !!!!"
  echo "!!!! Check /opt/iobroker/log/restore.log to see if restore was successful.  !!!!"
  echo "!!!!   When ioBroker starts it will reinstall all Adapters automatically.   !!!!"
  echo "!!!!         This might be take a looooong time! Please be patient!         !!!!"
  echo "!!!!  You can view installation process by taking a look at ioBroker log.   !!!!"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  sleep 10
  echo "Container will be stopped or restarted in 10 seconds..."
  sleep 10
  echo "stopping" > "$healthcheck"
  pkill -u iobroker
}

# parsing commands and options

# default command to run unless another was given
run=(display_help)

for arg in "$@"; do
  case $arg in
    help|-h|--help)
      run=(display_help)
      ;;
    status|stat|s)
      run=(maintenance_status)
      ;;
    on)
      run=(enable_maintenance)
      ;;
    off)
      run=(disable_maintenance)
      ;;
    upgrade|upgr|u)
      run=(upgrade_jscontroller)
      ;;
    restart|rest|r)
      run=(restart_container)
      ;;
    restore)
      run=(restore_iobroker)
      ;;
    -y|--yes)
      autoconfirm=yes
      ;;
    -kbn|--killbyname)
      killbyname=yes
      ;;
    --)
      break
      ;;
    *)
      >&2 echo "Unknown parameter: $arg"
      >&2 echo "Please try again or see help (help|-h|--help)."
      exit 1
      ;;
  esac
done

"${run[@]}"