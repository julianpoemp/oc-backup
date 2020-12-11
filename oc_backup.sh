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

cmd_zip_exists=false
cmd_sqldump_exists=false
missing_constants=""
is_config_valid=false

source ./oc_backup.cfg

# FUNCTIONS

function log {
  if [ "${SHOW_ERRORS_ONLY}" != true ] ; then
    echo "${1}"
  fi
}

function check_available_commands {
  if type "zip" &> /dev/null; then
    cmd_zip_exists=true
  else
    cmd_zip_exists=false
  fi

  if type "mysqldump" &> /dev/null; then
    cmd_sqldump_exists=true
  else
    cmd_sqldump_exists=true
  fi
}

function check_config {
  if [ "${OC_INSTALLATION_PATH}" = "" ] ; then
    missing_constants="OC_INSTALLATION_PATH, "
  fi

  if [ "${OC_DATA_PATH}" = "" ] ; then
      missing_constants="${missing_constants}OC_DATA_PATH, "
  fi

  if [ "${OC_DB_NAME}" = "" ] ; then
      missing_constants="${missing_constants}OC_DB_NAME, "
  fi

  if [ "${OC_DB_USER}" = "" ] ; then
      missing_constants="${missing_constants}OC_DB_USER, "
  fi

  if [ "${OC_DB_PASSWORD}" = "" ] ; then
      missing_constants="${missing_constants}OC_DB_PASSWORD, "
  fi

  if [ "${BACKUP_DESTINATION}" = "" ] ; then
      missing_constants="${missing_constants}BACKUP_DESTINATION"
  fi

  if [ "${missing_constants}" = "" ] ; then
    is_config_valid=true
  else
    is_config_valid=false
  fi
}

function enable_maintenance_mode {
  log "-> Enable maintenance mode..."
  configFile="${configFile//\'maintenance\' => false/\'maintenance\' => true}"
  echo "${configFile}" > "${configPath}"
}

function disable_maintenance_mode {
  log "-> Disbale maintenance mode..."
  configFile="${configFile//\'maintenance\' => true/\'maintenance\' => false}"
  echo "${configFile}" > "${configPath}"
}

function create_zip_backup {
  log "-> Create zip archive of owncloud files..."
  if [ "${SHOW_ERRORS_ONLY}" != true ] ; then
    zip -r -s 1000m "${BACKUP_DESTINATION}/${timeNow}_owncloud.zip" "${OC_INSTALLATION_PATH}" "${OC_DATA_PATH}"
  else
    zip -r -s 1000m "${BACKUP_DESTINATION}/${timeNow}_owncloud.zip" "${OC_INSTALLATION_PATH}" "${OC_DATA_PATH}" &> /dev/null
  fi
}

function doBackup {
  configPath="${OC_INSTALLATION_PATH}/config/config.php"

  timeNow=$(date "+%Y-%m-%d_%H-%M-%S")

  log "-> Backup owncloud configuration file..."
  cp "${configPath}" "${configPath}.back"

  log "-> Read owncloud configuration file..."
  configFile=$(<"${configPath}")

  enable_maintenance_mode

  log "-> Create backup folder"
  mkdir "${BACKUP_DESTINATION}" &> /dev/null

  log "-> Create database backup..."
  (mysqldump -u "${OC_DB_USER}" -p"${OC_DB_PASSWORD}" "${OC_DB_NAME}" > "${BACKUP_DESTINATION}/${timeNow}_owncloud.sql") &> /dev/null

  create_zip_backup

  disable_maintenance_mode

  duration=$SECONDS
  log "-> Finished after $(($duration / 60)) minutes."
}
# FUNCTIONS END

log "Start oc-backup v1.0.0..."

check_available_commands
check_config

if [ "${cmd_zip_exists}" = true ] && [ "${cmd_sqldump_exists}" = true ] ; then

  if [ "${is_config_valid}" = true ] ; then
    doBackup
  else
    echo "OC Backup Error: Invalid config file. Missing constants: ${missing_constants}."
  fi
else
  output="OC Backup Error: can not start backup, because of missing commands ("

  if [ "${cmd_zip_exists}" != true ] ; then
    output="${output}zip"
  fi

  if [ "${cmd_sqldump_exists}" != true ] ; then
    if [ "${cmd_zip_exists}" != true ] ; then
      output="${output}, "
    fi

    output="${output}sqldump"
  fi

  echo "${output})."
fi
