#!/usr/bin/env python3

pacbio_read_paths = [x.paths("qc").get("reads") for x in manifest.pacbio_reads]


def tbd(wilcards):
    raise ValueError(wilcards)


def get_pacbio_qc_input(wilcards):
    reads = manifest.reads.get(wilcards.bpa_package_id)
    return reads.paths("raw").get("reads")


# TODO: only handling BPA files for now, add SRR.
rule pacbio_qc_target:
    input:
        pacbio_read_paths,


# todo manifest logs
rule pacbio_qc:
    input:
        get_pacbio_qc_input,
    # TODO should get this from the manifest. Should be globals in this file.
    output:
        fastq="results/qc/reads/PACBIO_SMRT/{bpa_package_id}.fastq.gz",
        stats="results/qc/stats/PACBIO_SMRT/{bpa_package_id}.json",
    log:
        "logs/qc/PACBIO_SMRT/{bpa_package_id}.log",
    container:
        "docker://quay.io/biocontainers/atol-qc-raw-pacbio:0.1.1--pyhdfd78af_0"
    threads: 8
    resources:
        mem="16GB",
    params:
        logs_dir=lambda wildcards: manifest.get_stage_logs("qc"),
        mem_gb=lambda wilcards, resources: resources.mem_mb // 1000,
    shell:
        "echo "
        "atol-qc-raw-pacbio "
        "--threads {threads} "
        "--mem {params.mem_gb} "
        "--bam {input} "
        "--out {output.fastq} "
        "--logs {params.logs_dir} "
        "--stats {output.stats} "
        "&> {log} "
        "; exit 1"
