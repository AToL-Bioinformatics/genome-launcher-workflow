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


def webin_credentials(wildcards):
    webin_user = os.getenv("WEBIN_USER", None)
    webin_pass = os.getenv("WEBIN_PASS", None)

    if not (webin_user and webin_pass):
        raise WorkflowError("Set the WEBIN_USER and WEBIN_PASS envirnoment variables")

    return f"{webin_user}:{webin_pass}"


rule ena_raw_data_broker:
    input:
        [
            Path(manifest.get_dir("results"), "broker", f"{x.name}.brokered")
            for x in manifest.reads
        ],


rule ena_raw_data_upload:
    input:
        [
            Path(manifest.get_dir("results"), "broker", f"{x.name}.transferred")
            for x in manifest.reads
        ],


# this submits the runs
rule broker_runs:
    input:
        str_path(manifest.get_dir("results"), "broker", "{bpa_package_id}.transferred"),
        unpack(get_broker_input),
        manifest=config["manifest"],
    output:
        response=str_path(
            manifest.get_dir("results"), "broker", "{bpa_package_id}.brokered"
        ),
        receipts=str_path(
            manifest.get_dir("results"), "broker", "{bpa_package_id}.tar.gz"
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
        webin_ftp=config["webin_ftp"],
        webin_credentials=webin_credentials,
    shell:
        "receipts_dir=$( mktemp -d ) ; "
        "BROKER_STATE_DIR=${{receipts_dir}} "
        "BROKER_RECEIPT_DIR=${{receipts_dir}} "
        "submit_run_to_ena "
        "-n "
        "--qc_reads_report {input.stats_file} "
        "--bpa_package_id {wildcards.bpa_package_id} "
        "{input.manifest} "
        "&> {log.log} "
        "&& "
        "tar -cv --directory ${{receipts_dir}} . "
        "| gzip -9 > {output.receipts}"


# this sends the files
rule transfer_raw_reads:
    input:
        unpack(get_broker_input),
    output:
        touch(
            str_path(
                manifest.get_dir("results"), "broker", "{bpa_package_id}.transferred"
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
