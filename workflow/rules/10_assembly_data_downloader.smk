all_downloads = []

# FIXME this is nasty
for read in manifest.reads:
    for path in read.paths("raw").values():
        all_downloads.append(path)


rule assembly_data_downloader:
    input:
        config["manifest"],
    output:
        all_downloads,
    log:
        Path("logs", "assembly_data_downloader.log"),
    container:
        "docker://quay.io/biocontainers/atol-genome-launcher:0.7.2--pyhdfd78af_0"
    threads: 8
    shell:
        "assembly-data-downloader {input} 2> {log}"
