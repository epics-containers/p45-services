# helm pulishing CI script for beamline iocs
# uses image gcr.io/diamond-privreg/controls/prod/gitlab/gcloud-helm:0.1.0
helm version

set -e

# Helm Registry in diamond GCR
HELM_REPO=europe-docker.pkg.dev/diamond-privreg/bl45p-iocs

# turn on Open Container Initiative support
export HELM_EXPERIMENTAL_OCI=1

# log in to the registry
cat /etc/gcp/config.json | helm registry login -u _json_key --password-stdin https://europe-docker.pkg.dev/diamond-privreg

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
        URL="${HELM_REPO}/$(basename $ioc):${THIS_TAG}"
        echo saving ${ioc} to "${URL}" ...
        helm chart save ${ioc} "${URL}"
        echo push to "${URL}" ...
        helm chart push "${URL}"
    done
done

echo Done
