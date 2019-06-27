#!/bin/bash

if ! [ -d /etc/nginx ]; then
yum install nginx -y
sed -i 's-.*:80 .*--' /etc/nginx/nginx.conf
systemctl enable nginx
systemctl restart nginx
echo 'status nginx is: '
systemctl status nginx
fi
echo 'nginx has installed'

if ! [ -d /etc/tomcat ]; then
yum install tomcat -y
sudo yum install tomcat-webapps tomcat-admin-webapps -y
systemctl enable tomcat
systemctl restart tomcat
echo 'status tomcat is: '
systemctl status tomcat
fi
echo 'tomcat has installed'

if ! [ -d /etc/zabbix/zabbix_agentd.d ]; then
yum install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm -y
yum install zabbix-agent -y
if [ $(grep -c 'ServerActive=192.168.18.70' "/etc/zabbix/zabbix_agentd.conf") -eq 0 ]; then
sed -i 's/.*ServerActive=.*/ServerActive=192.168.18.70/' "/etc/zabbix/zabbix_agentd.conf"
fi
if [ $(grep -c 'Server=192.168.18.70' "/etc/zabbix/zabbix_agentd.conf") -eq 0 ]; then
sed -i 's/.*Server=127.*/Server=192.168.18.70/' "/etc/zabbix/zabbix_agentd.conf"
fi

systemctl enable zabbix-agent
systemctl restart zabbix-agent
echo 'status zabbix agent is: '
systemctl status zabbix-agent
fi
echo 'zabbix agent has installed'
