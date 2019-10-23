#!/bin/bash

echo "Checking openzwave installation state..."

if [ -f /usr/local/lib64 ]
then
  echo "Openzwave is NOT installed. Going to install it now..."
  cd /opt
  curl -L -O http://old.openzwave.com/downloads/openzwave-1.6.945.tar.gz
  tar -xf openzwave-1.6.945.tar.gz && rm openzwave-1.6.945.tar.gz
  cd openzwave-1.6.945 && make 2>&1 /dev/null && make install 2>&1 /dev/null
  ldconfig /usr/local/lib64
  cd /opt/iobroker
  echo "Openzwave is now installed..."
else
  echo "Openzwave is already installed..."
fi

exit 0