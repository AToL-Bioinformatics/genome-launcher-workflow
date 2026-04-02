#!/bin/bash

sbatch \
    --export=ALL,SNAKEMAKE_TARGET=post_genomeassembly \
    profiles/pawsey/genomelauncher.sh
