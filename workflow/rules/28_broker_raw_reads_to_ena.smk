#!/usr/bin/env python3


def get_broker_input(wildcards):
    read_file = manifest.reads.get(wildcards.bpa_package_id)
    reads = {k: str_path(v) for k, v in read_file.paths("qc").items()}
    reads["stats_file"] = str_path(read_file.stats_path("qc"))
    return reads


def generate_md5sum_file(wildcards, input):
    with open(input.stats_file, "rb") as f:
        stats_data = json.load(f)
    input_reads_name = Path(input.reads).name
    md5sum = stats_data.get("checksums").get(input_reads_name).get("md5")
    md5sum_file = str_path(tempfile.mkdtemp(), f"{input_reads_name}.md5")
    with open(md5sum_file, "wt") as f:
        f.write(f"{md5sum} {input_reads_name}\n")
    return md5sum_file


rule broker_raw_reads_to_ena:
    input:
        [
            Path(
                manifest.get_dir("receipts"),
                "broker",
                f"{x.name}",
                "broker_runs.done",
            )
            for x in manifest.reads
        ],


rule transfer_raw_reads_to_ena:
    input:
        [
            Path(
                manifest.get_dir("receipts"),
                "broker",
                f"{x.name}",
                "transfer_raw_reads.done",
            )
            for x in manifest.reads
        ],


# this submits the runs
rule broker_runs:
    input:
        str_path(
            manifest.get_dir("receipts"),
            "broker",
            "{bpa_package_id}",
            "transfer_raw_reads.done",
        ),
        unpack(get_broker_input),
        manifest=config["manifest"],
    output:
        flagfile=touch(
            str_path(
                manifest.get_dir("receipts"),
                "broker",
                "{bpa_package_id}",
                "broker_runs.done",
            )
        ),
    log:
        log=str_path(log_dir_base, "broker_runs", "{bpa_package_id}.log"),
        stats=str_path(log_dir_base, "broker_runs", "{bpa_package_id}.json"),
    benchmark:
        str_path(log_dir_base, "broker_runs", "{bpa_package_id}.stats.jsonl")
    container:
        config["containers"]["atol_genome_launcher"]
    resources:
        runtime="10m",
    params:
        outdir=subpath(output.flagfile, parent=True),
    shell:
        "BROKER_STATE_DIR=$( readlink -f {params.outdir} ) "
        "BROKER_RECEIPT_DIR=$( readlink -f {params.outdir} ) "
        "submit-run-to-ena "
        "--qc_reads_report {input.stats_file} "
        "--bpa_package_id {wildcards.bpa_package_id} "
        "{input.manifest} "
        "&> {log.log} "


# this sends the files
rule transfer_raw_reads:
    input:
        unpack(get_broker_input),
    output:
        touch(
            str_path(
                manifest.get_dir("receipts"),
                "broker",
                "{bpa_package_id}",
                "transfer_raw_reads.done",
            )
        ),
    log:
        log=str_path(log_dir_base, "transfer_raw_reads", "{bpa_package_id}.log"),
        stats=str_path(log_dir_base, "transfer_raw_reads", "{bpa_package_id}.json"),  # Bytes per second
    benchmark:
        str_path(log_dir_base, "transfer_raw_reads", "{bpa_package_id}.stats.jsonl")
    container:
        config["containers"]["curl"]
    resources:
        runtime="4h",
        shell_exec="sh",
    params:
        md5sum_file=generate_md5sum_file,
        webin_ftp=config["webin_ftp"],
        webin_credentials=webin_credentials,
    shell:
        "curl "
        "--upload-file {params.md5sum_file} "
        "--user {params.webin_credentials} "
        "{params.webin_ftp} "
        "2> {log.log} "
        "&& "
        "curl "
        "--upload-file {input.reads} "
        "--user {params.webin_credentials} "
        "-v "
        "--write-out '%{{json}}' "
        "{params.webin_ftp} "
        "> {log.stats} "
        "2>> {log.log} "
