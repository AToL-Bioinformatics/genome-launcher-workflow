

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
        bucket=f"{manifest.dataset_id}.{manifest.assembly_version}",
    shell:
        "pipeline-result-uploader "
        "--parallel_downloads {threads} "
        "--stage {wildcards.pipeline} "
        "--bucket {params.bucket} "
        "{input.manifest} "
        "{output.receipts} "
        "&> {log}"
