#!/bin/bash

echo "Loading IOC environment for BL45P ..."

# a mapping between genenric IOC repo roots and the related container registry
export EC_REGISTRY_MAPPING='github.com=ghcr.io gitlab.diamond.ac.uk=gcr.io/diamond-privreg/controls/ioc'
export EC_K8S_NAMESPACE=bl45p
export EC_EPICS_DOMAIN=bl45p
export EC_GIT_ORG=https://github.com/epics-containers
export EC_LOG_URL='https://graylog2.diamond.ac.uk/search?rangetype=relative&fields=message%2Csource&width=1489&highlightMessage=&relative=172800&q=pod_name%3A{ioc_name}*'
# export EC_CONTAINER_CLI=podman (not specified so ec can detect best option)

# the following configures kubernetes inside DLS.
if module --version > /dev/null; then
    if module avail pollux > /dev/null; then
        module load pollux > /dev/null
    fi
fi

# install the epics-containers-cli if (ec command) if we are in a venv
if [[ -n "$VIRTUAL_ENV" ]] ; then
    if ! ec --version &> /dev/null; then
        pip install epics-containers-cli
    fi
else
    echo "Please activate a virtualenv and re-run to install ec commandline tool"
fi

exec ${SHELL}
