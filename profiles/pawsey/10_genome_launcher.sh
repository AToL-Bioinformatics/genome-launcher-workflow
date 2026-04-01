#!/bin/bash

#SBATCH --job-name=genome-launcher
#SBATCH --time=0-12
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

# The virtual environment has to be created before running snakemake. See
# profiles/pawsey/preflight.
source venv/bin/activate

# The workflow needs to know where the AWS endpoint is.
export RCLONE_CONFIG_UPLOAD_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export RCLONE_CONFIG_UPLOAD_ENDPOINT=https://projects.pawsey.org.au
export RCLONE_CONFIG_UPLOAD_PROVIDER=Ceph
export RCLONE_CONFIG_UPLOAD_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export RCLONE_CONFIG_UPLOAD_TYPE=s3

export RCLONE_S3_ACCESS_KEY_ID="${RCLONE_CONFIG_UPLOAD_ACCESS_KEY_ID}"
export RCLONE_S3_ENDPOINT="${RCLONE_CONFIG_UPLOAD_ENDPOINT}"
export RCLONE_S3_PROVIDER="${RCLONE_CONFIG_UPLOAD_PROVIDER}"
export RCLONE_S3_SECRET_ACCESS_KEY="${RCLONE_CONFIG_UPLOAD_SECRET_ACCESS_KEY}"

# Setting XDG_CACHE_HOME to a tmpdir on the node is a workaround for a
# snakemake issue. If you let it cache the workflow you get "Failed to get
# mtime of cached git source file 0.1.1:workflow/Snakefile"
XDG_CACHE_HOME="$(mktemp -d)" \
        snakemake --profile profiles/pawsey
