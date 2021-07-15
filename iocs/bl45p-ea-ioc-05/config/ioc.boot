cd "$(TOP)"

epicsEnvSet "EPICS_TS_MIN_WEST", '0'


# Loading libraries
# -----------------

# Device initialisation
# ---------------------

dbLoadDatabase "dbd/ioc.dbd"
ioc_registerRecordDeviceDriver(pdbbase)

# simDetectorConfig(portName, maxSizeX, maxSizeY, dataType, maxBuffers, maxMemory)
simDetectorConfig("AND.CAM", 4128, 4104, 1, 50, 0)

# Autosave and restore initialisation
set_requestfile_path "$(TOP)/"'data'
set_savefile_path "/autosave"

save_restoreSet_status_prefix "BL45P-EA-IOC-05"
save_restoreSet_Debug 0
save_restoreSet_NumSeqFiles 3
save_restoreSet_SeqPeriodInSeconds 600
save_restoreSet_DatedBackupFiles 1
save_restoreSet_IncompleteSetsOk 1
set_pass0_restoreFile "BL45P-EA-IOC-05_0.sav"
set_pass0_restoreFile "BL45P-EA-IOC-05_1.sav"
set_pass1_restoreFile "BL45P-EA-IOC-05_1.sav"
set_pass1_restoreFile "BL45P-EA-IOC-05_2.sav"

# simDetectorConfig(portName, maxSizeX, maxSizeY, dataType, maxBuffers, maxMemory)
simDetectorConfig("AND.cam", 4128, 4104, 1, 50, 0)

# NDFileTIFFConfigure(portName, queueSize, blockingCallbacks, NDArrayPort, NDArrayAddr, maxBuffers, maxMemory)
NDFileTIFFConfigure("AND.tiff", 2, 0, "AND.cam", 0, 0, 0)

# NDPvaConfigure(portName, queueSize, blockingCallbacks, NDArrayPort, NDArrayAddr, pvName, maxMemory, priority, stackSize)
NDPvaConfigure("AND.pva", 2, 0, "AND.tiff", 0, BL45P-EA-AND-01:PVA:ARRAY, 0, 0, 0)
startPVAServer

# KafkaPluginConfigure(portName, queueSize, blockingCallbacks, NDArrayPort, NDArrayAddr, maxMemory, brokerAddress, topic)
KafkaPluginConfigure("AND.kaf", 3, 1, "AND.tiff", 0, -1, 172.23.168.20:30008, and_topic)


# instantiate Database records
dbLoadRecords (simDetector.template, "P=BL45P-EA-AND-01, R=:CAM:, PORT=AND.cam, TIMEOUT=1, ADDR=0")
dbLoadRecords (NDFileTIFF.template, "P=BL45P-EA-AND-01, R=:TIFF:, PORT=AND.tiff, NDARRAY_PORT=AND.cam, TIMEOUT=1, ADDR=0, NDARRAY_ADDR=0, ENABLED=1")
dbLoadRecords (NDPva.template, "P=BL45P-EA-AND-01, R=:PVA:, PORT=AND.pva, ADDR=0, TIMEOUT=1, NDARRAY_PORT=AND.tiff, NDARRAY_ADR=0, ENABLED=1")
dbLoadRecords (ADPluginKafka.template, "P=BL45P-EA-AND-01, R=:KFK:, PORT=AND.kaf, NDARRAY_PORT=AND.tiff, TIMEOUT=1, ADDR=0, NDARRAY_ADDR=0, ENABLED=1"))

dbLoadRecords(iocAdminSoft.db, "IOC=BL45P-EA-IOC-05")
dbLoadRecords(iocAdminScanMon.db, "IOC=BL45P-EA-IOC-05")
dbLoadRecords(iocGui.db, "name=DEV, EDM_FILE=ioc_stats_softdls.edl, IOC=BL45P-EA-IOC-05")

# Final ioc initialisation
# ------------------------
iocInit

create_monitor_set "BL45P-EA-IOC-05_0.req",  5, ""
create_monitor_set "BL45P-EA-IOC-05_1.req", 30, ""
create_monitor_set "BL45P-EA-IOC-05_2.req", 30, ""

dbpf "BL45P-EA-AND-01:KFK:KafkaMaxQueueSize", "50"

dbpf "BL45P-EA-AND-01:CAM:ImageMode",  "Multiple"
dbpf "BL45P-EA-AND-01:CAM:NumImages", "1000"
dbpf "BL45P-EA-AND-01:CAM:AcquirePeriod", ".05"
