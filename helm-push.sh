#!/bin/bash

function do_push() {
    if [[ -z ${DO_PUSH} ]] ; then
        echo "DRY RUN: helm push ${PACKAGE} oci://${REGISTRY_ROOT}"
    else
        echo "PUSHING: helm push ${PACKAGE} oci://${REGISTRY_ROOT}"
        helm push "${PACKAGE}" oci://${REGISTRY_ROOT}
    fi
}

set -e

IOC_ROOT="$(realpath ${1})"

if [ -z "${IOC_ROOT}" ] ; then
  echo "usage: helm-push.sh <ioc root folder> <semvar tag>"
fi

# TAG defaults to todays date and beta number as time of day
TAG=${TAG:-$(date +%Y.%-m.%-d-b%-H.%M)}
# Helm Registry defaults to GHCR
REGISTRY_ROOT=${REGISTRY_ROOT:-"ghcr.io/epics-containers"}
# Registry user defaults to USERNAME (default for GHCR)
CR_USER=${CR_USER:-"USERNAME"}

# extract name from the Chart.yaml
NAME=$(sed -n '/^name: */s///p' "${IOC_ROOT}/Chart.yaml")
CHART=oci://${REGISTRY_ROOT}/${NAME}

# Before calling this script: set CR_TOKEN to an access token fo the
# target registry.
# for github GHCR see https://github.com/settings/tokens
echo ${CR_TOKEN} | helm registry login -u ${CR_USER} --password-stdin $REGISTRY_ROOT

# Temp dir for testing if the helm chart has changed
TMPDIR=$(mktemp -d); cd ${TMPDIR}

echo "CHECKING deploy of ${IOC_ROOT} to helm repo as version ${TAG} ..."
helm package "${IOC_ROOT}" -u --app-version ${TAG} --version ${TAG}
PACKAGE=$(realpath ${NAME}-${TAG}.tgz)

# extract the latest version to a temporary folder
if helm pull ${CHART} &> out.txt; then
    cat $(realpath out.txt)
    # the output from helm pull contains the latest version number
    LATEST_VERSION=$(sed -n '/^Pulled:/s/.*://p' out.txt)
    echo "LATEST VERSION of ${CHART} is ${LATEST_VERSION}"
    mkdir latest_ioc this_ioc
    tar -xf *${LATEST_VERSION}.tgz -C latest_ioc
    rm *${LATEST_VERSION}.tgz

    # repackage the new IOC with same version as above for direct comparison
    # (packaging reformats the Chart.yaml file so this is the simplest approach)
    helm package "${IOC_ROOT}" --app-version ${LATEST_VERSION} --version ${LATEST_VERSION}
    tar -xf *${LATEST_VERSION}.tgz -C this_ioc

    # compare the packages and push the new package if it has changed
    if diff -r --exclude Chart.lock latest_ioc this_ioc > /dev/null ; then
        echo "IOC ${CHART} version ${LATEST_VERSION} is UNCHANGED."
    else
        echo "IOC ${CHART} version ${TAG} has CHANGED since ${LATEST_VERSION}."
        do_push
    fi
else
    # there was no previous version so push this one.
    echo "IOC ${CHART} version ${LATEST_VERSION} is a NEW IOC."
    do_push
fi

# clean up
if [ -z ${HELM_PUSH_DEBUG} ] ; then
    rm -r ${TMPDIR}
else
    echo "helm-push.sh comparison output is in ${TMPDIR}"
fi
