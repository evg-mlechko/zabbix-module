#!/bin/bash

# Installation Java
yum install -y java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64
if [ -d /etc/zabbix/zabbix_agentd.d ]; then
echo 'installed'
fi

# installation Nginx
if ! [ -d /etc/nginx ]; then
yum install nginx -y
sed -i 's-.*:80 .*--' /etc/nginx/nginx.conf
sed -i '/llisten       80 default_server;/a return 301 http://$host:8080/sample;' /etc/nginx/nginx.conf
systemctl enable nginx
systemctl restart nginx
echo 'status nginx is: '
systemctl status nginx
fi
echo 'nginx has installed'
sleep 5

# Installing tomcat
if ! [ -d /opt/tomcat ]; then
yum install wget -y
wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-8/v8.5.42/bin/apache-tomcat-8.5.42.tar.gz
tar -xzvf apache-tomcat-8.5.42.tar.gz -C /opt
cd /opt
mv apache-tomcat-8.5.42 tomcat
groupadd tomcat
useradd -g tomcat -d /opt/tomcat -s /bin/nologin tomcat
chown -R tomcat:tomcat /opt/tomcat/
cp -f /vagrant/tomcat.service /etc/systemd/system/tomcat.service
cp /vagrant/sample.war /opt/tomcat/webapps
cp /vagrant/setenv.sh /opt/tomcat/bin/
systemctl enable tomcat
systemctl restart tomcat
fi
echo 'tomcat has installed'
sleep 5

# Zabbix agent installation
if ! [ -d /etc/zabbix/zabbix_agentd.d ]; then
yum install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm -y
yum install zabbix-agent -y
# Server "zabbix_agentd.conf" set-up IP
if [ $(grep -c 'ServerActive=192.168.18.70' "/etc/zabbix/zabbix_agentd.conf") -eq 0 ]; then
sed -i 's/.*ServerActive=.*/ServerActive=192.168.18.70/' "/etc/zabbix/zabbix_agentd.conf"
fi
if [ $(grep -c 'Server=192.168.18.70' "/etc/zabbix/zabbix_agentd.conf") -eq 0 ]; then
sed -i 's/.*Server=127.*/Server=192.168.18.70/' "/etc/zabbix/zabbix_agentd.conf"
fi
fi

systemctl enable zabbix-agent
systemctl restart zabbix-agent
echo 'status zabbix agent is:'
systemctl status zabbix-agent
sleep 5


yum -y install python-pip
pip install requests
pip install simplejson requests

python /vagrant/zabbix_api.py
