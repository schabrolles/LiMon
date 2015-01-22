#!/bin/sh
#
# LiMon Server Install Script 
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

[ ! -d /etc/LiMon ] && sudo mkdir -p /etc/LiMon
sudo cp fig.yml /etc/LiMon

sudo cp LiMon_rc /etc/init.d/LiMon
sudo chmod 755 /etc/init.d/LiMon
sudo update-rc.d LiMon defaults

sudo fig -f /etc/LiMon/fig.yml -p LiMon up -d
