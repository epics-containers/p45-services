#!/bin/bash

# NOTE: all beamlines should have CI to push their IOC helm charts
# WARNING: use this script for testing but not for deploying 
# production IOCs. Instead use the CI by pushing a tag to 
# the main branch (this makes the source for the chart discoverable)
set -e

IOC_ROOT="${1}"
# determine the tag to use based on date or argument 2
TAG=${2:-$(date +%Y.%-m.%-d-%-H%M)}

if [ -z "${IOC_ROOT}" ] ; then
  echo "usage: helm-push.sh <ioc root folder> <semvar tag>"
fi

# Helm Registry in diamond GHCR
HELM_REPO=ghcr.io/epics-containers

# extract name from the Chart.yaml
NAME=$(awk '/^name:/{print $NF}' "${IOC_ROOT}/Chart.yaml")

# must set CR_PAT to a github personal access token 
# see https://github.com/settings/tokens
echo $CR_PAT | helm registry login -u USERNAME --password-stdin $HELM_REPO

echo "deploying ${IOC_ROOT} to helm repo as version ${TAG}"
helm package "${IOC_ROOT}" -u --app-version ${TAG} --version ${TAG}
package=${NAME}-${TAG}.tgz
          
helm push "${package}" oci://${HELM_REPO}
rm "${package}"