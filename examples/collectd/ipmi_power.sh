#!/bin/sh
#
# s.chabrolles@fr.ibm.com
#########################
ipmitool sensor | awk -F\| '/Watts/{ gsub(" ",""); print $1"="$2 }' > /tmp/power.out
