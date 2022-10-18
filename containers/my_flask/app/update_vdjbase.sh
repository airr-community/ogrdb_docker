#!/bin/sh

cd /ogre/imgt_files
wget --tries=2 -O vdjbase_status localhost:5000/vdjbase_import

updatedfile=vdjbase_status
slug=ogrdb-vdjbase
minsize=100

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

python /app/healthchecks.py $slug success