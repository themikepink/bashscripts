#!/bin/bash
if [ `whoami` != root ]; then
    echo Please run this script as root or using sudo
    exit
fi

if [ ! "$1" ]; then
    echo "createhost.sh [add|delete]"
    exit
fi

echo "Enter a domain (e.g. dev.example.com):";
read domain;
echo ""

if [ "$1" = "add" ]; then

    echo "Enter file location (e.g. mydir/myproject):"
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

        if ! grep "${domain}" /etc/apache2/httpd.conf >> /dev/null; then
            echo "127.0.0.1 ${domain}" >> /etc/hosts
            echo "Host file updated"
        else
            echo "Already in hosts"
        fi

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

fi

if [ "$1" = "delete" ]; then

    ### Check to see if $domain exists
    if [[ -e /etc/apache2/sites-available/${domain}.vhost.conf ]]; then

        echo "Permenantly delete? (y/n)";
        read delete;
        echo ""

        rm /etc/apache2/sites-enabled/${domain}.vhost.conf
        if [[ "${delete}" == "yes" ]] || [[ "${delete}" == "y" ]]; then
            rm /etc/apache2/sites-available/${domain}.vhost.conf

            if grep "${domain}" /etc/hosts >> /dev/null; then
                echo "deleting from host file"
                sed -i.bak "/${domain}/d" /etc/hosts
            fi

        fi
        echo "Virtual host deleted"
        echo "Would you like me to restart the server? (y/n)"
        read q
        if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
                apachectl restart
        fi
    else
        echo "${domain} not found"
    fi

fi
