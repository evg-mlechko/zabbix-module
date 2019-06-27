#!/bin/bash

if ! [ -d /usr/bin/mysql/mysql_install_db ]; then
yum install mariadb mariadb-server -y
/usr/bin/mysql_install_db --user=mysql
systemctl enable mariadb
systemctl restart mariadb
echo 'status mariadb is: '
systemctl status mariadb
mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin; grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix'; quit;"
fi
echo 'mariadb has installed'

if ! [ -d /etc/zabbix/web ]; then {
yum install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm -y
yum install zabbix-server-mysql zabbix-web-mysql -y
zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -pzabbix zabbix
if [ $(grep -c '/DBHost=localhost/s/^#\+//' "/etc/zabbix/zabbix_server.conf") -gt 0 ]; then
sed -i '/DBHost=localhost/s/^#\+//' "/etc/zabbix/zabbix_server.conf"
fi

if [ $(grep -c 'BPassword=zabbix' "/etc/zabbix/zabbix_server.conf") -eq 0 ]; then
sed -i 's/.*DBPassword=.*/DBPassword=zabbix/' "/etc/zabbix/zabbix_server.conf"
fi
echo'status zabbix server is: '
systemctl status zabbix-server
}
fi


# set timezone minsk
if [ $(grep -c 'php_value date.timezone Europe/Riga' "/etc/httpd/conf.d/zabbix.conf") -gt 0 ]; then
sed -i 's+.*php_value date.timezone Europe/Riga.*+php_value date.timezone Europe/Minsk+' "/etc/httpd/conf.d/zabbix.conf"
fi
if [ $(systemctl status httpd | grep -c "Active: inactive") -eq 1 ]; then
		systemctl start httpd
		echo 'httpd server started, status is:'
    systemctl status httpd
fi
