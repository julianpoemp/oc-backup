# Owncloud Backup Script

**! IN DEVELOPMENT, DO NOT USE IT UNTIL TESTED !**

This Script alllows to create a backup of the whole owncloud installation and its SQL Database. You can run this script
on your linux server where your owncloud installation is installed. In my case this scripts saves me a lot of time: During the backup my owncloud installation is unavailable for just 2 hours instead of days (I'm using encryption and I have a lot of small files to download). Please read the [Requirements](https://github.com/julianpoemp/oc-backup#requirements) before using this script.

## Features:

- Backup of owncloud installation to 1 GB zip parts => better download speed.
- Backup of owncloud SQL database next to the data backup
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

1. You need enough disk space on your server (min. twice the size of your owncloud directory).
2. Make sure that your webserver's operating system is Linux.
3. You need SSH access to the webserver where owncloud is installed in order to run this script. [What if I do not have SSH access?](#what-if-i-do-not-have-access-to-my-webserver)
4. Make sure that the commands `zip` and `mysqldump` exist.

## Example config file
Assuming your data directory and your owncloud directory are in the same folder called "myowncloud.com":
````
domainPath=/path/to/myowncloud.com
configPath=/path/to/myowncloud.com/owncloud/config/config.php
````

## What if I do not have SSH access to my webserver?

In that case there are two options:

1) If you are not using server-side encryption you could try to [make a backup without SSH access](#making-a-backup-without-ssh-access).
2) If you are using server-side encryption you have a lot of small files for sure. In that way I recommend you to get SSH access. If you don't want to, you could try making a backup manually, but the download speed will be very very slow and the backup will take a lot of more time.

## Making a backup without SSH access

1. Enable the maintenance mode in your config.php of your owncloud installation.
2. Export your SQL database and save it on your computer.
3. Use a FTP-Client and connect to your server.
4. Download your owncloud directory next to your SQL backup file.
5. After the download has finished disable maintenance mode.

As an alternative to a standard FTP-Client you could use my [webspace-backup](https://github.com/julianpoemp/webspace-backup) application.
