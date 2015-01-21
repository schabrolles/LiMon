#!/bin/sh
#
# MoniC Server Install Script 
#
#####################################################################################
# V1.0 s.chabrolles@fr.ibm.com
##################################################################################### 

sudo apt-get update

sudo dpkg -i ./lxc-docker-1.3.1-dev_1.3.1-dev-20150109131959-dddf5c9-dirty_ppc64el.deb
sudo gpasswd -a ibmadmin docker

sudo apt-get install -y python-pip

sudo pip install -U fig 

[ ! -d /var/lib/elasticsearch ] && sudo mkdir -p /var/lib/elasticsearch

[ ! -d /etc/MoniC ] && sudo mkdir -p /etc/MoniC
sudo cp fig.yml /etc/MoniC

sudo cp MoniC_rc /etc/init.d/MoniC
sudo chmod 755 /etc/init.d/MoniC
sudo update-rc.d MoniC defaults

sudo fig -f /etc/MoniC/fig.yml -p MoniC up -d
