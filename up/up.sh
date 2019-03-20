systeam=`uname`
if [ "${systeam}" = "Linux" ]
then
	cronfile="/var/spool/cron"
	up_dir="/root/up"
else
	cronfile="/var/spool/cron/crontabs"
	up_dir="/up"
fi
echo "$systeam"
echo "enter your choice"
echo ""
PS3=" >Ctrl + c to exit < " ; export PS3
select number in "osbak up" "schemabak up" "unload up" "root crontab -e" "informix crontab -e" 
do
  case $number in
    "osbak up"). "$up_dir"/osbakup.sh;;
    "schemabak up"). "$up_dir"/schemabak.sh;;
    "unload up"). "$up_dir"/unloadup.sh;;
    "root crontab -e") vi "$cronfile"/root;;
    "informix crontab -e") vi "$cronfile"/informix;;
  esac
done

