epics-pvcs Helm Chart
=====================

This is the first service that should be installed in a namespace because it creates the Volumes that hold shared data for IOCs.

Sets up the PVCs that all IOCs may use. These should be set up once and not deleted as they hold data for IOCs. All of the PVCs have a folder hierarchy with the names of IOCs at the root.

  - autosave data: for IOCs that support autosave. This is separate from IOC helm charts so that it can survive deletion and re-creation of an IOC.

  - opis: all the OPI files for engineering screens that an IOC supplies are saved here. This is stored in a single PVC so that the opis service can publish them over http for access by an OPI client.
