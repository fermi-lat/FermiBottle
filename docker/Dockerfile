# FermiBottle DockerFile
# maintained by the FSSC
# Author: Alex Reustle / Jim Amrhein (2025-)
#
# This is a two stage dockerfile building the fermi science tools
# and related software in a builder container, then copying
# binaries to the final product container.
#
# Build instructions are split variously across separate install
# scripts, or continuous RUN lines.

##########################################################################
#                             Start Builder
##########################################################################

# Use Centos 9 as our base. Name the builder container builder.
# This container will be thrown away once its contents are copied
# into another centos:9 container at the end of the script.
# https://www.centos.org/download/
# 2027-05-31 (End of RHEL9 full support phase)
FROM rockylinux:9-minimal AS builder

RUN microdnf update -y &&\
    microdnf install dnf -y &&\
    microdnf clean all 


# Using yum's replacement DNF now.
RUN dnf install -y epel-release  &&\
    dnf config-manager --enable epel &&\
    dnf install yum-utils -y  &&\
    dnf config-manager --set-enabled crb &&\
    dnf update -y &&\
    dnf clean all

# Install necessary dev packages from YUM/DNF, in alphabetical order
WORKDIR /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/rocky* &&\
    sed -i 's|#baseurl=|baseurl=|g' /etc/yum.repos.d/rocky* &&\
    echo "[main]" >> /etc/yum.conf && echo "timeout=300" >> /etc/yum.conf  && \
    echo "[main]" >> /etc/dnf/dnf.conf && echo "timeout=300" >> /etc/dnf/dnf.conf

# Should this be in another image (we build weekly) that we just "from" ?
RUN dnf install -y --enablerepo=crb --setopt=install_weak_deps=False \
  autoconf \
  automake \
  bzip2-devel \
  emacs \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  git \
  hdf5-devel \
  libpng-devel \
  libSM-devel \
  libxml2-devel \
  libxslt-devel \
  libX11-devel \
  libXdmcp-devel \
  libXext-devel \
  libXft-devel \
  libXpm-devel \
  libXrender-devel \
  libXt-devel \
  make \
  mesa-libGL-devel \
  ncurses-devel \
  openssl-devel \
  patch \
  perl \
  perl-ExtUtils-MakeMaker \
  readline-devel \
  sqlite-devel \
  sudo \
  tar \
  tcl-devel \
  tk-devel \
  vim \
  wget \
  which \
  zlib-devel && \
dnf clean all && \
rm -rf /var/cache/dnf

# Create the astrosoft directory in /home. This will be our
# install target for all astronomy software
ENV ASTROPFX=/home/astrosoft
ENV FTOOLS=$ASTROPFX/ftools
RUN mkdir -p $ASTROPFX &&\
    mkdir -p $FTOOLS

# Install Heasarc Ftools from nifty script. Note, we
# must first copy the install script into the container
# before we can execute it, which is unfortunate.  heasoft-6.33.2
### Breaks tempo shell - SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Latest release 6.36 Dec 2025
RUN curl -s -L https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/release/heasoft-6.36src_no_xspec_modeldata.tar.gz | tar zxv -o heasoft-6.36

# /etc/yum.repos.d/heasoft-6.36/
WORKDIR /etc/yum.repos.d/heasoft-6.36/BUILD_DIR
RUN ./configure --prefix=$FTOOLS CFLAGS=-fpic --enable-collapse --with-components="heacore tcltk attitude heatools Xspec ftools "
RUN ./hmake &&\
    ./hmake install &&\
    chmod -R g+rwx $ASTROPFX/ftools &&\
    ./hmake clean

# Do we clean up /etc/yum.repos.d/heasoft-6.36/
# WORKDIR /etc/yum.repos.d/

WORKDIR /
# pgplot. This should really be its own script.
# Do that JSA 03 2025
RUN curl -s -L ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz > pgplot5.2.tar.gz &&\
 tar zxvf pgplot5.2.tar.gz &&\
 rm -rf /pgplot5.2.tar.gz &&\
 mkdir -p $ASTROPFX/pgplot &&\
 cd $ASTROPFX/pgplot &&\
 cp /pgplot/drivers.list . &&\
 sed -i -e '71s/!/ /g' drivers.list &&\
 sed -i -e '72s/!/ /g' drivers.list &&\
 /pgplot/makemake /pgplot linux g77_gcc &&\
 sed -i -e 's/^FCOMPL=g77/FCOMPL=gfortran/g' makefile &&\
 make && make cpg && make clean &&\
 chmod -R g+rwx $ASTROPFX/pgplot &&\
 cp $ASTROPFX/pgplot/libpgplot.so /usr/lib64/ &&\
 rm -rf /pgplot

# Anaconda Fermitools, and other conda packages
ENV CONDAPFX=/opt/anaconda
ENV CONDABIN=${CONDAPFX}/bin/conda
ENV MAMBA=${CONDAPFX}/bin/mamba
ENV MAMBA_ROOT_PREFIX=${CONDAPFX}

ENV MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download"
ENV MINIFORGE_FILE=""

# Install miniforge; set timeouts and install a few pkgs
RUN curl -s -L -O "${MINIFORGE_URL}/Miniforge3-Linux-$(uname -m).sh" &&\
    bash "Miniforge3-Linux-$(uname -m).sh" -b -p ${CONDAPFX} &&\
    $CONDABIN config --set remote_connect_timeout_secs 500 &&\
    $CONDABIN config --set remote_read_timeout_secs 500 &&\
    $CONDABIN install --channel conda-forge --yes "mamba>=0.23" su-exec "setuptools" tini

#  && $MAMBA clean -afy
# Build the fermi env
# RUN $MAMBA create -n fermi  heasoft \
#     -c https://heasarc.gsfc.nasa.gov/FTP/software/conda/ \
#    -c conda-forge

RUN $MAMBA create --name fermi -c conda-forge  -c fermi --yes \
  "astropy" \
  gammapy \
  healpy \
  jupyter \
  jupyter_server \
  libpng \
  "matplotlib" \
  "numpy" \
  "python==3.11.*" \
  "scipy<1.14" \
  &&  $CONDAPFX/envs/fermi/bin/pip3 install --no-cache-dir aplpy  https://anaconda.org/jasercion/pyregion/2.3.1.dev7+g501f368/download/pyregion-2.3.1.dev7+g501f368.tar.gz

# Now we can install fermitools
RUN $MAMBA install  --name fermi -c conda-forge  -c fermi --yes \
   "python==3.11.*" \
   "fermitools==2.5.*" \
   "fermitools-data" \
   &&  sed -i '89,91d' ${CONDAPFX}/envs/fermi/etc/conda/activate.d/activate_fermitools.sh

# Didn't originally install in the fermi env
RUN  $MAMBA install --name fermi https://anaconda.org/conda-forge/fermipy/1.4.0/download/noarch/fermipy-1.4.0-pyh885dcc9_0.conda 
# && $MAMBA clean -afy

RUN $CONDAPFX/envs/fermi/bin/pip3 install --no-cache-dir pyds9 pint-pulsar \
     git+https://github.com/threeML/astromodels.git \
     git+https://github.com/threeML/threeML.git \
     && rm -rf ${CONDAPFX}/pkgs/* &&\
     chmod -R g+rwx ${CONDAPFX}

########################
RUN $MAMBA create --name fermigbm -c conda-forge --yes \
    astropy \
    basemap-data \
    basemap-data-hires \
    cfitsio \
    geos \
    healpy \
    jupyter \
    jupyter_server \
    libpng \
    numpy \
    "scipy==1.14.1" \
    pandas \
    pip \
    basemap \
    "python=3.11.*" 
    # && $MAMBA clean -afy

# Hoping to recover space from fermi and fermigdm creations
RUN $MAMBA clean -a --yes
# RUN $MAMBA clean -afy

# Pull the latest version and make sure NOT to get it from pypi:
RUN GEOS_DIR=${CONDAPFX}/envs/fermigbm/lib \
    $CONDAPFX/envs/fermigbm/bin/pip3 install --no-cache-dir \
    astro-gdt-fermi 
#    --no-binary ":none"  git+https://github.com/USRA-STI/gdt-core.git@main \
#    --no-binary ":none"  git+https://github.com/USRA-STI/gdt-fermi.git@main \
#    'scipy>=1.14.0' 

# Fermitools prefix
ENV FERMIPFX=$CONDAPFX/envs/fermi
ENV HOME=/home/fermi

RUN mkdir -p $HOME  &&\
    mkdir $ASTROPFX/bin

# Tempo 
ENV TEMPO=$ASTROPFX/tempo
COPY setup_tempo.sh $HOME/setup_tempo.sh
RUN sh $HOME/setup_tempo.sh && rm $HOME/setup_tempo.sh

# Tempo2
ENV TEMPO2=$ASTROPFX/tempo2/T2runtime
COPY setup_tempo2.sh  $HOME/setup_tempo2.sh
RUN sh $HOME/setup_tempo2.sh && rm $HOME/setup_tempo2.sh

RUN sh pwd && ls -l
COPY entrypoint $HOME/entrypoint

# Keep DS9 this way, trying to merge the RUN(s) doesn't work in Azure.
# RUN mkdir $ASTROPFX/bin
RUN curl --connect-timeout 300 -s -L https://ds9.si.edu/download/source/ds9.8.6.tar.gz | tar zxv
WORKDIR SAOImageDS9
RUN unix/configure && make && cp bin/ds9 $ASTROPFX/bin/.
WORKDIR ../

##########################################################################
#                     End Builder, Start final Product
##########################################################################

# Copy build products into a new Container / layer, specifically Rcoky Linux 9
FROM rockylinux:9

# MAINTAINER "Fermi LAT Collaboration" "fermihelp@milkyway.gsfc.nasa.gov"
LABEL org.opencontainers.image.authors="fermihelp@milkyway.gsfc.nasa.gov"

# This is the default location of the shared directoy.
VOLUME ["/data"]

# This is the default command that docker will run if no other command is
# specified, that's fine because we want it to just drop into a bash shell,
# not do anything fancy.
CMD [ "/bin/bash" ]

# Prepary the Environment of the new Container
ENV HOME=/home/fermi

ENV ASTROPFX=/home/astrosoft
RUN mkdir -p $ASTROPFX

# Copy all the important stuff from the builder into the final product.
# Also, set the permissions to give the wheel group ownership.
COPY --from=builder --chown=root:wheel /opt/anaconda /opt/anaconda
COPY --from=builder --chown=root:wheel $ASTROPFX/ftools $ASTROPFX/ftools
COPY --from=builder --chown=root:wheel $ASTROPFX/tempo $ASTROPFX/tempo
COPY --from=builder --chown=root:wheel $ASTROPFX/pgplot $ASTROPFX/pgplot
COPY --from=builder --chown=root:wheel $ASTROPFX/tempo2 $ASTROPFX/tempo2
COPY --from=builder --chown=root:wheel $ASTROPFX/bin $ASTROPFX/bin
### COPY --from=builder --chown=root:wheel $ASTROPFX/.gammaray_data_tools $ASTROPFX/.gammaray_data_tools
COPY --from=builder --chown=root:wheel /usr/lib64/libpgplot.so  /usr/lib64/libpgplot.so

# Now install a bunch of Yum packages, not the devel versions.
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/rocky* &&\
    sed -i 's|#baseurl=|baseurl=|g' /etc/yum.repos.d/rocky*

RUN echo "[main]" >> /etc/yum.conf && echo "timeout=90" >> /etc/yum.conf &&\
    yum update -y
RUN sed -i '/tsflags=nodocs/d' /etc/yum.conf 

# While the package xorg-x11-apps is deprecated in Red Hat Enterprise Linux 9 (RHEL9), 
# it is still available and can be installed on Rocky Linux 9 which is based on RHEL. 
# RUN dnf install xorg-x11-apps
 
RUN dnf install -y epel-release  &&\
    dnf config-manager --enable epel &&\
    dnf install yum-utils -y &&\
    dnf config-manager --set-enabled crb &&\
    dnf update -y &&\
    dnf clean all

RUN echo "[main]" >> /etc/dnf/dnf.conf && echo "timeout=90" >> /etc/dnf/dnf.conf

# Should this be in another image (we build weekly) that we just "from" ?
RUN dnf install -y --enablerepo=crb --setopt=install_weak_deps=False \
  bzip2 \
  dejavu-lgc-sans-fonts \
  emacs \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  gedit \
  git \
  libpng \
  libSM \
  libX11 \
  libXdmcp \
  libXext \
  libXft \
  libXp \
  libXpm \
  libXrender \
  libXt \
  make \
  mesa-libGL \
  ncurses\
  openssl \
  patch \
  perl \
  perl-ExtUtils-MakeMaker \
  readline\
  shadow-utils\
  sqlite \
  sudo \
  tar \
  time \
  vim \
  vim-X11 \
  wget \
  which \
  zlib-devel && \
yum clean all && \
dnf clean all && \
rm -rf /var/cache/dnf 

# Give members of the wheel group sudo access to execute all commands
# Redundantly also give this access to the fermi user
RUN echo -e '%wheel        ALL=(ALL)       NOPASSWD: ALL\n\
fermi        ALL=NOPASSWD: ALL\n\
fermi ALL=NOPASSWD: /usr/bin/yum' >> /etc/sudoers

RUN echo '/opt/anaconda/envs/fermi/lib' >> /etc/ld.so.conf.d/condalibs.conf 
# &&\
#    sudo /opt/anaconda/bin/conda init bash
RUN sed -i '135,157d' "/opt/anaconda/envs/fermi/etc/conda/activate.d/activate_fermitools.sh"

# The entrypoint script is very important. It is the starter script run
# by docker to prepare a specific container for an individual user.
# The entry point will set the UID of the fermi user inside the container
# to be the same as the host user account's UID. That way the user will have
# ownership over any files they create in the shared directory once they
# leave the container.
#
# Also the entrypoint will prepare the environment, create the new
# user directory, source the ScienceTools and the Ftools, and give
# The user a nice colorful shell.
# RUN pwd && ls -l   && \ 
#    find / -name entrypoint  

COPY --from=builder $HOME/entrypoint /opt/docker/bin/entrypoint
RUN ls -l /opt/docker/bin/entrypoint
ENTRYPOINT ["/opt/docker/bin/entrypoint"]

###############################################################################
####################### NEW ADDITIONS HERE ####################################
###############################################################################
