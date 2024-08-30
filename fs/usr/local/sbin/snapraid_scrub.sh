#!/bin/bash

#TODO: check if sync is in progress and if so wait

# Scrub 12% of array.  This should be performed on a sync'd array.
snapraid status | grep -E -i "WARNING|DANGER"
# will return 0 for matches
if [ $? -eq 0 ]; then
    printf "Subject: DeepCool Scrub Aborted\n\nDisk Array Issue: \n$(tail -n 60 /var/log/snapraid_stdout.log)" | ssmtp your@email.com
    logger "Cron job for SnapRaid scrub aborted!"
else
    # only scrub if no issues
    snapraid scrub -p 15
fi
