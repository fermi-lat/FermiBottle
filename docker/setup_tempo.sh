#! /bin/sh
TEMPO=$ASTROPFX/tempo
#git clone https://github.com/nanograv/tempo.git
# git clone https://git.code.sf.net/p/tempo/tempo tempo-tempo
git clone https://git.code.sf.net/p/tempo/tempo tempo
mkdir -p $TEMPO
cd tempo
bash prepare
./configure --prefix=$TEMPO
make && make install
cd ../
rm -rf tempo
chmod -R g+rwx $TEMPO
chown -R :wheel $TEMPO
