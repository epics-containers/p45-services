# Launch the IOC ***************************************************************

if [[ ${TARGET_ARCHITECTURE} == "rtems" ]] ; then
    echo "RTEMS IOC startup - copying IOC to RTEMS mount point ..."
    rm -rf ${K8S_IOC_ROOT}
    cp -r ${IOC}/* ${K8S_IOC_ROOT}
    telnet ${RTEMS_VME_CONSOLE_ADDR} ${RTEMS_VME_CONSOLE_PORT}
else
    # Execute the IOC binary and pass the startup script as an argument
    exec ${IOC}/bin/linux-x86_64/ioc ${final_ioc_startup}
fi