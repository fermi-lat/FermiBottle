# FermiBottle Docker Container

FermiBottle is a Docker container and analysis environment provided by the Fermi Science Support Center. 

For your exercises and analysis we have prepared FermiBottle preloaded with all the software we expect you will need. This will create a separate workspace for you without concern for operating system compatibility. The only required dependency is Docker, though X11 is necessary for graphical elements.

[Documentation and getting started instructions are available on the wiki](https://github.com/fermi-lat/FermiBottle/wiki)

## Included Software

The FermiBottle includes the following high level packages for high energy astrophysics analysis.

| Package        | version   | Conda Environment |
| -------        | -------   | ----------------- |
| Fermitools     | 2.0.8     | fermi             |
| Heasoft        | 6.26      | -                 |
| presto         | 4.0       | -                 |
| tempo          | 13.1      | -                 |
| tempo2         | 2018.02.1 | -                 |
| fermipy        | 1.0.0     | fermi             |
| gammpy         | 0.18.2    | fermi             |
| gbm_data_tools | 1.0.4     | fermi             |
| namia          | 0.8.4     | fermi             |
| pint-pulsar    | 0.7       | fermi             |
| threeml        | 2.2.1     | fermi             |
| pyds9          | 1.8.1     | fermi             |
| gspec          | 0.9.1     | gspec             |
