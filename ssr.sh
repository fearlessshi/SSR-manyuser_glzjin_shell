#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
echo
echo "#############################################################"
echo "# 一键对接SSR后端glzjinmod版本，支持Debian8+/Ubuntu16+      #"
echo "# Author: <@gmail.com>                      #"
echo "# Blog: www                                        #"
echo "#############################################################"
echo
read -p "请输入此节点在面板中的ID号: " nodeid
read -p "请输入完整面板域名/ip地址（例如https://www.94ish.me）: " host
read -p "请输入modwebapi验证密钥: " pass
read -p "请输入MYSQL_HOST: " MYSQL_HOST
read -p "请输入MYSQL_PORT : " MYSQL_PORT
read -p "请输入MYSQL_USER  : " MYSQL_USER
read -p "请输入MYSQL_PASS  : " MYSQL_PASS
read -p "请输入MYSQL_DB  : " MYSQL_DB
read -p "请输入测速时间间隔（默认6）：" speedtest
if [ -z "${speedtest}" ];then  
    speedtest=6 
fi
echo "开始部署"
sleep 2s
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
cd /root
apt-get update
apt-get -y install build-essential wget python-dev libffi-dev openssl python-pip libssl-dev zip unzip git
wget https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz #备用 wget http://sources.voidlinux.eu/libsodium-1.0.16/libsodium-1.0.16.tar.gz
tar xf libsodium-1.0.16.tar.gz && cd libsodium-1.0.16
./configure && make -j2 && make install
echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
ldconfig
cd .. && rm -f libsodium-1.0.16.tar.gz && rm -rf libsodium-1.0.16
apt -y install python-setuptools && easy_install pip && apt update && apt install git -y
git clone -b manyuser https://github.com/fearlessshi/shadowsocks.git
cd shadowsocks
pip install --upgrade setuptools
pip install -r requirements.txt
cp apiconfig.py userapiconfig.py
cp config.json user-config.json
chmod +x *.sh
echo "# Config
NODE_ID = ${nodeid}


# hour,set 0 to disable
SPEEDTEST = ${speedtest}
CLOUDSAFE = 1
ANTISSATTACK = 0
AUTOEXEC = 0

MU_SUFFIX = 'zhaoj.in'
MU_REGEX = '%5m%id.%suffix'
MULTI_THREAD = 1
SERVER_PUB_ADDR = '127.0.0.1'  # mujson_mgr need this to generate ssr link
API_INTERFACE = 'glzjinmod'  # glzjinmod, modwebapi

WEBAPI_URL = '${host}'
WEBAPI_TOKEN = '${pass}'

# mudb
MUDB_FILE = 'mudb.json'

# Mysql
MYSQL_HOST = '${MYSQL_HOST}' 
MYSQL_PORT = ${MYSQL_PORT}
MYSQL_USER = '${MYSQL_USER}'
MYSQL_PASS = '${MYSQL_PASS}'
MYSQL_DB = '${MYSQL_DB}'

MYSQL_SSL_ENABLE = 0
MYSQL_SSL_CA = ''
MYSQL_SSL_CERT = ''
MYSQL_SSL_KEY = ''

# API
API_HOST = '127.0.0.1'
API_PORT = 80
API_PATH = '/mu/v2/'
API_TOKEN = 'abcdef'
API_UPDATE_TIME = 60

# Manager (ignore this)
MANAGE_PASS = 'ss233333333'
# if you want manage in other server you should set this value to global ip
MANAGE_BIND_IP = '127.0.0.1'
# make sure this port is idle
MANAGE_PORT = 23333

# Safety
IP_MD5_SALT = 'randomforsafety'" > /root/shadowsocks/userapiconfig.py
apt-get install supervisor -y
echo "[program:ssr]
command=python /root/shadowsocks/server.py 
autorestart=true
autostart=true
user=root" > /etc/supervisor/conf.d/ssr.conf
echo "ulimit -n 1024000" >> /etc/default/supervisor
/etc/init.d/supervisor restart
echo -e "8.8.8.8 53
8.8.4.4 53" > /root/shadowsocks/dns.conf
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
supervisorctl restart ssr


echo "恭喜您!与SS-Panel-V3 mod对接完成!"
echo "查看日志:supervisorctl tail -f ssr stderr"
