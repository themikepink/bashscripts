#!/bin/bash

echo "Enter a domain (e.g. dev.example.com):";
read domain;
echo ""
echo "Enter file location (e.g. dnx/myproject):"
read folder;
echo ""

if [[ ! -e /etc/apache2/sites-available/${domain}.vhost.conf ]]; then
		
echo "		
<VirtualHost *:80>
    DocumentRoot "/Users/mikepink/Documents/Sites/vagrant-lamp/public/${folder}"
    ServerName ${domain}
    ErrorLog "/private/var/log/apache2/${domain}-error_log"
    CustomLog "/private/var/log/apache2/${domain}-access_log" common
  <Directory "/Users/mikepink/Documents/Sites/vagrant-lamp/public/${folder}">
    Options FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>
</VirtualHost>" >> /etc/apache2/sites-available/${domain}.vhost.conf

ln -s /etc/apache2/sites-available/${domain}.vhost.conf /etc/apache2/sites-enabled/${domain}.vhost.conf

		echo "${domain} created"
        echo "Testing configuration"
        apachectl configtest
        echo "Would you like me to restart the server? (y/n)"
        read q
        if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
                apachectl restart
        fi		
			
else
		echo "${domain} already exists"	
fi