bashscripts
===========

#### dovhost.sh

Adds and removed virtual hosts (including domains from your hosts file)

Configured for sites-available / sites-enabled apache setup

##### Commands

###### Add a new virtual host

`sudo dovhost.sh add`

###### Delete a virtual host

You have the option to delete permenantly or not

`sudo dovhost.sh delete`

###### Enable virtual host

Re-enables a virtual host that hasn't been permenantly deleted

`sudo dovhost.sh enable`

###### List all enabled virtual hosts

`sudo dovhost.sh list enabled`

###### List all available virtual hosts

`sudo dovhost.sh list available`

##### Adding to your zsh / bash

Add the following to your .zshrc file

`export PATH=$PATH:~/scripts`
`alias dovhost="sudo dovhost.sh"`
