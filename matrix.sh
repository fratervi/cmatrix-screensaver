#!/bin/bash

# This was written on Centos 7 and assumes that you have cmatrix and psmisc installed

sesh="pts/$(echo $SSH_TTY |cut -d'/' -f4)" #identifies current pts terminal session, I'm sure I can clean this up later.
# echo ${sesh} #uncomment for troubleshooting

while true
        do
        idle=$(w |grep "${sesh}" | tr -s " " | cut -d" " -f5 |cut -d "." -f1) #acquires current session idle time
        if [ $(echo "${idle}" | grep ':') ] ; then #if idle time is more than a minute converts idle time from minute:seconds to seconds or hours:minutes to seconds
                time1=$(echo $idle | awk -F: '{ print ($1)}')
                time2=$(echo $idle | awk -F: '{ print ($2)}')
                if [ $(echo "${idle}" | grep 'm') ] ; then #drops m from ##:##m format for idle times greater than 1 hour then calculates seconds
                        time2=$(echo "$time2" | cut -d"m" -f1)
                        idle=$(((time1 * 3600)+(time2 * 60))) 
                else
                        time2=`echo $time2|sed 's/^0*//'` #drops leading zero from seconds on minute:seconds format to avoid the seconds from being read as an octal value
                        idle=$(((time1 * 60)+time2))
                fi
        fi
#       clear
#       echo $idle
#       echo $sesh
        ps -a | grep -v grep | grep ${sesh} | grep cmatrix > /dev/null #checks for cmatrix in running processes
        result=$?
#       echo $result
        if [ "${idle}" -gt "300" ] ; then #checks idles time and kicks off cmatrix if exceeds 300 seconds
                if [ "${result}" -eq "0" ] ; then
                        echo "still running"  > /dev/null
                else
                        echo "not running" > /dev/null
                        /usr/bin/cmatrix -bau 2 -C magenta &
                fi
        else
                echo "not idle long enough"  > /dev/null
        fi
        if [ "${idle}" -lt "300" ] ; then #checks idle time and kills cmatrix if it drops below 300
                if [ "${result}" -eq "0" ] ; then
                        echo "still running"  > /dev/null
                        # echo -e "q\n"
                        # /usr/bin/killall -9 cmatrix > /dev/null
			 process=$(ps -aux | grep -i "${sesh}" | grep -i cmatrix | tr -s "  " |  cut -d " " -f2)
                        /usr/bin/kill -9 $process
                        clear
                else
                        echo "not running" > /dev/null
                fi
        else
                echo "new activity" > /dev/null
        fi
        done
