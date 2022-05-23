#!/bin/bash

thisdir=$(realpath $(dirname ${BASH_SOURCE[0]}))

if [ -z $(which podman 2> /dev/null) ]
then
    # use docker if we dont see podman installed
    shopt -s expand_aliases
    alias podman='docker'
fi

function addvol ()
{
  vols=$vols" --mount type=bind,source=${1},destination=${2},bind-propagation=rslave"
}
image=ghcr.io/epics-containers/ec-phoebus:main
environ="-e DISPLAY=$DISPLAY"
addvol ${thisdir} /screens
addvol ${thisdir}/phoebus /settings
addvol /tmp /tmp
opts=${opts}"-d --rm --net host --security-opt label=disable"
phoebus_opts="-settings /settings/settings.ini"

set -x
xhost +local:podman
podman run ${environ} ${vols} ${opts} ${image} ${phoebus_opts} ${@}


