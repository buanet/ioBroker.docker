#!/bin/sh

rm /var/run/dbus/pid
dbus-daemon --system

/etc/init.d/avahi-daemon stop
sleep 5
/etc/init.d/avahi-daemon start

exit 0
