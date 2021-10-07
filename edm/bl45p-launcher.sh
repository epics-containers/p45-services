#!/bin/bash

start=${1}
shift 1

thisdir=$(realpath $(dirname ${BASH_SOURCE[0]}))

# there is a cagateway running on p45-ws001 at 172.23.59.64
export EPICS_CA_ADDR_LIST=${EPICS_CA_ADDR_LIST:-172.23.59.64}

if [ ! -z $(which edm 2>  /dev/null) ]
then
    export EDMDATAFILES=$(echo $EDMDATAFILES | sed s+/screens+${thisdir}+g)
    echo launching native edm with paths: $EDMDATAFILES
    edm -noedit -x ${start}
    exit 0
fi

if [ -z $(which docker 2> /dev/null) ]
then
    # try podman if we dont see docker installed
    shopt -s expand_aliases
    alias docker='podman'
    opts="--privileged "
    module load gcloud
fi

image=gcr.io/diamond-pubreg/controls/python3/s03_utils/epics/edm:latest
environ="-e DISPLAY=$DISPLAY -e EDMDATAFILES"
environ="$environ -e EPICS_CA_ADDR_LIST"
volumes="-v ${thisdir}:/screens -v /tmp:/tmp"
opts=${opts}"-ti"

set -x
xhost +local:docker
docker run ${environ} ${volumes} ${@} ${opts} ${image} edm -x -noedit ${start}
