

rule assembly_data_downloader:
    input:
        manifest=config["manifest"],
    output:
        manifest.reads.flat_paths("raw"),
    log:
        Path(manifest.get_stage_logs("raw"), "assembly_data_downloader.log"),
    container:
        config["containers"]["atol_genome_launcher"]
    threads: 8
    shell:
        "assembly-data-downloader {input.manifest} 2> {log}"
