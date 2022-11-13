#!/bin/bash

if [ $1 == "-install" ]
then
  apt-get -qq update
  packages=$(cat /opt/scripts/.docker_config/.packages)
  for i in $packages; do
    if [ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ];
      then
        echo "$i is not installed. Installing..."
        sudo apt-get -qq -y install $i
        echo "Done."
      else
        echo "$i is already installed."
      fi
  done
elif [ $1 == "-update" ]
then
  apt-get -qq update
  apt-get -qq -y upgrade
else
  echo "No paramerter found!"
  exit 1
fi

# Silent Cleanup
apt-get -qq autoclean -y && apt-get -qq autoremove && apt-get -qq clean
rm -rf /tmp/* /var/tmp/* && rm -rf /root/.cache/* && rm -rf /var/lib/apt/lists/* && rm -f /opt/scripts/.docker_config/.packages

exit 0
