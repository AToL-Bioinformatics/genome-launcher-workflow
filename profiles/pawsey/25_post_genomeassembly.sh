#!/bin/bash

sbatch --export=ALL,SNAKEMAKE_TARGET=post_genomeassembly genomelauncher.sh
