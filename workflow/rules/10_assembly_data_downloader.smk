#!/usr/bin/env python3


def format_download_params(wildcards):
    download_params = manifest.reads.lane_url(Path(wildcards.raw_file))
    base_url = download_params.get("base_url")
    download_params["base_url_param"] = f"--base_url {base_url}" if base_url else ""

    return download_params


rule collect_lane_files:
    input:
        lambda wildcards: manifest.reads.collected_path_to_raw_paths(
            Path(wildcards.collected_file)
        ),
    output:
        Path("{collected_file}"),
    wildcard_constraints:
        collected_file="|".join([str(x) for x in manifest.reads.flat_paths("raw")]),
    container:
        config["containers"]["pigz"]
    resources:
        runtime=lambda wildcards, attempt: f"{int(1* attempt)}h",
    shell:
        "cat {input} > {output}"


rule download_file:
    output:
        read_file=temp(Path("{raw_file}")),
        check_file=temp(Path("{raw_file}.check.txt")),
    log:
        Path(manifest.get_stage_logs("raw"), "download_file", "{raw_file}.log"),
    wildcard_constraints:
        raw_file="|".join([str(x) for x in manifest.reads.all_raw_paths]),
    retries: 2
    container:
        config["containers"]["atol_genome_launcher"]
    resources:
        runtime=lambda wildcards, attempt: f"{int(4* attempt)}h",
    params:
        params=format_download_params,
    shell:
        "bpa-file-downloader "
        "--file_checksum {params.params[md5sum]} "
        "{params.params[base_url_param]} "
        "{params.params[url]} "
        "{output.read_file} "
        "&> {log}"
