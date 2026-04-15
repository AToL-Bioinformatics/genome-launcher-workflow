#!/usr/bin/env python3

# TODO: only handling BPA files for now, add SRR.

if len(hic_reads) > 0:
    hic_cram_parent = hic_reads.flat_paths("qc")[0].parent
    hic_stats_parent = hic_reads.stats_paths("qc")[0].parent
    hic_log_parent = hic_reads[0].log_path("qc").parent

    rule hic_qc:
        input:
            unpack(get_raw_reads),
        output:
            cram=Path(hic_cram_parent, "{bpa_package_id}.cram"),
            stats=Path(hic_stats_parent, "{bpa_package_id}.json"),
        log:
            Path(hic_log_parent, "{bpa_package_id}.log"),
        container:
            config["containers"]["atol_qc_raw_shortread"]
        threads: 12
        resources:
            mem="16GB",
            runtime="4h",
        params:
            dataset_id=manifest.dataset_id,
            hic_kit=config["hic_kit"],
            qc_logs_dir=lambda wildcards: Path(qc_logs_dir, wildcards.bpa_package_id),
        shell:
            "atol-qc-raw-shortread "
            "--cram {output.cram} "
            "--dataset_id {params.dataset_id} "
            "--hic_kit {params.hic_kit} "
            "--in {input.r1} "
            "--in2 {input.r2} "
            "--logs {params.qc_logs_dir} "
            "--stats {output.stats} "
            "--threads {threads} "
            "&> {log} "
