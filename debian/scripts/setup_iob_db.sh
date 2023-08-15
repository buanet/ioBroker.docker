#!/bin/bash

# reading env
debug=$DEBUG
objectsdbhost=$IOB_OBJECTSDB_HOST
objectsdbport=$IOB_OBJECTSDB_PORT
objectsdbtype=$IOB_OBJECTSDB_TYPE
objectsdbname=$IOB_OBJECTSDB_NAME # new for sentinel support
objectsdbpass=$IOB_OBJECTSDB_PASS # new for auth support
setgid=$SETGID
setuid=$SETUID
statesdbhost=$IOB_STATESDB_HOST
statesdbport=$IOB_STATESDB_PORT
statesdbtype=$IOB_STATESDB_TYPE
statesdbname=$IOB_STATESDB_NAME # new for sentinel support
statesdbpass=$IOB_STATESDB_PASS # new for auth support

# functions
write_iobroker_json() {
  mv /opt/iobroker/iobroker-data/iobroker.json.tmp /opt/iobroker/iobroker-data/iobroker.json
  chown -R "$setuid":"$setgid" /opt/iobroker/iobroker-data/iobroker.json && chmod 674 /opt/iobroker/iobroker-data/iobroker.json
}
set_objectsdb_type() {
  if [[ "$objectsdbtype" != "$(jq -r '.objects.type' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
    echo "IOB_OBJECTSDB_TYPE is available but value is different from detected ioBroker installation."
    echo -n "Setting type of objects db to \"""$objectsdbtype""\"... "
      jq --arg value "$objectsdbtype" '.objects.type = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
      write_iobroker_json
    echo "Done."
  else
    echo "IOB_OBJECTSDB_TYPE is available and value meets detected ioBroker installation."
  fi
}
set_objectsdb_host() {
  if [[ $objectsdbhost == *","* ]]; then
    if [[ "$(jq -c -n --arg value "$objectsdbhost" '$value|split(",")')" != "$(jq -r '.objects.host' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
      echo "IOB_OBJECTSDB_HOST is available but value is different from detected ioBroker installation."
      echo -n "Setting host of objects db to \"""$objectsdbhost""\"... "
        jq --arg value "$objectsdbhost" '.objects.host = ($value|split(","))' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
        write_iobroker_json
      echo "Done."
    else
      echo "IOB_OBJECTSDB_HOST is available and value meets detected ioBroker installation."
    fi
    if [[ $objectsdbname != "" ]]; then
      if [[ "$objectsdbname" != "$(jq -r '.objects.sentinelName' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
        echo "IOB_OBJECTSDB_NAME is available but value is different from detected ioBroker installation."
        echo -n "Setting name of objects db to \"""$objectsdbname""\"... "
          jq --arg value "$objectsdbname" '.objects.sentinelName = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
          write_iobroker_json
        echo "Done."
      else
        echo "IOB_OBJECTSDB_NAME is available and value meets detected ioBroker installation."
      fi
    else
      if [[ "$(jq -r '.objects.sentinelName' /opt/iobroker/iobroker-data/iobroker.json)" != "mymaster" ]]; then
        echo "IOB_OBJECTSDB_NAME is not available. Using default value \"mymaster\" instead."
        echo -n "Setting name of objects db to \"mymaster\"... "
          jq --arg value "mymaster" '.objects.sentinelName = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
          write_iobroker_json
        echo "Done."
      else
        echo "IOB_OBJECTSDB_NAME is not available but default value \"mymaster\" meets detected ioBroker installation.."
      fi
    fi
  else
    if [[ "$objectsdbhost" != "$(jq -r '.objects.host' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
      echo "IOB_OBJECTSDB_HOST is available but value is different from detected ioBroker installation."
      echo -n "Setting host of objects db to \"""$objectsdbhost""\"... "
        jq --arg value "$objectsdbhost" '.objects.host = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
        write_iobroker_json
      echo "Done."
    else
      echo "IOB_OBJECTSDB_HOST is available and value meets detected ioBroker installation."
    fi
  fi
}
set_objectsdb_port() {
  if [[ $objectsdbport == *","* ]]; then 
    if [[ "$(jq -c -n --arg value "$objectsdbport" '$value|split(",")')" != "$(jq -r '.objects.port' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
      echo "IOB_OBJECTSDB_PORT is available but value is different from detected ioBroker installation."
      echo -n "Setting port of objects db to \"""$objectsdbport""\"... "
        jq --arg value "$objectsdbport" '.objects.port = ($value|split(","))' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
        write_iobroker_json
      echo "Done."
    else
      echo "IOB_OBJECTSDB_PORT is available and value meets detected ioBroker installation."
    fi
  else
    if [[ "$objectsdbport" != "$(jq -r '.objects.port' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
      echo "IOB_OBJECTSDB_PORT is available but value is different from detected ioBroker installation."
      echo -n "Setting port of objects db to \"""$objectsdbport""\"... "
        jq --arg value "$objectsdbport" '.objects.port = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
        write_iobroker_json
      echo "Done."
    else
      echo "IOB_OBJECTSDB_PORT is available and value meets detected ioBroker installation."
    fi
  fi
}
set_objectsdb_pass() {
  if [[ "$objectsdbpass" == "none" ]]; then
    echo "IOB_OBJECTSDB_PASS is available but value is set to \"none\"."
    echo -n "Removing password of objects db... "
      jq '.objects.options.auth_pass = null' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
      write_iobroker_json
    echo "Done."
  elif [[ "$objectsdbpass" != "$(jq -r '.objects.options.auth_pass' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
    echo "IOB_OBJECTSDB_PASS is available but value is different from detected ioBroker installation."
    echo -n "Setting password of objects db... "
      jq --arg value "$objectsdbpass" '.objects.options.auth_pass = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
      write_iobroker_json
    echo "Done."
  else
  echo "IOB_OBJECTSDB_PASS is available and value meets detected ioBroker installation."
  fi
}
set_statesdb_type() {
  if [[ "$statesdbtype" != "$(jq -r '.states.type' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
    echo "IOB_STATESDB_TYPE is available but value is different from detected ioBroker installation."
    echo -n "Setting type of states db to \"""$statesdbtype""\"... "
      jq --arg value "$statesdbtype" '.states.type = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
      write_iobroker_json
    echo "Done."
  else
    echo "IOB_STATESDB_TYPE is available and value meets detected ioBroker installation."
  fi
}
set_statesdb_host() {
  if [[ $statesdbhost == *","* ]]; then
    if [[ "$(jq -c -n --arg parm "$statesdbhost" '$parm|split(",")')" != "$(jq -r '.states.host' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
      echo "IOB_STATESDB_HOST is available but value is different from detected ioBroker installation."
      echo -n "Setting host of states db to \"""$statesdbhost""\"... "
        jq --arg value "$statesdbhost" '.states.host = ($value|split(","))' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
        write_iobroker_json
      echo "Done."
    else
      echo "IOB_STATESDB_HOST is available and value meets detected ioBroker installation."
    fi
    if [[ $statesdbname != "" ]]; then
      if [[ "$statesdbname" != "$(jq -r '.states.sentinelName' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
        echo "IOB_STATESDB_NAME is available but value is different from detected ioBroker installation."
        echo -n "Setting name of states db to \"""$statesdbname""\"... "
          jq --arg value "$statesdbname" '.states.sentinelName = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
          write_iobroker_json
        echo "Done."
      else
        echo "IOB_STATESDB_NAME is available and value meets detected ioBroker installation."
      fi
    else
      if [[ "$(jq -r '.states.sentinelName' /opt/iobroker/iobroker-data/iobroker.json)" != "mymaster" ]]; then
        echo "IOB_STATESDB_NAME is not available. Using default value \"mymaster\" instead."
        echo -n "Setting name of states db to \"mymaster\"... "
          jq --arg value "mymaster" '.states.sentinelName = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
          write_iobroker_json
        echo "Done."
      else
        echo "IOB_STATESDB_NAME is not available but default value \"mymaster\" meets detected ioBroker installation.."
      fi
    fi
  else
    if [[ "$statesdbhost" != "$(jq -r '.states.host' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
      echo "IOB_STATESDB_HOST is available but value is different from detected ioBroker installation."
      echo -n "Setting host of states db to \"""$statesdbhost""\"... "
        jq --arg value "$statesdbhost" '.states.host = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
        write_iobroker_json
      echo "Done."
    else
      echo "IOB_STATESDB_HOST is available and value meets detected ioBroker installation."
    fi
  fi
}
set_statesdb_port() {
  if [[ $statesdbport == *","* ]]; then 
    if [[ "$(jq -c -n --arg value "$statesdbport" '$value|split(",")')" != "$(jq -r '.states.port' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
      echo "IOB_STATESDB_PORT is available but value is different from detected ioBroker installation."
      echo -n "Setting port of states db to \"""$statesdbport""\"... "
        jq --arg value "$statesdbport" '.states.port = ($value|split(","))' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
        write_iobroker_json
      echo "Done."
    else
      echo "IOB_STATESDB_PORT is available and value meets detected ioBroker installation."
    fi
  else
    if [[ "$statesdbport" != "$(jq -r '.states.port' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
      echo "IOB_STATESDB_PORT is available but value is different from detected ioBroker installation."
      echo -n "Setting port of states db to \"""$statesdbport""\"... "
        jq --arg value "$statesdbport" '.states.port = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
        write_iobroker_json
      echo "Done."
    else
      echo "IOB_STATESDB_PORT is available and value meets detected ioBroker installation."
    fi
  fi
}
set_statesdb_pass() {
  if [[ "$statesdbpass" == "none" ]]; then
    echo "IOB_STATESDB_PASS is available but value is set to \"none\"."
    echo -n "Removing password of states db... "
      jq '.states.options.auth_pass = null' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
      write_iobroker_json
    echo "Done."
  elif [[ "$statesdbpass" != "$(jq -r '.states.options.auth_pass' /opt/iobroker/iobroker-data/iobroker.json)" ]]; then
    echo "IOB_STATESDB_PASS is available but value is different from detected ioBroker installation."
    echo -n "Setting password of states db... "
      jq --arg value "$statesdbpass" '.states.options.auth_pass = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp
      write_iobroker_json
    echo "Done."
  else
    echo "IOB_STATESDB_PASS is available and value meets detected ioBroker installation."
  fi
}
config_error_output() {
  echo " "
  echo "Something went wrong. Looks like at least one parameter defining the custom db connection was not set properly or is missing."
  echo "Please check your configuration and try again."
  echo "For more information see ioBroker Docker Image Docs (https://docs.buanet.de/iobroker-docker-image/docs/)."
}

# parameter check
if [[ "$1" == "-master" ]]; then # setup master
  echo "IOB_MULTIHOST is available and set to \"master\"."
  echo "Done."
  echo " "
  # multihost objects db
  if [[ "$objectsdbtype" != "" && "$objectsdbhost" != "" && "$objectsdbport" != "" ]]; then
    echo "Configuring custom objects db..."
    set_objectsdb_type
    set_objectsdb_host
    set_objectsdb_port
    if [[ "$objectsdbpass" != "" ]]; then set_objectsdb_pass; fi
    echo "Done."
    echo " "
  elif [[ "$objectsdbtype" == "" && "$objectsdbhost" == "" && "$objectsdbport" == "" ]]; then
    echo "No custom objects db is set."
    if [[ "$(jq -r '.objects.host' /opt/iobroker/iobroker-data/iobroker.json)" != "0.0.0.0" ]]; then
      echo -n "Configuring default objects db to accept external connections... "
        jq --arg value "0.0.0.0" '.objects.host = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp 
        write_iobroker_json
      echo "Done."
    else
      echo "Default objects db is accepting external connections."
    fi
  else
    if [[ "$debug" == "true" ]]; then
      echo "[DEBUG] IOB_OBJECTSDB_TYPE = ""$objectsdbtype"
      echo "[DEBUG] IOB_OBJECTSDB_HOST = ""$objectsdbhost"
      echo "[DEBUG] IOB_OBJECTSDB_PORT = ""$objectsdbport"
    fi
    config_error_output
    exit 1
  fi
  # multihost states db
  if [[ "$statesdbtype" != "" && "$statesdbhost" != "" && "$statesdbport" != "" ]]; then
    echo "Configuring custom states db..."
    set_statesdb_type
    set_statesdb_host
    set_statesdb_port
    if [[ "$statesdbpass" != "" ]]; then set_statesdb_pass; fi
    echo "Done."
    echo " "
  elif [[ "$statesdbtype" == "" && "$statesdbhost" == "" && "$statesdbport" == "" ]]; then
    echo "No custom states db is set."
    if [[ "$(jq -r '.states.host' /opt/iobroker/iobroker-data/iobroker.json)" != "0.0.0.0" ]]; then
      echo -n "Configuring default states db to accept external connections... "
        jq --arg value "0.0.0.0" '.states.host = $value' /opt/iobroker/iobroker-data/iobroker.json > /opt/iobroker/iobroker-data/iobroker.json.tmp 
        write_iobroker_json
      echo "Done."
    else
      echo "Default states db is accepting external connections."
    fi
  else
    if [[ "$debug" == "true" ]]; then
      echo "[DEBUG] IOB_STATESDB_TYPE = ""$statesdbtype"
      echo "[DEBUG] IOB_STATESDB_HOST = ""$statesdbhost"
      echo "[DEBUG] IOB_STATESDB_PORT = ""$statesdbport"
    fi
    config_error_output
    exit 1
  fi
elif [[ "$1" == "-slave" ]]; then # setup slave
  echo "IOB_MULTIHOST is available and set to \"slave\"."
  echo "Done."
  echo " "
  # multihost slave objects db connection
  if [[ "$objectsdbtype" != "" && "$objectsdbhost" != "" && "$objectsdbport" != "" ]]; then
    echo "Configuring objects db connection..."
    set_objectsdb_type
    set_objectsdb_host
    set_objectsdb_port
    if [[ "$objectsdbpass" != "" ]]; then set_objectsdb_pass; fi
    echo "Done."
    echo " "
  else
    if [[ "$debug" == "true" ]]; then
      echo "[DEBUG] IOB_OBJECTSDB_TYPE = ""$objectsdbtype"
      echo "[DEBUG] IOB_OBJECTSDB_HOST = ""$objectsdbhost"
      echo "[DEBUG] IOB_OBJECTSDB_PORT = ""$objectsdbport"
    fi
    config_error_output
    exit 1
  fi
  # multihost slave states db connection
  if [[ "$statesdbtype" != "" && "$statesdbhost" != "" && "$statesdbport" != "" ]]; then
    echo "Configuring states db connection..."
    set_statesdb_type
    set_statesdb_host
    set_statesdb_port
    if [[ "$statesdbpass" != "" ]]; then set_statesdb_pass; fi
    echo "Done."
    echo " "
  else
    if [[ "$debug" == "true" ]]; then
      echo "[DEBUG] IOB_STATESDB_TYPE = ""$statesdbtype"
      echo "[DEBUG] IOB_STATESDB_HOST = ""$statesdbhost"
      echo "[DEBUG] IOB_STATESDB_PORT = ""$statesdbport"
    fi
    config_error_output
    exit 1
  fi
elif [[ "$1" == "-objectsdb" ]]; then # setup objects db standalone
  if [[ "$objectsdbtype" != "" && "$objectsdbhost" != "" && "$objectsdbport" != "" ]]; then
    echo "Configuring custom objects db..."
    set_objectsdb_type
    set_objectsdb_host
    set_objectsdb_port
    if [[ "$objectsdbpass" != "" ]]; then set_objectsdb_pass; fi
    echo "Done."
    echo " "
  else
    if [[ "$debug" == "true" ]]; then
    echo "[DEBUG] IOB_OBJECTSDB_TYPE = ""$objectsdbtype"
    echo "[DEBUG] IOB_OBJECTSDB_HOST = ""$objectsdbhost"
    echo "[DEBUG] IOB_OBJECTSDB_PORT = ""$objectsdbport"
    fi
    config_error_output
    exit 1
  fi
elif [[ "$1" == "-statesdb" ]]; then # setup states db standalone
  if [[ "$statesdbtype" != "" && "$statesdbhost" != "" && "$statesdbport" != "" ]]; then
    echo "Configuring custom states db..."
    set_statesdb_type
    set_statesdb_host
    set_statesdb_port
    if [[ "$statesdbpass" != "" ]]; then set_statesdb_pass; fi
    echo "Done."
    echo " "
  else
    if [[ "$debug" == "true" ]]; then
    echo "[DEBUG] IOB_STATESDB_TYPE = ""$statesdbtype"
    echo "[DEBUG] IOB_STATESDB_HOST = ""$statesdbhost"
    echo "[DEBUG] IOB_STATESDB_PORT = ""$statesdbport"
    fi
    config_error_output
    exit 1
  fi
fi
