Beamline BL45P the test epics-containers Beamline
=================================================

This repository contains the configuration files for the IOC instances
running on the test beamline BL45P at DLS.


It is a reference implementation of a beamline for
[epics-containers](https://github.com/epics-containers).


Experimenting with epics containers on a Workstation
----------------------------------------------------

If you would like to try out epics-containers locally in a devcontainer
without requiring Kubernetes, [see here](iocs/bl45p-ea-ioc-90/README.md)


Experimenting with epics containers on a K8S Cluster
----------------------------------------------------

Inside DLS you can experiment with BL45P by setting up your environment
as follows:

1. Set up a python virtual environment if you do not already have one.

```bash
module load python/3.10
python -m venv ~/.local/epics-containers
source ~/.local/epics-containers/bin/activate
```

2. Set up your environment for BL45P

```bash
# get bl45p environment file
curl https://raw.githubusercontent.com/epics-containers/bl45p/main/environment.sh -o ~/.local/bin/bl45p

# set up the environment
source ~/.local/bl45p

# You will asked for kubernetes credentials which are same as your linux login.

# You may also need to ask the cloud team for access to the kubernetes namespace bl45p on pollux.
```

3. Now if everything is working you should be able to see the IOC instances
   running on the bl45p kubernetes cluster:

```bash
ec ps
```

4. And also take a look at what other commands are available:

```bash
ec --help
ec ioc --help
```

