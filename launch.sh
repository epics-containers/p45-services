#/bin/bash

#
# Launch and IOC locally using podman or docker
#
# launces the IOC in a local container connected to the host NIC so that
# caget from the same host will work.

# this mounts the ioc instance's bin volume using -v=source:target
# wheras on the k8s cluster this will be done with a config map

if [ -z "${1}" ]
then
    echo 'usage ioc-launch <ioc-name> [command] [additional parameters]
        launches the ioc in a local container for debugging purposes
        if command is supplied, instead launches the container with command
        additional parameters are added e.g. '--user root'
    '
    exit 1
fi

ioc=$(realpath ${1})
shift
command=${1:-"bash /epics/ioc/config/start.sh"}
shift

if [ -z $(which docker 2> /dev/null) ]
then
    # use podman if we dont see docker installed
    shopt -s expand_aliases
    alias docker='podman'
fi

image=$(awk '/base_image/{print $NF}' ${ioc}/values.yaml)

echo docker run -it --network host $@ -v=${ioc}/config:/epics/ioc/config:rw ${image} ${command}
docker run -it --network host $@ -v=${ioc}/config:/epics/ioc/config:rw -vautosave:/autosave ${image} ${command}

