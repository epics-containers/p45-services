#!/bin/bash

# NOTE: all beamlines should have CI to push their IOC helm charts
# WARNING: use this script for testing but not for deploying 
# production IOCs. Instead use the CI by pushing a tag to 
# the main branch (this makes the source for the chart discoverable)
set -xe

IOC_ROOT="$(realpath ${1})"
# create a tag for todays date and beta number as time of day
TAG=${2:-$(+%Y.%-m.%-d-b%-H.%M)}

if [ -z "${IOC_ROOT}" ] ; then
  echo "usage: helm-push.sh <ioc root folder> <semvar tag>"
fi

# Helm Registry in GHCR
HELM_REPO=ghcr.io/epics-containers

# extract name from the Chart.yaml
NAME=$(sed -n '/^name: */s///p' "${IOC_ROOT}/Chart.yaml")
CHART=oci://${HELM_REPO}/${NAME}

# Before calling this script: set CR_PAT to a github personal access token 
# see https://github.com/settings/tokens
echo $CR_PAT | helm registry login -u USERNAME --password-stdin $HELM_REPO

echo "CHECKING deploy of ${IOC_ROOT} to helm repo as version ${TAG} ..."
helm package "${IOC_ROOT}" -u --app-version ${TAG} --version ${TAG}
PACKAGE=$(realpath ${NAME}-${TAG}.tgz)

# Temp dir for testing if the helm chart has changed
TMPDIR=$(mktemp -d); cd ${TMPDIR}

# extract the latest version to a temporary folder
if helm pull ${CHART} > out.txt; then
    LATEST_VERSION=$(sed -n '/^Pulled:/s/.*://p' out.txt)
    echo "LATEST VERSION of ${CHART} is ${LATEST_VERSION}"
    mkdir latest_ioc this_ioc
    tar -xf *tgz -C latest_ioc &> tar1.out

    # repackage the new IOC with same version as above for direct comparison
    # (packaging reformats the Chart.yaml file so this is the simplest approach)
    helm package "${IOC_ROOT}" --app-version ${LATEST_VERSION} --version ${LATEST_VERSION}
    tar -xf *tgz -C this_ioc &> tar2.out

    # compare the packages and push the new package if it has changed
    if diff -r --exclude Chart.lock latest_ioc this_ioc ; then 
        echo "NOT PUSHING unchanged IOC ${CHART} version ${LATEST_VERSION}"   
    else
        echo "PUSHING ${CHART} version ${TAG}"   
        helm push "${PACKAGE}" oci://${HELM_REPO}
    fi
else
    # there was no previous version so push this one.
    helm push "${PACKAGE}" oci://${HELM_REPO}
fi

# clean up
if [ -z ${HELM_PUSH_DEBUG} ] ; then
    rm "${PACKAGE}"
    rm -r ${TMPDIR}
else
    echo "helm-push.sh comparison output is in ${TMPDIR}"
fi
