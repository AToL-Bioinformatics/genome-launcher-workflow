#!/bin/bash -l
#SBATCH --job-name=atol-launcher-Saiphos_equalis
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4g
#SBATCH --time=1-00:00:00
#SBATCH --account=pawsey1132
#SBATCH --partition=work

module load singularity/4.1.0-nohost
module load nextflow/25.04.6

unset SBATCH_EXPORT

# Application specific commands:
set -eux

#set up project
SAMPLE_ID=rSaiEqu1 #ToLID
VERSION=v1 #assembly version
CONFIG=genomeassembly.config
BUSCO_DIR=/scratch/pawsey1132/atims/busco/
PIPELINE_VERSION="0.50.0"
WORKDIR=/scratch/pawsey1132/atims/new_pipeline_version/work_rSaiEqu1_sangertol

# where to put singularity files
if [ -z "${SINGULARITY_CACHEDIR}" ]; then
        export SINGULARITY_CACHEDIR=/software/projects/pawsey1132/atims/.singularity
        export APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}"
fi

export NXF_APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}/library"
export NXF_SINGULARITY_CACHEDIR="${SINGULARITY_CACHEDIR}/library"
export NXF_WORK="${WORKDIR}"

PIPELINE_PARAMS=(
        "--input" "./genomeassembly_config.yaml"
        "--outdir" "/scratch/pawsey1132/tharrop/atol-genome-launcher-testing/${SAMPLE_ID}/sanger_tol/${SAMPLE_ID}.${VERSION}"
        "--enable_hic_phasing"
        "-profile" "singularity,pawsey"
        "-r" "${PIPELINE_VERSION}"
        "-c" "${CONFIG}"
        "--busco_lineage_directory" "${BUSCO_DIR}"
)

# check sangertol assembly pipeline before running
nextflow \
        -log "nextflow_logs/nextflow_inspect_genomeassembly.$(date +"%Y%m%d%H%M%S").${RANDOM}.log" \
        inspect \
        -concretize sanger-tol/genomeassembly \
        "${PIPELINE_PARAMS[@]}"
#exit 0

# run sangertol assembly pipeline
nextflow \
        -log "nextflow_logs/nextflow_run_genomeassembly.$(date +"%Y%m%d%H%M%S").${RANDOM}.log" \
        run \
        sanger-tol/genomeassembly \
        "${PIPELINE_PARAMS[@]}"