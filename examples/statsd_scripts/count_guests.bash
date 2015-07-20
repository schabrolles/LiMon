#!/bin/bash

STATSD_SERVER=10.3.70.179
#HOSTNAME=paimpolKVM

ACTIVE_GUEST=$(($(virsh list --name | wc -l) - 1))
#echo "PUTVAL \"$HOSTNAME/Guests/active_guest\" interval=$INTERVAL N:$ACTIVE_GUEST"
echo "${HOSTNAME}.guests.active:${ACTIVE_GUEST}|g" | nc -w1 --send-only -u $STATSD_SERVER 8125

TOTAL_GUEST=$(($(virsh list --name --all | wc -l) - 1))
#echo "PUTVAL \"$HOSTNAME/Guests/total_guest\" interval=$INTERVAL N:$TOTAL_GUEST"
echo "${HOSTNAME}.guests.total:${TOTAL_GUEST}|g" | nc -w1 --send-only -u $STATSD_SERVER 8125
