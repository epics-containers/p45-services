#!/bin/bash

#
# generic kubernetes IOC startup script
#

set -x -e

# environment setup
this_dir=$(realpath $(dirname $0))
TOP=$(realpath ${this_dir}/..)
cd ${this_dir}
config_dir=${TOP}/config

# add module paths to environment for use in ioc startup script
source ${SUPPORT}/configure/RELEASE.shell

# setup filenames for boot scripts
startup_src=${config_dir}/ioc.boot.yaml
boot_src=${config_dir}/ioc.boot
db_src=/tmp/make_db.sh
boot=/tmp/$(basename ${boot_src})
db=/tmp/ioc.db

# If there is a yaml ioc description then generate the startup and DB.
# Otherwise assume the starup script ioc.boot is provided in the config folder.
if [ -f ${startup_src} ] ; then
    # get ibek support files from this ioc and all it's support modules
    defs=/ctools/*/*.ibek.support.yaml
    ibek build-startup ${startup_src} ${defs} --out ${boot} --db-out ${db_src}
fi

# build expanded database using the db_src shell script
if [ -f ${db_src} ]; then
    bash ${db_src} > ${db}
fi
exec ${IOC}/bin/linux-x86_64/ioc ${boot}
