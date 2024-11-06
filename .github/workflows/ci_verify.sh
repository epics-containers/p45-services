#!/bin/bash

# CI to verify all the instances specified in this repo have valid configs.
# The intention here is to verify that any mounted config folder will work
# with the container image specified in values.yaml
#
# At present this will only work with IOCs because it uses ibek. To support
# other future services that don't use ibek, we will need to add a standard
# entrypoint for validating the config folder mounted at /config.

ROOT=$(realpath $(dirname ${0})/../..)
set -xe
rm -rf ${ROOT}/.ci_work/
mkdir -p ${ROOT}/.ci_work

# use docker if available else use podman
if ! docker version &>/dev/null; then docker=podman; else docker=docker; fi

for service in ${ROOT}/services/*/  # */ to skip files
do

    ### Lint each service chart and validate if schema given ###
    service_name=$(basename $service)
    cp -r $service ${ROOT}/.ci_work/$service_name
    schema=$(cat ${service}/values.yaml | sed -rn 's/^# yaml-language-server: \$schema=(.*)/\1/p')
    if [ -n "${schema}" ]; then
        echo "{\"\$ref\": \"$schema\"}" > ${ROOT}/.ci_work/$service_name/values.schema.json
    fi
    $docker run --rm --entrypoint bash \
        -v ${ROOT}/.ci_work/$service_name:/services/$service_name \
        alpine/helm:3.14.3 \
        -c "helm dependency update /services/$service_name"
    $docker run --rm --entrypoint bash \
        -v ${ROOT}/.ci_work/$service_name:/services/$service_name \
        -v ${ROOT}/services/values.yaml:/services/values.yaml \
        alpine/helm:3.14.3 \
        -c "helm lint /services/$service_name --values /services/values.yaml"

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

        # This will fail and exit if the ioc.yaml is invalid
        $docker run --rm --entrypoint bash \
            -v ${service}/config:/config \
            -v ${runtime}:/epics/runtime \
            ${image} \
            -c 'ibek runtime generate /config/ioc.yaml /epics/ibek-defs/*'
        # show the startup script we just generated (and verify it exists)
        cat  ${runtime}/st.cmd

    fi

done

rm -r ${ROOT}/.ci_work