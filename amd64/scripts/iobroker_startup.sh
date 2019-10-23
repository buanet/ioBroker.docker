#!/bin/bash

# Reading ENV
packages=$PACKAGES
avahi=$AVAHI
uid=$SETUID
gid=$SETGID
zwave=$ZWAVE

# Getting date and time for logging 
dati=`date '+%Y-%m-%d %H:%M:%S'`

# Header
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
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" AVAHI: $AVAHI)" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" PACKAGES: $PACKAGES)" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" SETGID: $SETGID)" && echo " -----"
echo -n "-----               " && echo -n "$(printf "%-10s %-23s" SETUID: $SETUID)" && echo " -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '

# Checking and installing additional packages
echo "$(printf -- '-%.0s' {1..60})"
echo "-----   Step 1 of 5: Installing additional packages    -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '

if [ "$packages" != "" ]
then
  echo "The following packages will be installed:" $packages"..."
  echo $packages > /opt/scripts/.packages
  sh /opt/scripts/setup_packages.sh > /opt/scripts/setup_packages.log 2>&1
  echo "Done."
else
  echo "There are no additional packages defined."
fi
echo ' '

# Change directory for next steps
cd /opt/iobroker

# Detecting ioBroker-Installation
echo "$(printf -- '-%.0s' {1..60})"
echo "-----   Step 2 of 5: Detecting ioBroker installation   -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '

if [ `ls -1a|wc -l` -lt 3 ]
then
  echo "There is no data detected in /opt/iobroker. Restoring..."
  tar -xf /opt/initial_iobroker.tar -C /
  echo "Done."
else
  if [ -f /opt/iobroker/iobroker ]
  then
    echo "Installation of ioBroker detected in /opt/iobroker."
  else
    echo "There is data detected in /opt/iobroker, but it looks like it is no instance of iobroker!"
	echo "Please check/ recreate mounted folder/ volume and restart ioBroker container."
	exit 1
  fi
fi
echo ' '

# Checking ioBroker-Installation
echo "$(printf -- '-%.0s' {1..60})"
echo "-----   Step 3 of 5: Checking ioBroker installation    -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '

# Checking for first run and set uid/gid
if [ -f /opt/.firstrun ]
then 
  echo "This is the first run of a new container. Time for some preparation."
  echo ' '
  echo "Changing UID to "$uid" and GID to "$gid"..."
  usermod -u $uid iobroker
  groupmod -g $gid iobroker
  rm -f /opt/.firstrun
  echo "Done."
else
  echo "This is NOT the first run of the container. Some Steps will be skipped."
fi
echo ' '

# (Re)Setting permissions to "/opt/iobroker" and "/opt/scripts"  
echo "(Re)Setting folder permissions (This might take a while! Please be patient!)..."
  chown -R $uid:$gid /opt/iobroker
  chown -R $uid:$gid /opt/scripts
echo "Done."
echo ' '

# Backing up original iobroker-file and changing sudo to gosu
echo "Fixing \"sudo-bug\" by replacing sudo with gosu..."
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
fi

# Setting up prerequisites for some ioBroker-adapters
echo "$(printf -- '-%.0s' {1..60})"
echo "-----      Step 4 of 5: Applying special settings      -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '

echo "Some adapters have special requirements which can be activated by the use of environment variables."
echo "For more information take a look at readme.md"
echo ' '

# Checking for and setting up avahi-daemon
if [ "$avahi" = "true" ]
then
  echo "Avahi-daemon is activated by ENV."
  chmod 764 /opt/scripts/setup_avahi.sh
  sh /opt/scripts/setup_avahi.sh
  echo "Done."
  echo ' '
fi

if [ "$zwave" = "true" ]
then
  echo "ZWave is activated by ENV."
  chmod 764 /opt/scripts/setup_zwave.sh
  sh /opt/scripts/setup_zwave.sh
  echo "Done."
  echo ' '
fi

sleep 5

# Starting ioBroker
echo "$(printf -- '-%.0s' {1..60})"
echo "-----          Step 5 of 5: ioBroker startup           -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '
echo "Starting ioBroker..."
echo ' '
#gosu iobroker node --trace-warnings node_modules/iobroker.js-controller/controller.js > /opt/iobroker/iobroker.log 2>&1 &
gosu iobroker node node_modules/iobroker.js-controller/controller.js

# Preventing container restart by keeping a process alive even if iobroker will be stopped
tail -f /dev/null
