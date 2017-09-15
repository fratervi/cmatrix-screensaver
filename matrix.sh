#!/bin/bash

# This was written on Centos 7 and assumes that you have cmatrix and psmisc installed

sesh="pts/$(echo $SSH_TTY |cut -d'/' -f4)" #identifies current pts terminal session, I'm sure I can clean this up later.
# echo ${sesh} #uncomment for troubleshooting

while true
        do
        idle=$(w |grep "${sesh}" | tr -s " " | cut -d" " -f5 |cut -d "." -f1) #acquires current session idle time
        if [ $(echo "${idle}" | grep ':') ] ; then #if idle time is more than a minute converts idle time from minute:seconds to seconds
                idle=$(echo $idle | awk -F: '{ print ($1 * 60) + $2 }')
        fi
#       clear #can uncomment for trouble shooting
#       echo $idle #can uncomment for trouble shooting
#       echo $sesh #can uncomment for trouble shooting
        ps -a | grep -v grep | grep cmatrix > /dev/null #determines if cmatrix is already running I need to add more to make sure it is the current sessions process
        result=$?
#       echo $result #can uncomment for trouble shooting
        if [ "${idle}" -gt "300" ] ; then #if idle time is greater than 300 check for cmatrix and if it is not running launch it
                if [ "${result}" -eq "0" ] ; then
                        echo "still running"  > /dev/null
                else
                        echo "not running" > /dev/null
                        /usr/bin/cmatrix -bau 2 &
                fi
        else
                echo "not idle long enough"  > /dev/null
        fi
        if [ "${idle}" -lt "300" ] ; then #if idle time is less than 300 check for cmatrix and if it is running kill it
                if [ "${result}" -eq "0" ] ; then
                        echo "still running"  > /dev/null
                        # echo -e "q\n"
                        /usr/bin/killall -9 cmatrix > /dev/null
                else
                        echo "not running" > /dev/null
                fi
        else
                echo "new activity" > /dev/null
        fi
        done
