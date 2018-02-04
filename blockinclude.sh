# this is a file that shall be included in all other scripts to share the same vars

# directory where script is
EXECDIR="/jffs"

# logfile
LOGFILE="/tmp/blockinternet.log"

# list of IPs to block
BLOCKEDIPS=`cat /jffs/blockedIPs.txt`

# file that exist when we are in a blocked period
ISBLOCKEDFILE="/jffs/isblocked.txt"
