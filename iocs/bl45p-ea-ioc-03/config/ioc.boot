cd "$(TOP)"

dbLoadDatabase "dbd/ioc.dbd"
ioc_registerRecordDeviceDriver(pdbbase)

# Autosave and restore initialisation
set_requestfile_path "$(TOP)/"'data'
set_savefile_path "/autosave"

save_restoreSet_status_prefix "BL45P-EA-IOC-03"
save_restoreSet_Debug 0
save_restoreSet_NumSeqFiles 3
save_restoreSet_SeqPeriodInSeconds 600
save_restoreSet_DatedBackupFiles 1
save_restoreSet_IncompleteSetsOk 1
set_pass0_restoreFile "BL45P-EA-IOC-03_0.sav"
set_pass0_restoreFile "BL45P-EA-IOC-03_1.sav"
set_pass1_restoreFile "BL45P-EA-IOC-03_1.sav"
set_pass1_restoreFile "BL45P-EA-IOC-03_2.sav"

# simDetectorConfig(portName, maxSizeX, maxSizeY, dataType, maxBuffers, maxMemory)
simDetectorConfig("PCO.CAM", 2560, 2160, 1, 50, 0)

# KafkaPluginConfigure(portName, queueSize, blockingCallbacks, NDArrayPort, NDArrayAddr, maxMemory, brokerAddress, topic)
KafkaPluginConfigure("PCOK", 3, 1, "PCO.CAM", 0, -1, cs05r-sc-cloud-19.diamond.ac.uk:30016, pco_topic)

# Final ioc initialisation
# ------------------------
cd "$(TOP)"
dbLoadRecords "$(THIS_DIR)/BL45P-EA-IOC-03_expanded.db"
iocInit

create_monitor_set "BL45P-EA-IOC-03_0.req",  5, ""
create_monitor_set "BL45P-EA-IOC-03_1.req", 30, ""
create_monitor_set "BL45P-EA-IOC-03_2.req", 30, ""

dbpf "BL45P-EA-PCO-01:KFK:EnableCallbacks", "Enable"

dbpf "BL45P-EA-PCO-01:CAM:AcquirePeriod", "2"
