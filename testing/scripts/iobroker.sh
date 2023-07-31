#!/usr/bin/bash

if [ "$(id -u)" -eq 0 ]; then
  echo "WARNING! IoBroker should not be executed as root!"
fi

if [ "$1" = "fix" ]; then # call iobroker fixer
  curl -sL https://iobroker.net/fix.sh | bash -
elif [ "$1" = "diag" ]; then # call iobroker diag script
  if [ "$(id -u)" -eq 0 ]; then # check for execution as root
    gosu iobroker curl -sLf https://iobroker.net/diag.sh --output /home/iobroker/.diag.sh && bash /home/iobroker/.diag.sh | gosu iobroker tee /home/iobroker/iob_diag.log
  else
    curl -sLf https://iobroker.net/diag.sh --output /home/iobroker/.diag.sh && bash /home/iobroker/.diag.sh | tee /home/iobroker/iob_diag.log
  fi
elif [ "$1" = "start" ] || [ "$1" = "stop" ] || [ "$1" = "restart" ]; then # block execution of iobroker start | stop | restart
  echo "The execution of this command is blocked as your ioBroker is running inside a Docker container!"
  echo "Please check ioBroker Docker image docs (https://docs.buanet.de) for the proper way to perform this action!"
else # passing all other parameters to iobroker.js
  if [ "$(id -u)" -eq 0 ]; then # check for execution as root
    gosu iobroker node /opt/iobroker/node_modules/iobroker.js-controller/iobroker.js "$@"
  else
    node /opt/iobroker/node_modules/iobroker.js-controller/iobroker.js "$@"
  fi
fi
