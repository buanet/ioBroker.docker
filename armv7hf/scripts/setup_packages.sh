#!/bin/bash

apt-get update
apt-get install -y  $(cat /opt/scripts/.packages)
rm -rf /var/lib/apt/lists/*
rm -f /opt/scripts/.packages

exit 0
