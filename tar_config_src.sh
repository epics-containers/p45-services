#!/bin/bash

# create a zip file config/config.tz containing all the files in config_src
# for each ioc that has a config_src.
#
# The standard start.sh looks for a .tz file and expands it
#
# This is a temporary solution for very large db or startup scripts that
# exceed the maximum of 1MByte for a helm chart
#
# In future ibek will generate a startup script that build the DB at runtime
# so massive fully expanded DBs will no longer be needed.


this_dir=$(realpath $(dirname $0))

for config_src in $(find ${this_dir} -name config_src) ; do
    ioc_root=$(dirname $config_src)
    tar_file=${ioc_root}/config/config.tz
    src_folder=${ioc_root}/config_src

    echo "creating ${tar_file} by compressing ${src_folder}"
    rm -f ${tar_file}

    cd ${src_folder}
    tar -czvf ${tar_file} *
done




