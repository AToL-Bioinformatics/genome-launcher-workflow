#!/usr/bin/env python3

# TODO: this is generic now, elevate it
def get_pacbio_qc_input(wilcards):
    reads = manifest.reads.get(wilcards.bpa_package_id)
    return reads.paths("raw")


pacbio_reads = manifest.pacbio_reads
qc_logs_dir = manifest.get_stage_logs("qc")

pacbio_read_paths = pacbio_reads.flat_paths("qc")
pacbio_fastq_parent = pacbio_read_paths[0].parent
pacbio_stats_parent = pacbio_reads.stats_paths("qc")[0].parent


# TODO: only handling BPA files for now, add SRR.
rule pacbio_qc_target:
    input:
        pacbio_read_paths,


rule pacbio_qc:
    input:
        unpack(get_pacbio_qc_input),
    output:
        fastq=Path(pacbio_fastq_parent, "{bpa_package_id}.fastq.gz"),
        stats=Path(pacbio_stats_parent, "{bpa_package_id}.json"),
    log:
        Path(qc_logs_dir, "pacbio_qc", "{bpa_package_id}.log"),
    container:
        "docker://quay.io/biocontainers/atol-qc-raw-pacbio:0.1.1--pyhdfd78af_0"
    threads: 8
    resources:
        mem="16GB",
    params:
        mem_gb=lambda wilcards, resources: resources.mem_mb // 1000,
        qc_logs_dir=qc_logs_dir,
    shell:
        "echo "
        "atol-qc-raw-pacbio "
        "--threads {threads} "
        "--mem {params.mem_gb} "
        "--bam {input.reads} "
        "--out {output.fastq} "
        "--logs {params.qc_logs_dir} "
        "--stats {output.stats} "
        "&> {log} "
        "; exit 1"
