# FermiBottle Docker Container

FermiBottle is a Docker container and analysis environment provided by the Fermi Science Support Center. 

For your exercises and analysis we have prepared FermiBottle preloaded with all the software we expect you will need. This will create a separate workspace for you without concern for operating system compatibility. The only required dependency is Docker, though X11 is necessary for graphical elements.

[Documentation and getting started instructions are available on the wiki](https://github.com/fermi-lat/FermiBottle/wiki)

## Included Software

The FermiBottle includes the following high level packages for high energy astrophysics analysis.

| Package                                                              | Version   | Conda Environment | Description |
| -------                                                              | -------   | ----------------- | ----------------- |
| [Fermitools](https://github.com/fermi-lat/Fermitools-conda/wiki)     | 2.4.8    | fermi             | Basic tools necessary to analyze Fermi data|
| [HEASoft](https://heasarc.gsfc.nasa.gov/lheasoft/)                   | 6.35.1    | -                 | FITS file manipulation and multi-mission X-ray data analysis|
| [Fermipy](https://fermipy.readthedocs.io/en/latest/)                 | 1.4.0     | fermi             | Python package that facilitates analysis of LAT data with the Fermi Science Tools |
| [3ML](https://github.com/threeml/threeML)                            | 2.4.3     | fermi             | Framework for multi-wavelength/multi-messenger analysis for astronomy/astrophysics|
| [Gammpy](https://gammapy.org/)                                       | 1.3       | fermi             | Python package for gamma-ray astronomy |
| [Gamma-ray Data Tools](https://fermi.gsfc.nasa.gov/ssc/data/analysis/gbm/) | 2.2.0     | fermigbm          | Python-based centralized toolkit for analyzing data from space-based hard X-ray and gamma-ray instruments|
| [TEMPO](http://tempo.sourceforge.net/)                               | 13.1      | -                 | Pulsar timing data analysis|
| [TEMPO2](https://www.atnf.csiro.au/research/pulsar/tempo2/)          | 2023.05.1 | -                 | Software package for pulsar timing|
| [SAOImageDS9](https://github.com/SAOImageDS9/SAOImageDS9)            | 9.8.6     | -                 | Image display and visualization tool for astronomical data|
| [pyds9](http://hea-www.harvard.edu/RD/pyds9/)                        | 1.8.1     | -                 | Python interface to communicate with SAOImageDS9|
| [PINT](https://pypi.org/project/pint-pulsar/)                        | 1.1.3       | fermi             | Project to develop a new pulsar timing solution based on python and modern libraries |

<!-- | [GSpec](https://fermi.gsfc.nasa.gov/ssc/data/analysis/gbm/)          | 0.9.1     | fermigbm          | GBM data analysis via a user-interactive GUI | -->
<!-- | [PRESTO](https://github.com/scottransom/presto)                      | 4.0       | -                 | Large suite of pulsar search and analysis software| -->
<!-- | [naima](https://naima.readthedocs.io/en/latest/)                     | 0.8.4     | fermi             | Python package for computation of non-thermal radiation from relativistic particle populations | -->
