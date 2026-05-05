#!/bin/bash
#SBATCH --job-name=upload_logs
#SBATCH --time=0-01
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g

# Source snakemake environment
source profiles/pawsey/lib/snakemake_env.sh

# Setup and run
setup_snakemake
run_snakemake upload_all_logs

# remove the flagfile so we can run this rule again
rm .upload_all_logs.done
