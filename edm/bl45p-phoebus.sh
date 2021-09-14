#!/bin/bash

thisdir=$(realpath $(dirname ${BASH_SOURCE[0]}))

if [ -z $(which docker 2> /dev/null) ]
then
    # try podman if we dont see docker installed
    shopt -s expand_aliases
    alias docker='podman'
    opts="--privileged "
    module load gcloud
fi

image=ghcr.io/epics-containers/ec-phoebus:main
environ="-e DISPLAY=$DISPLAY"
volumes="-v ${thisdir}:/screens -v ${thisdir}/phoebus:/settings -v /tmp:/tmp"
opts=${opts}"-ti"
phoebus_opts="-settings /settings/settings.ini"

set -x
xhost +local:docker
docker run ${environ} ${volumes} ${opts} ${image} ${phoebus_opts} ${@}


