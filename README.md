# Owncloud Backup Script

**! IN DEVELOPMENT, DO NOT USE IT UNTIL TESTED !**

This Script alllows to create a backup of the whole owncloud installation and its SQL Database. You can run this script
on your linux server where your owncloud installation is installed.

## Features:

- Backup of owncloud installation to 1 GB zip parts => better download speed.
- Backup of owncloud SQL database
- Automatically enable maintenance mode while backup

## Why?

An owncloud installation can contain a lot of small files, especially if you are using server-side encryption. If you try to
make a remote backup via FTPS/SFTP your download-speed will be low because your FTP-Client tries to download those many, small
files. It's better to download bigger files, e.g. of size 1GB.

## One example scenario

For example you could create a cronjob that creates a backup every day at 3 a.m while you are sleeping. After that you
can download the backup whenever you wish to do - with the full download speed, because your FTP-client does not have to
download a lot of small files.


## Requirements

1. Make sure that your webserver's operating system is Linux.
2. You need SSH access to the webserver where owncloud is installed in order to run this script.
3. You need enough disk space on your server (min. twice the size of your owncloud directory).
