#!/bin/sh

rabbitmqctl add_user guest guest
rabbitmqctl set_permissions guest ".*" ".*" ".*"
