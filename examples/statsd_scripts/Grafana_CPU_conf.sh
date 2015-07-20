#!/bin/sh
#
# s.chabrolles@fr.ibm.com
#########################

STATSD_SERVER=10.3.84.51
STATSD_PORT=8125
HOSTNAME="ACG_`hostname -s`_collectd"

################################################################

SEND_CMD="nc -w1 --send-only -u ${STATSD_SERVER} ${STATSD_PORT}"


if [ -f /etc/SuSE-release ] ; then
	SEND_CMD="netcat -w1 -u ${STATSD_SERVER} ${STATSD_PORT}"
fi

SMT=`lscpu | awk '/^Thread/ { print $NF}'`
#SMT=`ppc64_cpu --smt | awk -F= '{ print $NF }'`
#CORES=`lscpu | awk '/^Core/ { CORESOCKET=$NF }; /^Socket/ { SOCKET=$NF } END { print CORESOCKET * SOCKET }'`
CORES=`/usr/sbin/ppc64_cpu --cores-on | awk '{ print $NF }'`
NUMA_NODE=`lscpu | awk ' /NUMA node\(s\)/ { print $NF}'`
FREQ=`grep -U MHz /proc/cpuinfo | sort -u | awk '{ split($NF,FREQ,".") ; print FREQ[1]}'`

echo "${HOSTNAME}.conf.cores:${CORES}|g" | $SEND_CMD
echo "${HOSTNAME}.conf.smt:${SMT}|g" | $SEND_CMD
echo "${HOSTNAME}.conf.numanode:${NUMA_NODE}|g" | $SEND_CMD
echo "${HOSTNAME}.conf.frequency:$FREQ|g" | $SEND_CMD
