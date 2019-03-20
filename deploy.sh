#!/bin/bash
#Date/time 
LOG_TIME=`date "+%H-%m-%d"`
LOG_DATE=`date "+%F-%m-%d"`
CTIME=$(date "+%H-%m-%d")   #此方法只存变量，不执行命令 用来记录打包文件的时间
CDATE=$(date "+%F-%m-%d")

#Lock file
LOCK_FILE="/tmp/deploy.lock"

#shell Env
SHELL_NAME="deploy.sh"
SHELL_DIR="/home/www"
SHELL_LOG="${SHELL_DIR}/${SHELL_NAME}.log"

#code Env
PRO_NAME="web-demo"
CODE_DIR="/deploy/code/web-demo"
CONFIG_DIR="/deploy/config/web-demo"
TMP_DIR="/deploy/tmp"
TAR_DIR="/deploy/tar"
PKG_DIR="web-demo"

# Group LIst
GROUP2_LIST="10.210.2.204"
GROUP1_LIST="10.134.96.245"


shell_lock(){
	touch $LOCK_FILE
}
shell_unlock(){
	rm -f $LOCK_FILE
}
usage(){
	echo $"Usage: $0 [ deploy | rollback ]"
}
writelog(){
	LOGINFO=$1
	echo "${DATE}  ${CTIME}: ${LOGINFO} ">>$SHELL_LOG
}
code_get(){
	writelog code_get;
	sleep 6
	cd $CODE_DIR && echo "git pull"
	cp -r ${CODE_DIR} ${TMP_DIR}
	API_VER="123"
}
code_build(){
	echo code_build
}
code_config(){
	writelog "code_config"
	/bin/cp -r $CONFIG_DIR/* $TMP_DIR/$PRO_NAME  #/bin/cp -r 防止之前有误提交的文件，直接覆盖掉
	PKG_NAME=$PRO_NAME"_"$API_VER"-"$CDATE"-"$CTIME
	cd $TMP_DIR  && touch 1&& mv $PRO_NAME $PKG_NAME
}
code_tar(){
	writelog "code_tar"
	cd $TMP_DIR && tar czf $PKG_NAME.tar.gz $PKG_NAME && mv $PKG_NAME.tar.gz $TAR_DIR/$PRO_NAME
}
code_scp(){
	for node in $GROUP1_LIST;do
		scp $TAR_DIR/$PKG_DIR/$PKG_NAME.tar.gz $node:/opt/webroot/$PKG_NAME.tar.gz
	done
	for node in $GROUP2_LIST;do
		scp $TAR_DIR/$PKG_DIR/$PKG_NAME.tar.gz $node:/opt/webroot/$PKG_NAME.tar.gz
	done
}

cluster_node_remove(){
	writelog "cluster_node_remove";
}

group1_code_deploy(){
	for node in $GROUP1_LIST;do
		ssh $node "cd /opt/webroot && tar zxf $PKG_NAME.tar.gz"		
		ssh $node "rm -rf /webroot/web-demo && ln -s /opt/webroot/$PKG_NAME /webroot/web-demo"
		scp $CONFIG_DIR/other/http.conf $node:/webroot/web-demo/http.conf
	done
}
group1_test(){
	ervice httpd restart
	curl -s --head http://10.134.96.245/index.html | grep '200 ok'
		if [ $? -ne 0 ];then
			echo "$GROUP1_LIST successed"
		else
			shell_unlock;
			exit
		fi	
}
group2_code_deploy(){
	for node in $GROUP2_LIST;do
		ssh $node "cd /opt/webroot && tar zxf $PKG_NAME.tar.gz"		
		ssh $node "rm -rf /webroot/web-demo && ln -s /opt/webroot/$PKG_NAME /webroot/web-demo"
		scp $CONFIG_DIR/other/http.conf $node:/webroot/web-demo/http.conf
	done
}
group2_test(){
	service httpd restart
	curl -s --head http://10.210.2.204/index.html | grep '200 ok'
		if [ $? -ne 0 ];then
			echo "$GROUP2_LIST successed"
		else
			shell_unlock;
			exit
		fi	
}
cluster_node_in(){
	echo clustar_mode_in
}
rollbak(){
	echo rollback
}

main(){
	if [ -f $LOCK_FILE ];then
		echo "Deploy is running" && exit;
	else
	DEPLOY_METHOD=$1
	case $DEPLOY_METHOD in 
		deploy)
			shell_lock;
			code_get;
			code_build;
			code_config;
			code_tar;
			code_scp;
			cluster_node_remove;
			group1_code_deploy;
			group1_test;
			group2_code_deploy;
			group2_test;
			cluster_node_in;
			shell_unlock;
			;;
		rollback)
			shell_lock;
			rollback;
			shell_unlock;
			;;
		*)
			usage;
	esac
       fi
}

main $1
