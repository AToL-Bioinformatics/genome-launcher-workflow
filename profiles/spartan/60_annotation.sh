#!/bin/bash
#SBATCH --job-name=annotation
#SBATCH --time=1-00
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=logs/slurm/annotation.%j.out
#SBATCH --error=logs/slurm/annotation.%j.err

# Source snakemake environment
source profiles/spartan/lib/snakemake_env.sh

# Setup and run
setup_snakemake

XDG_CACHE_HOME="$(mktemp -d)" \
	snakemake \
	--profile profiles/spartan \
	tiberius

# This target runs QC, uploads etc. with the standard command.
if [ $? -eq 0 ]; then
	run_snakemake post_annotation
fi
