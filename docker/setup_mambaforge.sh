#! /bin/sh

MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download"
MINIFORGE_FILE="Mambaforge-MacOSX-$(uname -m).sh"
curl -s -L -O "${MINIFORGE_URL}/${MINIFORGE_FILE}" 
bash "${MINIFORGE_FILE}" -b -p ${CONDAPFX}

