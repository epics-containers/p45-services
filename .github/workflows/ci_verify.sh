#!/bin/bash

# CI to verify all the instances specified in this repo have valid configs.
# The intention here is to verify that any mounted config folder will work
# with the container image specified in values.yaml
#
# At present this will only work with IOCs because it uses ibek. To support
# other future services that don't use ibek, we will need to add a standard
# entrypoint for validating the config folder mounted at /config.

HERE=$(realpath $(dirname ${0}))
ROOT=$(realpath ${HERE}/../..)
set -xe
rm -rf ${ROOT}/.ci_work/
mkdir -p ${ROOT}/.ci_work

# use docker if available else use podman
if ! docker version &>/dev/null; then docker=podman; else docker=docker; fi

# copy the services to a temporary location to avoid dirtying the repo
cp -r ${ROOT}/services/* ${ROOT}/.ci_work/

for service in ${ROOT}/.ci_work/*/  # */ to skip files
do
    ### Lint each service chart and validate if schema given ###
    service_name=$(basename $service)

    # skip services appearing in ci_skip_checks
    checks=${HERE}/ci_skip_checks
    if [[ -f ${checks} ]] && grep -q ${service_name} ${checks}; then
        echo "Skipping ${service_name}"
        continue
    fi

    schema=$(cat ${service}/values.yaml | sed -rn 's/^# yaml-language-server: \$schema=(.*)/\1/p')
    if [ -n "${schema}" ]; then
        echo "{\"\$ref\": \"$schema\"}" > ${service}/values.schema.json
    fi

    $docker run --rm --entrypoint bash \
        -v ${ROOT}/.ci_work:/services:z \
        -v ${ROOT}/.helm-shared:/.helm-shared:z \
        alpine/helm:3.14.3 \
        -c "
           helm lint /services/$service_name --values /services/values.yaml &&
           helm dependency update /services/$service_name &&
           rm -rf /services/$service_name/charts
        "

    ### Valiate each ioc config ###
    # Skip if subfolder has no config to validate
    if [ ! -f "${service}/config/ioc.yaml" ]; then
        continue
    fi

    # Get the container image that this service uses from values.yaml if supplied
    image=$(cat ${service}/values.yaml | sed -rn 's/^ +image: (.*)/\1/p')

    if [ -n "${image}" ]; then
        echo "Validating ${service} with ${image}"

        runtime=/tmp/ioc-runtime/$(basename ${service})
        mkdir -p ${runtime}

        # avoid issues with auto-gen genicam pvi files (ioc-adaravis only)
        sed -i s/AutoADGenICam/ADGenICam/ ${service}/config/ioc.yaml

        # This will fail and exit if the ioc.yaml is invalid
        $docker run --rm --entrypoint bash \
            -v ${service}/config:/config:z \
            -v ${runtime}:/epics/runtime:z \
            ${image} \
            -c 'ibek runtime generate /config/ioc.yaml /epics/ibek-defs/*'
        # show the startup script we just generated (and verify it exists)
        cat  ${runtime}/st.cmd

    fi

done

rm -r ${ROOT}/.ci_work
