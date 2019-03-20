PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin		;export PATH
systeam=`uname`
if [ "${systeam}" = "Linux" ]
then
    	cronfile="/var/spool/cron/informix"
	updir="/informix/up"
else
    	cronfile="/var/spool/cron/crontabs/informix"
	updir="/up"
fi
dir=`cat $cronfile | grep -v "^#"| grep  schema|awk '{print $7}'|cut -d "/" -f 1,2,3`
dir1=`cat $cronfile | grep -v "^#"| grep  schema|awk '{print $7}'|cut -d "/" -f 1,2,3,4`
dir2=`cat $cronfile | grep -v "^#"| grep  schema|awk '{print $7}'|cut -d "/" -f 1,2,3,4,5`
dir3=`cat $cronfile | grep -v "^#"| grep  schema|awk '{print $7}'|cut -d "/" -f 1,2,3,4,5,6`
count=`ls $dir| grep schema.sh | wc -l`
count1=`ls $dir1 | grep schema.sh | wc -l`
count2=`ls $dir2 | grep schema.sh | wc -l`
count3=`ls $dir3 | grep schema.sh | wc -l`
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
real_count=`ls -al | grep schema.sh | wc -l`
if [ $real_count -eq 1 ]
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
	echo -n " **Script err****"
fi
