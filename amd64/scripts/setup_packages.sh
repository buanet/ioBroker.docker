#!/bin/bash

apt-get -qq update

packages=$(cat /opt/scripts/.packages)
for i in $packages; do
  sudo apt-get -qq -y install $i
done

# apt-get install -y  $(cat /opt/scripts/.packages)

rm -rf /var/lib/apt/lists/*
rm -f /opt/scripts/.packages

exit 0
