Beamline BL45P Reference Implementation of and epics-containers Beamline
========================================================================

This repository contains the configuration files for the IOC instances
running on the test beamline BL45P at DLS.

It is a reference implementation of a beamline for
[epics-containers](https://github.com/epics-containers).

Inside DLS you can experiment with BL45P by setting up your environment
as follows:

```bash
# get bl45p environment file
curl https://raw.githubusercontent.com/epics-containers/bl45p/main/environment.sh -o ~/.local/bin/bl45p

# start a new shell to pick up .local/bin in PATH
bash

# set up the environment
source bl45p
```

Now if everythin is working you should be able to see the IOC instances
running on the bl45p kubernetes cluster:

```bash
ec ps
```

And also take a look at what other commands are available:

```bash
ec --help
ec ioc --help
```

