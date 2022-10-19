#!/bin/sh

cd /ogre/imgt_files
wget --tries=2 -O vdjbase_status localhost:5000/vdjbase_import

updatedfile=vdjbase_status
slug=ogrdb-vdjbase
minsize=10

if ! [ $(find "$updatedfile") ]
then
    /usr/local/bin/python /app/healthchecks.py infra-goaccess fail -m "$updatedfile not created"
	exit
else
	echo "$updatedfile exists"
fi	

if [ $(find "$updatedfile" -mmin +60) ]
then
	/usr/local/bin/python /app/healthchecks.py vdjbase-backups -m "$updatedfile not updated"
	exit
else
	echo "$updatedfile updated"
fi

backupsize=$(find "$updatedfile" -printf "%s")

if [ $backupsize -lt $minsize ]
then
	/usr/local/bin/python /app/healthchecks.py vdjbase-backups fail -m "$updatedfile is implausibly small"
	exit
else
	echo "$updatedfile is a reasonable size"
fi

/usr/local/bin/python /app/healthchecks.py $slug success