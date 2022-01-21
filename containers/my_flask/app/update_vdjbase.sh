#!/bin/sh

cd /ogre/imgt_files
wget --tries=2 -O vdjbase_status localhost:5000/vdjbase_import
