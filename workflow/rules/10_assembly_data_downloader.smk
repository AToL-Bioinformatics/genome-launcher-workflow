

rule assembly_data_downloader:
    input:
        manifest=ancient(config["manifest"]),
    output:
        manifest.reads.flat_paths("raw"),
    log:
        Path(manifest.get_stage_logs("raw"), "assembly_data_downloader.log"),
    container:
        config["containers"]["atol_genome_launcher"]
    threads: 8
    resources:
        runtime="2h",
    shell:
        "assembly-data-downloader "
        "--parallel_downloads {threads} "
        "{input.manifest} "
        "&> {log}"
