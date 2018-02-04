#!/bin/sh

#
# This file shall be executed when the router is booted
# Stick it into /jffs to survive boot and make it run at boot by:
# nvram set jffs2_exec="/jffs/bootexec.sh"
# nvram commit
# 


# logfile
LOGFILE="/tmp/blockinternet.log"

# file that exist when we are in a blocked period
ISBLOCKEDFILE="/jffs/isblocked.txt"

# note that we re-booted
echo "$(date) Boot, adding cron job to block internet " >> $LOGFILE

# check if internet was blocked when we went down, if so re-block
if [ -f $ISBLOCKEDFILE ]; then
  /jffs/blocking.sh block restore_block_at_boot
fi

# update cron to block/unblock per schedule below
/usr/sbin/cru a unblockweekdays "30 19 * * 1-4 /jffs/blocking.sh unblock weekday"
/usr/sbin/cru a blockweekdays "0 21 * * 1-4 /jffs/blocking.sh block weekday"
/usr/sbin/cru a unblockfri "0 16 * * 5 /jffs/blocking.sh unblock Friday"
/usr/sbin/cru a blockfri "0 1 * * 6 /jffs/blocking.sh block Friday"
/usr/sbin/cru a unblocksat "0 17 * * 6 /jffs/blocking.sh unblock Saturday"
/usr/sbin/cru a blocksat "0 1 * * 0 /jffs/blocking.sh block Saturday"
/usr/sbin/cru a unblocksun "0 17 * * 0 /jffs/blocking.sh unblock Sunday"
/usr/sbin/cru a blocksun "0 21 * * 0 /jffs/blocking.sh block Sunday"

# add watchdog every minute, this is because the router seems to flush/reset iptables at some frequent / random (?) interval
/usr/sbin/cru a blockwatchdog "*/1 * * * * /jffs/blocking.sh checkBlocking"

# report completion
echo "$(date) Boot (/jfss/bootexec.sh), completed normally " >> $LOGFILE
