def remote_log_file(wildcards):
    temp_tar_file = Path(
        tempfile.mkstemp(suffix=".tar.gz", prefix=f"logs.{date.today()}.")[1]
    )
    remote_tar_file = Path(log_dir_base, temp_tar_file.name)
    return {"temp_tar_file": temp_tar_file, "remote_tar_file": remote_tar_file}


rule pipeline_result_uploader:
    input:
        manifest=config["manifest"],
    output:
        receipts=Path(
            manifest.get_dir("results"), "upload_receipts", "{pipeline}.jsonl"
        ),
    log:
        Path(log_dir_base, "{pipeline}", "pipeline_result_uploader.log"),
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
        manifest=config["manifest"],
    output:
        touch(Path(".upload_all_logs.done")),
    container:
        config["containers"]["atol_genome_launcher"]
    params:
        bucket=f"{manifest.dataset_id}.{manifest.assembly_version}".lower(),
        logs_dir=log_dir_base,
        tar_files=remote_log_file,
    resources:
        runtime="10m",    
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
