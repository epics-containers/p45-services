#!/bin/bash

start=${1}
shift 1

thisdir=$(realpath $(dirname ${BASH_SOURCE[0]}))

# if there is a no cagateway running on p45-ws001 at 172.23.59.64
# use addresses for all nodes in the p45 beamline instead
export EPICS_CA_ADDR_LIST="172.23.59.101 172.23.59.1 172.23.245.116"


export EDMDATAFILES=$(echo $EDMDATAFILES | sed s+/screens+${thisdir}+g)
echo launching edm with paths: $EDMDATAFILES
edm -noedit -x ${start}
exit 0

# if [ -z $(which podman 2> /dev/null) ]
# then
#     # use docker if we dont see podman installed
#     shopt -s expand_aliases
#     alias podman='docker'
# fi

# image=ghcr.io/epics-containers/edm
# environ="-e DISPLAY=$DISPLAY -e EDMDATAFILES"
# environ="$environ -e EPICS_CA_ADDR_LIST"
# volumes="-v ${thisdir}:/screens -v /tmp:/tmp"
# opts=${opts}"--privileged --rm -d --net host"

# set -x
# xhost +local:docker
# podman run ${environ} ${volumes} ${@} ${opts} ${image} edm -x -noedit ${start}
