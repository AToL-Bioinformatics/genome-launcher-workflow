#!/bin/bash

#SBATCH --job-name=genome-launcher
#SBATCH --time=0-01
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=logs/slurm/genome-launcher.%j.out
#SBATCH --error=logs/slurm/genome-launcher.%j.err

set -eux

# Dependencies
module load python/3.11.6 singularity/4.1.0-nohost
unset SBATCH_EXPORT

# apptainer setup. SINGULARITY_CACHEDIR must be set.
if [ -z "${SINGULARITY_CACHEDIR}" ]; then
        printf "The SINGULARITY_CACHEDIR variable is required" 1>&2
        exit 1
fi
export APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}"
printf "SINGULARITY_CACHEDIR: %s\n" ${SINGULARITY_CACHEDIR} 1>&2

# check for snakemake
if ! command -v snakemake >/dev/null 2>&1; then
        export MYVENV=$(mktemp -d)
        python3 -m venv $MYVENV
        source $MYVENV/bin/activate
        python3 -m pip install --upgrade pip setuptools wheel
        python3 -m pip install -r config/requirements.txt
        deploy-pipeline config/manifest.yaml --workflow_tag 0.0.10 --force
fi

snakemake --profile profiles/pawsey
