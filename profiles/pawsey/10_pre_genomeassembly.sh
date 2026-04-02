#!/bin/bash

sbatch \
    --export=ALL,SNAKEMAKE_TARGET=pre_genomeassembly \
    profiles/pawsey/genomelauncher.sh
