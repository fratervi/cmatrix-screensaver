#!/bin/bash

# This was written on Centos 7 and assumes that you have cmatrix and psmisc installed

sesh="pts/$(echo $SSH_TTY |cut -d'/' -f4)" #identifies current pts terminal session, I'm sure I can clean this up later.
# echo "$(date) - ${sesh}" >> ~/bin/matrix.log #uncomment for troubleshooting

while true
        do
#        echo "Date - $(date) - Top of loop" >> ~/bin/matrix.log #uncomment for troubleshooting
        idle=$(w |grep "${sesh}" | tr -s " " | cut -d" " -f5 |cut -d "." -f1) #acquires current session idle time
#       echo "Idle time : ${idle}" >> ~/bin/matrix.log #uncomment for troubleshooting
        if [ $(echo "${idle}" | grep ':') ] ; then #if idle time is more than a minute converts idle time from minute:seconds to seconds or hours:minutes to seconds
                time1=$(echo $idle | awk -F: '{ print ($1)}')
#               echo "time1 = ${time1}" >> ~/bin/matrix.log #uncomment for troubleshooting
                time2=$(echo $idle | awk -F: '{ print ($2)}')
#               echo "time2 = ${time2}" >> ~/bin/matrix.log #uncomment for troubleshooting
                if [ $(echo "${idle}" | grep 'm') ] ; then #drops m from ##:##m format for idle times greater than 1 hour then calculates seconds
                        time2=$(echo "$time2" | cut -d"m" -f1)
                        idle=$(((time1 * 3600)+(time2 * 60)))
#                       echo "New Idle time = ${idle}" >> ~/bin/matrix.log #uncomment for troubleshooting
                else
                        time2=`echo $time2|sed 's/^0*//'` #drops leading zero from seconds on minute:seconds format to avoid the seconds from being read as an octal value
                        idle=$(((time1 * 60)+time2))
#                       echo "New Idle time = ${idle}" >> ~/bin/matrix.log #uncomment for troubleshooting
                fi
       fi
#       echo "idle time = ${idle}" >> ~/bin/matrix.log #uncomment for troubleshooting
#       echo "session = $sesh" >> ~/bin/matrix.log #uncomment for troubleshooting
       ps -a | grep -v grep | grep ${sesh} | grep cmatrix > /dev/null #checks for cmatrix in running processes
       result=$?
#       echo "result = ${result}" >> ~/bin/matrix.log #uncomment for troubleshooting
       if [ "${idle}" -gt "300" ] ; then #checks idles time and kicks off cmatrix if exceeds 300 seconds
                if [ "${result}" -eq "0" ] ; then
                echo "cmatrix still running"  >> ~/bin/matrix.log
                else
#                        echo "cmatrix not running, starting" >> ~/bin/matrix.log #uncomment for troubleshooting
                        echo "cmatrix not running, starting" > /dev/null
                        /usr/bin/cmatrix -basu 2 -C magenta &
                fi
        else
#                echo "not idle long enough"  >> ~/bin/matrix.log #uncomment for troubleshooting
                echo "not idle long enough"  > /dev/null
        fi
        if [ "${idle}" -lt "300" ] ; then #checks idle time and kills cmatrix if it drops below 300
                if [ "${result}" -eq "0" ] ; then
#                       echo "cmatrix still running, identifying and killing it"  >> ~/bin/matrix.log #uncomment for troubleshooting
                         process=$(ps -aux | grep -i "${sesh}" | grep -i cmatrix | tr -s "  " |  cut -d " " -f2)
#                       echo "$process - PID $(ps -aux | grep -i "${sesh}" | grep -i cmatrix)" >> ~/bin/matrix.log #uncomment for troubleshooting
                        /usr/bin/kill -9 $process
                        tput cnorm
                        clear
                else
#                        echo "cmatrix not running" >> ~/bin/matrix.log #uncomment for troubleshooting
                        echo "cmatrix not running" > /dev/null
                fi
        else
#                echo "new activity" >> ~/bin/matrix.log #uncomment for troubleshooting
                echo "new activity" > /dev/null
        fi
#               echo "Date - $(date) - Bottom of loop" >> ~/bin/matrix.log #uncomment for troubleshooting
        sleep 5
        done
