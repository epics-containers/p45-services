#!/bin/bash

echo'
Generic IOC with no confuguration

If you see this message you are running a Generic IOC deployed with the
helm chart at XXXXX but with no confugration.

To correcly dqploy this IOC you need to create a configmap and mount it
as a folder into the IOC container at /etc/epics/ioc/config.

The folder should contain one of:

- ioc.yaml
- start.sh
- st.cmd + db.subst

To easily make such a deployment use the epics-containers-cli tool at
https://github.com/epics-containers/epics-containers-cli.

See epics-containers documentation for further info at
https://epics-containers.github.io/
'