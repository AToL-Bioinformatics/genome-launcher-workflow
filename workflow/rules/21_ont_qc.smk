#!/usr/bin/env python3

# TODO: only handling BPA files for now, add SRR.
# TODO: ONT reads could be a list of fastq files, need to handle this here

if len(ont_reads) > 0:
    ont_fastq_parent = ont_reads.flat_paths("qc")[0].parent
    ont_stats_parent = ont_reads.stats_paths("qc")[0].parent
    ont_log_parent = ont_reads[0].log_path("qc").parent

    rule ont_qc:
        input:
            ancient(unpack(get_raw_reads)),
        output:
            fastq=Path(ont_fastq_parent, "{bpa_package_id}.fastq.gz"),
            stats=Path(ont_stats_parent, "{bpa_package_id}.json"),
        log:
            Path(ont_log_parent, "{bpa_package_id}.log"),
        container:
            config["containers"]["atol_qc_raw_ont"]
        threads: lambda wildcards, attempt: int(64 * attempt)
        resources:
            mem=lambda wildcards, attempt: f"{int(255* attempt)}GB",
            runtime="24h",
        params:
            qc_logs_dir=lambda wildcards: Path(qc_logs_dir, wildcards.bpa_package_id),
            min_length=1000,
        shell:
            "atol-qc-raw-ont "
            "--threads {threads} "
            "--min-length {params.min_length} "
            "--tarfile {input.single_end} "
            "--logs {params.qc_logs_dir} "
            "--out {output.fastq} "
            "--stats {output.stats} "
            "&> {log} "
