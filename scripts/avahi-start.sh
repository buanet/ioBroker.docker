#!/bin/sh
rm /var/run/dbus/pid
dbus-daemon --system
/etc/init.d/avahi-daemon stop
/etc/init.d/avahi-daemon start
exit 0
