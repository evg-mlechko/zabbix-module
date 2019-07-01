#!/bin/bash
# Installing mariadb
if ! [ -d /usr/bin/mysql ]; then
yum install mariadb mariadb-server -y
/usr/bin/mysql_install_db --user=mysql
systemctl enable mariadb
systemctl start mariadb
echo 'status mariadb is: '
systemctl status mariadb
#syntax error near by quit
mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix'
quit;"
fi

# installing zabbixweb
if ! [ -d /etc/zabbix/web ]; then {
yum install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm -y
yum install zabbix-server-mysql zabbix-web-mysql -y
zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -pzabbix zabbix
}
fi

# Setting up server pwd, etc
if [ $(grep -c '/DBHost=localhost/s/^#\+//' "/etc/zabbix/zabbix_server.conf") -gt 0 ]; then
sed -i '/DBHost=localhost/s/^#\+//' "/etc/zabbix/zabbix_server.conf"
fi
if [ $(grep -c 'BPassword=zabbix' "/etc/zabbix/zabbix_server.conf") -eq 0 ]; then
sed -i 's/.*DBPassword=.*/DBPassword=zabbix/' "/etc/zabbix/zabbix_server.conf"
fi


yum install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm

# set timezone minsk
if [ $(grep -c 'php_value date.timezone Europe/Riga' "/etc/httpd/conf.d/zabbix.conf") -gt 0 ]; then
sed -i 's+.*php_value date.timezone Europe/Riga.*+php_value date.timezone Europe/Minsk+' "/etc/httpd/conf.d/zabbix.conf"
fi
systemctl start httpd
if [ $(systemctl status zabbix-server | grep -c "Active: inactive") -eq 1 ]; then
		systemctl start zabbix-server
		echo 'status zabbix server is: '
    systemctl status zabbix-server
fi

# Installing Zabbix Agent
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


# yum install zabbix-java-gateway -y
# systemctl start zabbix-java-gateway
# systemctl enable zabbix-java-gateway
