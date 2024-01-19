#!/usr/bin/env bash

if [ -e /usr/sbin/avahi-daemon ] && [ -e /var/run/dbus ]
then
  echo "[setup_avahi.sh] Avahi is already installed. Nothing to do here."
else
  echo -n "[setup_avahi.sh] Avahi-daemon is NOT installed. Going to install it now... "
    apt-get -q update > /opt/scripts/avahi_startup.log 2>&1
    apt-get -q -y --no-install-recommends install libavahi-compat-libdnssd-dev avahi-daemon >> /opt/scripts/avahi_startup.log 2>&1
    # Silent Cleanup
    apt-get -qq autoclean -y && apt-get -qq autoremove && apt-get -qq clean
    rm -rf /tmp/* /var/tmp/* /root/.cache/* /var/lib/apt/lists/* || true
  echo "Done."
  echo -n "[setup_avahi.sh] Configuring avahi-daemon... "
    sed -i '/^rlimit-nproc/s/^\(.*\)/#\1/g' /etc/avahi/avahi-daemon.conf
  echo "Done."
  echo -n "[setup_avahi.sh] Configuring dbus... "
    mkdir /var/run/dbus/
  echo "Done."
fi

if [ -f /var/run/dbus/pid ];
then
  rm -f /var/run/dbus/pid
fi

if [ -f /var/run/avahi-daemon//pid ];
then
  rm -f /var/run/avahi-daemon//pid
fi

echo -n "[setup_avahi.sh] Starting dbus... "
  dbus-daemon --system >> /opt/scripts/avahi_startup.log 2>&1
echo "Done."

echo -n "[setup_avahi.sh] Starting avahi-daemon... "
  avahi-daemon >> /opt/scripts/avahi_startup.log 2>&1 &
echo "Done."

exit 0
