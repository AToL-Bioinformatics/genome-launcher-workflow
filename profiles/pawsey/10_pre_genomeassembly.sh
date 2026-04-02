#!/bin/bash

sbatch --export=ALL,SNAKEMAKE_TARGET=pre_genomeassembly genomelauncher.sh
