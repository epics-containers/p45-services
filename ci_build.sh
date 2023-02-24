#!/bin/sh

# script to run inside the container alpine/k8s to build and deploy
# the helm chart for each ioc

set -ex

# the included busybox diff does not support --exclude
apk --no-cache add diffutils

# tar up the ioc source if needed (TODO temp workaround until ibek builds IOC contents)
./tar_config_src.sh

# build and push the helm chart for each ioc
for ioc_root in $(ls -d iocs/*/) ; do
    ./helm-push.sh ${ioc_root} ;
done