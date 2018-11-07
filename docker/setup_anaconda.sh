#! /bin/sh

curl -s -L https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh > anaconda.sh
bash anaconda.sh -b -p ${CONDAPFX}
rm anaconda.sh
# echo "export PATH=${CONDAPFX}/bin:$PATH" >> ${HOME}/.bashrc
export PATH=${CONDAPFX}/bin:$PATH
conda install --yes -c conda-forge gosu tini
conda create --name fermi -c conda-forge -c fermi \
  astropy \
  fermipy \
  fermitools \
  fermitools-data \
  jupyter \
  libpng \
  matplotlib \
  numpy \
  pmw \
  pyyaml \
  scipy \
  --yes

pip install pyds9 pysqlite

rm -rf ${CONDAPFX}/pkgs/*
chmod -R g+rwx /opt/anaconda

#   pip install numpy scipy astropy matplotlib jupyter pysu &&\
#   pip install pmw pyfits pywcs pyds9 pysqlite fermipy

### Note, there is a pgplot in conda forge if you need it.
