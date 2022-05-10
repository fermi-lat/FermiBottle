#! /bin/sh

curl -s -L http://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft6.30.1/heasoft-6.30.1src_no_xspec_modeldata.tar.gz > heasoft-6.30.1.tar.gz
tar zxf heasoft-6.30.1.tar.gz
rm heasoft-6.30.1.tar.gz
cd heasoft-6.30.1/BUILD_DIR
FTOOLS=$ASTROPFX/ftools
mkdir -p $FTOOLS
./configure --prefix=$FTOOLS CFLAGS=-fpic --enable-collapse \
  --with-components="heacore tcltk attitude heatools Xspec ftools "
./hmake -j 4 && ./hmake install
cd ..
rm -rf /heasoft-6.30.1
chmod -R g+rwx $FTOOLS
