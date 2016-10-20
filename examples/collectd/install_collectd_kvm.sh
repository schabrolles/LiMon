#!/bin/ksh
#
# s.chabrolles@fr.ibm.com
#############################################

yum --enablerepo epel install -y collectd collectd-sensors collectd-virt

semodule -i mypol.pp
semodule -i collectd_zswap.pp

cp 01_collectd.conf 02_sensors.conf /etc/collectd.d

systemctl enable collectd
systemctl start collectd
