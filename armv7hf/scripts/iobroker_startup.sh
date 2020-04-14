#!/bin/bash

# Reading ENV
adminport=$IOB_ADMINPORT
avahi=$AVAHI
objectsdbhost=$IOB_OBJECTSDB_HOST
objectsdbport=$IOB_OBJECTSDB_PORT
objectsdbtype=$IOB_OBJECTSDB_TYPE
packages=$PACKAGES
setgid=$SETGID
setuid=$SETUID
statesdbhost=$IOB_STATESDB_HOST
statesdbport=$IOB_STATESDB_PORT
statesdbtype=$IOB_STATESDB_TYPE
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
if [ "$adminport" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" ADMINPORT: $adminport)" && echo " -----"; fi
if [ "$avahi" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" AVAHI: $avahi)" && echo " -----"; fi
if [ "$objectsdbhost" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" IOB_OBJECTSDB_HOST: $objectsdbhost)" && echo " -----"; fi
if [ "$objectsdbport" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" IOB_OBJECTSDB_PORT: $objectsdbport)" && echo " -----"; fi
if [ "$objectsdbtype" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" IOB_OBJECTSDB_TYPE: $objectsdbtype)" && echo " -----"; fi
if [ "$packages" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" PACKAGES: $packages)" && echo " -----"; fi
if [ "$setgid" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" SETGID: $setgid)" && echo " -----"; fi
if [ "$setuid" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" SETUID: $setuid)" && echo " -----"; fi
if [ "$statesdbhost" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" IOB_STATESDB_HOST: $statesdbhost)" && echo " -----"; fi
if [ "$statesdbport" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" IOB_STATESDB_PORT: $statesdbport)" && echo " -----"; fi
if [ "$statesdbtype" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" IOB_STATESDB_TYPE: $statesdbtype)" && echo " -----"; fi
if [ "$usbdevices" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" USBDEVICES: $usbdevices)" && echo " -----"; fi
if [ "$zwave" != "" ]; then echo -n "-----               " && echo -n "$(printf "%-10s %-23s" ZWAVE: $zwave)" && echo " -----"; fi
echo "$(printf -- '-%.0s' {1..60})"
echo ' '


#####
# STEP 1 - Preparing container
#####
echo "$(printf -- '-%.0s' {1..60})"
echo "-----         Step 1 of 5: Preparing container         -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '

# Installing additional packages and setting uid/gid
if [ "$packages" != "" ] || [ $(cat /etc/group | grep 'iobroker:' | cut -d':' -f3) != $setgid ] || [ $(cat /etc/passwd | grep 'iobroker:' | cut -d':' -f3) != $setuid ]
then
  if [ "$packages" != "" ]
  then
    echo "Installing additional packages is set by ENV."
    echo "The following packages will be installed:" $packages"..."
    echo $packages > /opt/scripts/.packages
    bash /opt/scripts/setup_packages.sh
    echo "Done."
    echo ' '
  fi
  if [ $(cat /etc/group | grep 'iobroker:' | cut -d':' -f3) != $setgid ] || [ $(cat /etc/passwd | grep 'iobroker:' | cut -d':' -f3) != $setuid ]
  then
    echo "Different UID and/ or GID is set by ENV."
    echo "Changing UID to "$setuid" and GID to "$setgid"..."
    usermod -u $setuid iobroker
    groupmod -g $setgid iobroker
    echo "Done."
    echo ' '
  fi
else
  echo "Nothing to do here."
fi

# Change directory for next steps
cd /opt/iobroker


#####
# Detecting ioBroker-Installation
#####
echo "$(printf -- '-%.0s' {1..60})"
echo "-----   Step 2 of 5: Detecting ioBroker installation   -----"
echo "$(printf -- '-%.0s' {1..60})"
echo ' '

if [ `find /opt/iobroker -type f | wc -l` -lt 1 ]
then
  echo "There is no data detected in /opt/iobroker. Restoring initial ioBroker installation..."
  tar -xf /opt/initial_iobroker.tar -C /
  echo "Done."
elif [ -f /opt/iobroker/iobroker ]
then
  echo "Existing installation of ioBroker detected in /opt/iobroker."
elif [ $(ls iobroker_20* 2> /dev/null | wc -l) != "0" ] && [ $(tar -ztvf /opt/iobroker/iobroker_20*.tar.gz "backup/backup.json" 2> /dev/null | wc -l) != "0" ]
then
  echo "ioBroker backup file detected in /opt/iobroker. Restoring ioBroker..."
  mv /opt/iobroker/*.tar.gz /opt/
  tar -xf /opt/initial_iobroker.tar -C /
  mkdir /opt/iobroker/backups
  mv /opt/*.tar.gz /opt/iobroker/backups/
  iobroker restore 0 > /opt/iobroker/log/restore.log 2>&1
  echo "Done."
  echo ' '
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "!!!!!                             IMPORTANT NOTE                             !!!!!"
  echo "!!!!!        The sartup script restored iobroker from a backup file.         !!!!!"
  echo "!!!!! Check /opt/iobroker/log/restore.log to see if restore was successful.  !!!!!"
  echo "!!!!! When ioBroker now starts it will reinstall all Adapters automatically. !!!!!"
  echo "!!!!!         This might be take a looooong time! Please be patient!         !!!!!"
  echo "!!!!!  You can view installation process by taking a look at ioBroker log.   !!!!!"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
else
  echo "There is data detected in /opt/iobroker but it looks like it is no instance of iobroker or a valid backup file!"
  echo "Please check/ recreate mounted folder/ volume and restart ioBroker container."
  exit 1
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
  chown -R $setuid:$setgid /opt/iobroker
  chown -R $setuid:$setgid /opt/scripts
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
    bash iobroker host $(cat /opt/iobroker/.install_host)
    rm -f /opt/iobroker/.install_host
  echo 'Done.'
  echo ' '
elif [ $(bash iobroker object get system.adapter.admin.0 --pretty | grep -oP '(?<="host": ")[^"]*') != $(hostname) ]
then
  echo "Hostname in ioBroker does not match the hostname of this container."
  echo "Updating hostname to " $(hostname)"..."
    bash iobroker host $(iobroker object get system.adapter.admin.0 --pretty | grep -oP '(?<="host": ")[^"]*')
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
if [ "$adminport" != "" ]
then
  if [ "$adminport" != $(bash iobroker object get system.adapter.admin.0 --pretty | grep -oP '(?<="port": )[^,]*') ]
  then
    echo "Adminport set by ENV does not match port configured in ioBroker installation."
    echo "Setting Adminport to \""$adminport"\"..."
    bash iobroker set admin.0 --port $adminport
    echo 'Done.'
    echo ' '
  fi
fi


# Checking ENV for AVAHI
if [ "$avahi" != "" ]
then
  if [ "$avahi" = "true" ]
  then
    echo "Avahi-daemon is activated by ENV."
    chmod 755 /opt/scripts/setup_avahi.sh
    bash /opt/scripts/setup_avahi.sh
    echo "Done."
    echo ' '
  fi
fi


# Checking ENV for Z-WAVE
if [ "$zwave" != "" ]
then
  if [ "$zwave" = "true" ]
  then
    echo "Z-Wave is activated by ENV."
    chmod 755 /opt/scripts/setup_zwave.sh
    bash /opt/scripts/setup_zwave.sh
    echo "Done."
    echo ' '
  fi
fi


# checking ENV for USBDEVICES
if [ "$usbdevices" != "" ]
then
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
fi


# Checking ENVs for custom setup of objects db
if [ "$objectsdbtype" != "" ] || [ "$objectsdbhost" != "" ] || [ "$objectsdbport" != "" ]
then
  if [ "$objectsdbtype" != $(jq '.objects.type' /opt/iobroker/iobroker-data/iobroker.json) ]
  then
    echo "ENV IOB_OBJECTSDB_TYPE is set and value is different from detected ioBroker installation."
    echo "Setting type of objects db to \""$objectsdbtype"\"..."
    jq --arg objectsdbtype "$objectsdbtype" '.objects.type = $objectsdbtype' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp && mv /opt/iobroker/iobroker-data/iobroker.json.tmp /opt/iobroker/iobroker-data/iobroker.json
    echo "Done."
  else
    echo "ENV IOB_OBJECTSDB_TYPE is set and value meets detected ioBroker installation. Nothing to do here."
  fi
  if [ "$objectsdbhost" != $(jq '.objects.host' /opt/iobroker/iobroker-data/iobroker.json) ]
  then
    echo "ENV IOB_OBJECTSDB_HOST is set and value is different from detected ioBroker installation."
    echo "Setting host of objects db to \""$objectsdbhost"\"..."
    jq --arg objectsdbhost "$objectsdbhost" '.objects.host = $objectsdbhost' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp && mv /opt/iobroker/iobroker-data/iobroker.json.tmp /opt/iobroker/iobroker-data/iobroker.json
    echo "Done."
  else
    echo "ENV IOB_OBJECTSDB_HOST is set and value meets detected ioBroker installation. Nothing to do here."
  fi
  if [ "$objectsdbport" != $(jq '.objects.port' /opt/iobroker/iobroker-data/iobroker.json) ]
  then
    echo "ENV IOB_OBJECTSDB_PORT is set and value is different from detected ioBroker installation."
    echo "Setting port of objects db to \""$objectsdbport"\"..."
    jq --arg objectsdbport "$objectsdbport" '.objects.port = $objectsdbport' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp && mv /opt/iobroker/iobroker-data/iobroker.json.tmp /opt/iobroker/iobroker-data/iobroker.json
    echo "Done."
  else
    echo "ENV IOB_OBJECTSDB_PORT is set and value meets detected ioBroker installation. Nothing to do here."
  fi
  echo ' '
fi


# Checking ENVs for custom setup of states db#
if [ "$statesdbtype" != "" ] || [ "$statesdbhost" != "" ] || [ "$statesdbport" != "" ]
then
  if [ "$statesdbtype" != $(jq '.states.type' /opt/iobroker/iobroker-data/iobroker.json) ]
  then
    echo "ENV IOB_STATESDB_TYPE is set and value is different from detected ioBroker installation."
    echo "Setting type of states db to \""$statesdbtype"\"..."
    jq --arg statesdbtype "$statesdbtype" '.states.type = $statesdbtype' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp && mv /opt/iobroker/iobroker-data/iobroker.json.tmp /opt/iobroker/iobroker-data/iobroker.json
    echo "Done."
  else
    echo "ENV IOB_STATESDB_TYPE is set and value meets detected ioBroker installation. Nothing to do here."
  fi
  if [ "$statesdbhost" != $(jq '.states.host' /opt/iobroker/iobroker-data/iobroker.json) ]
  then
    echo "ENV IOB_STATESDB_HOST is set and value is different from detected ioBroker installation."
    echo "Setting host of states db to \""$statesdbhost"\"..."
    jq --arg statesdbhost "$statesdbhost" '.states.host = $statesdbhost' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp && mv /opt/iobroker/iobroker-data/iobroker.json.tmp /opt/iobroker/iobroker-data/iobroker.json
    echo "Done."
  else
    echo "ENV IOB_STATESDB_HOST is set and value meets detected ioBroker installation. Nothing to do here."
  fi
  if [ "$statesdbport" != $(jq '.states.port' /opt/iobroker/iobroker-data/iobroker.json) ]
  then
    echo "ENV IOB_STATESDB_PORT is set and value is different from detected ioBroker installation."
    echo "Setting port of states db to \""$statesdbport"\"..."
    jq --arg statesdbport "$statesdbport" '.states.port = $statesdbport' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp && mv /opt/iobroker/iobroker-data/iobroker.json.tmp /opt/iobroker/iobroker-data/iobroker.json
    echo "Done."
  else
    echo "ENV IOB_STATESDB_PORT is set and value meets detected ioBroker installation. Nothing to do here."
  fi
  echo ' '
fi


# Checking for Userscripts in /opt/userscripts
if [ `find /opt/userscripts -type f | wc -l` -lt 1 ]
then
  echo "There is no data detected in /opt/userscripts. Restoring exapmple userscripts..."
  tar -xf /opt/initial_userscripts.tar -C /
  chmod 755 /opt/userscripts/userscript_firststart_example.sh
  chmod 755 /opt/userscripts/userscript_everystart_example.sh
  echo "Done."
  echo ' '
elif [ -f /opt/userscripts/userscript_firststart.sh ] || [ -f /opt/userscripts/userscript_everystart.sh ]
then
  if [ -f /opt/userscripts/userscript_firststart.sh ] && [ -f /opt/.firstrun ]
  then
    echo "Userscript for first start detected and this is the first start of a new container."
    echo "Running userscript_firststart.sh..."
    chmod 755 /opt/userscripts/userscript_firststart.sh
    bash /opt/userscripts/userscript_firststart.sh
    rm -f /opt/.firstrun
    echo "Done."
    echo ' '
  fi
  if [ -f /opt/userscripts/userscript_everystart.sh ]
  then
    echo "Userscript for every start detected. Running userscript_everystart.sh..."
    chmod 755 /opt/userscripts/userscript_everystart.sh
    bash /opt/userscripts/userscript_everystart.sh
    echo "Done."
    echo ' '
  fi
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
