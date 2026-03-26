#!/usr/bin/env python3


def get_reads_path(name, stage):
    reads = manifest.reads.get(name)
    return reads.paths(stage)


def get_raw_reads(wildcards):
    return get_reads_path(wildcards.bpa_package_id, "raw")
