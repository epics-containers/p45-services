#!/bin/bash

# setup the environment for using the BL45P beamline

set -e

echo "Loading IOC environment for BL45P ..."

if ! ec --version &> /dev/null; then
    pip install epics-containers-cli
fi

# a mapping between genenric IOC repo roots and the related container registry
export EC_REGISTRY_MAPPING='github.com=ghcr.io gitlab.diamond.ac.uk=gcr.io/diamond-privreg/controls/ioc'
export EC_K8S_NAMESPACE=bl45p
export EC_EPICS_DOMAIN=bl45p
export EC_GIT_ORG=https://github.com/epics-containers
export EC_LOG_URL='https://graylog2.diamond.ac.uk/search?rangetype=relative&fields=message%2Csource&width=1489&highlightMessage=&relative=172800&q=pod_name%3A{ioc_name}*'

# ibek is not required outside of the generic IOC containers but is occasionally useful
source <(ec --show-completion bash)
if ibek --version &> /dev/null; then
    source <(ibek --show-completion bash)
fi

# the following configures kubernetes inside DLS. But this script is used in CI
# so skip this step if we are not on the DLS network
if module --version &> /dev/null; then
    if module avail pollux > /dev/null; then
        module load pollux > /dev/null
        # allow this to fail if the cluster is not available
        if ! ec ps ; then echo "no cluster available"; fi
    fi
fi
