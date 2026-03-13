#!/bin/bash

# --- Configuration ---
ENV_NAME="fermi"                # Name of your conda environment
REPO_URL="https://github.com/fermi-lat/ScienceTools.git" # URL of the repo
# CONDA_PATH="/opt/anaconda/lib/python3.11/site-packages/conda/shell/"    # Path to your conda installation

# --- Setup Conda ---
# Source conda.sh to allow activation within a script
# source "$CONDA_PATH/etc/profile.d/conda.sh" || echo "Conda path incorrect."
# /opt/anaconda/lib/python3.12/site-packages/conda/shell/etc/profile.d/conda.sh

mkdir -p /home/fermi/FB_TESTING
cd /home/fermi/FB_TESTING/

# --- Git Clone ---
git clone "$REPO_URL"
git clone "https://github.com/USRA-STI/gdt-fermi.git"
git clone "https://github.com/FermiSummerSchool/fermi-summer-school.git"
git clone "https://github.com/fermi-lat/AnalysisThreads.git"

cd ScienceTools/
# --- Create Directory ---
mkdir -p /home/fermi/FB_TESTING/test_results

# Activate the environment
# Initialize conda for this shell session
eval "$(conda shell.bash hook)"
conda activate "$ENV_NAME"
conda install pmw junit-xml pytest -y

cd /home/fermi/FB_TESTING/test_results/
## ../ScienceTools/recipe/tests/ST-unit-test -w -d -v
## ../ScienceTools/recipe/tests/ST-AGN-thread-test -w -d -v
## pytest --junitxml=fermipy_results.xml -vv --pyargs fermipy
pytest --junitxml=threeml_results.xml -vv --pyargs threeML
cd ../fermi-summer-school/
cd ../fermi-summer-school/Likelihood_Advanced/
pytest --nbmake --nbmake-timeout=1000000 --junitxml=/home/fermi/FB_TESTING/test_results/fss_Likelihood_adv_result.xml -vv *.ipynb
# cd ../Data_Exploration/
x# pytest --nbmake --nbmake-timeout=1000000 --junitxml=/home/fermi/FB_TESTING/test_results/data_quicklook_result.xml -vv pytest --nbmake --nbmake-timeout=10000 --junitxml=de_result2.xml -vv Data_Exploration/Data_Exploration.ipynb Data_QuickLook.ipynb 
#pytest --nbmake --nbmake-timeout=10000 --junitxml=/home/fermi/FB_TESTING/test_results/de_data_expl_result.xml  -vv Data_Exploration/Data_Exploration.ipynb 
# echo "Setup complete: Env $ENV_NAME activated, repo cloned, and test_results created."

conda deactivate
conda activate fermigbm
cd ../gdt-fermi/docs/notebooks
for f in *.tar; do tar -xf "$f"; done
pytest --nbmake --nbmake-timeout=10000 --junitxml=/home/fermi/FB_TESTING/test_results/gdt_fermi_results.xml -vv *.ipynb
echo "Setup complete: Env fermigbm"
