#!/bin/sh

cd /ogre/static/docs
wget --no-check-certificate -O vdjbase.fasta "https://www.vdjbase.org/data/Alleles?name=&gene=&similar=&show_imgt=on&show_novel=on&download="
