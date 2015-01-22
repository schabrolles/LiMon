#!/bin/sh
#
# LiMon Server Install Script 
#
#####################################################################################
# V1.0 s.chabrolles@fr.ibm.com
##################################################################################### 

echo
echo "############################################"
echo "Update ubuntu apt cache"
echo

sudo apt-get update

echo
echo "############################################"
echo "Install docker"
echo

sudo dpkg -i ./lxc-docker-1.3.1-dev_1.3.1-dev-20150109131959-dddf5c9-dirty_ppc64el.deb
sudo gpasswd -a ibmadmin docker

sudo apt-get install -y python-pip

sudo pip install -U fig 

echo
echo "############################################"
echo "Prepare Environment "
echo


[ ! -d /var/lib/elasticsearch ] && sudo mkdir -p /var/lib/elasticsearch
[ ! -d /var/lib/graphite/storage/whisper ] && sudo mkdir -p /var/lib/graphite/storage/whisper

[ ! -d /etc/LiMon ] && sudo mkdir -p /etc/LiMon
sudo cp fig.yml /etc/LiMon

sudo cp LiMon_rc /etc/init.d/LiMon
sudo chmod 755 /etc/init.d/LiMon
sudo update-rc.d LiMon defaults

echo
echo "############################################"
echo "Install debug tool nsenter"
echo

cd /tmp
curl https://www.kernel.org/pub/linux/utils/util-linux/v2.24/util-linux-2.24.tar.gz | tar -zxf-
cd util-linux-2.24
./configure --without-ncurses
make nsenter
[ $? -eq 0 ] && (echo ; echo "success" )
sudo cp nsenter /usr/local/bin
[ $? -eq 0 ] && (echo ; echo "success" )



echo
echo "############################################"
echo "LiMon Creation ............ please Wait"
echo

sudo fig -f /etc/LiMon/fig.yml -p LiMon up -d

sudo service LiMon status

echo
echo "If you are not root, please relogin to unable docker privileges"
