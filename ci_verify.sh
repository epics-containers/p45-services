#!/bin/bash

# CI framework agnostic to verify all the IOC instances specified in the repo

THIS_DIR=$(dirname ${0})
set -ex

# environment.sh desires a venv to be active - make a temp one for tests
tmpvenv=$(mktemp -d)
python3 -mvenv ${tmpvenv}
source ${tmpvenv}/bin/activate

# setup environment for epics-containers-cli (ec) to work with BL45P
source ${THIS_DIR}/environment.sh

for ioc in iocs/*
do
    if [ ! -d "${ioc}/config" ]; then
        continue
    fi

    # verify that the instance can generate a schema
    ec -d dev launch --target runtime ${ioc} --execute \
    'if [[ -d /epics/links/ibek/ ]]; then ibek ioc generate-schema /epics/links/ibek/*.ibek.support.yaml; fi'

    # verify that the instance can launch its IOC

    # put the values.yaml file in a test config directory with basic startup script
    cp -r ${ioc}/values.yaml ci_test/

    # launch the generic IOC pointing at that config
    # TODO this is not really testing any Python IOCs so need to think about that
    ec -d dev launch --target runtime ci_test --args '-dit'

    # a python IOC will immediately exit.
    # Docker errors stopping a non-existent container unlike podman
    ec -d dev stop || echo docker stop failed

done

rm -r ${tmpvenv}

