#!/usr/bin/env python3


# TODO: this is generic now, elevate it
def get_hic_qc_input(wilcards):
    reads = manifest.reads.get(wilcards.bpa_package_id)
    return reads.paths("raw")


hic_reads = manifest.hic_reads
qc_logs_dir = manifest.get_stage_logs("qc")

hic_read_paths = hic_reads.flat_paths("qc")
hic_cram_parent = hic_read_paths[0].parent
hic_stats_parent = hic_reads.stats_paths("qc")[0].parent


# TODO: only handling BPA files for now, add SRR.
rule hic_qc_target:
    input:
        hic_read_paths,


# FIXME! copied directly from pacbio
rule hic_qc:
    input:
        unpack(get_hic_qc_input),
    output:
        cram=Path(hic_cram_parent, "{bpa_package_id}.cram"),
        stats=Path(hic_stats_parent, "{bpa_package_id}.json"),
    log:
        Path(qc_logs_dir, "hic_qc", "{bpa_package_id}.log"),
    container:
        "docker://quay.io/biocontainers/atol-qc-raw-shortread:0.3.1--pyhdfd78af_0"
    threads: 12
    params:
        qc_logs_dir=qc_logs_dir,
    shell:
        "echo "
        "atol-qc-raw-shortread "
        "--threads {threads} "
        "--in {input.r1} "
        "--in2 {input.r2} "
        "--logs {params.qc_logs_dir} "
        "--cram {output.cram} "
        "--stats {output.stats} "
        "&> {log} "
        "; exit 1"
