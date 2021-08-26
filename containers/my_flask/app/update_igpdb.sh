#!/bin/sh

cd /ogre/static/docs
wget -O igpdb.fasta --post-data "paper=0&study=0&type=All&file=true&submit=Download" http://cgi.cse.unsw.edu.au/~ihmmune/IgPdb/download.php
