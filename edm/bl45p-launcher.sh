
ioc=${1}
start=${2}
shift 2
thisdir=$(realpath $(dirname ${BASH_SOURCE[0]}))

if [ -z $(which docker 2> /dev/null) ]
then
    # try podman if we dont see docker installed
    shopt -s expand_aliases
    alias docker='podman'
    opts= "--privilege "
fi

image=gcr.io/diamond-pubreg/controls/python3/s03_utils/epics/edm:latest
servers="172.23.59.1 172.23.59.101"
environ="-e DISPLAY=$DISPLAY -e EDMDATAFILES=/screens -e EPICS_CA_AUTO_ADDR_LIST=NO"
volumes="-v ${thisdir}/screens:/screens -v /tmp:/tmp"
opts=${opts}"-ti"

set -x
xhost +local:docker
docker pull ${image}
docker run -e EPICS_CA_ADDR_LIST="${servers}" ${environ} ${volumes} ${@} ${opts} ${image} edm -x -noedit ${start}
