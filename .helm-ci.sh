# helm pulishing CI script for beamline iocs
# uses image gcr.io/diamond-privreg/controls/prod/gitlab/gcloud-helm:0.1.0

# IMPORTANT: for new beamlines you will need to first create the beamline
# helm repo with:
#   module load gcloud
#   gcloud auth login --no-launch-browser
#   gcloud artifacts repositories create --location=europe \
#      --repository-format=docker bl40p-iocs


helm version

set -e

# Helm Registry in diamond GCR
HELM_REPO=europe-docker.pkg.dev/diamond-privreg


# turn on Open Container Initiative support
export HELM_EXPERIMENTAL_OCI=1

# log in to the registry
if [ -z ${CI_BUILD_ID} ]
then
    # this was run locally - get creds from gcloud and push to work repo
    echo "LOCAL deploy to helm repo"
    CI_PROJECT_NAME="work"
    gcloud auth print-access-token | helm registry login -u oauth2accesstoken \
      --password-stdin ${HELM_REPO}
else
    # running under Gitlab CI - get creds from /etc/gcp/config.json
    cat /etc/gcp/config.json | helm registry login -u _json_key \
      --password-stdin ${HELM_REPO}
fi

# Update all chart dependencies.
for ioc in iocs/*; do helm dependency update $ioc; done

# determine the tag to use based on date
TAG=$(date +%Y.%m.%d-T%H%M)
# udate the helm chart versions with the tag
sed -e "s/^version: .*$/version: ${TAG}/g" -e "s/^appVersion: .*$/appVersion: ${TAG}/g" -i iocs/*/Chart.yaml

# push all ioc chart packages to the registry
for ioc in iocs/*
do
    for THIS_TAG in latest ${TAG}
    do
        URL="${HELM_REPO}/${CI_PROJECT_NAME}-iocs/$(basename $ioc):${THIS_TAG}"
        echo saving ${ioc} to "${URL}" ...
        helm chart save ${ioc} "${URL}"
        echo push to "${URL}" ...
        helm chart push "${URL}"
    done
done

echo Done
