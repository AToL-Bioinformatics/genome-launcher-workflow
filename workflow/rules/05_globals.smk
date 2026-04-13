#!/usr/bin/env python3


# Variables for S3 transfers. Set them to empty strings at runtime if you're
# not using them.
envvars:
    "RCLONE_S3_ACCESS_KEY_ID",
    "RCLONE_S3_ENDPOINT",
    "RCLONE_S3_PROVIDER",
    "RCLONE_S3_SECRET_ACCESS_KEY",


log_dir_base = manifest.get_dir("logs")
qc_logs_dir = manifest.get_stage_logs("qc")

pacbio_reads = manifest.pacbio_reads
ont_reads = manifest.ont_reads
hic_reads = manifest.hic_reads


odb12_busco_dataset = f"{manifest.busco_odb12_dataset_name}_odb12"
odb10_busco_dataset = f"{manifest.busco_odb10_dataset_name}_odb10"

sample_id = ".".join([manifest.dataset_id, str(manifest.assembly_version)])

# wildcard_constraints:
#     busco_dataset=busco_dataset,
