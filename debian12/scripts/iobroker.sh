#!/usr/bin/bash

# run iob fix
iob_fix () {
  if [ "$(id -u)" -eq 0 ]; then
    echo "The ioBroker fixer script is not specifically designed to run in Docker."
    echo "Although it is generally safe to use, use it at your own risk and make sure to restart your container immediately after execution!"

    local reply
    read -rp 'Do you want to continue? [yes/no] ' reply
    if [[ "$reply" == y || "$reply" == Y || "$reply" == yes ]]; then
      : # continue
    else
      return 1
    fi
    curl -sL https://iobroker.net/fix.sh | bash -
  else
    echo "Due to some limitations in Docker, you need to run the ioBroker fixer script as root."
    echo "Please connect as root user and try again."
  fi
}

# run iob diag
iob_diag () {
  if [ "$(id -u)" -eq 0 ]; then
    echo "The ioBroker diag script is not specifically designed to run in Docker."
    echo "Although it is generally safe to use, use it at your own risk."
    local reply
    read -rp 'Do you want to continue? [yes/no] ' reply
    if [[ "$reply" == y || "$reply" == Y || "$reply" == yes ]]; then
      : # continue
    else
      return 1
    fi
    curl -sLf https://iobroker.net/diag.sh --output /home/iobroker/.diag.sh && bash /home/iobroker/.diag.sh | gosu iobroker tee /home/iobroker/iob_diag.log
  else
    echo "Due to some limitations in Docker, you need to run the ioBroker fixer script as root."
    echo "Please connect as root user and try again."
  fi
}

if [ "$1" = "fix" ]; then # call iobroker fixer
  iob_fix
elif [ "$1" = "node fix" ]; then # call iobroker node fixer
  echo "The execution of this command is blocked as your ioBroker is running inside a Docker container!"
  echo "To fix any issues with nodejs, please pull the latest version of the Docker image and recreate your container."
elif [ "$1" = "diag" ]; then # call iobroker diag script
  iob_diag
elif [ "$1" = "start" ] || [ "$1" = "stop" ] || [ "$1" = "restart" ]; then # block execution of iobroker start | stop | restart
  echo "The execution of this command is blocked as your ioBroker is running inside a Docker container!"
  echo "For more details see ioBroker Docker image docs (https://docs.buanet.de/iobroker-docker-image/docs/) or use the maintenance script 'maintenance --help'."
elif [ "$1" = "m" ] || [ "$1" = "maint" ] || [ "$1" = "maintenance" ]; then # call iobroker maintenance script
  shift
  if [ "$(id -u)" -eq 0 ]; then # check for execution as root
    gosu iobroker bash /opt/scripts/maintenance.sh "$@"
  else
    bash /opt/scripts/maintenance.sh "$@"
  fi
else # passing all other parameters to iobroker.js
  if [ "$(id -u)" -eq 0 ]; then # check for execution as root
    gosu iobroker node /opt/iobroker/node_modules/iobroker.js-controller/iobroker.js "$@"
  else
    node /opt/iobroker/node_modules/iobroker.js-controller/iobroker.js "$@"
  fi
fi
