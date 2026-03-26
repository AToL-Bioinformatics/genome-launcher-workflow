#!/usr/bin/env python3

# TODO: only handling BPA files for now, add SRR.

if len(pacbio_reads) > 0:
    pacbio_fastq_parent = pacbio_reads.flat_paths("qc")[0].parent
    pacbio_stats_parent = pacbio_reads.stats_paths("qc")[0].parent
    pacbio_log_parent = pacbio_reads[0].log_path("qc").parent

    rule pacbio_qc:
        input:
            unpack(get_raw_reads),
        output:
            fastq=Path(pacbio_fastq_parent, "{bpa_package_id}.fastq.gz"),
            stats=Path(pacbio_stats_parent, "{bpa_package_id}.json"),
        log:
            Path(pacbio_log_parent, "{bpa_package_id}.log"),
        container:
            "docker://quay.io/biocontainers/atol-qc-raw-pacbio:0.1.1--pyhdfd78af_0"
        threads: 8
        resources:
            mem="16GB",
        params:
            mem_gb=lambda wildcards, resources: resources.mem_mb // 1000,
            qc_logs_dir=qc_logs_dir,
        shell:
            "atol-qc-raw-pacbio "
            "--threads {threads} "
            "--mem {params.mem_gb} "
            "--bam {input.reads} "
            "--out {output.fastq} "
            "--logs {params.qc_logs_dir} "
            "--stats {output.stats} "
            "&> {log} "
