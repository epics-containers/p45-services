#!/bin/bash

this_dir=$(realpath $(dirname $0))
ioc_name=$(basename ${this_dir})

TOP=$(realpath ${this_dir}/..)

boot=${this_dir}/${ioc_name}.boot

#TODO in future ibek will build this IOC on the fly with correct paths
adcore=${SUPPORT}/ADCore-R3-10


# Update the boot script to work in the directory it resides in
# using msi MACRO substitution.
# Output to /tmp for guarenteed writability
msi -MTOP=${TOP},THIS_DIR=${this_dir},ADCORE=${adcore} ${boot} > /tmp/ioc.boot

exec ${SUPPORT}/ioc/bin/linux-x86_64/ioc /tmp/ioc.boot