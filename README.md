# FermiBottle Docker Container

FermiBottle is a Docker container and analysis environment provided by the Fermi Science Support Center. 

For your exercises and analysis we have prepared FermiBottle preloaded with all the software we expect you will need. This will create a separate workspace for you without concern for operating system compatibility. The only required dependency is Docker, though X11 is necessary for graphical elements.

[Documentation and getting started instructions are available on the wiki](https://github.com/fermi-lat/FermiBottle/wiki)

## Included Software

The FermiBottle includes the following high level packages for high energy astrophysics analysis.

| Package                                                              | Version   | Conda Environment | Description |
| -------                                                              | -------   | ----------------- | ----------------- |
| [Fermitools](https://github.com/fermi-lat/Fermitools-conda/wiki)     | 2.2.11    | fermi             | Basic tools necessary to analyze Fermi data|
| [HEASoft](https://heasarc.gsfc.nasa.gov/lheasoft/)                   | 6.33.2    | -                 | FITS file manipulation and multi-mission X-ray data analysis|
| [Fermipy](https://fermipy.readthedocs.io/en/latest/)                 | 1.2.0     | fermi             | Python package that facilitates analysis of LAT data with the Fermi Science Tools |
| [3ML](https://github.com/threeml/threeML)                            | 2.4.1     | fermi             | Framework for multi-wavelength/multi-messenger analysis for astronomy/astrophysics|
| [Gammpy](https://gammapy.org/)                                       | 1.2       | fermi             | Python package for gamma-ray astronomy |
| [GSpec](https://fermi.gsfc.nasa.gov/ssc/data/analysis/gbm/)          | 0.9.1     | fermigbm          | GBM data analysis via a user-interactive GUI |
| [GBM Data Tools](https://fermi.gsfc.nasa.gov/ssc/data/analysis/gbm/) | 1.1.1     | fermigbm          | High-level API layer allowing a user to read, reduce, and visualize GBM data|
| [TEMPO](http://tempo.sourceforge.net/)                               | 13.1      | -                 | Pulsar timing data analysis|
| [TEMPO2](https://www.atnf.csiro.au/research/pulsar/tempo2/)          | 2021.06.1 | -                 | Software package for pulsar timing|
| [SAOImageDS9](https://github.com/SAOImageDS9/SAOImageDS9)            | 8.5.0     | -                 | Image display and visualization tool for astronomical data|
| [pyds9](http://hea-www.harvard.edu/RD/pyds9/)                        | 1.8.1     | -                 | Python interface to communicate with SAOImageDS9|
| [PINT](https://pypi.org/project/pint-pulsar/)                        | 1.0       | fermi             | Project to develop a new pulsar timing solution based on python and modern libraries |
<!-- | [PRESTO](https://github.com/scottransom/presto)                      | 4.0       | -                 | Large suite of pulsar search and analysis software| -->
<!-- | [naima](https://naima.readthedocs.io/en/latest/)                     | 0.8.4     | fermi             | Python package for computation of non-thermal radiation from relativistic particle populations | -->
