#!/bin/bash
root=$(realpath $(dirname $0)/..)
ibek=$root/ibek

set -e -x

echo "make schema"
ibek ioc-schema ${ibek}/*.ibek.defs.yaml ${ibek}/pmac.ibek.entities.schema.json "${@}"

echo "make helm Chart"
cd $root
ibek build-helm bl45p-mo-ioc-01.yaml

# REMOVED: below deferred to ioc startup time
# echo "make ioc startup files"
# cd $root/iocs/bl45p-mo-ioc-01
# ibek build-startup config/ioc.boot.yaml $ibek/*.ibek.defs.yaml --out config/ioc.boot
