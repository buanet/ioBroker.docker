#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

if [ "$1" == "-install" ]
then
  apt-get -q update >> /opt/scripts/setup_packages.log 2>&1
  packages=$(cat /opt/scripts/.docker_config/.packages)
  echo ' '
  for i in $packages; do
    if [ "$(dpkg-query -W -f='${Status}' "$i" 2>/dev/null | grep -c "ok installed")" -eq 0 ];
      then
        echo -n "$i is not installed. Installing... "
        DEBIAN_FRONTEND=noninteractive apt-get -q -y install "$i" >> /opt/scripts/setup_packages.log 2>&1
        return=$?
        if [[ "$return" -ne 0 ]]; then
          echo "Failed."
          echo "For more details see \"/opt/scripts/setup_packages.log\"."
          echo ' '
        else
        echo "Done."
        fi
      else
        echo "$i is already installed."
      fi
  done
elif [ "$1" == "-update" ]; then
  echo -n "Updating Linux packages on first run... "
  apt-get -q update >> /opt/scripts/setup_packages.log 2>&1
  return=$?
  apt-get -q -y upgrade >> /opt/scripts/setup_packages.log 2>&1
  return1=$?
  if [[ "$return" -ne 0 || "$return1" -ne 0 ]]; then
    echo "Failed."
    echo "For more details see \"/opt/scripts/setup_packages.log\"."
    echo "Make sure the container has internet access to get the latest package updates."
    echo "This has no impact to the setup process. The script will continue."
  else
    echo 'Done.'
  fi
else
  echo "No paramerter found!"
  exit 1
fi

# Silent Cleanup
apt-get -qq autoclean -y && apt-get -qq autoremove && apt-get -qq clean
rm -rf /tmp/* /var/tmp/* && rm -rf /root/.cache/* && rm -rf /var/lib/apt/lists/* && rm -f /opt/scripts/.docker_config/.packages

exit 0
