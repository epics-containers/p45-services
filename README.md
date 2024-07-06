# beamline bl45p IOC Instances and Services

This repository holds the a definition of beamline bl45p IOC Instances and services. Each sub folder of the `services` directory contains a helm chart for a specific service or IOC.

The respository is deployed into the beamline cluster using Argo CD which keeps the cluster namespace bl45p in sync with the contents of this repo.

See apps.yaml for the root app of apps description.

