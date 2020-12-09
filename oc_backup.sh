#!/bin/bash
# Title: OC Backup Script
# Description: Creates a backup of the whole owncloud installation incl. SQL database.
# Author: Julian Poemp
# Version: 1.0.0
# Check for updates:

SECONDS=0

# constants ot configuration file
domainPath=""
configPath=""

echo "Read backup config..."
source ./oc_backup.cfg

timeNow=$(date "+%Y-%m-%d_%H-%M-%S")

echo "Backup owncloud configuration file..."
cp "${configPath}" "${configPath}.back"

echo "Read owncloud configuration file..."
configFile=$(<"${configPath}")

echo "Set maintenance mode..."
configFile=$(echo "${configFile//\('maintenance' =>\) false\(,\)/\1 true\2/g}"
echo "${configFile}" > ${configPath}

echo "Create database backup..."
# mysqldump -u $dbUser -p"${dbPassword}" ${dbName} > ${timeNow}_ocsp.sql

echo "Create zip archive of owncloud files..."
# zip -r -s 1000m ${timeNow}_ocsp.zip ${owncloudPath}

echo "Deactivate maintenance mode..."
configFile=$(echo "${configFile}" | sed -e "s/\('maintenance' =>\) true\(,\)/\1 false\2/g")
echo "${configFile}" > ${configPath}
duration=$SECONDS
echo "Finished after $(($duration / 60)) minutes."
