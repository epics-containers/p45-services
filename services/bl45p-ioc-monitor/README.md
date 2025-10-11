# A Proxy service for Training Rigs

Training Rigs run on a single server with a pmac motion controller and pandabox connected to their additional NICs.

```
192.168.250.18: pandabox direct connection
192.168.250.13: pmac motion controller direct connection
```

To access the pandabox GUI on ports 80 and 8008, the pmac control port on 1025 from workstations, we require that those ports be forwarded to the correct addresses that are only accessable via the training rig server.


This service simply runs socat commands in containers as configured by [values.yaml](values.yaml)


# templates

(templates folder - TODO make this an OCI chart?)

The templates define a basic service that can run a list of commands with one container for each command. See example [values.yaml](values.yaml)


