# Launch the IOC ***************************************************************
set -x

TOP=$(realpath $(dirname $0)/..)
cd ${TOP}
CONFIG_DIR=${TOP}/config

# add module paths to environment for use in ioc startup script
source ${SUPPORT}/configure/RELEASE.shell

if [[ ${TARGET_ARCHITECTURE} == "rtems" ]] ; then
    echo "RTEMS IOC startup (custom4)"

    echo "Copying IOC file to RTEMS mount point ..."

    if [[ -z ${K8S_IOC_ROOT} ]]; then
        echo "ERROR: K8S_IOC_ROOT is not set. Cannot proceed."
        exit 1
    fi

    rm -rf ${K8S_IOC_ROOT}/*
    cp -r ${IOC}/* ${K8S_IOC_ROOT}

    if [ -f ${CONFIG_DIR}/ioc.substitutions ]; then
        # generate ioc.db from ioc.substitutions, including all templates from SUPPORT
        echo "generating ioc.db from ioc.substitutions"
        includes=$(for i in ${SUPPORT}/*/db; do echo -n "-I $i "; done)
        cp ${CONFIG_DIR}/ioc.substitutions /tmp
        msi ${includes} -S /tmp/ioc.substitutions -o /tmp/ioc.db
        cp /tmp/ioc.db ${K8S_IOC_ROOT}/config
    fi

    set +x
    # now connect to the console.

    echo "Connecting to RTEMS console at ${RTEMS_VME_CONSOLE_ADDR}:${RTEMS_VME_CONSOLE_PORT}"
    python3 ${CONFIG_DIR}/telnet3.py ${RTEMS_VME_CONSOLE_ADDR} ${RTEMS_VME_CONSOLE_PORT} --reboot ${RTEMS_VME_AUTO_REBOOT}
    while true; do
        echo "telnet exited, restarting ..."
        sleep 2
        python3 ${CONFIG_DIR}/telnet3.py ${RTEMS_VME_CONSOLE_ADDR} ${RTEMS_VME_CONSOLE_PORT}
    done
else
    # Execute the IOC binary and pass the startup script as an argument
    exec ${IOC}/bin/linux-x86_64/ioc ${final_ioc_startup}
fi

# Note to reboot via crate monitor would be
# $ { echo -n R,7E$'\r'; sleep 2; } | nc -t ${RTEMS_VME_CONSOLE_ADDR} ${RTEMS_VME_CRATE_MONITOR_PORT} |hexdump -C