#!/bin/bash

# NOTES
# Ideally network users/groups would be setup and 664/775 would be used for files/folders
# to prevent write acceess to guest users.  But in absence of this can fallback to 666/777
# and use nobody:nogroup ownership.  Since I have seperate private and guest networks will
# live with nobody:nogroup use for now.
#
# Using -exec will only print output of executed command so -print is added to force output
# of find command results as well.
# Using -not is apparently not POSIX compliant (versus '!') but cron translates exclamation
# points in the command field to a new line.  So sticking with -not because it looks cleaner
# than escaping '!'.
# -o flag is an 'or' operator within find expressions
#
# lost+found is created by fsck.  Just leave it be.
# .Trash-* folders created by desktop folder browsing.  Leave them in case it confuses the desktop.
# git repo was created with special permissions so don't touch 'em

#TODO: experiment with rwsrwsrwx permissions on folders to help prevent the need for this script.
# The s on a directory indicates the setgid bit which means all new files created in such a 
# directory will have the ownership of the dir rather than the user.

# chmod files
# finds files which are not 666 permission and fixes them
find /mnt/storage       -type f -not \( -path /mnt/storage/git -prune -o -path /mnt/storage/.Trash-* -prune -o -path /mnt/storage/lost+found -prune \) -not -perm 666 -exec chmod 666 {} \; -print
find /mnt/tmp/temp           -type f -not \( -path /mnt/tmp/temp/.Trash-* -prune -o -path /mnt/tmp/temp/lost+found -prune \) -not -perm 666 -exec chmod 666 {} \; -print

# chmod directories
# finds directories which are not 777 and fixes them
find /mnt/storage       -type d -not \( -path /mnt/storage/git -prune -o -path /mnt/storage/.Trash-* -prune -o -path /mnt/storage/lost+found -prune \) -not -perm 777 -exec chmod 777 {} \; -print
find /mnt/tmp/temp           -type d -not \( -path /mnt/tmp/temp/.Trash-* -prune -o -path /mnt/tmp/temp/lost+found -prune \) -not -perm 777 -exec chmod 777 {} \; -print

# chown everything
# finds anything not owned by nobody:nogroup and fixes them
find /mnt/storage       -not \( -path /mnt/storage/git -prune -o -path /mnt/storage/.Trash-* -prune -o -path /mnt/storage/lost+found -prune \) -not -user nobody -exec chown nobody:nogroup {} \; -print
find /mnt/tmp/temp           -not \( -path /mnt/tmp/temp/.Trash-* -prune -o -path /mnt/tmp/temp/lost+found -prune \) -not -user nobody -exec chown nobody:nogroup {} \; -print

# remove those annoying macOS files
find /mnt/storage -type f -name *.DS_Store -exec rm {} \; -print
find /mnt/tmp/temp -type f -name *.DS_Store -exec rm {} \; -print
