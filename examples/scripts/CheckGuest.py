#!/usr/bin/env python
###############################################################################
# Check KVM guest and send alert in InfluxDB when guest are
# - created, removed, started, stopped
#
# Author : s.chabrolles@fr.ibm.com
###############################################################################

import logging
import optparse
import sys
import libvirt
import time
import requests
import socket

# ######################################################
# Global Variables definition
Active = []
Inactive = []
AllDomains = []

# ######################################################
# Function definition


def main():
    """ Main Function """
    logging.debug("Entering in function")
    global Active
    global Inactive
    global AllDomains

    if check_param():
        conn = connection()
        Active = list_Active(conn)
        Inactive = conn.listDefinedDomains()
        AllDomains = Active + Inactive
        while 1:
            logging.debug("Waiting {} seconds".format(options.time))
            time.sleep(float(options.time))
            logging.debug("Checking VMs")
            checkVMs(conn)
    else:
        sys.exit(1)


def list_Active(conn):
    """ Function used to fetch active Domain names in a list """
    logging.debug("Entering in function")
    Active = []
    for i in conn.listDomainsID():
        Active.append(conn.lookupByID(i).name())
    return Active


def checkVMs(conn):
    """ Checks Active/Define VMs and compare with previous list. """
    logging.debug("Entering in function")
    global Active
    global Inactive
    global AllDomains

    HOSTNAME = options.useHostname

    New_Active = list_Active(conn)
    New_Inactive = conn.listDefinedDomains()
    New_AllDomains = New_Active + New_Inactive

    UPDATE_GUEST_NUM = 0

    logging.debug("Check for VM created")
    for VM in New_AllDomains:
        if "guestfs" in VM:
            New_AllDomains.remove(VM)
        else:
            if VM not in AllDomains:
                logging.info("New VM Created: {}".format(VM))
                InfluxDB_alert(
                    "alert_guest",
                    "guest_created",
                    "host=" + HOSTNAME + ",VM=" + VM,
                    VM + " created")
                logging.info("{} guests defined".format(len(New_AllDomains)))
                UPDATE_GUEST_NUM = 1

    logging.debug("Check for VM stoped")
    for VM in Active:
        if VM not in New_Active:
            logging.info("VM Stopped: {}".format(VM))
            InfluxDB_alert(
                "alert_guest",
                "guest_stopped",
                "host=" + HOSTNAME + ",VM=" + VM,
                VM + " stopped")
            logging.info("{} guests running".format(len(New_Active)))
            UPDATE_GUEST_NUM = 1

    logging.debug("Check for VM deleted")
    for VM in AllDomains:
        if "guestfs" in VM:
            New_AllDomains.remove(VM)
        else:
            if VM not in New_AllDomains:
                logging.info("VM Deleted: {}".format(VM))
                InfluxDB_alert(
                    "alert_guest",
                    "guest_deleted",
                    "host=" + HOSTNAME + ",VM=" + VM,
                    VM + " deleted")
                logging.info("{} guests defined".format(len(New_AllDomains)))
                UPDATE_GUEST_NUM = 1

    logging.debug("Check for VM started")
    for VM in New_Active:
        if VM not in Active:
            logging.info("VM Started: {}".format(VM))
            InfluxDB_alert(
                "alert_guest",
                "guest_started",
                "host=" + HOSTNAME + ",VM=" + VM,
                VM + " started")
            logging.info("{} guests running".format(len(New_Active)))
            UPDATE_GUEST_NUM = 1

    if UPDATE_GUEST_NUM == 1:
        DATA = "guest_num,host=" + HOSTNAME + \
            " guest_defined=" + str(len(New_AllDomains)) + \
            ",guest_running=" + str(len(New_Active))
        InfluxDB_post(
            options.influxIP,
            options.influxPORT,
            options.influxDB,
            DATA)

    Inactive = New_Inactive
    Active = New_Active
    AllDomains = New_AllDomains


def InfluxDB_post(influxIP, influxPORT, influxDB, DATA):
    """ Send data in InfluxDB """
    logging.debug("Entering in function")
    url = "http://" + str(influxIP) + ":" + str(influxPORT) + "/write?db=" + \
        str(influxDB)
    r = requests.post(url, data=DATA)
    if r.status_code is not 204:
        logging.error("[{}]: {}".format(r.status_code, r.text))
    r.close()


def InfluxDB_alert(mesurment, event, TAG, MSG):
    """ Send InfluxDB alert """
    logging.debug("Entering in function")
    DATA_HEAD = mesurment + ",event=" + event + "," + TAG
    DATA = DATA_HEAD + " message=\"" + MSG + "\""
    logging.debug(DATA)
    InfluxDB_post(
        options.influxIP,
        options.influxPORT,
        options.influxDB,
        DATA)


def check_param():
    """ Function used to check if all required parameters
        are correctly set up
    """
    logging.debug("Entering in function")
    if not options.influxIP:
        parser.error(
            "You must specify an InfluxDB IP or Hostname '-H' or '--host'"
            )

    if not options.influxDB:
        parser.error(
            "You must specify an InfluxDB DB name '-D' or '--db'"
            )

    return True


def connection():
    """ Function used to connect to the hypervisor
    """
    logging.debug("Entering in function")
    conn = libvirt.openReadOnly(None)
    if conn is None:
        logging.critical('Failed to open connection to the hypervisor')
        sys.exit(1)

    return conn


if __name__ == "__main__":

    usage = "Usage: %prog --host <InfluxDB_Hostname> --db <InfluxDB_Name>"
    parser = optparse.OptionParser(usage=usage)

    parser.add_option(
        "-t", "--time",
        dest="time",
        default=30,
        help="sleep time in (s) between each check"
    )
    parser.add_option(
        "-H", "--host",
        dest="influxIP",
        help="influxDB IP or Hostname"
    )
    parser.add_option(
        "-P", "--port",
        dest="influxPORT",
        default=8086,
        help="influxDB listen port"
    )
    parser.add_option(
        "-D", "--db",
        dest="influxDB",
        help="influxDB DB name"
    )
    parser.add_option(
        "--useHostname",
        dest="useHostname",
        default=socket.gethostname(),
        help="use to change local hostname value when writting into InfluxDB"
    )

    debug = optparse.OptionGroup(
            parser,
            "debug",
            "The following options are for debugging"
            )
    parser.add_option_group(debug)

    debug.add_option(
            "--loglevel",
            dest="loglevel",
            default="WARNING",
            help="Set logging level: CRITICAL, ERROR, WARNING, INFO, DEBUG"
            )
    options, args = parser.parse_args()

    ######################################################################
    # Logging

    numeric_level = getattr(logging, options.loglevel.upper(), None)
    if not isinstance(numeric_level, int):
            # raise ValueError('Invalid log level: %s' % options.loglevel)
            logging.error('Invalid log level: %s' % options.loglevel)
    log_format_func = '[%(levelname)s] %(funcName)s: %(message)s'
    log_format_time = '%(asctime)s [%(levelname)s] %(message)s'
    log_format_full = '%(asctime)s [%(levelname)s] %(filename)s (%(funcName)s) %(message)s'
    logging.basicConfig(
            # level=logging.INFO,
            level=numeric_level,
            # filename='/var/log/CheckGuest.log'
            format=log_format_full
            )

    ######################################################################
    # Start Main
    main()
