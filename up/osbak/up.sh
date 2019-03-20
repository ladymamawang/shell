#!/bin/sh
#####Auto transmission  script##########

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin         ;export PATH

day=`date +%y%m`
ip="98.79"                                      ;export ip
FILE="${ip}.os.tar.gz"                             ;export FILE
TAR="${ip}.os.tar"                                 ;export TAR
LDIR="/exp/backup/osbak"                        ;export LDIR

RIP="10.134.97.159"                              ;export RIP
RDIR="/backup/monbak_$day"        ;export RDIR

tar cvf $TAR 5 && gzip $TAR

ftp -n<<!
open $RIP
user root root123
binary
hash
prompt
cd $RDIR
lcd $LDIR
put $FILE
close
bye
!
rm -rf /exp/backup/osbak/*.tar.gz

