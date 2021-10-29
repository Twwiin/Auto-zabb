#!/bin/bash
# Timezone set
timedatectl set-timezone Asia/Almaty
dnf install chrony
systemctl enable chronyd --now
# Firewall open ports
firewall-cmd --permanent --add-port={80/tcp,443/tcp,10051/tcp,10050/tcp,10051/udp,10051/udp}
firewall-cmd --reload
# Off the SElinux
setenforce 0 #now session off
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config #permanent off
# Setup server Database manage
dnf install mariadb-server
systemctl enable mariadb --now
mysqladmin -u root password
# Setup Web-server
dnf install nginx
systemctl enable nginx --now
# Pause. OPEN http://<IP>/
read -p "Please open site to test nginx http://<IP>/ "
# Setup PHP and PHP-FPM
dnf install php php-fpm php-mysqli
# Pause.
sudo chmod 777 /etc/php.ini
read -p "Do   vi /etc/php.ini - date=Asia/Almaty, max_ext=300, post=16M, input=300"
# Start PHP-FPM
systemctl enable php-fpm --now
# Pause.
sudo chmod /etc/nginx/nginx.conf
read -p "Do   vi /etc/nginx/nginx.conf -> http-server add location ~ \..php$ (and  many arguments)"
# Settings check for nginx
nginx -t
systemctl restart nginx
# Pause.
sudo chmod 777 /usr/share/nginx/html
read -p "Do   vi /usr/share/nginx/html/index.php add <?php phpinfo(); ?>"
# Pause.
read -p "Open http://<IP>/"
# Download and install Zabbix
dnf install https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
dnf install zabbix-server-mysql zabbix-web-mysql zabbix-agent zabbix-get
# Setting up Database
read -p "Do   CREATE ALL PRIVILEGES ON zabbix.* TO zabbix@localhost IDENTIFIED BY 'zabbixpassword';"
mysql -uroot -p
# Settings a little bit more
cd /usr/share/doc/zabbix-server-mysql
gunzip create.sql.gz
mysql -u root -p zabbix < create.sql
# Setting up zabbix. Pause.
read -p "Do   vi /etc/zabbix/zabbix_server.conf add DBPassword=zabbixpassword and check DBName=zabbix, DBUser=zabbix"
# Owner setup
chown apache:apache /etc/zabbix/web
# Auto-run monitoring and run
systemctl enable zabbix-server --now
# Pause.
read -p "Do   vi /etc/nginx/nginx.conf and redact root=/usr/share/zabbix;,set $root_path /usr/share/zabbix;"
# Start nginx
systemctl restart nginx
# Add Russian UI
dnf install glibc-langpack-ru
# Pause.
read -p "END OF THE SCRIPT. Please install zabbix-agent and set UI to russian"
