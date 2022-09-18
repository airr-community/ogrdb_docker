#!/bin/bash
# Modify this file to use the required zenodo token and id, and the ogrdb password
cd /tmp
/usr/bin/mysqldump -h mariadb -P 3306 -u ogrdb -p75CVi8SFqsjifY --ignore-table=ogrdb.alembic_version --ignore-table=ogrdb.role --ignore-table=ogrdb.roles_submissions --ignore-table=ogrdb.roles_users --ignore-table=ogrdb.user ogrdb >ogrdb_dump.sql  
/bin/tar -cvzf ogrdb_archive.tgz ogrdb_dump.sql /ogre/attachments/*
/usr/local/bin/python /app/zenodo_new_version.py access_tocken deposition_id ogrdb_archive.tgz 0