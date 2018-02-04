#!/bin/sh

#
# Place this script in the /jffs directory
# chmod 755 blocking.sh
#

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
  # create block file to indicate we are now blocking
  echo "$(date) Blocking internet $2" > $ISBLOCKEDFILE

  for blockedIP in $BLOCKEDIPS; do
    # check if the blocked IP is defacto blocked
    STR=`/usr/sbin/iptables -vL FORWARD | grep $blockedIP`
    if [ "$STR" = "" ]; then
      /usr/sbin/iptables -I FORWARD -s $blockedIP -j DROP
      echo "$(date) Blocked IP " $blockedIP $2  >> $LOGFILE
    else
      echo "$(date) Blocked IP stats:" $STR  >> $LOGFILE
    fi
  done

  #echo "$(date) Blocking completed " >> $LOGFILE
}


#
# Unblock IPs
#
unblockIPs()
{

  # start with removing isblocking file
  /bin/rm $ISBLOCKEDFILE

  for blockedIP in $BLOCKEDIPS; do
    STR=`/usr/sbin/iptables -L FORWARD | grep $blockedIP`
    if [ "$STR" != "" ]; then
      /usr/sbin/iptables -D FORWARD -s $blockedIP -j DROP
      echo "$(date) Unblocking $2 $blockedIP $STR " >> $LOGFILE
    fi
  done

  #echo "$(date) Unblocking completed " >> $LOGFILE
}


#
# Check if the IPs that are supposed to be blocked indeed are, if not block
#
checkBlockedIPs()
{
  #echo "$(date) Checking blocking..." >> $LOGFILE

  if [ -f "$ISBLOCKEDFILE" ]; then
    #echo "$(date) We are in a blocked period" >> $LOGFILE
    blockIPs
  else
    #echo "$(date) Not in a blocked period" >> $LOGFILE
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
