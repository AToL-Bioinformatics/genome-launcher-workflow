#!/bin/bash -l
#SBATCH --job-name=ascc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32g
#SBATCH --time=1-00:00:00
#SBATCH --account=pawsey1132
#SBATCH --partition=work

module load singularity/4.1.0-slurm

unset SBATCH_EXPORT

# Application specific commands:
set -eux

# Set up project. Outdir must be on scratch.
SAMPLE_ID="rSaiEqu1"
PIPELINE_ATTEMPT="v3"
OUTDIR="results/${SAMPLE_ID}.${PIPELINE_ATTEMPT}"
PIPELINE_VERSION="0.5.3"

# Set up nextflow. Download a GitHub release for the target version if
# required.
NEXTFLOW_VERSION="25.04.8"
NEXTFLOW_DIR="${OUTDIR}/nextflow/${NEXTFLOW_VERSION}/ascc_${PIPELINE_VERSION}"
mkdir -p "${NEXTFLOW_DIR}/logs"

if [ ! -f "${NEXTFLOW_DIR}/nextflow" ]; then
        wget \
                -O "${NEXTFLOW_DIR}/nextflow" \
                "https://github.com/nextflow-io/nextflow/releases/download/v${NEXTFLOW_VERSION}/nextflow"

        chmod 755 "${NEXTFLOW_DIR}/nextflow"
fi

# nf gets confused if either the cache or home directory is shared across
# pipeline runs. This block contains the nextflow cache, home and work
# directories to the results directory to limit the damage.
export PATH="${NEXTFLOW_DIR}:${PATH}"
printf "nextflow: %s\n" "$(readlink -f "$(which nextflow)")"
export NXF_HOME="$(readlink -f "${NEXTFLOW_DIR}/home")"
export NXF_CACHE_DIR="$(readlink -f "${NEXTFLOW_DIR}/cache")"
export NXF_WORK="$(readlink -f "${NEXTFLOW_DIR}/work")"

# set up singularity
if [ -z "${SINGULARITY_CACHEDIR:-}" ]; then
        export SINGULARITY_CACHEDIR=/software/projects/pawsey1132/tharrop/.singularity
        export APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}"
fi

export NXF_APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}/library"
export NXF_SINGULARITY_CACHEDIR="${SINGULARITY_CACHEDIR}/library"

# set up pipeline
PIPELINE_PARAMS=(
        "--input" "${SAMPLE_ID}_ascc_samplesheet.csv"
        "--outdir" "${OUTDIR}/ascc"
        "--fcs_gx_database_path" "$(readlink -f results/fcsgx/fcsgx)"
        "-profile" "singularity,pawsey"
        "-params-file" "${SAMPLE_ID}_ascc_config.yaml"
        "-r" "${PIPELINE_VERSION}"
        "-c" "ascc.config"
)

# run
nextflow \
        -log "${NEXTFLOW_DIR}/logs/nextflow_run_ascc.$(date +"%Y%m%d%H%M%S").${RANDOM}.log" \
        run \
        sanger-tol/ascc \
        "${PIPELINE_PARAMS[@]}" \
        -resume
