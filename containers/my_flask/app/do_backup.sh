#!/bin/bash
#@author Julius Zaromskis
#@description Backup script for your website

BACKUP_DIR=/backup
TEMP_DIR=/tmp

slug=ogrdb-backup
python /app/healthchecks.py $slug start

# Precautionary cleanup
mkdir -p $BACKUP_DIR/incoming
mkdir -p $BACKUP_DIR/temp
mkdir -p $BACKUP_DIR/backup.daily
mkdir -p $BACKUP_DIR/backup.weekly
mkdir -p $BACKUP_DIR/backup.monthly
rm $BACKUP_DIR/incoming/*
rm -rf $BACKUP_DIR/temp/*

# Dump MySQL tables
mysqldump --all-databases -h mariadb -P 3306 -u ogrdb -p75CVi8SFqsjifY >/config/log/sqldump

updatedfile=/config/log/sqldump
minsize=1000

if ! [ $(find "$updatedfile") ]
then
    python /app/healthchecks.py infra-goaccess fail -m "$updatedfile not created"
	exit
else
	echo "$updatedfile exists"
fi	

if [ $(find "$updatedfile" -mmin +60) ]
then
	python /app/healthchecks.py vdjbase-backups -m "$updatedfile not updated"
	exit
else
	echo "$updatedfile updated"
fi

backupsize=$(find "$updatedfile" -printf "%s")

if [ $backupsize -lt $minsize ]
then
	python /app/healthchecks.py vdjbase-backups fail -m "$updatedfile is implausibly small"
	exit
else
	echo "$updatedfileis a reasonable size"
fi

# Backup logs and config

mkdir -p $BACKUP_DIR/temp/config
cp -r /config/*  $BACKUP_DIR/temp/config/.
mkdir -p $BACKUP_DIR/temp/ogre
cp -r /ogre/*  $BACKUP_DIR/temp/ogre/.
mkdir -p $BACKUP_DIR/temp/app
cp -r /app/*  $BACKUP_DIR/temp/app/.
mkdir -p $BACKUP_DIR/temp/infra_config
cp -r /infra_config/*  $BACKUP_DIR/temp/infra_config/.

cd $BACKUP_DIR/temp
	
# Compress tables and files
tar -cvzf $BACKUP_DIR/incoming/archive.tgz *

updatedfile=$BACKUP_DIR/incoming/archive.tgz
minsize=1000

if ! [ $(find "$updatedfile") ]
then
    python /app/healthchecks.py infra-goaccess fail -m "$updatedfile not created"
	exit
else
	echo "$updatedfile exists"
fi	

if [ $(find "$updatedfile" -mmin +60) ]
then
	python /app/healthchecks.py vdjbase-backups -m "$updatedfile not updated"
	exit
else
	echo "$updatedfile updated"
fi

backupsize=$(find "$updatedfile" -printf "%s")

if [ $backupsize -lt $minsize ]
then
	python /app/healthchecks.py vdjbase-backups fail -m "$updatedfile is implausibly small"
	exit
else
	echo "$updatedfileis a reasonable size"
fi

# Cleanup
rm -rf $BACKUP_DIR/temp/*

# Run backup rotate
cd $BACKUP_DIR
bash /app/rotate.sh

python /app/healthchecks.py $slug success
