#!/bin/bash
root=$(realpath $(dirname $0)/..)
ibek=$root/ibek

set -e

echo "make schema"
ibek ioc-schema ${ibek}/{epics,pmac}.ibek.defs.yaml ${ibek}/pmac.ibek.entities.schema.json "${@}"

echo "make helm Chart"
cd $root
ibek build-helm bl45p-mo-ioc-99.yaml

echo "make ioc startup files"
cd $root/iocs/bl45p-mo-ioc-99
ibek build-startup config/ioc.boot.yaml $ibek/*.ibek.defs.yaml --out config/ioc.boot
