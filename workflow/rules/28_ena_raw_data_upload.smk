#!/usr/bin/env python3


def get_broker_input(wildcards):
    read_file = manifest.reads.get(wildcards.bpa_package_id)
    reads = read_file.paths("qc")
    reads["stats_file"] = read_file.stats_path("qc")
    return reads


def generate_md5sum_file(wildcards, input):
    with open(input.stats_file, "rb") as f:
        stats_data = json.load(f)
    input_reads_name = Path(input.reads).name
    md5sum = stats_data.get("checksums").get(input_reads_name).get("md5")
    md5sum_file = Path(tempfile.mkdtemp(), f"{input_reads_name}.md5")
    with open(md5sum_file, "wt") as f:
        f.write(f"{md5sum} {input_reads_name}\n")
    return md5sum_file


def webin_credentials(wildcards):
    webin_user = os.getenv("WEBIN_USER", None)
    webin_pass = os.getenv("WEBIN_PASS", None)

    if not (webin_user and webin_pass):
        raise WorkflowError("Set the WEBIN_USER and WEBIN_PASS envirnoment variables")

    return f"{webin_user}:{webin_pass}"


rule ena_raw_data_upload:
    input:
        [
            Path(manifest.get_dir("results"), "brokered_reads", f"{x.name}.done")
            for x in manifest.reads
        ],


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
        stats=Path(log_dir_base, "broker_raw_reads", "{bpa_package_id}.json"),  # Bytes per second
    benchmark:
        Path(
            log_dir_base, "broker_raw_reads", "{bpa_package_id}.stats.jsonl"
        ).as_posix()
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
