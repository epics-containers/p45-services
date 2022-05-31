#!/bin/bash
this_dir=$(realpath $(dirname $0))

ibek ioc-schema ${this_dir}/{epics,pmac}.ibek.defs.yaml ${this_dir}/pmac.ibek.entities.schema.json "${@}"