!/bin/sh

source /jffs/blockinclude.sh

echo "$(date) Checking blocking..." >> $LOGFILE

# are we in a blocked period, then check if iptables rules is in place
if [ -f "$ISBLOCKEDFILE" ]; then

  #echo "$(date) We are in a blocked period" >> $LOGFILE

  for blockedIP in $BLOCKEDIPS; do

    # check if the blocked IP is defacto blocked
    STR=`/usr/sbin/iptables -L FORWARD | grep $blockedIP`
    if [ "$STR" = "" ]; then
      echo "$(date) Blocked IP " $blockedIP " not blocked by iptables while in blocked period, adding block!" >> $LOGFILE
      /usr/sbin/iptables -I FORWARD -s $blockedIP -j DROP
    fi
  done
else
  echo "$(date) Not in a blocked period" >> $LOGFILE
fi
