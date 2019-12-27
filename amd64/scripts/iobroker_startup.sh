#!/bin/bash

# Reading ENV
adminport=$ADMINPORT
avahi=$AVAHI
gid=$SETGID
packages=$PACKAGES
redis=$REDIS
uid=$SETUID
usbdevices=$USBDEVICES
zwave=$ZWAVE

# Getting date and time for logging 
dati=`date '+%Y-%m-%d %H:%M:%S'`

# Logging header
echo ' '
echo "$(printf -- '-%.0s' {1..60})"
echo -n "$(printf -- '-%.0s' {1..15})" && echo -n "     "$dati"      " && echo "$(printf -- '-%.0s' {1..15})"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '
echo "$(printf -- '-%.0s' {1..60})"
echo "-----       Welcome to your ioBroker-container!        -----"
echo "-----          Startupscript is now running.           -----"
echo "-----                Please be patient!                -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '
echo "$(printf -- '-%.0s' {1..60})"
echo "-----              Debugging information               -----"
echo "-----                                                  -----"
echo "-----                      System                      -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" arch: $(uname -m))" && echo " -----"
echo "-----                                                  -----"
echo "-----                     Versions                     -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" image: $VERSION)" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" node: $(node -v))" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" npm: $(npm -v))" && echo " -----"
echo "-----                                                  -----"
echo "-----                       ENV                        -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" ADMINPORT: $ADMINPORT)" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" AVAHI: $AVAHI)" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" PACKAGES: $PACKAGES)" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" REDIS: $REDIS)" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" SETGID: $SETGID)" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" SETUID: $SETUID)" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" USBDEVICES: $USBDEVICES)" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" ZWAVE: $ZWAVE)" && echo " -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '


# Not in use
# if [ -f /opt/.firstrun ]
# rm -f /opt/.firstrun


#####
# STEP 1 - Preparing container
#####
echo "$(printf -- '-%.0s' {1..60})"
echo "-----         Step 1 of 5: Preparing container         -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '

# Installing additional packages
if [ "$packages" != "" ]
then
  echo "Installing additional packages is set by ENV."
  echo "The following packages will be installed:" $packages"..."
  echo $packages > /opt/scripts/.packages
  sh /opt/scripts/setup_packages.sh > /opt/scripts/setup_packages.log 2>&1
  echo "Done."
else
  echo "There are no additional packages defined."
fi
echo ' '

# Checking and setting uid/gid
if [ $(cat /etc/group | grep 'iobroker:' | cut -d':' -f3) != $gid ] || [ $(cat /etc/passwd | grep 'iobroker:' | cut -d':' -f3) != $uid ]
then 
  echo "Different UID and/ or GID is set by ENV."
  echo "Changing UID to "$uid" and GID to "$gid"..."
  usermod -u $uid iobroker
  groupmod -g $gid iobroker
  echo "Done."
else
  echo "There are no changes in UID/ GID needed."
fi
echo ' '

# Change directory for next steps
cd /opt/iobroker


#####
# Detecting ioBroker-Installation
#####
echo "$(printf -- '-%.0s' {1..60})"
echo "-----   Step 2 of 5: Detecting ioBroker installation   -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '

if [ `ls -1a|wc -l` -lt 3 ]
then
  echo "There is no data detected in /opt/iobroker. Restoring initial ioBroker installation..."
  tar -xf /opt/initial_iobroker.tar -C /
  echo "Done."
else
  if [ -f /opt/iobroker/iobroker ]
  then
    echo "Existing installation of ioBroker detected in /opt/iobroker."
  else
    files=(/opt/iobroker/*)
    if [ ${#files[@]} -lt 2 ]; then
      if tar -ztvf /opt/iobroker/*.tar.gz "backup/backup.json" &> /dev/null; then
        echo "ioBroker Backup detected in /opt/iobroker. Restoring ioBroker..."
        mv /opt/iobroker/iobroker_20*.tar.gz /opt/
        tar -xf /opt/initial_iobroker.tar -C /
        mkdir /opt/iobroker/backups
        rm -r /opt/iobroker/backups/* &> /dev/null
        mv /opt/iobroker_20*.tar.gz /opt/iobroker/backups/
        iobroker restore 0
		echo "Done."
      else
        echo "There is data detected in /opt/iobroker, but it looks like it is no instance of iobroker or a valid backup file!"
        echo "Please check/ recreate mounted folder/ volume and restart ioBroker container."
        exit 1
     fi
    else
      echo "There is data detected in /opt/iobroker, but it looks like it is no instance of iobroker!"
      echo "Please check/ recreate mounted folder/ volume and restart ioBroker container."
      exit 1
    fi
  fi
fi
echo ' '


#####
# Checking ioBroker-Installation
#####
echo "$(printf -- '-%.0s' {1..60})"
echo "-----   Step 3 of 5: Checking ioBroker installation    -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '

# (Re)Setting permissions to "/opt/iobroker" and "/opt/scripts"  
echo "(Re)Setting folder permissions (This might take a while! Please be patient!)..."
  chown -R $uid:$gid /opt/iobroker
  chown -R $uid:$gid /opt/scripts
echo "Done."
echo ' '

# Backing up original iobroker-file and changing sudo to gosu
echo "Fixing \"sudo-bug\" by replacing sudo in iobroker with gosu..."
  cp -a /opt/iobroker/iobroker /opt/iobroker/iobroker.bak
  chmod 755 /opt/iobroker/iobroker
  sed -i 's/sudo -H -u/gosu/g' /opt/iobroker/iobroker
echo "Done."
echo ' '

# Checking for first run of a new installation and renaming ioBroker
if [ -f /opt/iobroker/.install_host ]
then
  echo "Looks like this is a new and empty installation of ioBroker."
  echo "Hostname needs to be updated to " $(hostname)"..."
    sh /opt/iobroker/iobroker host $(cat /opt/iobroker/.install_host)
    rm -f /opt/iobroker/.install_host
  echo 'Done.'
  echo ' '
elif [ $(iobroker object get system.adapter.admin.0 --pretty | grep -oP '(?<="host": ")[^"]*') != $(hostname) ]
then
  echo "Hostname in ioBroker does not match the hostname of this container."
  echo "Updating hostname to " $(hostname)"..."
    sh /opt/iobroker/iobroker host $(iobroker object get system.adapter.admin.0 --pretty | grep -oP '(?<="host": ")[^"]*')
  echo 'Done.'
  echo ' '
fi


#####
# Setting up prerequisites for some ioBroker-adapters
#####
echo "$(printf -- '-%.0s' {1..60})"
echo "-----      Step 4 of 5: Applying special settings      -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '

echo "Some adapters have special requirements/ settings which can be activated by the use of environment variables."
echo "For more information take a look at readme.md on Github!"
echo ' '

# Checking ENV for Adminport
if [ "$adminport" != $(iobroker object get system.adapter.admin.0 --pretty | grep -oP '(?<="port": )[^,]*') ]
then
  echo "Adminport set by ENV does not match port configured in ioBroker installation."
  echo "Setting Adminport to" $adminport"..."
    iobroker set admin.0 --port $adminport
  echo 'Done.'
  echo ' '
fi

# Checking ENV for AVAHI
if [ "$avahi" = "true" ]
then
  echo "Avahi-daemon is activated by ENV."
  chmod 764 /opt/scripts/setup_avahi.sh
  sh /opt/scripts/setup_avahi.sh
  echo "Done."
  echo ' '
fi

# Checking ENV for Z-WAVE
if [ "$zwave" = "true" ]
then
  echo "Z-Wave is activated by ENV."
  chmod 764 /opt/scripts/setup_zwave.sh
  sh /opt/scripts/setup_zwave.sh
  echo "Done."
  echo ' '
fi

# checking ENV for USBDEVICES
if [ "$usbdevices" != "none" ]
then
  echo "Usb-device-support is activated by ENV."
  
  IFS=';' read -ra devicearray <<< "$usbdevices"
    for i in "${devicearray[@]}"
    do
      echo "Setting permissions for" $i"..."
      chown root:dialout $i
      chmod g+rw $i
    done
  echo "Done."
  echo ' '
fi

# Checking ENV for REDIS
if [ "$redis" != "false" ]
then
  echo "Connection to Redis is configured by ENV."
  echo "Installing prerequisites..."
  apt-get update 2>&1> /dev/null && apt-get install -y jq 2>&1> /dev/null && rm -rf /var/lib/apt/lists/* 2>&1> /dev/null
  redisserver=$(echo $redis | sed -E  's/(.*):(.*)/\1/')
  redisport=$(echo $redis | sed -E  's/(.*):(.*)/\2/')
  echo "Setting configuration for Redis (Server: "$redisserver", Port: "$redisport") in ioBroker..."
  cd /opt/iobroker/iobroker-data
  jq --arg redisserver "$redisserver" --arg redisport "$redisport" '.states.type = "redis" | .states.host = $redisserver | .states.port = $redisport' iobroker.json > iobroker.json.tmp && mv iobroker.json.tmp iobroker.json
  cd /opt/iobroker
  echo "Done."
  echo ' '
fi

sleep 5


#####
# Starting ioBroker
#####
echo "$(printf -- '-%.0s' {1..60})"
echo "-----          Step 5 of 5: ioBroker startup           -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '
echo "Starting ioBroker..."
echo ' '

gosu iobroker node node_modules/iobroker.js-controller/controller.js

# Preventing container restart by keeping a process alive even if iobroker will be stopped
tail -f /dev/null
