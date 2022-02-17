#!/usr/bin/env bash

# Bash strict mode.
set -euo pipefail

autoconfirm=       # Can be set to 'yes' by command line option.
killbyname=        # Can be set to 'yes' by command line option /
                   # undocumented, only for use with backitup restore scripts.
healthcheck=/opt/scripts/.docker_config/.healthcheck
sigterm_timeout=15 # seconds

display_help() {
  echo 'This script manages your ioBroker container.'
  echo ''
  echo "Usage: ${BASH_SOURCE[0]} COMMAND [OPTION]"
  echo ''
  echo 'COMMANDS'
  echo '------------------'
  echo '       status     > reports the current state of maintenance mode'
  echo '       on         > switches mantenance mode ON'
  echo '       off        > switches mantenance mode OFF and stops or restarts the container'
  echo '       upgrade    > puts the container to maintenance mode and upgrades ioBroker'
  echo '       help       > shows this help'
  echo ''
  echo 'OPTIONS'
  echo '------------------'
  echo '       -y|--yes   > confirms the used command without asking'
  echo '       -h|--help  > shows this help'
  echo ''
}

maintenance_enabled() {
  [[ -f "$healthcheck" && "$(cat "$healthcheck")" == maintenance ]]
}

maintenance_status() {
  if maintenance_enabled; then
    echo 'Maintenance mode is turned ON.'
  else
    echo 'Maintenance mode is turned OFF.'
  fi
}

enable_maintenance() {
  if maintenance_enabled; then
    echo 'Maintenance mode is already turned ON.'
    return
  fi

  if [[ "$killbyname" == yes ]]; then
    # Undocumented, only for use with backitup restore scripts.

    echo 'This command will activate maintenance mode and stop js-controller.'
    echo 'Activating maintenance mode...'
    echo 'maintenance' > "$healthcheck"
    echo 'Stopping ioBroker...'
    stop_and_wait "$sigterm_timeout" -u iobroker -f iobroker.js-controller
    echo 'Done.'
    return
  fi

  echo 'You are now going to stop ioBroker and activate maintenance mode for this container.'

  if [[ "$autoconfirm" != yes ]]; then
    local reply

    read -rp 'Do you want to continue [yes/no]? ' reply
    if [[ "$reply" == y || "$reply" == Y || "$reply" == yes ]]; then
      : # Pass.
    else
      return 1
    fi
  else
    echo 'This command was already confirmed by the -y or --yes option.'
  fi

  echo 'Activating maintenance mode...'
  echo 'maintenance' > "$healthcheck"
  echo 'Stopping ioBroker...'
  stop_and_wait "$sigterm_timeout" -u iobroker
}

disable_maintenance() {
  if ! maintenance_enabled; then
    echo 'Maintenance mode is already turned OFF.'
    return
  fi

  echo 'You are now going to deactivate maintenance mode for this container.'
  echo 'Depending on the restart policy, your container will be stopped or restarted immediately.'

  if [[ "$autoconfirm" != yes ]]; then
    local reply

    read -rp 'Do you want to continue [yes/no]? ' reply
    if [[ "$reply" == y || "$reply" == Y || "$reply" == yes ]]; then
      : # Pass.
    else
      return 1
    fi
  else
    echo 'This command was already confirmed by the -y or --yes option.'
  fi

  echo 'Deactivating maintenance mode and forcing container to stop or restart...'
  echo 'stopping' > "$healthcheck"
  stop_and_wait "$sigterm_timeout" -u root
}

upgrade_jscontroller() {
  echo 'You are now going to upgrade your js-controller.'
  echo 'As this will change data in /opt/iobroker, make sure you have a backup!'
  echo 'During the upgrade process, the container will automatically switch into maintenance mode and stop ioBroker.'
  echo 'Depending on the restart policy, your container will be stopped or restarted automatically after the upgrade.'

  if [[ "$autoconfirm" != yes ]]; then
    local reply

    read -rp 'Do you want to continue [yes/no]? ' reply
    if [[ "$reply" == y || "$reply" == Y || "$reply" == yes ]]; then
      : # Pass.
    else
      return 1
    fi
  else
    echo 'This command was already confirmed by the -y or --yes option.'
  fi

  if ! maintenance_enabled > /dev/null; then
    autoconfirm=yes
    enable_maintenance
  fi

  echo 'Upgrading js-controller...'
  iobroker update
  iobroker upgrade self
  echo 'Done.'

  echo 'Container will be stopped or restarted...'
  echo 'stopping' > "$healthcheck"
  stop_and_wait "$sigterm_timeout" -u root
}

stop_and_wait() {
  local status timeout

  timeout="${1:?Need timeout in seconds}"
  shift

  timeout="$(date --date="now + $timeout sec" +%s)"
  pkill "$@"
  status=$?
  if (( status >= 2 )); then # Syntax error or fatal error.
    return 1
  fi

  if (( status == 1 )); then # No processes matched or could be signalled.
    return
  fi

  # pgrep exits with status 1 when there are no matches, i.e. everyone exited.
  while pgrep "$@" > /dev/null; (( $? != 1 )); do
    if (($(date +%s) > timeout)); then
      printf 'timed out\n'
      return 1
    fi

    printf '.'
    sleep 0.5
  done

  printf '\n'
}

# Default command to run unless another was given.
run=(display_help)
for arg in "$@"; do
  case $arg in
    help|-h|--help)
      run=(display_help)
      ;;
    status)
      run=(maintenance_status)
      ;;
    on)
      run=(enable_maintenance)
      ;;
    off)
      run=(disable_maintenance)
      ;;
    upgrade)
      run=(upgrade_jscontroller)
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
      >&2 echo 'Please try again or see help (help|-h|--help).'
      exit 1
      ;;
  esac
done

"${run[@]}"
