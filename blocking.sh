#!/bin/sh

# logfile
LOGFILE="/tmp/blockinternet.log"

# list of IPs to block
BLOCKEDIPS="192.168.1.12 192.168.1.32 192.168.1.236"

# file that exist when we are in a blocked period
ISBLOCKEDFILE="/jffs/isblocked.txt"

#
# Block the IPs specified in global var $BLOCKEDIPS
#
blockIPs()
{
  for blockedIP in $BLOCKEDIPS; do
    echo "$(date) Blocking $2 $blockedIP" >> $LOGFILE
    /usr/sbin/iptables -I FORWARD -s $blockedIP -j DROP
  done

  # create block file to indicate we are now blocking
  echo "$(date) Blocking internet $2" > $ISBLOCKEDFILE
}

#
# Unblock IPs
#
unblockIPs()
{

  # start with removing isblocking file
  /bin/rm $ISBLOCKEDFILE

  for blockedIP in $BLOCKEDIPS; do
    /usr/sbin/iptables -D FORWARD -s $blockedIP -j DROP
    echo "$(date) Unblocking $2 $blockedIP" >> $LOGFILE
  done

  echo "$(date) Unblocking completed " >> $LOGFILE
}


#
# Check if the IPs that are supposed to be blocked indeed are, if not block
#
checkBlockedIPs()
{
  echo "$(date) Checking blocking..." >> $LOGFILE

  # are we in a blocked period, then check if iptables rules is in place
  if [ -f "$ISBLOCKEDFILE" ]; then
    echo "$(date) We are in a blocked period" >> $LOGFILE

    for blockedIP in $BLOCKEDIPS; do
      # check if the blocked IP is defacto blocked, may well been removed by system
      STR=`/usr/sbin/iptables -L FORWARD | grep $blockedIP`
      if [ "$STR" = "" ]; then
        echo "$(date) Blocked IP " $blockedIP " not blocked by iptables while in blocked period, adding block!" >> $LOGFILE
        /usr/sbin/iptables -I FORWARD -s $blockedIP -j DROP
      fi
    done
  else
    echo "$(date) Not in a blocked period" >> $LOGFILE
    # remove any blocks there may be left, could happen if unblock/block clash 
    unblockIPs
  fi
}


#
# Scripts starts here
#

if [ "$1" = "block" ]
then
  blockIPs
elif [ "$1" = "unblock" ]
then
  unblockIPs
elif [ "$1" = "checkBlocking" ]
then
  checkBlockedIPs
else
  echo $0 " called with unknown or no argument, existing without action" >> $LOGFILE
fi
