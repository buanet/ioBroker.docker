#!/bin/bash

if [ $1 == "-install" ]
then
  apt -qq update
  packages=$(cat /opt/scripts/.docker_config/.packages)
  for i in $packages; do
    if [ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ];
      then
        echo "$i is not installed. Installing..."
        sudo apt -qq -y install $i
        echo "Done."
      else
        echo "$i is already installed."
      fi
  done
elif [ $1 == "-update" ]
then
  apt -qq update
  apt -qq -y upgrade
else
  echo "No paramerter found!"
  exit 1
fi

# Silent Cleanup
apt -qq autoclean -y && apt -qq autoremove && apt -qq clean
rm -rf /tmp/* /var/tmp/* && rm -rf /root/.cache/* && rm -rf /var/lib/apt/lists/* && rm -f /opt/scripts/.docker_config/.packages

exit 0
