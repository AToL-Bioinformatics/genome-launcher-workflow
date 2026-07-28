#!/usr/bin/env python3


def get_temp_tarfiles(wildcards):

    dir_name = wildcards.dir_name
    temp_tar_file = Path(
        tempfile.mkstemp(suffix=".tar.gz", prefix=f"{dir_name}.{date.today()}.")[1]
    )

    try:
        remote_tar_file = Path(manifest.get_dir(dir_name), temp_tar_file.name)
    # if we don't know this directory, just upload it in results
    except KeyError:
        remote_tar_file = Path("results", dir_name, temp_tar_file.name)

    return {"temp_tar_file": temp_tar_file, "remote_tar_file": remote_tar_file}


def get_local_logs_dir(wildcards):
    try:
        return manifest.get_dir(wildcards.dir_name)
    except KeyError as e:
        if wildcards.dir_name == "receipts":
            return str_path(manifest.get_dir("results"), "upload_receipts")
        else:
            raise e


_log_dir_names = ["logs", "qc_stats", "receipts"]


rule pipeline_result_uploader:
    input:
        manifest=config["manifest"],
    output:
        receipts=str_path(
            manifest.get_dir("results"), "upload_receipts", "{pipeline}.jsonl"
        ),
    log:
        str_path(log_dir_base, "{pipeline}", "pipeline_result_uploader.log"),
    benchmark:
        str_path(log_dir_base, "{pipeline}", "pipeline_result_uploader.stats.jsonl")
    container:
        config["containers"]["atol_genome_launcher"]
    threads: 8
    resources:
        runtime="2h",
    params:
        bucket=f"{manifest.dataset_id}.{manifest.assembly_version}".lower(),
    shell:
        "pipeline-result-uploader "
        "--parallel_downloads {threads} "
        "--stage {wildcards.pipeline} "
        "--bucket {params.bucket} "
        "{input.manifest} "
        "{output.receipts} "
        "&> {log}"


rule upload_all_logs:
    input:
        expand(
            Path(".{dir_name}.upload_all_logs.done"),
            dir_name=_log_dir_names,
        ),


rule upload_logs:
    input:
        manifest=config["manifest"],
    output:
        touch(Path(".{dir_name}.upload_all_logs.done")),
    wildcard_constraints:
        dir_name="|".join(_log_dir_names),
    container:
        config["containers"]["atol_genome_launcher"]
    resources:
        runtime="10m",
    params:
        bucket=f"{manifest.dataset_id}.{manifest.assembly_version}".lower(),
        tar_files=get_temp_tarfiles,
        logs_dir=get_local_logs_dir,
    shell:
        "tar -cv "
        "--directory {params.logs_dir}/ "
        ". "
        "| pigz -9 > {params.tar_files[temp_tar_file]} "
        "&& "
        "result-file-uploader "
        "--bucket {params.bucket} "
        "{params.tar_files[temp_tar_file]} "
        "{params.tar_files[remote_tar_file]} "
