#!/bin/sh

echo 'Preparing...'
rm /var/run/dbus/pid
dbus-daemon --system

echo 'Restarting...'
/etc/init.d/avahi-daemon stop
sleep 5
/etc/init.d/avahi-daemon start

exit 0
