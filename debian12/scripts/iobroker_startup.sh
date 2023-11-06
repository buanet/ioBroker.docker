#!/usr/bin/env bash

# bash strict mode
set -euo pipefail

# Setting healthcheck status to "starting"
echo "starting" > /opt/.docker_config/.healthcheck

# Reading ENV
set +u
adminport=$IOB_ADMINPORT
avahi=$AVAHI
backitup=$IOB_BACKITUP_EXTDB
debug=$DEBUG
multihost=$IOB_MULTIHOST
offlinemode=$OFFLINE_MODE
objectsdbhost=$IOB_OBJECTSDB_HOST
objectsdbport=$IOB_OBJECTSDB_PORT
objectsdbtype=$IOB_OBJECTSDB_TYPE
objectsdbname=$IOB_OBJECTSDB_NAME
objectsdbpass=$IOB_OBJECTSDB_PASS
packages=$PACKAGES
packagesupdate=$PACKAGES_UPDATE
permissioncheck=$PERMISSION_CHECK
setgid=$SETGID
setuid=$SETUID
statesdbhost=$IOB_STATESDB_HOST
statesdbport=$IOB_STATESDB_PORT
statesdbtype=$IOB_STATESDB_TYPE
statesdbname=$IOB_STATESDB_NAME
statesdbpass=$IOB_STATESDB_PASS
usbdevices=$USBDEVICES
set -u

pkill_timeout=10      # timeout for iobroker shutdown in seconds

# Stop on error function
stop_on_error() {
  if [[ "$debug" == "true" ]]; then 
    echo " "
    echo "[DEBUG] Debug mode prevents the container from exiting on errors."
    echo "[DEBUG] This enables you to investigate or fix your issue on the command line."
    echo "[DEBUG] If you want to stop or restart your container you have to do it manually."
    echo "[DEBUG] IoBroker is not running!"
      tail -f /dev/null
  else
    echo " "
    echo "This Script will exit now."
      exit 1
  fi
}

# Getting date and time for logging
dati=$(date '+%Y-%m-%d %H:%M:%S')

# Logging header
echo " "
echo "$(printf -- '-%.0s' {1..80})"
echo -n "$(printf -- '-%.0s' {1..25})" && echo -n "     ""$dati""      " && echo "$(printf -- '-%.0s' {1..25})"
echo "$(printf -- '-%.0s' {1..80})"
echo "-----                                                                      -----"
echo "----- ██╗  ██████╗  ██████╗  ██████╗   ██████╗  ██╗  ██╗ ███████╗ ██████╗  -----"
echo "----- ██║ ██╔═══██╗ ██╔══██╗ ██╔══██╗ ██╔═══██╗ ██║ ██╔╝ ██╔════╝ ██╔══██╗ -----"
echo "----- ██║ ██║   ██║ ██████╔╝ ██████╔╝ ██║   ██║ █████╔╝  █████╗   ██████╔╝ -----"
echo "----- ██║ ██║   ██║ ██╔══██╗ ██╔══██╗ ██║   ██║ ██╔═██╗  ██╔══╝   ██╔══██╗ -----"
echo "----- ██║ ╚██████╔╝ ██████╔╝ ██║  ██║ ╚██████╔╝ ██║  ██╗ ███████╗ ██║  ██║ -----"
echo "----- ╚═╝  ╚═════╝  ╚═════╝  ╚═╝  ╚═╝  ╚═════╝  ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝ -----"
echo "-----                                                                      -----"
echo "-----              Welcome to your ioBroker Docker container!              -----"
echo "-----                    Startupscript is now running!                     -----"
echo "-----                          Please be patient!                          -----"
echo "$(printf -- '-%.0s' {1..80})"
echo " "
echo "$(printf -- '-%.0s' {1..80})"
echo "-----                          System Information                          -----"
echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" arch: "$(uname -m)")" && echo " -----"
echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" hostname: "$(hostname)")" && echo " -----"
echo "-----                                                                      -----"
echo "-----                          Version Information                         -----"
echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" image: "${VERSION}")" && echo " -----"
echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" build: "${BUILD}")" && echo " -----"
echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" node: "$(node -v)")" && echo " -----"
echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" npm: "$(npm -v)")" && echo " -----"
echo "-----                                                                      -----"
echo "-----                        Environment Variables                         -----"
if [[ "$adminport" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_ADMINPORT: "$adminport")" && echo " -----"; fi
if [[ "$avahi" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" AVAHI: "$avahi")" && echo " -----"; fi
if [[ "$debug" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" DEBUG: "$debug")" && echo " -----"; fi
if [[ "$backitup" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_BACKITUP_EXTDB: "$backitup")" && echo " -----"; fi
if [[ "$multihost" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_MULTIHOST: "$multihost")" && echo " -----"; fi
if [[ "$objectsdbtype" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_OBJECTSDB_TYPE: "$objectsdbtype")" && echo " -----"; fi
if [[ "$objectsdbhost" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_OBJECTSDB_HOST: "$objectsdbhost")" && echo " -----"; fi
if [[ "$objectsdbport" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_OBJECTSDB_PORT: "$objectsdbport")" && echo " -----"; fi
if [[ "$objectsdbname" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_OBJECTSDB_NAME: "$objectsdbname")" && echo " -----"; fi
if [[ "$objectsdbpass" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_OBJECTSDB_PASS: "***")" && echo " -----"; fi
if [[ "$statesdbtype" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_STATESDB_TYPE: "$statesdbtype")" && echo " -----"; fi
if [[ "$statesdbhost" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_STATESDB_HOST: "$statesdbhost")" && echo " -----"; fi
if [[ "$statesdbport" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_STATESDB_PORT: "$statesdbport")" && echo " -----"; fi
if [[ "$statesdbname" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_STATESDB_NAME: "$statesdbname")" && echo " -----"; fi
if [[ "$statesdbpass" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" IOB_STATESDB_PASS: "***")" && echo " -----"; fi
if [[ "$offlinemode" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" OFFLINE_MODE: "$offlinemode")" && echo " -----"; fi
if [[ "$packages" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" PACKAGES: "$packages")" && echo " -----"; fi
if [[ "$permissioncheck" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" PERMISSION_CHECK: "$permissioncheck")" && echo " -----"; fi
if [[ "$setgid" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" SETGID: "$setgid")" && echo " -----"; fi
if [[ "$setuid" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" SETUID: "$setuid")" && echo " -----"; fi
if [[ "$usbdevices" != "" ]]; then echo -n "-----                    " && echo -n "$(printf "%-20s %-28s" USBDEVICES: "$usbdevices")" && echo " -----"; fi
echo "$(printf -- '-%.0s' {1..80})"
echo " "

# Debug logging notice
if [[ "$debug" == "true" ]]; then
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "!!!!                            DEBUG LOG ACTIVE                            !!!!"
  echo "!!!!               Environment variable DEBUG is set to true.               !!!!"
  echo "!!!! This will extend the logging output and may slow down container start. !!!!"
  echo "!!!!          Please make sure to deactivate if no longer needed.           !!!!"
  echo "!!!!     For more information see ioBroker Docker image documentation:      !!!!"
  echo "!!!!           https://docs.buanet.de/iobroker-docker-image/docs/           !!!!"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo " "
fi

#####
# STEP 1 - Preparing container
#####
echo "$(printf -- '-%.0s' {1..80})"
echo "-----                   Step 1 of 5: Preparing container                   -----"
echo "$(printf -- '-%.0s' {1..80})"
echo " "

# Actions running on first start only
if [[ -f /opt/.docker_config/.first_run ]]; then
  # Updating Linux packages
  if [[ "$offlinemode" = "true" ]]; then
    echo "OFFLINE_MODE is \"true\". Skipping Linux package updates on first run."
    echo " "
  elif [[ "$packagesupdate" = "true" ]]; then
    if ! bash /opt/scripts/setup_packages.sh -update; then echo "Failed."; fi
    echo " "
  fi

  # Installing packages from ENV
  if [[ "$packages" != "" && "$offlinemode" = "true" ]]; then
    echo "PACKAGES is set, but OFFLINE_MODE is \"true\". Skipping Linux package installation."
  elif [[ "$packages" != "" ]]; then
    echo "PACKAGES is set. Installing the following additional Linux packages: ""$packages"
    if ! bash /opt/scripts/setup_packages.sh -install; then echo "Failed."; fi
  fi
  echo " "
else
  echo "This is not the first run of this container. Skipping first run preparation."
fi
echo " "

# Setting UID and/ or GID
if [[ "$setgid" != "$(id -u iobroker)" || "$setuid" != "$(id -u iobroker)" ]]; then
  echo "SETUID and/ or SETGID are set to custom values."
  echo -n "Changing UID to \"""$setuid""\" and GID to \"""$setgid""\"... "
    usermod -u "$setuid" iobroker
    groupmod -og "$setgid" iobroker
  echo "Done."
  echo " "
fi

# Change directory for next steps
cd /opt/iobroker

#####
# STEP 2 - Detecting ioBroker-Installation
#####
echo "$(printf -- '-%.0s' {1..80})"
echo "-----             Step 2 of 5: Detecting ioBroker installation             -----"
echo "$(printf -- '-%.0s' {1..80})"
echo " "

if [[ `find /opt/iobroker -type f | wc -l` -lt 1 ]]; then
  echo "There is no data detected in /opt/iobroker."
  echo -n "Restoring initial ioBroker installation... "
    tar -xf /opt/initial_iobroker.tar -C /
  echo "Done."
elif [[ -f /opt/iobroker/iobroker ]]; then
  echo "Existing installation of ioBroker detected in \"/opt/iobroker\"."
elif [[ "$(ls *_backupiobroker.tar.gz 2> /dev/null | wc -l)" != "0" && "$(tar -ztvf /opt/iobroker/*_backupiobroker.tar.gz "backup/backup.json" 2> /dev/null | wc -l)" != "0" ]]; then
  echo "IoBroker backup file detected in /opt/iobroker."
  if [[ "$debug" == "true" ]]; then echo "[DEBUG] Backup file name: " "$(ls *_backupiobroker.tar.gz)"; fi
  echo "Since Docker Image v8, automatic initial restore is no longer supported!"
  echo "IoBroker will start with a fresh installation, while your backup file will be copied into the backup directory."
  echo "You will be able to restore your backup file manually by using the backitup adapter or the containers maintenance script."
  echo "For more information see ioBroker Docker Image Docs (https://docs.buanet.de/iobroker-docker-image/docs/)."
  echo " "
  echo -n "Copying backup file and restoring initial ioBroker installation... "
    mv /opt/iobroker/*.tar.gz /opt/
    tar -xf /opt/initial_iobroker.tar -C /
    mkdir /opt/iobroker/backups
    mv /opt/*.tar.gz /opt/iobroker/backups/
    # fixing permission errors during restore
    chown -R "$setuid":"$setgid" /opt/iobroker
  echo "Done."
else
  echo "There is data detected in /opt/iobroker but it looks like it is no instance of ioBroker!"
  if [[ "$debug" == "true" ]]; then
    echo "[DEBUG] Detected files:"
    ls -al
  fi
  echo "Please check/ recreate mounted folder or volume and try again."
  stop_on_error
fi
echo " "

#####
# STEP 3 - Checking ioBroker-Installation
#####
echo "$(printf -- '-%.0s' {1..80})"
echo "-----             Step 3 of 5: Checking ioBroker installation              -----"
echo "$(printf -- '-%.0s' {1..80})"
echo " "

# Backing up original iobroker executable to fix sudo bug with gosu
if [[ -n $(cmp /opt/scripts/iobroker.sh /opt/iobroker/iobroker) ]]; then
  echo -n "Replacing ioBroker executable to fix sudo bug... "
  cp -a /opt/iobroker/iobroker /opt/iobroker/iobroker.bak
  cp -f /opt/scripts/iobroker.sh /opt/iobroker/iobroker
  chmod 755 /opt/iobroker/iobroker
  echo "Done."
  echo " "
fi

# (Re)Setting permissions to "/opt/iobroker" and "/opt/scripts"
if [[ "$permissioncheck" == "false" ]]; then
  echo "PERMISSION_CHECK is set to false. Use this at your own risk!"
else
  echo -n "(Re)setting permissions (This might take a while! Please be patient!)... "
    chown -R "$setuid":"$setgid" /opt/iobroker
    chown -R "$setuid":"$setgid" /opt/scripts
    chown -R "$setuid":"$setgid" /opt/.docker_config
  echo "Done."
fi
echo " "

# Checking multihost and db setup
if [[ "$multihost" == "master" || "$multihost" == "slave" ]]; then
  # multihost enabled
  if [[ "$multihost" == "master" ]]; then
    set +e
    bash /opt/scripts/setup_iob_db.sh -master
    return=$?
    set -e
    if [[ "$return" -ne 0 ]]; then stop_on_error; fi
  elif [[ "$multihost" == "slave" ]]; then
    set +e
    bash /opt/scripts/setup_iob_db.sh -slave
    return=$?
    set -e
    if [[ "$return" -ne 0 ]]; then stop_on_error; fi
  fi
elif [[ "$multihost" == "" || "$multihost" == "false" ]]; then
  # no multihost, only debug output
  if [[ "$debug" == "true" ]]; then
    echo "[DEBUG] Checking multihost settings... "
    echo "[DEBUG] No multihost settings detected."
    echo "[DEBUG] Done."
    echo " "
  fi
  # checking custom objects db settings
  if [[ "$objectsdbtype" != "" || "$objectsdbhost" != "" || "$objectsdbport" != "" ]]; then
    set +e
    bash /opt/scripts/setup_iob_db.sh -objectsdb
    return=$?
    set -e
    if [[ "$return" -ne 0 ]]; then stop_on_error; fi
  else
    #no custom objects db settings, only debug output
    if [[ "$debug" == "true" ]]; then
      echo "[DEBUG] Checking custom objects db settings... "
      echo "[DEBUG] No custom objects db settings detected."
      echo "[DEBUG] Done."
      echo " "
    fi 
  fi
  # checking custom states db settings
  if [[ "$statesdbtype" != "" || "$statesdbhost" != "" || "$statesdbport" != "" ]]; then
    set +e
    bash /opt/scripts/setup_iob_db.sh -statesdb
    return=$?
    set -e
    if [[ "$return" -ne 0 ]]; then stop_on_error; fi
  else
    #no custom states db settings, only debug output
    if [[ "$debug" == "true" ]]; then
      echo "[DEBUG] Checking custom states db settings... "
      echo "[DEBUG] No custom states db settings detected."
      echo "[DEBUG] Done."
      echo " "
    fi 
  fi
else
  echo "IOB_MULTIHOST is set, but the value is not valid. Please check your configuration."
  if [[ "$debug" == "true" ]]; then echo "[DEBUG] IOB_MULTIHOST = ""$multihost"; fi
  echo "For more information see ioBroker Docker Image Docs (https://docs.buanet.de/iobroker-docker-image/docs/#environment-variables-env)."
  stop_on_error
fi

# if restored a fresh install, running "iob setup first" for database init (but not on slaves!), otherwise check database connection
if [[ -f /opt/iobroker/.fresh_install && "$multihost" != "slave" ]]; then
  echo -n "Initializing a fresh installation of ioBroker... "
  if [[ ! -d "/opt/iobroker/log" ]]; then gosu iobroker mkdir "/opt/iobroker/log"; fi
  set +e
  gosu iobroker iob setup first > /opt/iobroker/log/iob_setup_first.log 2>&1
  return=$?
  set -e
  rm -f /opt/iobroker/.fresh_install
  if [[ "$return" -ne 0 ]]; then
    echo "Failed."
    echo "For more details see \"/opt/iobroker/log/iob_setup_first.log\"."
    echo "Please check your configuration and try again."
    stop_on_error
  fi
  echo "Done."
  echo " "
else
  echo -n "Checking Database connection... "
  set +e
  if gosu iobroker iob uuid &> /dev/null; then
    echo "Done."
    echo " "
  else
    errormsg=$(gosu iobroker iob uuid 2>&1 | sed 's/^/[DEBUG] /')
    echo "Failed."
    if [[ "$debug" == "true" ]]; then
      echo "[DEBUG] Error message: "
      echo "$errormsg"
    fi
    echo "Please check your configuration and try again."
    echo "For more information see ioBroker Docker Image Docs (https://docs.buanet.de/iobroker-docker-image/docs)."
    stop_on_error
  fi
  set -e
fi

# hostname check
if [[ "$multihost" == "slave" ]]; then
  echo "IOB_MULTIHOST is set to \"slave\". Hostname check will be skipped."
  echo " "
else
  # get admin instance and hostname
  set +e
  admininstance=$(gosu iobroker iob list instances | grep 'enabled' | grep -m 1 -o 'system.adapter.admin..')
  set -e
  if [[ "$admininstance" != "" ]]; then
    if [[ "$debug" == "true" ]]; then echo "[DEBUG] Detected admin instance is:" "$admininstance"; fi 
    adminhostname=$(gosu iobroker iob object get "$admininstance" --pretty | grep -oP '(?<="host": ")[^"]*')
    if [[ "$debug" == "true" ]]; then echo "[DEBUG] Detected admin hostname is:" "$adminhostname"; fi
  else
    set +e
    admininstance=$(gosu iobroker iob list instances | grep 'disabled' | grep -m 1 -o 'system.adapter.admin..')
    set -e
    if [[ "$admininstance" != "" ]]; then
      if [[ "$debug" == "true" ]]; then echo "[DEBUG] Detected admin instance is disabled."; fi 
      if [[ "$debug" == "true" ]]; then echo "[DEBUG] Detected admin instance is:" "$admininstance"; fi 
      adminhostname=$(gosu iobroker iob object get "$admininstance" --pretty | grep -oP '(?<="host": ")[^"]*')
      if [[ "$debug" == "true" ]]; then echo "[DEBUG] Detected admin hostname is:" "$adminhostname"; fi
    else
      echo "There was a problem detecting the admin instance of your iobroker."
      echo "Make sure the ioBroker installation you use has an admin instance or try again with a fresh installation and restore your configuration."
      echo "For more details see https://docs.buanet.de/iobroker-docker-image/docs/#restore"
      stop_on_error
    fi
  fi
  # check hostname
  if [[ "$adminhostname" != "" && "$adminhostname" != "$(hostname)" ]]; then
    echo "Hostname in ioBroker does not match the hostname of this container."
    echo -n "Updating hostname to \"""$(hostname)""\"... "
      gosu iobroker iob host "$adminhostname"
    echo "Done."
    echo " "
  elif [[ "$adminhostname" = "$(hostname)" ]]; then
    echo "Hostname in ioBroker matches the hostname of this container."
    echo "No action required."
    echo " "
  else
    echo "There was a problem checking the hostname."
    stop_on_error
  fi
fi

# extended debug output
if [[ "$debug" == "true" && "$multihost" != "slave" ]]; then
  echo "[DEBUG] Collecting some more ioBroker debug information... "
  echo " "
  # get information and send to array
  IFS=$'\n'
  instances_array=("$(gosu iobroker iob list instances)")
  repos_array=("$(gosu iobroker iob repo list)")
  updates_array=("$(gosu iobroker iob update)")
  # list iob instances
  echo "[DEBUG] ##### iobroker list instances #####"
    for i in "${instances_array[@]}"
    do
      echo "$i"
    done
  echo " "
  echo "[DEBUG] ##### iobroker repo list #####"
    for i in "${repos_array[@]}"
    do
      echo "$i"
    done
  echo " "
  echo "[DEBUG] ##### iobroker update #####"
    for i in "${updates_array[@]}"
    do
      echo "$i"
    done
  echo " "
  unset IFS
fi

#####
# STEP 4 - Setting up special sessting for ioBroker-adapters
#####
echo "$(printf -- '-%.0s' {1..80})"
echo "-----                Step 4 of 5: Applying special settings                -----"
echo "$(printf -- '-%.0s' {1..80})"
echo " "

echo "Some adapters have special requirements/ settings which can be activated by the use of environment variables."
echo "For more information see ioBroker Docker Image Docs (https://docs.buanet.de/iobroker-docker-image/docs/)."
echo " "

# Checking ENV for Adminport
if [[ "$adminport" != "" && "$multihost" != "slave" ]]; then
  adminportold=$(gosu iobroker iob object get "$admininstance" --pretty | grep -oP '(?<="port": )[^,]*')
  admininstanceshort=$(echo "$admininstance" | grep -m 1 -o 'admin..')
  if [[ "$adminport" != "$adminportold" ]]; then
    echo "IOB_ADMINPORT is set and does not match port configured in ioBroker."
    if [[ "$debug" == "true" ]]; then echo "[DEBUG] Detected Admin Port in ioBroker: " "$adminportold"; fi
    echo "Setting Adminport to \"""$adminport""\"... "
      gosu iobroker iob set "$admininstanceshort" --port "$adminport"
    echo "Done."
    echo " "
  fi
fi

# Checking ENV for Backitup (external database backups)
if [[ "$backitup" == "true" ]]; then
  echo -n "IOB_BACKITUP_EXTDB is \"true\". Unlocking features..."
  echo "true" > /opt/.docker_config/.backitup
  echo "true" > /opt/scripts/.docker_config/.backitup # old path, needed until changed in backitup
  echo "Done."
  echo " "
fi

# Checking ENV for AVAHI
if [[ "$avahi" = "true" && "$offlinemode" = "true" ]]; then
  echo "AVAHI is \"true\", but OFFLINE_MODE is also \"true\". Skipping Avahi daemon setup."
elif [[ "$avahi" = "true" ]]; then
  echo "AVAHI is \"true\". Running setup script... "
    chmod 755 /opt/scripts/setup_avahi.sh
    bash /opt/scripts/setup_avahi.sh
  echo "Done."
  echo " "
fi

# checking ENV for USBDEVICES
if [[ "$usbdevices" != "" && "$usbdevices" != "none" ]]; then
  echo "USBDEVICES is set."
  IFS=';' read -ra devicearray <<< "$usbdevices"
    for i in "${devicearray[@]}"
    do
      if [[ -e "$i" ]]; then
        echo -n "Setting permissions for \"""$i""\"... "
        chown root:dialout "$i"
        chmod g+rw "$i"
        echo "Done."
        if [[ "$debug" == "true" ]]; then echo "[DEBUG] Permissions set: " "$(ls -al "$i")"; fi
      else
        echo "Looks like the device \"""$i""\" does not exist."
        echo "Did you mount it correctly by using the \"--device\" option?"
        echo "For more information see ioBroker Docker Image Docs (https://docs.buanet.de/iobroker-docker-image/docs/#mounting-usb-devices)."
        stop_on_error
      fi
    done
  echo " "
fi

# Checking for Userscripts in /opt/userscripts
if [[ $(find /opt/userscripts -type f | wc -l) -lt 1 ]]; then
  echo -n "There is no data detected in /opt/userscripts. Restoring exapmple userscripts... "
    tar -xf /opt/initial_userscripts.tar -C /
    chmod 755 /opt/userscripts/userscript_firststart_example.sh
    chmod 755 /opt/userscripts/userscript_everystart_example.sh
  echo "Done."
elif [[ -f /opt/userscripts/userscript_firststart.sh || -f /opt/userscripts/userscript_everystart.sh ]]; then
  if [[ -f /opt/userscripts/userscript_firststart.sh && -f /opt/.docker_config/.first_run ]]; then
    echo "Userscript for first start detected and this is the first start of a new container."
    echo "Running userscript_firststart.sh... "
      chmod 755 /opt/userscripts/userscript_firststart.sh
      if ! bash /opt/userscripts/userscript_firststart.sh; then
        echo "Failed."
      else
        echo "Done."
      fi
  fi
  if [[ -f /opt/userscripts/userscript_everystart.sh ]]; then
    echo "Userscript for every start detected. Running userscript_everystart.sh... "
      chmod 755 /opt/userscripts/userscript_everystart.sh
      if ! bash /opt/userscripts/userscript_everystart.sh; then
        echo "Failed."
      else
        echo "Done."
      fi
  fi
  echo " "
fi


# Removing first run an fresh install markers when exists
if [[ -f /opt/.docker_config/.first_run ]]; then rm -f /opt/.docker_config/.first_run; fi
if [[ -f /opt/iobroker/.fresh_install ]]; then rm -f /opt/iobroker/.fresh_install; fi

#####
# STEP 5 - Starting ioBroker
#####
echo "$(printf -- '-%.0s' {1..80})"
echo "-----                    Step 5 of 5: ioBroker startup                     -----"
echo "$(printf -- '-%.0s' {1..80})"
echo " "
echo "Starting ioBroker... "
echo " "
echo "##### #### ### ## # iobroker.js-controller log output # ## ### #### #####"

# Setting healthcheck status to "running"
echo "running" > /opt/.docker_config/.healthcheck

# Function for graceful shutdown by SIGTERM signal
shut_down() {
  echo " "
  echo "Recived termination signal (SIGTERM)."
  echo "Shutting down ioBroker... "

  local status timeout

  timeout="$(date --date="now + ""$pkill_timeout"" sec" +%s)"
  pkill -u iobroker -f iobroker.js-controller
  status=$?
  if (( status >= 2 )); then      # syntax error or fatal error
    return 1
  fi

  if (( status == 1 )); then      # no processes matched
    return
  fi

  # pgrep exits with status 1 when there are no matches
  while pgrep -u iobroker > /dev/null; (( $? != 1 )); do
    if (($(date +%s) > timeout)); then
      echo -e "\nTimeout reached. Killing remaining processes... "
      pkill --signal SIGKILL -u iobroker
      echo "Done. Have a nice day!"
      exit
    fi

    echo -n "."
    sleep 1
  done

  echo -e '\nDone. Have a nice day!'
  exit
}

# Trap to get signal for graceful shutdown
trap 'shut_down' SIGTERM

# IoBroker start
gosu iobroker node node_modules/iobroker.js-controller/controller.js & wait

# Fallback process for keeping container running when ioBroker is stopped for maintenance (e.g. js-controller update)
gosu iobroker tail -f /dev/null
