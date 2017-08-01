#!/bin/sh
#
# LiMon Server Install Script
#
#####################################################################################
# v1.0 s.chabrolles@fr.ibm.com
# v1.5 Added mutli-arch (x86_64 ppc64le) support
# v2.0 migrate to grafana 2.0 and ubuntu 15.04
# v3.0 migrate to grafana 3.0 and ubuntu 16.04
# v3.1 migrate to grafana 3.1 and add influxdb 0.13.0
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

#	ppc64le) sudo cp docker.list /etc/apt/sources.list.d && sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y install ntp docker.io --force-yes
	ppc64le) sudo apt-get -y install ntp docker.io --force-yes
	;;

	*) echo "Arch $SYS_ARCH not supported"
	exit 1
	;;
esac

sudo gpasswd -a $USER docker
sudo systemctl enable docker
sudo systemctl start docker


sudo apt-get install -y python-pip python-whisper
sudo -H pip install --upgrade pip
sudo -H pip install -U setuptools
sudo -H pip install -U docker-compose

echo
echo "############################################"
echo "Prepare Environment "
echo


[ ! -d /var/lib/grafana/dashboards ] && sudo mkdir -p /var/lib/grafana/dashboards
[ ! -d /var/lib/grafana/data/plugins ] && sudo mkdir -p /var/lib/grafana/data/plugins
[ ! -d /var/lib/grafana/data/log ] && sudo mkdir -p /var/lib/grafana/data/log
[ -f grafana.db ] && sudo cp -rp grafana.db /var/lib/grafana

[ ! -d /var/lib/graphite/storage/whisper ] && sudo mkdir -p /var/lib/graphite/storage/whisper
[ ! -d /var/lib/graphite/storage/log/webapp ] && sudo mkdir -p /var/lib/graphite/storage/log/webapp

sudo tar -C /var/lib -zxvf influxdb.tar.gz

[ ! -d /etc/LiMon ] && sudo mkdir -p /etc/LiMon
sudo cp docker-compose.yml_${SYS_ARCH} /etc/LiMon/docker-compose.yml

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

sudo docker-compose -f /etc/LiMon/docker-compose.yml up -d

sudo service LiMon status

echo
echo "Installation complete. open a browser and connect to your server IP with http://<your_server_ip>"

echo
echo "If you are not root, please relogin to unable docker privileges"
