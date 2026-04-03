#!/bin/bash -l
#SBATCH --job-name=ascc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32g
#SBATCH --time=1-00
#SBATCH --output=logs/slurm/ascc.%j.out
#SBATCH --error=logs/slurm/ascc.%j.err

# Source nextflow environment
source profiles/pawsey/lib/nextflow_env.sh

# Pipeline configuration
PIPELINE="ascc"
PIPELINE_VERSION="0.5.3"
SAMPLE_ID="$(get_sample_id)"

# Setup nextflow
setup_nextflow "${PIPELINE}" "${PIPELINE_VERSION}" "25.04.8"

# Pipeline parameters
PIPELINE_PARAMS=(
        "--input" "${SAMPLE_ID}_ascc_samplesheet.csv"
        "--outdir" "results/${PIPELINE}/${SAMPLE_ID}"
        "--fcs_gx_database_path" "$(readlink -f results/fcsgx/fcsgx)"
        "-profile" "singularity,pawsey,ascc"
        "-params-file" "${SAMPLE_ID}_ascc_config.yaml"
        "-r" "${PIPELINE_VERSION}"
        "-c" "profiles/pawsey/pawsey.config"
        "-c" "profiles/pawsey/ascc.params.config"
)

# Run pipeline
run_nextflow "sanger-tol/${PIPELINE}" PIPELINE_PARAMS
