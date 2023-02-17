# Owncloud/Nexcloud Backup Script

This script alllows to backup your owncloud (or nextcloud) installation with data and its SQL Database. You can run this
script
on your linux server where your cloud is installed. In my case this scripts saves me a lot of time: During the backup my
owncloud installation is unavailable for just 2 hours instead of days (I'm using encryption and I have a lot of small
files to download). Please read the [Requirements](https://github.com/julianpoemp/oc-backup#requirements) before using
this script.

**Some statistics**: My owncloud folder (data + owncloud installation) has a size of 112 GB and contains 492733 files (
incl. encryption keys). The size of the backup is only 75.5 GB. My owncloud installation was in maintenance mode for
just 77 minutes. After that I downloaded the files with full speed.

## Features:

- Backup of owncloud/nextcloud installation to 1 GB zip parts => smaller backup size, bigger parts to download => better
  download speed.
- Backup of owncloud/nextcloud SQL database next to the data backup
- Automatically enable maintenance mode while backup
- Automation via cronjob supported
- Download and remove completely created parts of the backup while it's running to save time and disc space

## Why?

An owncloud/nextcloud installation can contain a lot of small files, especially if you are using server-side encryption.
If you try to
make a remote backup via FTPS/SFTP your download-speed will be low because your FTP-Client tries to download those many,
small
files. It's better to download bigger files, e.g. of size 1GB. Further more your owncloud is unavailable just for the
time the backup files are created, not for the time you need to download the files.

## How does it work?

It's just a shell script. It enables the maintenance mode, makes a backup of the SQL database, a backup of the data
directory and a backup of the owncloud installation directory. After it has finished the backup it disables the
maintenance mode automatically.

## Requirements

1. Make sure that your webserver's operating system is Linux.
2. You need enough disk space on the destination of the backup (max. the size of your owncloud/nextcloud directory). *
   *Tip: You can download parts of the backup while it's running (only full created parts, not the temporary ones!). As
   soon as the download finished you can remove the downloaded parts.**
3. You need terminal access (SSH or local) to the webserver where owncloud is installed in order to run this
   script. [What if I do not have SSH access?](#what-if-i-do-not-have-access-to-my-webserver)
4. Make sure that the commands `zip` and `mysqldump` exist.

## Installation & Run

1. Clone this repository to a directory on your server or upload both oc_backup.sh and oc_backup_sample.cfg manually.

````shell
git clone https://github.com/julianpoemp/oc-backup.git
````

2. Duplicate `oc_backup_sample.cfg` and rename it to `oc_backup.cfg`
2. Change the oc_backup.cfg file with the data of your owncloud installation.
   See [config example](#example-config-file).
3. To start the backup run `sh ./oc_backup.sh`. While it is running your owncloud is in maintenance mode.
4. After the backup you can download the backup to your computer.

## Update

If you installed oc_backup manually you need to update manually. I recommend to clone this repository so you just have
to call `git pull` to receive updates.

## Example config file

Assuming your data directory and your owncloud directory are in the same folder called "myowncloud.com":

````
OCB_TYPE="owncloud"
OC_INSTALLATION_PATH=/path/to/myowncloud.com/owncloud
OC_DATA_PATH=/path/to/myowncloud.com/data
OC_DB_NAME=owncloud
OC_DB_USER=user
OC_DB_PASSWORD=password
BACKUP_PATH=/path/to/backup
CREATE_LOGFILE=true
````

## Command line arguments

<table>
  <tbody>
    <tr>
      <td>
        -c
      </td>
      <td>
        Absolute path to the config file for oc-backup.
      </td>
    </tr>
     <tr>
      <td>
        -h
      </td>
      <td>
        Show help text.
      </td>
    </tr>
  </tbody>
</table>

## Tested on production servers

- [www.all-inkl.com](https://all-inkl.com/PA308D2013F2745)\1 : This is my webspace provider. I tested the script on a
  SSH server from that company.

\1 Affiliate Link. If you buy a product I'll get a small commission :)

## What if I do not have SSH access to my webserver?

In that case there are two options:

1) If you are not using server-side encryption you could try
   to [make a backup without SSH access](#making-a-backup-without-ssh-access).
2) If you are using server-side encryption you have a lot of small files for sure. In that way I recommend you to get
   SSH access. If you don't want to, you could try making a backup manually, but the download speed will be very very
   slow and the backup will take a lot of more time.

## Making a backup without SSH access

1. Enable the maintenance mode in your config.php of your owncloud installation.
2. Export your SQL database and save it on your computer.
3. Use a FTP-Client and connect to your server.
4. Download your owncloud directory next to your SQL backup file.
5. After the download has finished disable maintenance mode.

As an alternative to a standard FTP-Client you could use
my [webspace-backup](https://github.com/julianpoemp/webspace-backup) application.

## How to run it automatically using cronjob

1. On your server call `crontab -e`
2. Add a line, something like that ````00 4 * * * <absolute path to oc_backup.sh &> /dev/null````
3. Save it.

Example:

````
# run it every day at 4 a.m.
00 4 * * * /home/julian/oc_backup.sh -c /home/julian/somefolder/oc_backup.cfg &> /dev/null
````
