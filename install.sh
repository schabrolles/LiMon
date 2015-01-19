#!/bin/sh
#
# Monitor Install Script 
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

[ ! -d /etc/monitor ] && sudo mkdir -p /etc/monitor
sudo cp fig.yml /etc/monitor

sudo cp monitor_rc /etc/init.d/monitor
sudo chmod 755 /etc/init.d/monitor
sudo update-rc.d monitor defaults

sudo fig -f /etc/monitor/fig.yml -p monitor up -d
