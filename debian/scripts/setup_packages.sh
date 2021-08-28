#!/bin/bash

if [ $1 == "-install" ]
then
  apt-get -qq update
  packages=$(cat /opt/scripts/.packages)
  for i in $packages; do
    sudo apt-get -qq -y install $i
  done
elif [ $1 == "-update" ]
then
  apt-get -qq update
  apt-get -qq -y upgrade
else
  echo "No paramerter found!"
  exit 1
fi

rm -rf /var/lib/apt/lists/*
rm -f /opt/scripts/.packages

exit 0
