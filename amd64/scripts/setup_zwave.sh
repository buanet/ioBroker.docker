#!/bin/bash

echo "Checking openzwave installation state..."

if [ -f /usr/local/lib64 ]
then
  echo "Openzwave is already installed..."
else
  echo "Openzwave is NOT installed. Going to install it now..."
  cd /opt
  curl -s -L -O http://old.openzwave.com/downloads/openzwave-1.6.945.tar.gz
  tar -xf openzwave-1.6.945.tar.gz && rm openzwave-1.6.945.tar.gz
  cd openzwave-1.6.945 && make > /dev/null 2>&1 && make install > /dev/null 2>&1
  ldconfig /usr/local/lib64
  cd /opt/iobroker
  # echo "Openzwave is now installed..."
fi

exit 0