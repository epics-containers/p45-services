#!/bin/bash

# check we are sourced
if [ "$0" = "$BASH_SOURCE" ]; then
    echo "ERROR: Please source this script"
    exit 1
fi

echo "Loading IOC environment for BL45P ..."

# a mapping between genenric IOC repo roots and the related container registry
export EC_REGISTRY_MAPPING='github.com=ghcr.io gitlab.diamond.ac.uk=gcr.io/diamond-privreg/controls/ioc'
# the namespace to use for kubernetes deployments
export EC_K8S_NAMESPACE=bl45p
# the git organisation used for beamline repositories
export EC_GIT_ORG=https://github.com/epics-containers
# the git repo for this beamline (or accelerator domain)
export EC_DOMAIN_REPO=git@github.com:epics-containers/bl45p.git
# declare your centralised log server Web UI
export EC_LOG_URL='https://graylog2.diamond.ac.uk/search?rangetype=relative&fields=message%2Csource&width=1489&highlightMessage=&relative=172800&q=pod_name%3A{ioc_name}*'
# enforce a specific container cli - defaults to whatever is available
# export EC_CONTAINER_CLI=podman
# enable debug output in all 'ec' commands
# export EC_DEBUG=1

# the following configures kubernetes inside DLS.
# replace this with however your cluster is configured - essenially needs to
# ~/.kube/config
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
