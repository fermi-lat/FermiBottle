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
COPY setup_ftools.sh $HOME/setup_ftools.sh
RUN sh setup_ftools.sh && rm setup_ftools.sh
RUN curl -s -L https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft6.30.1/heasoft-6.30.1src_no_xspec_modeldata.tar.gz | tar zxv -o heasoft-6.30.1
RUN cd heasoft-6.30.1/BUILD_DIR &&\
FTOOLS=$ASTROPFX/ftools && \
mkdir -p $FTOOLS && \
./configure --prefix=$FTOOLS CFLAGS=-fpic --enable-collapse \
  --with-components="heacore tcltk attitude heatools Xspec ftools " && \
./hmake -j4 && ./hmake install &&\
cd ../../ &&\
chmod -R g+rwx $ASTROPFX/ftools

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
RUN mkdir $ASTROPFX/bin
COPY ds9 $ASTROPFX/bin/ds9
# RUN mkdir $ASTROPFX/bin &&\
#  cd $ASTROPFX/bin &&\
#  curl http://ds9.si.edu/download/centos7/ds9.centos7.8.2.1.tar.gz | tar zxv

# Anaconda Fermitools, and other conda packages
ENV CONDAPFX /opt/anaconda
ENV CONDABIN ${CONDAPFX}/bin/conda
ENV MAMBA ${CONDAPFX}/bin/mamba

# Anaconda Fermitools, and other conda packages
ENV CONDAPFX /opt/anaconda
ENV CONDABIN ${CONDAPFX}/bin/conda
ENV MAMBA ${CONDAPFX}/bin/mamba

RUN curl -s -L https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-aarch64.sh > anaconda.sh && bash anaconda.sh -b -p ${CONDAPFX}

# COPY setup_mambaforge.sh ${HOME}/setup_mambaforge.sh
# RUN sh ${HOME}/setup_mambaforge.sh

RUN $CONDABIN install --channel conda-forge --yes mamba su-exec tini
RUN $MAMBA create --name fermi -c conda-forge -c threeml -c fermi -c fermi/label/dev \
  fermitools=2.1.4 \
  gammapy \
  healpy \
  jupyter \
  numpy \
  scipy \
  libpng \
  --yes

  # pint-pulsar \
  # fermipy=1.0.1 \
  # naima \
  # astromodels \
  # threeml \
RUN $CONDAPFX/envs/fermi/bin/pip install pyds9
RUN rm -rf ${CONDAPFX}/pkgs/*
RUN chmod -R g+rwx ${CONDAPFX}

########################
# GBM Data Tools
########################
  # https://fermi.gsfc.nasa.gov/ssc/data/analysis/gbm/gbm_data_tools/gbm_data_tools-1.0.4.tar.gz > gbm_data_tools-1.0.4.tar.gz
RUN curl -s -L \
  https://fermi.gsfc.nasa.gov/ssc/data/analysis/gbm/gbm_data_tools/gbm_data_tools-1.1.0.tar.gz > gbm_data_tools-1.1.0.tar.gz
  # https://www.dropbox.com/s/i3jhkjmg04a7rts/gbm_data_tools-1.1.0.tar.gz > gbm_data_tools-1.1.0.tar.gz
RUN GEOS_DIR=/envs/fermi/lib  $CONDAPFX/envs/fermi/bin/pip3 install gbm_data_tools-1.1.0.tar.gz &&\
  rm gbm_data_tools-1.1.0.tar.gz

RUN curl -s -L \
  https://fermi.gsfc.nasa.gov/ssc/data/analysis/gbm/gspec/gspec-0.9.1.tar.gz > gspec-0.9.1.tar.gz
RUN $CONDABIN create --name gspec -c conda-forge pip --yes &&\
  $CONDAPFX/envs/gspec/bin/pip3 install gspec-0.9.1.tar.gz &&\
  rm gspec-0.9.1.tar.gz

# Fermitools prefix
ENV FERMIPFX $CONDAPFX/envs/fermi


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


