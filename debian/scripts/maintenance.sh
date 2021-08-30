#!/bin/bash

############################
##### default settings #####
############################

autoconfirm=no              # yould be set to true by commandline option
switch=none


####################################
##### declaration of functions #####
####################################

# display help text
display_help() {
  echo "This script is build to manage your ioBroker container!"
  echo ''
  echo "Usage: maintenance [ COMMAND ] [ OPTION ]"
  echo "       maint [ COMMAND ] [ OPTION ]"
  echo ''
  echo "COMMANDS"
  echo "------------------"
  echo "       status     > gives the current state of maintenance mode"
  echo "       on         > switches mantenance mode ON"
  echo "       off        > switches mantenance mode OFF and shuts down/ restarts container"
  echo "       upgrade    > will put container to maintenance mode and upgrade iobroker"
  echo "       help       > shows this help"
  echo ''
  echo "OPTIONS"
  echo "------------------"
  echo "       -y|--yes   > confirms the used command without asking"
  echo "       -h|--help  > shows this help"  
  echo ''  
  exit 0
}

# checking maintenance mode status
check_status() {
  if [ $(cat /opt/scripts/.docker_config/.healthcheck) == 'maintenance' ]
  then
    echo 'Maintenance mode is turned ON.'
  elif [ $(cat /opt/scripts/.docker_config/.healthcheck) != 'maintenance' ]
  then
    echo 'Maintenance mode is turned OFF.'
  fi
}

# turn maintenance mode ON
switch_on() {
  if [ $(cat /opt/scripts/.docker_config/.healthcheck) != 'maintenance' ] && [ "$autoconfirm" == "no" ] # maintenance mode OFF / autoconfirm = no
  then
    echo 'You are now going to stop ioBroker and activating maintenance mode for this container.'
    read -p 'Do you want to continue [yes/no]? ' A
    if [ "$A" == "y" ] || [ "$A" == "Y" ] || [ "$A" == "yes" ]
    then
      echo 'Activating maintenance mode...'
      echo "maintenance" > /opt/scripts/.docker_config/.healthcheck
      sleep 1
      echo 'Done.'
      echo 'Stopping ioBroker...'
      pkill -u iobroker
      sleep 1
      echo 'Done.'
      exit 0
    else
    exit 0
    fi
  elif [ $(cat /opt/scripts/.docker_config/.healthcheck) != 'maintenance' ] && [ "$autoconfirm" == "yes" ] # maintenance mode OFF / autoconfirm = yes
  then
    echo 'You are now going to stop ioBroker and activating maintenance mode for this container.'
    echo 'This command was already confirmed by -y or --yes option.'
    echo 'Activating maintenance mode...'
    echo "maintenance" > /opt/scripts/.docker_config/.healthcheck
    sleep 1
    echo 'Done.'
    echo 'Stopping ioBroker...'
    pkill -u iobroker
    sleep 1
    echo 'Done.'
    exit 0
  else
    echo 'Maintenance mode is already turned ON.'
  fi
}

# turn maintenance mode OFF
switch_off() {
  echo 'You are now going to deactivate maintenance mode for this container.'
  echo 'Depending on the restart policy, your container will be stopped/ restarted immediately.'
  read -p 'Do you want to continue [yes/no]? ' A
  if [ "$A" == "y" ] || [ "$A" == "Y" ] || [ "$A" == "yes" ]
  then
    echo 'Deactivating maintenance mode and forcing container to stop/ restart...'
    echo "stopping" > /opt/scripts/.docker_config/.healthcheck
    pkill -u root
    exit 0
  else
    exit 0
  fi
}

# upgrade js-controller
upgrade() {
  echo 'You are now going to upgrade your js-controller.'
  echo 'As this will change data in /opt/iobroker, make sure you have a backup!'
  echo 'During the upgrade process the container will automatically switch into maintenance mode and stop ioBroker.'
  echo 'Depending of the restart policy, you container will be stoped/ restarted automatically after the upgrade.'
  read -p 'Do you want to continue [yes/no]? ' A
  if [ "$A" == "y" ] || [ "$A" == "Y" ] || [ "$A" == "yes" ]
  then
    echo 'Activating maintenance mode...'
    echo "maintenance" > /opt/scripts/.docker_config/.healthcheck
    sleep 1
    echo 'Done.'
    echo 'Stopping ioBroker...'
    pkill -u iobroker
    sleep 1
    echo 'Done.'
    echo 'Upgrading js-controller...'
    iobroker update
    iobroker upgrade self
    sleep 1
    echo 'Done.'
    echo 'Container will be stopped/ restarted in 5 seconds...'
    sleep 5
    echo "stopping" > /opt/scripts/.docker_config/.healthcheck
    pkill -u root
    exit 0
  else
    exit 0
  fi
}

########################################
##### parsing commands and options #####
########################################

# reading all arguments and putting them in reverse
reverse=
for i in "$@"; do
  reverse="$i $reverse"
done

# checking the arguments 
for i in $reverse; do
  case $i in
    help|-h|--help)
      display_help        # calling function to display help text
      exit
      ;;
    status)
      check_status        # calling function to check maintenance mode status
      ;;
    on)
      switch_on           # calling function to switch maintenance mode on
      ;;
    off)
      switch_off          # calling function to switch maintenance mode off
      ;;
    upgrade)
      upgrade             # calling function to upgrade js-controller
      ;;
    -y|--yes)
      autoconfirm=yes     # setting autoconfrm option to "yes"
      ;;
    -a=*|--argument=*)    # dummy exaple for parsing option with value
      ARGUMENT="${i#*=}"
      shift
      ;;
    --)                   # End of all options.
      shift
      break
      ;;
    -?*|?*)
      echo 'WARN: Unknown parameter. Please try again or see help (-h|--help).'
      break
      ;;
    *)                    # Default case: No more options, so break out of the loop.
      break
      ;;
  esac
done

exit 0
