#!/bin/bash

# log this script to a persisted file so we can see what happened in the last exit
touch /autosave/stop-time
exec > /autosave/stop.log
exec 2>&1

elif [[ ${RTEMS_VME_AUTO_REBOOT} == 'true' ]] ; then
    # killall telnet
    # sleep 5
    echo 'iocPause'
fi



