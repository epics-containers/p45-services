#!/bin/bash

# A script for pushing a helm chart to a helm registry
# it will only push the chart if it has changed since the last version
#
# This script is intended to be used in a CI/CD pipeline of both gitlab and github.
# It can also be run locally - but in this case leave TAG blank and it will use the
# current date and time as the version number with a beta suffix of current time.
#
# INPUTS
#  ${1}: (CHART_ROOT) the root folder of the helm chart to be pushed
#  TAG: the version number to be used for the new helm chart (default: today's date - beta)
#  REGISTRY_ROOT: the root of the helm registry (default: ghcr.io/epics-containers)
#  REGISTRY_FOLDER: the folder in the registry (default: the current root folder name)
#  CR_USER: the username for the registry (default: USERNAME)
#  CR_TOKEN: the password for the registry (default: None)

function do_push() {
    if [[ -z ${DO_PUSH} ]] ; then
        echo "DRY RUN: helm push ${PACKAGE} ${CHART_FOLDER}"
    else
        echo "PUSHING: helm push ${PACKAGE} ${CHART_FOLDER}"
        helm push "${PACKAGE}" ${CHART_FOLDER}
    fi
}

set -ex

CHART_ROOT="$(realpath ${1})"

if [ -z "${CHART_ROOT}" ] ; then
  echo "usage: helm-push.sh <chart root folder>"
fi

# TAG defaults to todays date and beta number as time of day
TAG=${TAG:-$(date +%Y.%-m.%-d-b%-H-%M)}
# Helm Registry defaults to GHCR
REGISTRY_ROOT=${REGISTRY_ROOT:-"ghcr.io/epics-containers"}
# Registry user defaults to USERNAME (default for GHCR)
CR_USER=${CR_USER:-"USERNAME"}
# Registry folder should be the name of the repo (default to the current root folder)
REGISTRY_FOLDER=${REGISTRY_FOLDER:-$(basename $(realpath $(git rev-parse --show-toplevel)))}

# extract name from the Chart.yaml
NAME=$(sed -n '/^name: */s///p' "${CHART_ROOT}/Chart.yaml")
CHART_FOLDER=oci://${REGISTRY_ROOT}/${REGISTRY_FOLDER}
CHART=${CHART_FOLDER}/${NAME}

echo ${CR_TOKEN} | helm registry login -u ${CR_USER} --password-stdin $REGISTRY_ROOT

# Temp dir for testing if the helm chart has changed
TMPDIR=$(mktemp -d); cd ${TMPDIR}

echo "CHECKING deploy of ${CHART_ROOT} to helm repo as version ${TAG} ..."
helm package "${CHART_ROOT}" -u --app-version ${TAG} --version ${TAG}
PACKAGE=$(realpath ${NAME}-${TAG}.tgz)

# extract the latest version to a temporary folder
if helm pull ${CHART} &> out.txt; then
    cat $(realpath out.txt)
    # the output from helm pull contains the latest version number
    LATEST_VERSION=$(sed -n '/^Pulled:/s/.*://p' out.txt)
    echo "LATEST VERSION of ${CHART} is ${LATEST_VERSION}"
    mkdir latest_chart this_chart
    tar -xf *${LATEST_VERSION}.tgz -C latest_chart
    rm *${LATEST_VERSION}.tgz

    # repackage the new chart with same version as above for direct comparison
    # (packaging reformats the Chart.yaml file so this is the simplest approach)
    helm package "${CHART_ROOT}" --app-version ${LATEST_VERSION} --version ${LATEST_VERSION}
    tar -xf *${LATEST_VERSION}.tgz -C this_chart

    # compare the packages and push the new package if it has changed
    if diff -r --exclude Chart.lock latest_chart this_chart ; then
        echo "chart ${CHART} version ${LATEST_VERSION} is UNCHANGED."
    else
        echo "chart ${CHART} has CHANGED since ${LATEST_VERSION}, deploying version ${TAG}."
        do_push
    fi
else
    # there was no previous version so push this one.
    echo "chart ${CHART} version ${LATEST_VERSION} is a NEW chart."
    do_push
fi

# clean up
if [ -z ${HELM_PUSH_DEBUG} ] ; then
    rm -r ${TMPDIR}
else
    echo "helm-push.sh comparison output is in ${TMPDIR}"
fi
