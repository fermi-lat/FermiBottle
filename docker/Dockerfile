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

# Use Centos 6 as our base. Name the builder container builder.
# This container will be thrown away once its contents are copied
# into another centos:6 container at the end of the script.
FROM centos:6 as builder

# Install necessary dev packages from YUM, in alphabetical order
RUN yum update -y && \
yum install -y \
  autoconf \
  automake \
  bzip2-devel \
  emacs \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  git \
  libpng-devel \
  libSM-devel \
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
# COPY setup_ftools.sh $HOME/setup_ftools.sh
# RUN sh setup_ftools.sh && rm setup_ftools.sh
RUN curl -s -L http://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft6.24/heasoft-6.24src.tar.gz > heasoft-6.24.tar.gz && \
tar zxf heasoft-6.24.tar.gz && \
rm heasoft-6.24.tar.gz && \
cd heasoft-6.24/BUILD_DIR && \
FTOOLS=$ASTROPFX/ftools && \
mkdir -p $FTOOLS && \
./configure --prefix=$FTOOLS CFLAGS=-fpic --enable-collapse \
  --with-components="heacore tcltk attitude heatools Xspec ftools " && \
./hmake && ./hmake install && \
cd .. && \
rm -rf /heasoft-6.24 && \
chmod -R g+rwx $FTOOLS

# Add a timestamp for the build. Also, bust the cache.
#ADD https://now.httpbin.org/when/now /opt/docker/etc/timestamp

# Anaconda Fermitools, and other conda packages
ENV CONDAPFX /opt/anaconda
ENV CONDABIN ${CONDAPFX}/bin/conda

RUN curl -s -L https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh > anaconda.sh && bash anaconda.sh -b -p ${CONDAPFX}

RUN $CONDABIN install --yes -c conda-forge/label/cf201901 gosu tini
RUN $CONDABIN create --name fermi -c conda-forge/label/cf201901 -c fermi/label/beta -c fermi \
  astropy \
  fermipy \
  fermitools=1.0.5 \
  fermitools-data \
  jupyter \
  libpng \
  matplotlib \
  numpy \
  pmw \
  pyyaml \
  scipy \
  --yes
RUN $CONDAPFX/bin/pip install pyds9 pysqlite
RUN rm -rf ${CONDAPFX}/pkgs/*
RUN chmod -R g+rwx /opt/anaconda

########################
# python 3 and gspec
########################
RUN curl -s -L \
  https://fermi.gsfc.nasa.gov/ssc/data/analysis/gbm/gspec/gbm_data_tools-0.9.1.tar.gz > gbm_data_tools-0.9.1.tar.gz
RUN $CONDABIN create --name py3 -c conda-forge python=3.7 pip --yes &&\
  $CONDAPFX/envs/py3/bin/pip install gbm_data_tools-0.9.1.tar.gz &&\
  rm gbm_data_tools-0.9.1.tar.gz

# Fermitools prefix
ENV FERMIPFX $CONDAPFX/envs/fermi

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
 rm -rf /pgplot

# Tempo2
ENV TEMPO2 $ASTROPFX/tempo2/T2runtime
COPY setup_tempo2.sh $HOME/setup_tempo2.sh
RUN sh setup_tempo2.sh && rm setup_tempo2.sh

# DS9
RUN mkdir $ASTROPFX/bin &&\
 cd $ASTROPFX/bin &&\
 curl http://ds9.si.edu/download/centos6/ds9.centos6.8.0.tar.gz | tar zxv

# RMFIT
RUN cd /usr/local/bin &&\
 curl https://fermi.gsfc.nasa.gov/ssc/data/analysis/rmfit/rmfit_v432_64bit.tar.gz | tar zxv


##########################################################################
#                     End Builder, Start final Product
##########################################################################

# Copy build products into a new Container / layer, specifically centos 6
FROM centos:6
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
COPY --from=builder --chown=root:wheel /usr/local/bin/rmfit_v432 /usr/local/bin/rmfit_v432

# Now install a bunch of Yum packages, not the devel versions.
RUN sed -i '/tsflags=nodocs/d' /etc/yum.conf && \
yum update -y && \
yum install -y \
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


