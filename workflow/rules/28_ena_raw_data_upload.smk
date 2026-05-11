#!/usr/bin/env python3


# Plan: read the stats file, return params, use the params to upload.

# Needs a target to collect all the flag files. (DONE)

# Needs a flag file to indicate the upload completed. Quick way is to use the
# parent of the stat/read file. (DONE)

# Needs a function to get the input stats/read file from the flag file. TODO:
# handle multiple files per bpa_package_id

# Manifest has the json stat files defined.


rule ena_raw_data_upload:
    input:
        [
            Path(manifest.get_dir("results"), "brokered_reads", f"{x.name}.done")
            for x in manifest.reads
        ],


# raise ValueError()


def get_broker_input(wildcards):
    read_file = manifest.reads.get(wildcards.bpa_package_id)
    reads = read_file.paths("qc")
    reads["stats_file"] = read_file.stats_path("qc")
    return reads


def read_md5sum(wildcards, input):
    with open(input.stats_file, "rb") as f:
        stats_data = json.load(f)
    md5sum = stats_data.get("checksums").get(Path(input.reads).name).get("md5")
    return md5sum


rule broker_raw_reads:
    input:
        unpack(get_broker_input),
    output:
        touch(
            Path(
                manifest.get_dir("results"), "brokered_reads", "{bpa_package_id}.done"
            )
        ),
    log:
        log=Path(log_dir_base, "broker_raw_reads", "{bpa_package_id}.log"),
        trace=Path(log_dir_base, "broker_raw_reads", "{bpa_package_id}.trace.txt"),
    container:
        config["containers"]["curl"]
    resources:
        runtime="4h",
        shell_exec="sh",
    params:
        md5sum=read_md5sum,
        reads_name=subpath(input.reads, basename=True),
        webin_ftp=config["webin_ftp"],
    shell:
        "printf '%s %s' {params.md5sum} {params.reads_name} > {input.reads}.md5 "
        "&& "
        "curl "
        "--verbose "
        "--upload-file {input.reads}.md5 "
        "--user USER:PASS "
        "{params.webin_ftp} "
        "&> {log.log} "
        "&& "
        "curl "
        "--verbose "
        "--upload-file {input.reads} "
        "--user USER:PASS "
        "--trace-ascii {log.trace} "
        "{params.webin_ftp} "
        "2>&1 >> {log.log} "
