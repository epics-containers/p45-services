#!/bin/bash

# create a zip file files/config.tz containing all the files in files_src

this_dir=$(realpath $(dirname $0))
tar_file=${this_dir}/config.tz
src_folder=${this_dir}/config_src

echo "creating ${tar_file} by compressing ${src_folder}"
rm ${tar_file}

cd ${src_folder}
tar -czvf ${tar_file} *
