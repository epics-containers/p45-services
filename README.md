ioc instance configuration for Beamline BL45P
=============================================

Note for example you can start an IOC locally like this

```
podman run -it --security-opt label=disable --entrypoint bash -v $(pwd)/iocs/bl45p-ea-ioc-01/config:/epics/ioc/config ghcr.io/epics-containers/ioc-adaravis-linux-runtime:23.9.2
```
