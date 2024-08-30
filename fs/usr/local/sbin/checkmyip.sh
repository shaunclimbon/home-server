#!/bin/bash

# Suggested crontab entry:
# */5 *   * * *   root    /usr/local/sbin/checkmyip.sh >/dev/null 2>&1

file="/var/local/myip.dat"
ramfile="/tmp/myip.dat"
SEND_IP=0

# Get current WAN IP
if IP_NOW=$(dig +short myip.opendns.com @resolver1.opendns.com); then
  # Check for some unexpected non-IP value
  if ! [[ $IP_NOW =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then exit 2; fi
else
  # Failed to get IP
  exit 1
fi

# Compare to saved value
if [ -e $ramfile ]; then
  # ram value found
  IP_SAVED=$(cat $ramfile)
  if [ "$IP_NOW" != "$IP_SAVED" ]; then SEND_IP=1; fi
else
  # no ram value
  if [ -e $file ]; then
    # disk value found
    IP_SAVED=$(cat $file)
    if [ "$IP_NOW" != "$IP_SAVED" ]; then
      SEND_IP=1
    else
      # add ram value
       sudo echo $IP_NOW > $ramfile
    fi
  else
    # do disk value found
    SEND_IP=1
  fi
fi

if [ $SEND_IP -eq 1 ]; then
  # update both values
  sudo echo $IP_NOW > $file
  sudo echo $IP_NOW > $ramfile
  #echo "SEND EMAIL!"
  printf "Subject: DeepCool Message\n\nNew IP Address: $IP_NOW" | ssmtp your@email.com
fi

