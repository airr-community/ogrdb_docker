#!/bin/sh
cd /app
/usr/local/bin/python imgt/track_imgt_ref.py imgt/track_imgt_config.yaml

updatedfile=/ogre/imgt_files/log.txt
slug=ogrdb-imgt
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
	echo "$updatedfile is a reasonable size"
fi

python /app/healthchecks.py $slug success -m "`tail /ogre/imgt_files/log.txt`"
