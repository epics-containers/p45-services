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
    echo 'usage ioc-launch <ioc-name> [user]
        launches the ioc in a local container for debugging purposes
    '
    exit 1
fi

ioc=$(realpath ${1})

if [ -z $(which docker 2> /dev/null) ]
then
    # use podman if we dont see docker installed
    shopt -s expand_aliases
    alias docker='podman'
fi

command="bash /epics/ioc/config/start.sh"
image=$(awk '/base_image/{print $NF}' ${ioc}/values.yaml)

echo docker run -it --network host -v=${ioc}/config:/epics/ioc/config:rw ${image} ${command}
docker run -it --network host -v=${ioc}/config:/epics/ioc/config:rw -vautosave:/autosave ${image} ${command}

