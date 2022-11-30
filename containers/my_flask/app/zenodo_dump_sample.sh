#!/bin/bash
# Modify this file to use the required zenodo token and id, and the ogrdb password

slug=ogrdb-zenodo
/usr/local/bin/python /app/healthchecks.py $slug start

cd /tmp
/usr/bin/mysqldump -h mariadb -P 3306 -u ogrdb -p75CVi8SFqsjifY --ignore-table=ogrdb.alembic_version --ignore-table=ogrdb.role --ignore-table=ogrdb.roles_submissions --ignore-table=ogrdb.roles_users --ignore-table=ogrdb.user ogrdb >ogrdb_dump.sql  
/bin/tar -cvzf ogrdb_archive.tgz ogrdb_dump.sql /ogre/attachments/*

updatedfile=ogrdb_archive.tgz
minsize=5000

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

cd /app
/usr/local/bin/python zenodo.py 7148774 /tmp/ogrdb_archive.tgz 0

/usr/local/bin/python /app/healthchecks.py $slug success
