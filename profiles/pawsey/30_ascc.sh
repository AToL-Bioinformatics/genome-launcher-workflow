#!/bin/bash -l
#SBATCH --job-name=ascc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4g
#SBATCH --time=1-00:00:00
#SBATCH --output=logs/slurm/ascc.%j.out
#SBATCH --error=logs/slurm/ascc.%j.err

module load singularity/4.1.0-slurm

unset SBATCH_EXPORT

# Application specific commands:
set -eux

#set up project
SAMPLE_ID="$(basename $(dirname $(readlink -f venv)))"
GENOMEASSEMBLY_PIPELINE="genomeassembly"
ASCC_PIPELINE="ascc"
PIPELINE_VERSION="0.5.3"


### Setting up samplesheet ###

#FILE HEADER
echo "sample,assembly_type,assembly_file" > ${SAMPLE_ID}_ascc_samplesheet.csv

#PRIMARY
#look for hifiasm-hic/scaffolding output first
if test -n "$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm-hic.*/scaffolding_hap1/yahs/asm_hap1_scaffolds_final.fa.gz -type f -print)"; then
    PRIMARY="$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm-hic.*/scaffolding_hap1/yahs/asm_hap1_scaffolds_final.fa.gz -type f -print)"
    echo "${SAMPLE_ID},PRIMARY,${PWD}/${PRIMARY}" >> ${SAMPLE_ID}_ascc_samplesheet.csv
# if not there, use hifiasm/scaffolding
elif test -n "$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/scaffolding_hap1/yahs/asm_hap1_scaffolds_final.fa.gz -type f -print)"; then
    PRIMARY="$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/scaffolding_hap1/yahs/asm_hap1_scaffolds_final.fa.gz -type f -print)"
    echo "${SAMPLE_ID},PRIMARY,${PWD}/${PRIMARY}" >> ${SAMPLE_ID}_ascc_samplesheet.csv
# if not there, use hifiasm/purgedups
elif test -n "$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/purging/asm.purged.fa.gz -type f -print)"; then
    PRIMARY="$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/purging/asm.purged.fa.gz -type f -print)"
    echo "${SAMPLE_ID},PRIMARY,${PWD}/${PRIMARY}" >> ${SAMPLE_ID}_ascc_samplesheet.csv
# throw an error if none of the above are found
else
    echo "no primary assembly files found"
    exit 1
fi

# HAPLO
#look for hifiasm-hic/scaffolding output first
if test -n "$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm-hic.*/scaffolding_hap2/yahs/asm_hap2_scaffolds_final.fa.gz -type f -print)"; then
    HAPLO="$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm-hic.*/scaffolding_hap2/yahs/asm_hap2_scaffolds_final.fa.gz -type f -print)"
    echo "${SAMPLE_ID},HAPLO,${PWD}/${HAPLO}" >> ${SAMPLE_ID}_ascc_samplesheet.csv
# if not there, use hifiasm/scaffolding
elif test -n "$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/scaffolding_hap2/yahs/asm_hap2_scaffolds_final.fa.gz -type f -print)"; then
    HAPLO="$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/scaffolding_hap2/yahs/asm_hap2_scaffolds_final.fa.gz -type f -print)"
    echo "${SAMPLE_ID},HAPLO,${PWD}/${HAPLO}" >> ${SAMPLE_ID}_ascc_samplesheet.csv
# if not there, use hifiasm/purgedups
elif test -n "$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/purging/asm.htigs.all.fa.gz -type f -print)"; then
    HAPLO="$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/purging/asm.htigs.all.fa.gz -type f -print)"
    echo "${SAMPLE_ID},HAPLO,${PWD}/${HAPLO}" >> ${SAMPLE_ID}_ascc_samplesheet.csv
# throw an error if none of the above are found
else
    echo "no alternate assembly files found"
    exit 1
fi

# MITO
#look for mitohifi read-mode output first
if test -n "$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/mito.reads/final_mitogenome.fasta -type f -print)"; then
    MITO="$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/mito.reads/final_mitogenome.fasta -type f -print)"
    echo "${SAMPLE_ID},MITO,${PWD}/${MITO}" >> ${SAMPLE_ID}_ascc_samplesheet.csv
# if not there, look for mitohifi contigs mode
elif test -n "$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/mito/final_mitogenome.fasta -type f -print)"; then
    MITO="$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/mito/final_mitogenome.fasta -type f -print)"
    echo "${SAMPLE_ID},MITO,${PWD}/${MITO}" >> ${SAMPLE_ID}_ascc_samplesheet.csv
#if not there, look for oatk output
elif test -n "$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/mito.oatk/*.mito.ctg.fasta -type f -print)"; then
    MITO="$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/mito.oatk/*.mito.ctg.fasta -type f -print)"
    echo "${SAMPLE_ID},MITO,${PWD}/${MITO}" >> ${SAMPLE_ID}_ascc_samplesheet.csv
else
    echo "no mitochondrial assembly found"
fi

# PLASTID
# look for oatk output
if test -n "$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/mito.oatk/*.pltd.ctg.fasta -type f -print)"; then 
    PLASTID="$(find results/${GENOMEASSEMBLY_PIPELINE}/${SAMPLE_ID}/${SAMPLE_ID}.hifiasm.*/mito.oatk/*.pltd.ctg.fasta -type f -print)"
    echo "${SAMPLE_ID},PLASTID,${PWD}/${PLASTID}" >> ${SAMPLE_ID}_ascc_samplesheet.csv
else
    echo "no plastid assembly found"
fi

######


# Set up nextflow. Download a GitHub release for the target version if
# required.
NEXTFLOW_VERSION="25.04.8"
NEXTFLOW_DIR="results/${ASCC_PIPELINE}/nextflow/${NEXTFLOW_VERSION}/${PIPELINE_VERSION}"
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


# set up pipeline
PIPELINE_PARAMS=(
        "--input" "${SAMPLE_ID}_ascc_samplesheet.csv"
        "--outdir" "results/${ASCC_PIPELINE}/${SAMPLE_ID}"
        "--fcs_gx_database_path" "$(readlink -f results/fcsgx/fcsgx)"
        "-profile" "singularity,pawsey"
        "-params-file" "config/ascc.yaml"
        "-r" "${PIPELINE_VERSION}"
        "-c" "profiles/pawsey/ascc.config"
)

# run
nextflow \
        -log "${NEXTFLOW_DIR}/logs/nextflow-${SLURM_JOB_ID}.log" \
        run \
        sanger-tol/ascc \
        "${PIPELINE_PARAMS[@]}" \
        -resume
