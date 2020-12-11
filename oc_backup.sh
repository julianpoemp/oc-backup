#!/bin/bash
# Title: OC Backup Script
# Description: Creates a backup of the whole owncloud installation incl. SQL database.
# Author: Julian Poemp
# Version: 1.0.0
# LICENSE: MIT
# Check for updates: https://github.com/julianpoemp/oc-backup

SECONDS=0

# constants ot configuration file
OC_INSTALLATION_PATH=""
OC_DATA_PATH=""
OC_DB_NAME=""
OC_DB_USER=""
OC_DB_PASSWORD=""
BACKUP_DESTINATION=""
SHOW_ERRORS_ONLY=false

doesZipExist=false
doesSQLDumpExist=false

source ./oc_backup.cfg

# functions
function log {
  if [ "${SHOW_ERRORS_ONLY}" != true ] ; then
    echo "${1}"
  fi
}

function doBackup {
  configPath="${OC_INSTALLATION_PATH}/config/config.php"

  timeNow=$(date "+%Y-%m-%d_%H-%M-%S")

  log "-> Backup owncloud configuration file..."
  cp "${configPath}" "${configPath}.back"

  log "-> Read owncloud configuration file..."
  configFile=$(<"${configPath}")

  log "-> Set maintenance mode..."
  configFile="${configFile//\'maintenance\' => false/'maintenance' => true}"
  echo "${configFile}" > "${configPath}"

  log "-> Create backup folder"
  mkdir "${BACKUP_DESTINATION}" &> /dev/null

  log "-> Create database backup..."
  (mysqldump -u "${OC_DB_USER}" -p"${OC_DB_PASSWORD}" "${OC_DB_NAME}" > "${BACKUP_DESTINATION}/${timeNow}_owncloud.sql") &> /dev/null

  log "-> Create zip archive of owncloud files..."
  if [ "${SHOW_ERRORS_ONLY}" != true ] ; then
    zip -r -s 1000m "${BACKUP_DESTINATION}/${timeNow}_owncloud.zip" "${OC_INSTALLATION_PATH}" "${OC_DATA_PATH}"
  else
    zip -r -s 1000m "${BACKUP_DESTINATION}/${timeNow}_owncloud.zip" "${OC_INSTALLATION_PATH}" "${OC_DATA_PATH}" &> /dev/null
  fi

  log "-> Deactivate maintenance mode..."
  configFile="${configFile//\'maintenance\' => true/'maintenance' => false}"
  echo "${configFile}" > "${configPath}"
  duration=$SECONDS
  log "-> Finished after $(($duration / 60)) minutes."
}
# functions end

log "Start oc-backup v1.0.0..."

if type "zip" &> /dev/null; then
  doesZipExist=true
else
  doesZipExist=false
fi

if type "mysqldump" &> /dev/null; then
  doesSQLDumpExist=true
else
  doesSQLDumpExist=false
fi


if [ "${doesZipExist}" = true ] && [ "${doesSQLDumpExist}" = true ] ; then
  doBackup
else
  output="OC Backup Error: can not start backup, because of missing commands ("

  if [ "${doesZipExist}" != true ] ; then
    output="${output}zip"
  fi

  if [ "${doesSQLDumpExist}" != true ] ; then
    if [ "${doesZipExist}" != true ] ; then
      output="${output}, "
    fi

    output="${output}sqldump"
  fi

  echo "${output})."
fi
