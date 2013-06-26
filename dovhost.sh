#!/bin/bash

### Check if we are running as a superuser
if [ `whoami` != root ]; then
    echo Please run this script as root or using sudo
    exit
fi

### Check if we have a valid command
if [ ! "$1" ]; then
    echo "dovhost.sh [add|delete|enable|list]"
    exit
fi

### List virtual hosts (available and enabled)
if [[ "$1" = "list" ]]; then
    ### List enabled hosts
    if [[ "$2" = "enabled" ]]; then
        DIR="/etc/apache2/sites-enabled"
        SUFFIX="vhost.conf"
        for i in "$DIR"/*
        do
            echo ${i%%.$SUFFIX} |sed 's#^.*/##'
        done
        exit
    fi
    ### List available hosts
    if [[ "$2" = "available" ]]; then
        DIR="/etc/apache2/sites-available"
        SUFFIX="vhost.conf"
        for i in "$DIR"/*
        do
            echo ${i%%.$SUFFIX} |sed 's#^.*/##'
        done
        exit
    fi
    ### No list type selected
    echo "dovhost.sh list [enabled|available]"
    exit
fi

### Collect the domain we want to use as a virtual host
echo "Enter a domain (e.g. dev.example.com):";
read domain;
echo ""

### Add new virtual host
if [ "$1" = "add" ]; then

    ### Collect directory information
    echo "Enter file location (e.g. mydir/myproject):"
    read folder;
    echo ""

    ### Does this exist already?
    if [[ ! -e /etc/apache2/sites-available/${domain}.vhost.conf ]]; then

### Virtual host template - write to file
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

        ### Create symbolic link in enabled directory
        ln -s /etc/apache2/sites-available/${domain}.vhost.conf /etc/apache2/sites-enabled/${domain}.vhost.conf

        echo "${domain} created"

        ### Check to see if this domain exists in the host file - if not add it
        if ! grep "${domain}" /etc/apache2/httpd.conf >> /dev/null; then
            echo "127.0.0.1 ${domain}" >> /etc/hosts
            echo "Host file updated"
        else
            echo "Already in hosts"
        fi

        echo "Testing configuration"
        apachectl configtest
        ### Restart apache?
        echo "Would you like me to restart the server? (y/n)"
        read q
        if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
            apachectl restart
        fi

    else
        echo "${domain} already exists"
    fi

fi

### Enable a virtual host that already has a conf file in sites-available
if [ "$1" = "enable" ]; then
    if [[ -e /etc/apache2/sites-available/${domain}.vhost.conf ]]; then
        if [[ -e /etc/apache2/sites-enabled/${domain}.vhost.conf ]]; then
            echo "${domain} already enabled"
            exit
        fi
        ### Create symbolic link in enabled directory
        ln -s /etc/apache2/sites-available/${domain}.vhost.conf /etc/apache2/sites-enabled/${domain}.vhost.conf
        echo "Site enabled"

        ### Check to see if this domain exists in the host file - if not add it
        if ! grep "${domain}" /etc/apache2/httpd.conf >> /dev/null; then
            echo "127.0.0.1 ${domain}" >> /etc/hosts
            echo "Host file updated"
        else
            echo "Already in hosts"
        fi

        echo "Would you like me to restart the server? (y/n)"
        read q
        if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
            apachectl restart
        fi
    else
        echo "${domain} not found"
    fi
fi

### Delete virtual host from sites enabled
if [ "$1" = "delete" ]; then

    ### Check to see if $domain exists
    if [[ -e /etc/apache2/sites-available/${domain}.vhost.conf ]]; then

        echo "Permenantly delete? (y/n)";
        read delete;
        echo ""

        if [[ -e /etc/apache2/sites-enabled/${domain}.vhost.conf ]]; then
            rm /etc/apache2/sites-enabled/${domain}.vhost.conf
        fi

        if grep "${domain}" /etc/hosts >> /dev/null; then
            echo "deleting from host file"
            sed -i.bak "/${domain}/d" /etc/hosts
        fi

        ### Delete from sites-available and hosts file is permenantly delete
        if [[ "${delete}" == "yes" ]] || [[ "${delete}" == "y" ]]; then
            rm /etc/apache2/sites-available/${domain}.vhost.conf
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



