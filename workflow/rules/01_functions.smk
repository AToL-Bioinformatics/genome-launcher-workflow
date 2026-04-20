#!/usr/bin/env python3


def get_reads_path(name, stage):
    reads = manifest.reads.get(name)
    return reads.paths(stage)


def get_raw_reads(wildcards):
    return get_reads_path(wildcards.bpa_package_id, "raw")


# def replace_ext(path: Path, new_ext: str = "") -> Path:
#     extensions = "".join(Path(path).suffixes)
#     return Path(str(path).replace(extensions, new_ext))
