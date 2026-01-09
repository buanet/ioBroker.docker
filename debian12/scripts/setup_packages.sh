#!/usr/bin/env bash

# bash strict mode
set -euo pipefail

# Reading ENV
set +u
packages=$PACKAGES
debug=$DEBUG
set -u

export DEBIAN_FRONTEND=noninteractive

check_package_preq() {
  # check for influx packages
  if [[ "$i" == "influxdb" || "$i" == "influxdb2-cli" ]]; then
    # add influxdata repo keys - FIXED VERSION
    apt-get -q install -y curl gnupg >> /opt/scripts/setup_packages.log 2>&1
    
    # Remove old keys/repos
    rm -f /etc/apt/sources.list.d/influx*
    rm -f /etc/apt/keyrings/influx*
    
    # Download and add GPG key
    tmp_keyring=$(mktemp)
    if ! curl --silent --location https://repos.influxdata.com/influxdata-archive.key | gpg --dearmor > "$tmp_keyring"; then
      echo "Failed to download or dearmor InfluxData GPG key." >&2
      rm -f "$tmp_keyring"
      return 1
    fi
    mv "$tmp_keyring" /usr/share/keyrings/influxdata-archive.gpg
    echo "deb [signed-by=/usr/share/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main" > /etc/apt/sources.list.d/influxdata.list
    apt-get -q update >> /opt/scripts/setup_packages.log 2>&1
  fi
}

check_package_validity() {
  # check string for double spaces
  while echo "$packages" | grep -q '  '; do
    packages=$(echo "$packages" | sed 's/  / /g')
  done
  # remove packages when "influxdb" AND "influxdb2-cli"
  if echo "$packages" | grep -qw "influxdb" && echo "$packages" | grep -qw "influxdb2-cli"; then
    echo "PACKAGES includes influxdb AND influxdb2-cli."
    echo "As installing both packages together is not possible, they will be skipped."
    packages=$(echo "$packages" | sed 's/influxdb2-cli//g;s/influxdb//g')
    # check string for double spaces again
    while echo "$packages" | grep -q '  '; do
      packages=$(echo "$packages" | sed 's/  / /g')
    done
    if [[ $debug == "true" ]]; then echo "[DEBUG] New list of packages: $packages"; fi
    echo " "
  fi
}

if [[ "$1" == "-install" ]]; then
  echo " "
  apt-get -q update >> /opt/scripts/setup_packages.log 2>&1
  check_package_validity
  for i in $packages; do
    if ! dpkg -s "$i" >/dev/null 2>&1; then
      echo -n "$i is not installed. Installing... "
      check_package_preq >> /opt/scripts/setup_packages.log 2>&1
      if ! apt-get -q -y --no-install-recommends install "$i" >> /opt/scripts/setup_packages.log 2>&1; then
        echo "Failed."
        echo "For more details see \"/opt/scripts/setup_packages.log\"."
      else
        echo "Done."
      fi
    else
      echo "$i is already installed."
    fi
  done
elif [[ "$1" == "-update" ]]; then
  echo -n "PACKAGES_UPDATE is set. Updating Linux packages on first run... "
  apt-get -q update >> /opt/scripts/setup_packages.log 2>&1
  return1=$?
  apt-get -q -y upgrade >> /opt/scripts/setup_packages.log 2>&1
  return2=$?
  if [[ "$return1" -ne 0 || "$return2" -ne 0 ]]; then
    echo "Failed."
    echo "For more details see \"/opt/scripts/setup_packages.log\"."
    echo "Make sure the container has internet access to get the latest package updates."
    echo "This has no impact to the setup process. The script will continue."
  else
    echo "Done."
  fi
else
  echo "No parameter found!"
  exit 1
fi

# Silent Cleanup
apt-get -qq autoclean -y && apt-get -qq autoremove && apt-get -qq clean
rm -rf /tmp/* /var/tmp/* /root/.cache/* /var/lib/apt/lists/* || true

exit 0
