PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin		;export PATH
systeam=`uname`
if [ "${systeam}" = "Linux" ]
then
    	cronfile="/var/spool/cron/root"
	updir="/root/up"
else
    	cronfile="/var/spool/cron/crontabs/root"
	updir="/up"
fi
dir=`cat $cronfile | grep -v "^#"| grep  osbak|awk '{print $7}'|cut -d "/" -f 1,2`
dir1=`cat $cronfile | grep -v "^#"| grep  osbak|awk '{print $7}'|cut -d "/" -f 1,2,3`
dir2=`cat $cronfile | grep -v "^#"| grep  osbak|awk '{print $7}'|cut -d "/" -f 1,2,3,4`
dir3=`cat $cronfile | grep -v "^#"| grep  osbak|awk '{print $7}'|cut -d "/" -f 1,2,3,4,5`
count=`ls $dir| grep osbak.sh | wc -l`
count1=`ls $dir1 | grep osbak.sh | wc -l`
count2=`ls $dir2 | grep osbak.sh | wc -l`
count3=`ls $dir3 | grep osbak.sh | wc -l`
if [ $count -eq 1 ]
then 
	right_dir=$dir
elif [ $count1 -eq 1 ]
then 
	right_dir=$dir1
elif [ $count2 -eq 1 ]
then 
	right_dir=$dir2
else
	right_dir=$dir3
fi
cd $right_dir
up_count=`ls -al | grep up.sh | wc -l`
if [ $up_count -eq 1 ]
then
	ls -al;
	tput bold
	echo ""
	echo ""
	echo -n "Any key to countiu"
	echo ""
	echo ""
	tput sgr0
	read n 
	vi up.sh;chmod +x up.sh;. ./up.sh
else
	echo ""
	echo ""
	echo -n "****getting up.sh****"
	echo ""
	echo ""
	ftp -n -i <<!
	open 10.134.96.245
	user root root123
        cd $updir/osbak
        get up.sh
        bye
!
fi
