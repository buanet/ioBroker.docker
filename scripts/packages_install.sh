#!/bin/bash

packages=$PACKAGES
echo 'ENV packages:' $packages

apt-get update && apt-get install -y $packages && rm -rf /var/lib/apt/lists/*

exit 0
