epics-opis Helm Chart
=====================

Installs the web server that shares the engineering screens published by each IOC. The structure is two deep only: IOC names as folders at the root containing all the IOCs OPI files in a flat list.

Deploy this chart to the cluster by setting up your cluster namespace connection using environment.sh and then executing
the following commands:

```bash
# lists the latest versions of all services
ec list
# deploy the latest version of the epics-pvcs which includes an opis volume
ec deploy epics-pvcs VERSION
# deploy the latest version of the epics-opis service
ec deploy epics-opis VERSION
```
