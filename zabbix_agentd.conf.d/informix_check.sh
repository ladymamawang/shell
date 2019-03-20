#! /usr/bin/ksh

# Set your Informix variables here
for testdir in `ls /u | egrep "inf|ids" | grep -v tar`
do
        if [ -f /u/$testdir/etc/onconfig.top ] ;then
                dir=$testdir
        fi
done
INFORMIXDIR=/u/$dir
if [ -f $INFORMIXDIR/.profile ];then
        PROFILE=$INFORMIXDIR/.profile
else
        PROFILE=$INFORMIXDIR/.bash_profile
fi
PATH=$PATH:$INFORMIXDIR/bin
export INFORMIXDIR PATH
INFORMIXSERVER1=`cat $PROFILE|grep -v '^#'|grep INFORMIXSERVER=|awk -F "=" '{printf $2}'`
INFORMIXSERVER=`echo $INFORMIXSERVER1|awk '{print $1}'|awk -F ";" '{print $1}'`
ONCONFIG=`cat $PROFILE|grep -v '^#'|grep ONCONFIG=|awk -F "=" '{printf $2}'`
export INFORMIXSERVER
export ONCONFIG=`echo $ONCONFIG|sed 's/^ //;s/ $//'`
export PATH=$PATH:$HOME/bin
export unset USERNAME
export PATH=$PATH:$HOME/bin
export PATH=$INFORMIXDIR/bin:$PATH;export PATH
export INFORMIXSERVER
export DBDATE=Y4MD0;export DBDATE
export DBCENTURY=C;export DBCENTURY
export DBDELIMITER=^A;export DBDELIMITER
export ONCONFIG=onconfig.top;export ONCONFIG
export DB_LOCALE=zh_tw.big5;export DB_LOCALE
export TERM=xterm;export TERM
export CLIENT_LOCALE=zh_tw.big5;export CLIENT_LOCALE
export SERVER_LOCALE=zh_tw.big5;export SERVER_LOCALE
export PS1=`hostname`'<$INFORMIXSERVER><$PWD>$' export PS1
export export PATH


ONSTAT=$INFORMIXDIR/bin/onstat
GREP=grep
export POSIXLY_CORRECT=1 # to AWK parse equal on all OS the regular expressions... (on Linux this can be disabled)
AWK=awk
SED=sed
TR=tr
CUT=cut
DATE=date
# Check if onstat is accessible

if [ ! -x $ONSTAT ] ; then
  echo "ZBX_NOTSUPPORTED"
  exit 1
fi
Check_item=$1
check(){
        case $1 in
        dbstatus)
                $ONSTAT - >/dev/null
                echo $?
                ;;
        logstatus)
                $ONSTAT -l | $GREP -c B
                ;;
        hdrstatus)
                $ONSTAT -g dri | $GREP "off"> /dev/null
                echo $?
                ;;
        unloadstatus)
                sys=`uname`
                if [ $sys = 'Linux' ];then
                        dir=`crontab -l | grep unload | grep -v "#" |awk '{print $7}' | sed 's/\/unload.sh//g'`
#                       cron=`crontab -l -u informix | grep unload | grep -v "#" |awk '{print $3}'`
                else
                        dir=`crontab -l informix | grep unload | grep -v "#" |awk '{print $7}'|sed 's/\/unload.sh//g'`
#                       cron=`crontab -l informix | grep unload | grep -v "#" |awk '{print $3}'`
                fi
                changedir=`find $dir -type d -a -mtime -8 -a -name '[1-7]' | wc -l`
                changedir1=`find $dir -type f -a -mtime -8 -a -name '[1-7].tar.gz' | wc -l`
                if [ $changedir -ge 1 ] || [ $changedir1 -ge 1 ];then
                        echo '0'
                else
                        echo '1'
                fi
                ;;
        *)
                echo "err"
                ;;
        esac

}
check $Check_item

