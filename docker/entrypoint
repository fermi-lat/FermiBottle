#!/bin/bash -il

# Create conda user with the same uid as the host, so the container can write
# to mounted volumes
# Adapted from https://denibertovic.com/posts/handling-permissions-with-docker-volumes/

if [ ! -e /.fermibottle ]; then
  touch -d "1 minute ago" /.fermibottle
fi

USER_ID=${HOST_USER_ID:-9001}
# echo $HOST_USER_ID
# echo $USER_ID
useradd --shell /bin/bash -u $USER_ID -o -c "" -m fermi
usermod -aG root fermi
usermod -aG wheel fermi
echo 'fermi' | passwd fermi --stdin >& /dev/null
export HOME=/home/fermi
export USER=fermi
export LOGNAME=fermi
export MAIL=/var/spool/mail/fermi
export HEADAS="$(find /home/astrosoft/ftools -type d -name $(uname -m)*)"
export TEMPO2=$HOME/astrosoft/tempo2/T2runtime
export ASTROSOFT=$HOME/astrosoft
export PATH=$ASTROSOFT:/opt/anaconda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=$ASTROSOFT/bin:${HEADAS}/bin:${PATH}
export PATH=$ASTROSOFT/tempo/bin:$ASTROSOFT/tempo2/bin:$ASTROSOFT/pgplot:$PATH

## Solve permissions issues
ln -s /home/astrosoft /home/fermi/astrosoft
### ln -s /home/astrosoft/.gammaray_data_tools /home/fermi/.gammaray_data_tools

ln -s /opt/anaconda/bin/conda /home/fermi/astrosoft/bin/conda
/opt/anaconda/bin/conda config --add channels fermi
### chown -R fermi:fermi /home/astrosoft/.gammaray_data_tools
chown fermi:fermi $HOME/.condarc
chown fermi:fermi $HOME/astrosoft
#### chown fermi:fermi $HOME/.gammaray_data_tools
chown -R fermi:fermi $HOME
cd $HOME

if [ ! .bash_profile -nt /.fermibottle ]; then
  echo "#################
# Added by entrypoint at date: `date`
# Environment variables
export HOME=${HOME}
export USER=${USER}
export LOGNAME=${LOGNAME}
export MAIL=${MAIL}
export ASTROSOFT=${ASTROSOFT}
export HEADAS=${HEADAS}
export TEMPO2=${TEMPO2}
export PATH=${PATH}:\$PATH

# Source the tools!
. \$HEADAS/headas-init.sh

" >> $HOME/.bash_profile
fi

# Aliases
if [ ! .bashrc -nt /.fermibottle ]; then
  echo "
# Aliases
alias notebook='jupyter notebook --ip 00.00.00.00 --no-browser'
alias gbm-demos='jupyter notebook --ip 00.00.00.00 --no-browser /home/fermi/.gbm_data_tools/1.1.1/tutorials'
" >> $HOME/.bashrc
fi

# Source everything that needs to be.
/opt/anaconda/bin/conda init --all -q > /dev/null 2>&1
# /opt/anaconda/bin/conda activate fermi
# . /opt/anaconda/bin/activate base
. $HEADAS/headas-init.sh
chown -R fermi:fermi $HOME/pfiles
chown -R fermi:fermi $HOME


# Run whatever the user wants.
echo "Welcome to the Fermi Container."
exec /opt/anaconda/bin/su-exec fermi "$@"
