cd "$(TOP)"

epicsEnvSet "EPICS_TS_MIN_WEST", '0'

dbLoadDatabase "dbd/ioc.dbd"
ioc_registerRecordDeviceDriver(pdbbase)

# Autosave and restore initialisation
set_requestfile_path "$(TOP)/"'data'
set_savefile_path "/autosave"

save_restoreSet_status_prefix "BL45P-EA-IOC-04"
save_restoreSet_Debug 0
save_restoreSet_NumSeqFiles 3
save_restoreSet_SeqPeriodInSeconds 600
save_restoreSet_DatedBackupFiles 1
save_restoreSet_IncompleteSetsOk 1
set_pass0_restoreFile "BL45P-EA-IOC-04_0.sav"
set_pass0_restoreFile "BL45P-EA-IOC-04_1.sav"
set_pass1_restoreFile "BL45P-EA-IOC-04_1.sav"
set_pass1_restoreFile "BL45P-EA-IOC-04_2.sav"

# simDetectorConfig(portName, maxSizeX, maxSizeY, dataType, maxBuffers, maxMemory)
simDetectorConfig("PIL.CAM", 1475, 1679, 1, 50, 0)

# KafkaPluginConfigure(portName, queueSize, blockingCallbacks, NDArrayPort, NDArrayAddr, maxMemory, brokerAddress, topic)
KafkaPluginConfigure("PILK", 3, 1, "PIL.CAM", 0, -1, cs05r-sc-cloud-19.diamond.ac.uk:30016, PIL4)

# Final ioc initialisation
# ------------------------
cd "$(TOP)"
dbLoadRecords "$(THIS_DIR)/BL45P-EA-IOC-04_expanded.db"
iocInit

create_monitor_set "BL45P-EA-IOC-04_0.req",  5, ""
create_monitor_set "BL45P-EA-IOC-04_1.req", 30, ""
create_monitor_set "BL45P-EA-IOC-04_2.req", 30, ""

dbpf "BL45P-EA-PIL-01:KFK:EnableCallbacks", "Enable"
dbpf "BL45P-EA-PIL-01:KFK:KafkaMaxQueueSize", "50"

dbpf "BL45P-EA-PIL-01:CAM:ImageMode",  "Multiple"
dbpf "BL45P-EA-PIL-01:CAM:NumImages", "1000"
dbpf "BL45P-EA-PIL-01:CAM:AcquirePeriod", "2"
