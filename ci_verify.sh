#!/bin/bash

# CI framework agnostic to verify all the IOC instances specified in the repo

THIS_DIR=$(dirname ${0})
set -ex

# setup environment for epics-containers-cli (ec) to work with BL45P
source ${THIS_DIR}/environment.sh

for ioc in iocs/*
do
    if [ ! -d "${ioc}/config" ]; then
        continue
    fi

    # verify that the instance can generate a schema
    ec --log-level debug dev launch --target runtime ${ioc} --execute \
    'ibek ioc generate-schema /epics/links/ibek/*.ibek.support.yaml'

    # verify that the instance can launch its IOC

    # put the values.yaml file a test config directory with basic startup script
    cp -r ${ioc}/values.yaml ci_test/
    # launch the generic IOC pointing at that config
    ec --log-level debug dev launch --target runtime ci_test --args '-dit'
    ec --log-level debug dev stop ./ci_test/

done
