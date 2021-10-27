#!/bin/bash
# Uses 7zip to compress and add a password to backup - mainly for protection in cloud, not local thus password is added plaintext on linux-host
#
# Built for use in crontab, run once a month
# backup-rotation is 6 months (older backups get deleted)
# 
# example:
# /scriptlocation/backupscript.sh "/home/user/documents" "/mnt/backupdisk/documents/monthly" "documents" "password123" "user:usergroup" "*excluded\files\here"



# retrieve variables from invoke command
BACKUPFOLDER=$1         #example: "/home/user/documents".
OUTPUTFOLDER=$2         #example: "/mnt/backupdisk/documents/monthly".
BACKUPNAME=$3           #example: "documents".
BACKUPPASSWORD=$4       #example: "password123".
USERANDGROUP=$5         #example: "user:usergroup". Chown and chmod is run on output of backedup file
EXCLUDEFOLDER=$6        #example: "*excluded\files\here". If you want to exclude a folder from being backed up, add it here

# Don't run multiple versions of the script
if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then
        echo "This script is already running with PID `pidof -x $(basename $0) -o %PPID`"
        exit
fi

# Abort on all errors, set -x
set -o errexit

echo $(date)
echo "Backing up folder: $BACKUPFOLDER"
echo "Saving to: $OUTPUTFOLDER"

LASTMONTH=$(date +%Y%m -d "1 month ago")
SIXMONTHSAGO=$(date +%Y%m -d "6 months ago")

echo
echo "Starting process monthly backup..."
echo

if [ ! -f $OUTPUTFOLDER/$BACKUPNAME-$LASTMONTH.7z ];
then
        echo "using 7zip to compress and password protect backup"
        7za a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -mhe=on -p"$BACKUPPASSWORD" /tmp/$BACKUPNAME $BACKUPFOLDER -xr!$EXCLUDEFOLDER 1>/dev/null
        echo "using 7zip to compress and password protect backup - done"
        echo
        if [ -f $OUTPUTFOLDER/$BACKUPNAME.7z ]
        then
                echo "Renaming previous backup"
                mv $OUTPUTFOLDER/$BACKUPNAME.7z $OUTPUTFOLDER/$BACKUPNAME-$LASTMONTH.7z
                echo "Renaming previous backup - Done"
                echo
        fi
        echo "Moving new backup from /tmp to $OUTPUTFOLDER"
        mv /tmp/$BACKUPNAME.7z $OUTPUTFOLDER/$BACKUPNAME.7z
        echo "Moving new backup from /tmp to $OUTPUTFOLDER - Done"
        echo "Changing ownership"
        chown $USERANDGROUP $OUTPUTFOLDER/$BACKUPNAME.7z
        chmod 700 $OUTPUTFOLDER/$BACKUPNAME.7z
        if [ -f $OUTPUTFOLDER/$BACKUPNAME-$SIXMONTHSAGO.7z ];
        then
                echo
                echo "Cleaning up folder by removing 6 month old backup"
                rm -rf "$OUTPUTFOLDER/$BACKUPNAME-$SIXMONTHSAGO.7z"
                echo "Cleaning up folder by removing 6 month old backup - Done"
        fi
else
        echo "!! Backup of $OUTPUTFOLDER/$BACKUPNAME-$LASTMONTH.7z already exists"
        echo "!! This means current months backup already exists, no need to create backup until next month"
        rm -rf /tmp/$BACKUPNAME.7z
fi

echo
echo "Done!"