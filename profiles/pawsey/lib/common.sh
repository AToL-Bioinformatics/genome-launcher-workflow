#!/bin/bash
# Common setup for all Pawsey jobs

set -eux

# Unset SBATCH_EXPORT to prevent environment leakage
unset SBATCH_EXPORT

# Singularity/Apptainer setup
setup_singularity() {
    module load singularity/4.1.0-slurm

    if [ -z "${SINGULARITY_CACHEDIR:-}" ]; then
        export SINGULARITY_CACHEDIR=/software/projects/pawsey1132/${USER}/.singularity
    fi
    export APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}"

    printf "SINGULARITY_CACHEDIR: %s\n" "${SINGULARITY_CACHEDIR}" 1>&2
}

# Get sample/dataset ID from manifest or directory
# FIXME - use yaml_manifest for this
get_sample_id() {
    if [ -f "config/manifest.yaml" ]; then
        grep "dataset_id" config/manifest.yaml | head -n1 | cut -d' ' -f2 | sed "s/\"//g"
    else
        basename "$(dirname "$(readlink -f venv)")"
    fi
}
