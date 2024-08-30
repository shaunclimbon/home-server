#!/bin/bash

# see 'logrotate' documentation for info on automatic log management
# e.g. https://betterstack.com/community/guides/logging/how-to-manage-log-files-with-logrotate-on-ubuntu-20-04/

# first check status and only proceed to sync if good
snapraid status | grep -E -i "WARNING|DANGER"
# will return 0 for matches
if [ $? -eq 0 ]; then
    printf "Subject: DeepCool Backup Aborted\n\nDisk Array Issue: \n$(tail -n 60 /var/log/snapraid_stdout.log)" | ssmtp your@email.com
    logger "Cron job for SnapRaid sync aborted!"
    exit 1
fi

# don't capture stdout, too much redundant information
echo -e "\n[$(date)] snapraid sync" >> /var/log/snapraid.log
snapraid sync -l ">>/var/log/snapraid.log"

echo -e "\n[$(date)] snapraid status" >> /var/log/snapraid.log
echo -e "\n[$(date)] snapraid status" >> /var/log/snapraid_stdout.log
snapraid status -l ">>/var/log/snapraid.log" 2>&1 >> /var/log/snapraid_stdout.log

echo -e "\n[$(date)] snapraid smart" >> /var/log/snapraid.log
echo -e "\n[$(date)] snapraid status" >> /var/log/snapraid_stdout.log
snapraid smart -l ">>/var/log/snapraid.log" 2>&1 >> /var/log/snapraid_stdout.log
