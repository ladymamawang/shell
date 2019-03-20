PATH=$PATH:$HOME/bin

export PATH
unset USERNAME

sys=`uname`
if [ $sys = 'Linux' ];then
                        
	dir=`crontab -l -u informix | grep unload | grep -v "#" |awk '{print $7}' | sed 's/\/unload.sh//g'`
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

