#!/bin/bash

# NOTE: all beamlines should have CI to push their IOC helm charts
# WARNING: use this script for testing but not for deploying 
# production IOCs. Instead use the CI by pushing a tag to 
# the main branch (this makes the source for the chart discoverable)
set -e

IOC_ROOT="$(realpath ${1})"
# determine the tag to use based on date or argument 2
TAG=${2:-$(date +%Y.%-m.%-d-%-H%M)}

if [ -z "${IOC_ROOT}" ] ; then
  echo "usage: helm-push.sh <ioc root folder> <semvar tag>"
fi

# Helm Registry in GHCR
HELM_REPO=ghcr.io/epics-containers
HELM_OCI=oci://${HELM_REPO}

# extract name from the Chart.yaml
NAME=$(awk '/^name:/{print $NF}' "${IOC_ROOT}/Chart.yaml")
CHART=${HELM}/${NAME}
CHART_OCI=${HELM_OCI}/${NAME}

# Before calling this script: set CR_PAT to a github personal access token 
# see https://github.com/settings/tokens
echo $CR_PAT | helm registry login -u USERNAME --password-stdin $HELM_REPO

echo "deploying ${IOC_ROOT} to helm repo as version ${TAG}"
helm package "${IOC_ROOT}" -u --app-version ${TAG} --version ${TAG}
PACKAGE=$(realpath ${NAME}-${TAG}.tgz)

# determine if this IOC has changed since latest helm chart push
TMPDIR=$(mktemp -d)
cd $TMPDIR
helm pull ${CHART_OCI} > out.txt
LATEST_VERSION=$(sed -n '/^Pulled/s=.*:==p' out.txt)
echo latest chart: $LATEST_VERSION
mkdir latest_ioc this_ioc
tar -xf *tgz -C latest_ioc
# repackage the new IOC with same version as above for direct comparison
# (packaging reformats the Chart.yaml file so this is the best approach)
helm package "${IOC_ROOT}" -u --app-version ${LATEST_VERSION} --version ${LATEST_VERSION}
tar -xf *tgz -C this_ioc
echo comparing $(realpath latest) $(realpath this) 
if diff -r latest_ioc this_ioc &> diff.out ; then 
    MATCH=YES ; else MATCH=NO
fi
cd -
rm -r $TMPDIR

if [ "$MATCH" == "NO" ] ; then    
    helm push "${PACKAGE}" ${HELM_OCI}
else 
    echo "not pushing unchanged IOC"
fi
rm "${PACKAGE}"
