#!/bin/bash

# A script for pushing a helm chart to a helm registry
# it will only push the chart if it has changed since the last version
#
# This script is for the CI/CD pipeline of both gitlab and github.
# It can also be run locally - but in this case leave TAG blank and it will
# use the current date and time as the version number with a beta suffix
# of current time.
#
# INPUTS
#  ${1}: (CHART_ROOT) the root folder of the helm chart to be pushed
#  TAG: the version number for the new helm chart (default: today's date - beta)
#  REGISTRY_FOLDER: the folder in the registry
#  CR_USER: the username for the registry (default: USERNAME)
#  CR_TOKEN: the password for the registry (no default)
#  DO_PUSH: if true, the chart will be pushed to the registry (default: false)


# validate parameters ##########################################################

set -xe

if [[ -z "${1}" || -z "${REGISTRY_FOLDER}" || -z "${CR_TOKEN}" ]] ; then
    echo "usage: helm-push.sh <chart root folder>"
    echo "required environment variables:"
    echo "  REGISTRY_FOLDER: the folder in the registry"
    echo "  CR_TOKEN: the password for the registry"
    exit 1
fi


# setup environment variable ###################################################

# extract the chart name from the Chart.yaml
CHART_ROOT="$(realpath ${1})"
NAME=$(sed -n '/^name: */s///p' "${CHART_ROOT}/Chart.yaml")
CHART=oci://${REGISTRY_FOLDER}/${NAME}

# TAG defaults to todays date and beta number as time of day
if [[ -z "${TAG}" || "${DO_PUSH}" == "false" ]] ; then
    TAG=$(date +%Y.%-m.%-d-b%-H-%M)
fi

CR_USER=${CR_USER:-"USERNAME"}


# login ########################################################################

echo ${CR_TOKEN} | helm registry login -u ${CR_USER} \
    --password-stdin http://${REGISTRY_FOLDER}


# build the new helm chart #####################################################

# helm lint "${CHART_ROOT}"
helm package "${CHART_ROOT}" -u --app-version ${TAG} --version ${TAG}
PACKAGE=$(realpath ${NAME}-${TAG}.tgz)


# compare ######################################################################

TMPDIR=$(mktemp -d); cd ${TMPDIR}

# extract the latest version to a temporary folder
if helm pull ${CHART} > out.txt 2>&1; then
    cat $(realpath out.txt)
    # the output from helm pull contains the latest version number
    LATEST_VERSION=$(sed -n '/^Pulled:/s/.*://p' out.txt)
    echo "LATEST VERSION of ${CHART} is ${LATEST_VERSION}"
    mkdir latest_chart this_chart
    tar -xf *${LATEST_VERSION}.tgz -C latest_chart
    rm *${LATEST_VERSION}.tgz

    # repackage the new chart with same version as above for direct comparison
    # (packaging reformats the Chart.yaml file so this is the simplest approach)
    helm package "${CHART_ROOT}" --app-version ${LATEST_VERSION} \
        --version ${LATEST_VERSION}
    tar -xf *${LATEST_VERSION}.tgz -C this_chart

    # compare the packages and don't push if they are the same
    if diff -r --exclude Chart.lock latest_chart this_chart ; then
        echo "chart ${CHART} version ${LATEST_VERSION} is UNCHANGED."
        DO_PUSH="false"
    else
        echo "chart ${CHART} has CHANGED since ${LATEST_VERSION}"
    fi
else
    # there was no previous version so push this one.
    echo "chart ${CHART} version ${LATEST_VERSION} is a NEW chart."
fi


# push #########################################################################

if [[ ${DO_PUSH} == "true" ]] ; then
    echo "PUSHING: helm push ${PACKAGE} ${export}"
    helm push ${PACKAGE} oci://${REGISTRY_FOLDER}
else
    echo "DRY RUN: helm push ${PACKAGE} oci://${REGISTRY_FOLDER}"
    echo "use 'export DO_PUSH=true' to push the beta chart to the registry."
fi


# clean up #####################################################################
if [[ -z ${HELM_PUSH_DEBUG} ]] ; then
    rm -r ${TMPDIR}
else
    echo "helm-push.sh comparison output is in ${TMPDIR}"
fi




