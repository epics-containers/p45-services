Sample epics-containers IOC
===========================

This IOC uses the AreaDetector Simulator to demonstrate running an IOC
in a contianer without requiring IRL hardware to connect to.

The following steps will get you viewing data from the Simulator.

1. clone ioc-adsimdetector project
   - git clone --recursive git@github.com:epics-containers/ioc-adsimdetector.git
1. clone this example beamline project as a peer of the above
   - git clone git@github.com:epics-containers/bl45p.git
1. open ioc-adsimdetector in vscode
   - module load vscode
   - code ioc-simdetector
1. choose re-open in a container when prompted (or click on
   the blue bottom left corner and choose open in container)
1. File -> add folder to workspace and choose
   - /repos/bl45p
   - you will get a transient error and need to click reload
1. Get the Generic adsimdetector IOC built
   - ibek ioc build
1. Add this IOC instance's config to the generic IOC's config
   - ln -s /repos/bl45p/iocs/bl45p-ea-ioc-90/config/ioc.yaml /epics/ioc/config
1. start up your IOC instance
   - /epics/ioc/start.sh
   - the terminal is now the ioc shell - later you can exit with ctrl-D
1. Open a new terminal and poke some PVs in your IOC
   - ctrl-shift-5
   - caput BL45P-EA-SIM-01:PVA:EnableCallbacks 1
   - caput BL45P-EA-SIM-01:CAM:Acquire 1
   - (ignore warnings from Channel Access)
1. This enables the PVA streamer and starts the simulation detector
1. Now in a terminal outside of the container:
   - module load python/3.10
   - python -m venv /scratch/venv3.9
   - source /scratch/venv3.9/bin/activate
   - pip install c2dataviewer
   - c2dv --pv BL45P-EA-SIM-01:PVA:OUTPUT
1. this starts the dataviewer and points it at the PVA stream
   - hit Auto button to set the while balance nicely
   - you should see diagonal stripes moving across the screen

TODO: we are working on supplying the bob files needed to open a GUI
onto the detector and control it more easily. Expected to be available
by 13 Oct 2023.
