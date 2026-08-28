#!/usr/bin/env python3


rule report_pipeline_result_to_canopy:
    input:
        manifest=config["manifest"],
        git_log=str_path(manifest.get_dir("git_logs"), "{pipeline}.json"),
        receipts=str_path(manifest.get_dir("receipts"), "{pipeline}.jsonl"),
    output:
        assembly_run_list=str_path(
            manifest.get_dir("receipts"), "{pipeline}.assembly_run_list.json"
        ),
        stage_run_list=str_path(
            manifest.get_dir("receipts"), "{pipeline}.stage_run_list.json"
        ),
    log:
        log=str_path(log_dir_base, "report_pipeline_result_to_canopy", "{pipeline}.log"),
        stats=str_path(
            log_dir_base, "report_pipeline_result_to_canopy", "{pipeline}.json"
        ),
    benchmark:
        str_path(
            log_dir_base, "report_pipeline_result_to_canopy", "{pipeline}.stats.jsonl"
        )
    container:
        config["containers"]["atol_genome_launcher"]
    shell:
        "report-pipeline-result-to-canopy "
        "--git_log {input.git_log} "
        "--receipts {input.receipts} "
        "--assembly_run_list {output.assembly_run_list} "
        "--stage_run_list {output.stage_run_list} "
        "{input.manifest} "
        "&> {log}"
