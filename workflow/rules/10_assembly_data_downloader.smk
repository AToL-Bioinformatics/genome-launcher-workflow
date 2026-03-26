

rule assembly_data_downloader:
    input:
        manifest=config["manifest"],
    output:
        manifest.reads.flat_paths("raw"),
    log:
        Path(manifest.get_stage_logs("raw"), "assembly_data_downloader.log"),
    container:
        "docker://quay.io/biocontainers/atol-genome-launcher:0.7.2--pyhdfd78af_0"
    threads: 8
    shell:
        "assembly-data-downloader {input.manifest} 2> {log}"
