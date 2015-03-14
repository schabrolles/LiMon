#!/bin/sh
#
# LiMon Server Install Script 
#
#####################################################################################
# v1.0 s.chabrolles@fr.ibm.com
# v1.5 Added mutli-arch (x86_64 ppc64le) support
##################################################################################### 

. /etc/os-release

if [ "$ID" != "ubuntu" ] ; then
	echo "This Version of LiMon was only packged/tested on ubuntu"
	exit 1
fi

SYS_ARCH=`uname -m`

#####################################################################################

echo
echo "############################################"
echo "Update ubuntu apt cache"
echo

sudo apt-get update
sudo apt-get install -y curl

echo
echo "############################################"
echo "Install docker"
echo

USER=`whoami`

case $SYS_ARCH in 
	x86_64) curl -sSL https://get.docker.com/ubuntu/ | sudo sh
	;;
	
	ppc64le) sudo dpkg -i ./docker.io-1.4.1-dev_ppc64el.deb
	;;
	
	*) echo "Arch $SYS_ARCH not supported" 
	exit 1
	;;
esac

sudo gpasswd -a $USER docker

sudo apt-get install -y python-pip python-whisper
sudo pip install -U fig 

echo
echo "############################################"
echo "Prepare Environment "
echo


[ ! -d /var/lib/elasticsearch ] && sudo mkdir -p /var/lib/elasticsearch
[ ! -d /var/lib/graphite/storage/whisper ] && sudo mkdir -p /var/lib/graphite/storage/whisper

[ ! -d /etc/LiMon ] && sudo mkdir -p /etc/LiMon
sudo cp fig.yml_${SYS_ARCH} /etc/LiMon/fig.yml

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
echo "Installation complete. open a browser and connect to your server IP with http://<your_server_ip>"

echo
echo "If you are not root, please relogin to unable docker privileges"
