#!/usr/bin/env bash

# bash strict mode
set -euo pipefail

autoconfirm=      # can be set to 'yes' by command line option
killbyname=       # can be set to 'yes' by command line option (undocumented, only for use with backitup restore scripts)
internal_detached=      # internal marker to prevent recursive detached relaunch
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

# detect if script is called from ioBroker process tree (e.g. javascript adapter)
called_from_iobroker_tree() {
  local current_pid parent_pid parent_args

  current_pid="$PPID"
  while [[ "$current_pid" =~ ^[0-9]+$ ]] && (( current_pid > 1 )); do
    parent_args="$(ps -o args= -ww -p "$current_pid" 2> /dev/null || true)"
    if [[ "$parent_args" == *"iobroker.js-controller"* ]] || [[ "$parent_args" == *"controller.js"* ]] || [[ "$parent_args" == *"javascript.js"* ]]; then
      return 0
    fi

    parent_pid="$(ps -o ppid= -p "$current_pid" 2> /dev/null | tr -d ' ' || true)"
    if [[ ! "$parent_pid" =~ ^[0-9]+$ ]] || (( parent_pid <= 1 )); then
      break
    fi
    current_pid="$parent_pid"
  done

  return 1
}

# relaunch command detached from current process tree and return immediately
run_detached() {
  local log_file

  log_file="/opt/iobroker/log/maintenance-detached.log"
  if command -v setsid > /dev/null 2>&1; then
    setsid -f bash "$0" "$@" > "$log_file" 2>&1 < /dev/null
  else
    nohup bash "$0" "$@" > "$log_file" 2>&1 < /dev/null &
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
    while pgrep -u iobroker -f 'io\..' > /dev/null; (( $? != 1 )); do
      if (($(date +%s) > timeout)); then
        echo -e "\nTimeout reached. Killing remaining processes..."
        pgrep --list-full -u iobroker -f 'io\..'
        pkill --signal SIGKILL -u iobroker -f 'io\..'
        echo "Done."
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
  echo " "
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

  if [[ "$internal_detached" != yes ]] && called_from_iobroker_tree; then
    local -a detached_args

    detached_args=(restart --internal-detached)
    if [[ "$autoconfirm" == yes ]]; then
      detached_args+=(-y)
    fi
    if [[ "$killbyname" == yes ]]; then
      detached_args+=(-kbn)
    fi

    echo "Detected execution from ioBroker process tree."
    echo "Restart command will continue in detached mode."
    run_detached "${detached_args[@]}"
    echo "Detached restart process started."
    return
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

# restore iobroker <<< Removed due to changes in backup structure and the availability of the graphical restore with backitup
restore_iobroker() {
  echo "Due to changes in ioBroker backup structure, restoring is no longer supported by this script."
  echo "Please use the original ioBroker commands or the graphical ui of backitup adapter."
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
    --internal-detached)
      internal_detached=yes
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
