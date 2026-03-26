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
        params:
            qc_logs_dir=qc_logs_dir,
        shell:
            "atol-qc-raw-shortread "
            "--threads {threads} "
            "--in {input.r1} "
            "--in2 {input.r2} "
            "--logs {params.qc_logs_dir} "
            "--cram {output.cram} "
            "--stats {output.stats} "
            "&> {log} "
