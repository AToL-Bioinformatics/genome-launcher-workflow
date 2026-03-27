#!/usr/bin/env python3


busco_directory_url = "https://busco-data.ezlab.org/v5/data"
busco_manifest_path = "file_versions.tsv"


def get_lineage_hash(wildcards, input):
    manifest = get_my_manifest(input.busco_manifest, wildcards.busco_dataset)
    return manifest["hash"]


def get_lineage_url(wildcards, input):
    # e.g.
    # https://busco-data.ezlab.org/v5/data/lineages/vertebrata_odb10.2024-01-08.tar.gz
    manifest = get_my_manifest(input.busco_manifest, wildcards.busco_dataset)
    return f"{busco_directory_url}/lineages/{wildcards.busco_dataset}.{manifest['date']}.tar.gz"


def get_my_manifest(busco_manifest, lineage):
    manifest = read_manifest(busco_manifest)
    return manifest[lineage]


@cache
def read_manifest(manifest):
    lineage_to_hash = {}
    with open(manifest) as f:
        for line in f:
            line_split = line.strip().split("\t")
            if line_split[4] == "lineages":
                lineage_to_hash[line_split[0]] = {
                    "date": line_split[1],
                    "hash": line_split[2],
                }
    return lineage_to_hash


rule expand_busco_lineage_files:
    input:
        busco_dataset=Path("resources", "busco_lineage_files", "{busco_dataset}.tar.gz"),
    output:
        lineage_directory=directory(
            Path("resources", "staging", "busco", "lineages", "{busco_dataset}")
        ),
    log:
        Path("logs", "staging", "expand_busco_lineage_files", "{busco_dataset}.log"),
    container:
        config["containers"]["pigz"]
    resources:
        runtime=lambda wildcards, attempt: int(attempt * 10),
    shell:
        "mkdir -p {output.lineage_directory} && "
        "tar -zxf {input} -C {output.lineage_directory} --strip-components 1 &> {log} && "
        "printf $(date -Iseconds) > {output.lineage_directory}/TIMESTAMP"


rule download_busco_lineage_files:
    input:
        busco_manifest=Path("resources", "busco_lineage_files", "file_versions.tsv"),
    output:
        busco_dataset=Path("resources", "busco_lineage_files", "{busco_dataset}.tar.gz"),
    log:
        Path("logs", "staging", "download_busco_lineage_files", "{busco_dataset}.log"),
    retries: 3
    shadow:
        "minimal"
    container:
        config["containers"]["wget"]
    resources:
        runtime=lambda wildcards, attempt: int(attempt * 10),
    params:
        lineage_url=get_lineage_url,
        lineage_hash=get_lineage_hash,
    shell:
        "wget -O {output} {params.lineage_url} &> {log} && "
        "printf '%s %s' {params.lineage_hash}  {output} | md5sum -c - &>> {log}"


rule download_busco_manifest:
    output:
        busco_manifest=Path("resources", "busco_lineage_files", "file_versions.tsv"),
    log:
        Path("logs", "staging", "download_busco_manifest.log"),
    container:
        config["containers"]["wget"]
    params:
        busco_manifest_url=f"{busco_directory_url}/{busco_manifest_path}",
    shell:
        "wget {params.busco_manifest_url} -O {output} &> {log}"
