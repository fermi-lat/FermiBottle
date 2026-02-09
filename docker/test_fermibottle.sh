#!/bin/bash

# --- Configuration ---
ENV_NAME="fermi"                # Name of your conda environment
REPO_URL="https://github.com/fermi-lat/ScienceTools.git" # URL of the repo
CONDA_PATH="/opt/anaconda/lib/python3.12/site-packages/conda/shell/"    # Path to your conda installation

# --- Setup Conda ---
# Source conda.sh to allow activation within a script
source "$CONDA_PATH/etc/profile.d/conda.sh" || echo "Conda path incorrect."
# /opt/anaconda/lib/python3.12/site-packages/conda/shell/etc/profile.d/conda.sh

mkdir -p /home/fermi/
cd /home/fermi/

# --- Git Clone ---
git clone "$REPO_URL"

cd ScienceTools/
# --- Create Directory ---
mkdir -p test_results

# Activate the environment
conda activate "$ENV_NAME"
conda install pmw junit-xml pytest

cd test_results/
pytest --junitxml=test_results/fermipy_results.xml -vv --pyargs fermipy
../recipe/tests/ST-unit-test -w -d -v
../recipe/tests/ST-AGN-thread-test -w -d -v


echo "Setup complete: Env $ENV_NAME activated, repo cloned, and test_results created."
