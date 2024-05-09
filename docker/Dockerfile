# FermiBottle DockerFile
# maintained by the FSSC
# Author: Alex Reustle
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

# Use Centos 8 as our base. Name the builder container builder.
# This container will be thrown away once its contents are copied
# into another centos:8 container at the end of the script.
FROM centos:8 as builder

# Install necessary dev packages from YUM, in alphabetical order
RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum install -y epel-release
RUN yum update -y
# RUN yum install -y centos-release-scl
# RUN yum install -y devtoolset-7-gcc*
# RUN yum update -y
# RUN yum install -y \
RUN yum install -y --enablerepo=powertools \
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
yum clean all && \
rm -rf /var/cache/yum

# Create the astrosoft directory in /home. This will be our
# install target for all astronomy software
ENV ASTROPFX /home/astrosoft
RUN mkdir -p $ASTROPFX

# Install Heasarc Ftools from nifty script. Note, we
# must first copy the install script into the container
# before we can execute it, which is unfortunate.
RUN curl -s -L https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/release/heasoft-6.33.2src_no_xspec_modeldata.tar.gz | tar zxv -o heasoft-6.33.2
ENV FTOOLS=$ASTROPFX/ftools
RUN mkdir -p $FTOOLS
WORKDIR heasoft-6.33.2/BUILD_DIR
RUN ./configure --prefix=$FTOOLS CFLAGS=-fpic --enable-collapse --with-components="heacore tcltk attitude heatools Xspec ftools "
RUN ./hmake
RUN ./hmake install
RUN chmod -R g+rwx $ASTROPFX/ftools
WORKDIR ../../

# Tempo
COPY setup_tempo.sh $HOME/setup_tempo.sh
RUN sh setup_tempo.sh && rm setup_tempo.sh

# pgplot. This should really be its own script.
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
ENV CONDAPFX /opt/anaconda
ENV CONDABIN ${CONDAPFX}/bin/conda
ENV MAMBA ${CONDAPFX}/bin/mamba

#
ENV MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download"
ENV MINIFORGE_FILE=""
RUN curl -s -L -O "${MINIFORGE_URL}/Mambaforge-Linux-$(uname -m).sh" 
RUN bash "Mambaforge-Linux-$(uname -m).sh" -b -p ${CONDAPFX}

RUN $CONDABIN install --channel conda-forge --yes "mamba>=0.23" su-exec setuptools tini
RUN $MAMBA create --name fermi -c conda-forge -c fermi -c fermi/label/dev \
  "astropy<6" \
  "fermitools==2.2.11" \
  fermitools-data \
  gammapy \
  healpy \
  jupyter \
  jupyter_server \
  libpng \
  "matplotlib>=3.5" \
  "numpy<1.24.0" \
  "python==3.9" \
  "scipy<1.12" \
  --yes

# ENV FERMI_DIR=${CONDAPFX}/envs/fermi/share/fermitools
# RUN $FERMI_DIR/etc/conda/activate.d/activate_fermitools.sh $CONDAPFX/envs/fermi/bin/pip3 install fermipy pyds9 threeml astromodels pint-pulsar
# RUN ln -s ${FERMI_DIR}/data//caldb ${FERMI_DIR}/data/caldb
RUN $CONDAPFX/envs/fermi/bin/pip3 install fermipy==1.2.0 pyds9 threeml astromodels pint-pulsar
RUN rm -rf ${CONDAPFX}/pkgs/*
RUN chmod -R g+rwx ${CONDAPFX}

########################
# GBM Data Tools
########################
RUN curl -s -L \
  https://fermi.gsfc.nasa.gov/ssc/data/analysis/gbm/gspec/gspec-0.9.1.tar.gz > gspec-0.9.1.tar.gz
RUN $CONDABIN create --name fermigbm -c conda-forge \
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
    scipy \
    pip \
    python=3.9 \
    --yes &&\
  $CONDAPFX/envs/fermigbm/bin/pip3 install gspec-0.9.1.tar.gz &&\
  rm gspec-0.9.1.tar.gz
RUN GEOS_DIR=${CONDAPFX}/envs/fermigbm/lib \
    $CONDAPFX/envs/fermigbm/bin/pip3 install \
    'basemap @ git+https://github.com/matplotlib/basemap@v1.4.1#subdirectory=packages/basemap'
RUN GEOS_DIR=${CONDAPFX}/envs/fermigbm/lib \
    $CONDAPFX/envs/fermigbm/bin/pip3 install \
    'https://fermi.gsfc.nasa.gov/ssc/data/analysis/gbm/gbm_data_tools/gbm_data_tools-1.1.1.tar.gz'

# Fermitools prefix
ENV FERMIPFX $CONDAPFX/envs/fermi

# Tempo2
ENV TEMPO2 $ASTROPFX/tempo2/T2runtime
COPY setup_tempo2.sh $HOME/setup_tempo2.sh
RUN sh setup_tempo2.sh && rm setup_tempo2.sh

# DS9
RUN mkdir $ASTROPFX/bin
RUN curl -s -L http://ds9.si.edu/download/source/ds9.8.5.tar.gz | tar zxv
WORKDIR SAOImageDS9
RUN unix/configure && make && cp bin/ds9 $ASTROPFX/bin/.
WORKDIR ../



##########################################################################
#                     End Builder, Start final Product
##########################################################################

# Copy build products into a new Container / layer, specifically centos 8
FROM centos:8
MAINTAINER "Fermi LAT Collaboration" "fermihelp@milkyway.gsfc.nasa.gov"

# This is the default location of the shared directoy.
VOLUME ["/data"]

# This is the default command that docker will run if no other command is
# specified, that's fine because we want it to just drop into a bash shell,
# not do anything fancy.
CMD [ "/bin/bash" ]

# Prepary the Environment of the new Container
ENV ASTROPFX /home/astrosoft
RUN mkdir -p $ASTROPFX

# Copy all the important stuff from the builder into the final product.
# Also, set the permissions to give the wheel group ownership.
COPY --from=builder --chown=root:wheel /opt/anaconda /opt/anaconda
COPY --from=builder --chown=root:wheel $ASTROPFX/ftools $ASTROPFX/ftools
COPY --from=builder --chown=root:wheel $ASTROPFX/tempo $ASTROPFX/tempo
COPY --from=builder --chown=root:wheel $ASTROPFX/pgplot $ASTROPFX/pgplot
COPY --from=builder --chown=root:wheel $ASTROPFX/tempo2 $ASTROPFX/tempo2
COPY --from=builder --chown=root:wheel $ASTROPFX/bin $ASTROPFX/bin
COPY --from=builder --chown=root:wheel /root/.gbm_data_tools $ASTROPFX/.gbm_data_tools
COPY --from=builder --chown=root:wheel /usr/lib64/libpgplot.so  /usr/lib64/libpgplot.so 

# Now install a bunch of Yum packages, not the devel versions.
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum update -y
RUN sed -i '/tsflags=nodocs/d' /etc/yum.conf && \
yum update -y && \
yum install -y --enablerepo=powertools \
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
  xorg-x11-apps \
  zlib-devel && \
yum clean all && \
rm -rf /var/cache/yum
# yum --setopt=tsflags='' reinstall shadow-utils &&\

# Give members of the wheel group sudo access to execute all commands
# Redundantly also give this access to the fermi user
RUN echo -e '%wheel        ALL=(ALL)       NOPASSWD: ALL\n\
fermi        ALL=NOPASSWD: ALL\n\
fermi ALL=NOPASSWD: /usr/bin/yum' >> /etc/sudoers

RUN echo '/opt/anaconda/envs/fermi/lib' >> /etc/ld.so.conf.d/condalibs.conf
RUN /opt/anaconda/bin/conda init bash
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
COPY entrypoint /opt/docker/bin/entrypoint
ENTRYPOINT ["/opt/docker/bin/entrypoint"]

###############################################################################
####################### NEW ADDITIONS HERE ####################################
###############################################################################


