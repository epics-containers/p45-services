#!/bin/bash

# check we are sourced
if [ "$0" = "$BASH_SOURCE" ]; then
    echo "ERROR: Please source this script"
    exit 1
fi

echo "Loading IOC environment for BL45P ..."

# a mapping between genenric IOC repo roots and the related container registry
export EC_REGISTRY_MAPPING='github.com=ghcr.io gitlab.diamond.ac.uk=gcr.io/diamond-privreg/controls/ioc'
export EC_K8S_NAMESPACE=bl45p
export EC_GIT_ORG=https://github.com/epics-containers
export EC_LOG_URL='https://graylog2.diamond.ac.uk/search?rangetype=relative&fields=message%2Csource&width=1489&highlightMessage=&relative=172800&q=pod_name%3A{ioc_name}*'
# export EC_CONTAINER_CLI=podman (uncomment to enforce a specific container cli)
# export EC_DEBUG=1 (uncomment to enable debug output)

# the following configures kubernetes inside DLS.
if module --version &> /dev/null; then
    if module avail pollux > /dev/null; then
        module unload pollux > /dev/null
        module load pollux > /dev/null
    fi
fi

# check if epics-containers-cli (ec command) is installed and install if not
if ! ec --version &> /dev/null; then
    # must be in a venv and this is the reliable check
    if python3 -c 'import sys; sys.exit(0 if sys.base_prefix==sys.prefix else 1)'; then
        echo "ERROR: Please activate a virtualenv and re-run"
        return
    elif ! ec --version &> /dev/null; then
        pip install epics-containers-cli
    fi
fi

# enable shell completion for ec commands
source <(ec --show-completion ${SHELL})
