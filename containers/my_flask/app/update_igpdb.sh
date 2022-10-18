#!/bin/sh

cd /ogre/imgt_files
wget -O igpdb.fasta --post-data "paper=0&study=0&type=All&file=true&submit=Download" http://cgi.cse.unsw.edu.au/~ihmmune/IgPdb/download.php

updatedfile=igpdb.fasta
slug=ogrdb-igpdb
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

python /app/healthchecks.py $slug success