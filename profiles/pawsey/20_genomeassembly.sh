#!/bin/bash -l
#SBATCH --job-name=genomeassembly
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4g
#SBATCH --time=1-00:00:00
#SBATCH --output=logs/slurm/genomeassembly.%j.out
#SBATCH --error=logs/slurm/genomeassembly.%j.err

module load singularity/4.1.0-slurm

unset SBATCH_EXPORT

# Application specific commands:
set -eux

#set up project
SAMPLE_ID="$(basename $(dirname $(readlink -f venv)))"

PIPELINE="genomeassembly"
PIPELINE_VERSION="0.50.0"

# Set up nextflow. Download a GitHub release for the target version if
# required.
NEXTFLOW_VERSION="25.04.6"
NEXTFLOW_DIR="results/${PIPELINE}/nextflow/${NEXTFLOW_VERSION}/${PIPELINE_VERSION}"
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

# apptainer setup. SINGULARITY_CACHEDIR must be set.
if [ -z "${SINGULARITY_CACHEDIR}" ]; then
        printf "The SINGULARITY_CACHEDIR variable is required" 1>&2
        exit 1
fi
export APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}"
printf "SINGULARITY_CACHEDIR: %s\n" ${SINGULARITY_CACHEDIR} 1>&2

export NXF_APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}/library"
export NXF_SINGULARITY_CACHEDIR="${SINGULARITY_CACHEDIR}/library"

# todo. Use yaml_manifest and format the PIPELINE_PARAMS for result dir etc.
#     "pipeline_output": "results/{pipeline}/{dataset_id}.{assembly_version}",
PIPELINE_PARAMS=(
        "--input" "config/genomeassembly.yaml"
        "--outdir" "results/${PIPELINE}/${SAMPLE_ID}"
        "--enable_hic_phasing"
        "-profile" "singularity,pawsey"
        "-r" "${PIPELINE_VERSION}"
        "-c" "profiles/pawsey/genomeassembly.config"
        "--busco_lineage_directory" "resources/staging/busco/lineages"
)

# run sangertol assembly pipeline
nextflow \
        -log "${NEXTFLOW_DIR}/logs/slurm-%j-${RANDOM}.log" \
        run \
        "sanger-tol/${PIPELINE}" \
        "${PIPELINE_PARAMS[@]}" \
        -resume
