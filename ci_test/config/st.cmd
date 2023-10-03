# EPICS IOC Startup SCript
cd "/epics/ioc"

epicsEnvSet EPICS_CA_MAX_ARRAY_BYTES 6000000

iocInit
