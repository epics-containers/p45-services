# RTEMS Test IOC BL45P-EA-IOC-90

on 'error' 'break'

epicsEnvSet("EPICS_CA_REPEATER_PORT","7065")
epicsEnvSet("EPICS_CA_SERVER_PORT","7064")
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","3000000")
epicsEnvSet("EPICS_TS_MIN_WEST","0")
epicsEnvSet("IOCSH_PS1","bl45p-ea-ioc-90 > ")

dbLoadDatabase "/iocs/bl45p/bl45p-ea-ioc-90/dbd/ioc.dbd"
ioc_registerRecordDeviceDriver(pdbbase)
epicsEnvSet("PRINTDEBUG", "3")

dbLoadRecords("/iocs/bl45p/bl45p-ea-ioc-90/config/ioc.db")

iocInit
