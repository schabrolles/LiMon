#!/bin/sh
#
# s.chabrolles@fr.ibm.com
#########################

SMT=`lscpu | awk '/^Thread/ { print $NF}'`
#SMT=`ppc64_cpu --smt | awk -F= '{ print $NF }'`
#CORES=`lscpu | awk '/^Core/ { CORESOCKET=$NF }; /^Socket/ { SOCKET=$NF } END { print CORESOCKET * SOCKET }'`
CORES=`/usr/sbin/ppc64_cpu --cores-on | awk '{ print $NF }'`
NUMA_NODE=`lscpu | awk ' /NUMA node\(s\)/ { print $NF}'`
FREQ=`grep -U MHz /proc/cpuinfo | sort -u | awk '{ split($NF,FREQ,".") ; print FREQ[1]*1000000}'`

echo "SMT=$SMT
CORES=$CORES
NUMA_NODE=$NUMA_NODE
FREQ=$FREQ" > /var/log/machine.conf
