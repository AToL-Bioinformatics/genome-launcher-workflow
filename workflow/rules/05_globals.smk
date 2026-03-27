#!/usr/bin/env python3

qc_logs_dir = manifest.get_stage_logs("qc")

pacbio_reads = manifest.pacbio_reads
ont_reads = manifest.ont_reads
hic_reads = manifest.hic_reads

busco_dataset = f"{manifest.busco_lineage}_odb12"
# wildcard_constraints:
#     busco_dataset=busco_dataset,
