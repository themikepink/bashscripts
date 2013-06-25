#!/bin/bash
if [ `whoami` != root ]; then
    echo Please run this script as root or using sudo
    exit
fi

echo "Enter a domain (e.g. dev.example.com):";
read domain;
echo ""

### Check to see if $domain exists
if [[ -e /etc/apache2/sites-available/${domain}.vhost.conf ]]; then

    echo "Permenantly delete? (y/n)";
    read delete;
    echo ""

    rm /etc/apache2/sites-enabled/${domain}.vhost.conf
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