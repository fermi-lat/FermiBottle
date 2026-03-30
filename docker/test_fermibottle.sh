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
conda install ipykernel nb_conda_kernels  astropy junit-xml pytest -y

cd /home/fermi/FB_TESTING/test_results/
../ScienceTools/recipe/tests/ST-unit-test -w -d -v
../ScienceTools/recipe/tests/ST-AGN-thread-test -w -d -v
pytest --junitxml=fermipy_results.xml -vv --pyargs fermipy
pytest --junitxml=threeml_results.xml -vv --pyargs threeML
# pytest --junitxml=threeml_results.xml -vv --pyargs astromodels
### cd ../fermi-summer-school/
### pytest --nbmake --nbmake-timeout=1000000 --junitxml=/home/fermi/FB_TESTING/test_results/fss_Likelihood_adv_result.xml -vv Likelihood_Advanced/*.ipynb
cd /home/fermi/FB_TESTING/fermi-summer-school/
pytest --nbmake --nbmake-timeout=3000 --junitxml=/home/fermi/FB_TESTING/test_results/data_quicklook_result.xml -vv Data_Exploration/*.ipynb
## pytest --nbmake --nbmake-timeout=10000 --junitxml=/home/fermi/FB_TESTING/test_results/de_data_expl_result.xml  -vv Data_Exploration/Data_Exploration.ipynb 
# echo "Setup complete: Env $ENV_NAME activated, repo cloned, and test_results created."

# cd /home/fermi/FB_TESTING/AnalysisThreads/
# pytest --nbmake --nbmake-timeout=3000 --junitxml=/home/fermi/FB_TESTING/test_results/de_data_expl_result.xml  -vv Data_Exploration/Data_Exploration.ipynb


cd /home/fermi/FB_TESTING/AnalysisThreads/SourceAnalysis
# Currently failing
pytest --nbmake --nbmake-timeout=3000 --junitxml=/home/fermi/FB_TESTING/test_results/esa6_result.xml -vv 6.ExtendedSourceAnalysis/*.ipynb
pytest --nbmake --nbmake-timeout=10000 --junitxml=/home/fermi/FB_TESTING/test_results/ulh2_result.xml -vv 2.UnbinnedLikelihood/*.ipynb
pytest --nbmake --nbmake-timeout=3000 --junitxml=/home/fermi/FB_TESTING/test_results/pul5_result.xml -vv 5.PythonUpperLimits/*.ipynb
pytest --nbmake --nbmake-timeout=3000 --junitxml=/home/fermi/FB_TESTING/test_results/pg8_results.xml -vv  8.PulsarGating/*.ipynb

# Should work, running in cicd
# pytest --nbmake --nbmake-timeout=3000 --junitxml=/home/fermi/FB_TESTING/test_results/blh1_result.xml -vv 1.BinnedLikelihood/*.ipynb
# pytest --nbmake --nbmake-timeout=3000 --junitxml=/home/fermi/FB_TESTING/test_results/plh3_result.xml -vv 3.PythonLikelihood/*.ipynb
# pytest --nbmake --nbmake-timeout=3000 --junitxml=/home/fermi/FB_TESTING/test_results/splh4_result.xml -vv 4.SummedPythonLikelihood/*.ipynb
# pytest --nbmake --nbmake-timeout=3000 --junitxml=/home/fermi/FB_TESTING/test_results/lap7_result.xml -vv 7.LATAperturePhotometry/*.ipynb
# pytest --nbmake --nbmake-timeout=5000 --junitxml=/home/fermi/FB_TESTING/test_results/ed10_result.xml -vv 10.EnergyDispersion/*.ipynb

# conda deactivate
# conda activate fermigbm
# cd /home/fermi/FB_TESTING/gdt-fermi/docs/notebooks
# for f in *.tar; do tar -xf "$f"; done
# pytest --nbmake --nbmake-timeout=10000 --junitxml=/home/fermi/FB_TESTING/test_results/gdt_fermi_results.xml -vv *.ipynb
# echo "Setup complete: Env fermigbm"
