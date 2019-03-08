#! /bin/sh

curl -s -L http://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft6.24/heasoft-6.24src.tar.gz > heasoft-6.24.tar.gz
tar zxf heasoft-6.24.tar.gz
rm heasoft-6.24.tar.gz
cd heasoft-6.24/BUILD_DIR
FTOOLS=$ASTROPFX/ftools
mkdir -p $FTOOLS
./configure --prefix=$FTOOLS CFLAGS=-fpic --enable-collapse \
  --with-components="heacore tcltk attitude heatools Xspec ftools "
./hmake && ./hmake install
cd ..
rm -rf /heasoft-6.23
chmod -R g+rwx $FTOOLS
