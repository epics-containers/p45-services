# A dummy IOC startup script for verifying that a generic IOC binary
# has been built correctly.

on 'error' 'break'

epicsEnvSet("EPICS_CA_REPEATER_PORT","7065")
epicsEnvSet("EPICS_CA_SERVER_PORT","7064")
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","3000000")
epicsEnvSet("EPICS_TS_MIN_WEST","0")

dbLoadDatabase "dbd/ioc.dbd"
ioc_registerRecordDeviceDriver(pdbbase)
epicsEnvSet("PRINTDEBUG", "3")
iocInit
