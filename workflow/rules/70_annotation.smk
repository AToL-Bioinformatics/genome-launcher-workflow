def get_tiberius_model_cfg(wildcards, input):
    if manifest.tiberius_model_cfg is None:
        logger.error(
            (
                "The Manifest doesn't specify tiberius_model_cfg. "
                "This is currently parsed from augustus_dataset_name. "
                "See https://github.com/AustralianBioCommons/atol-canopy/issues/67."
            )
        )
        return None
    return manifest.tiberius_model_cfg


rule annotation:
    input:
        str_path(
            manifest.treeval_assembly.outputs_for("annotation").get(
                "annooddities_stats"
            )
        ),
        qc_busco_json=str_path(
            manifest.treeval_assembly.outputs_for("annotation").get("qc_busco_json")
        ),


rule atol_qc_annotation:
    input:
        gtf=str_path(manifest.treeval_assembly.outputs_for("annotation").get("gtf")),
        fasta=str_path(manifest.treeval_assembly.outputs_for("ascc").get("PRIMARY")),
        busco_lineage=str_path(
            "resources", "staging", "busco", "lineages", odb12_busco_dataset
        ),
        # db="data/omark/LUCA.h5", FIXME
        # ete_ncbi_db="data/omark/ete/taxa.sqlite",  FIXME
    output:
        qc_busco_json=str_path(
            manifest.treeval_assembly.outputs_for("annotation").get("qc_busco_json")
        ),
        qc_busco_txt=str_path(
            manifest.treeval_assembly.outputs_for("annotation").get("qc_busco_txt")
        ),
        qc_omark=str_path(
            manifest.treeval_assembly.outputs_for("annotation").get("qc_omark")
        ),
        qc_proteins=str_path(
            manifest.treeval_assembly.outputs_for("annotation").get("qc_proteins")
        ),
    log:
        str_path(
            manifest.get_stage_logs("annotation"), "atol_qc_annotation.primary.log"
        ),
    benchmark:
        str_path(
            manifest.get_stage_logs("annotation"),
            "atol_qc_annotation.primary.stats.jsonl",
        )
    container:
        config["containers"]["atol_qc_annotation"]
    threads: 16
    resources:
        mem="64GB",
        runtime=120,
    params:
        lineage_dataset=subpath(input.busco_lineage, basename=True),
        lineages_path=subpath(input.busco_lineage, parent=True),
        mem_gb=lambda wildcards, resources: int(resources.mem_mb / 1000),
        outdir=subpath(output["qc_busco_json"], parent=True),
        taxid=manifest.taxon_id
    shell:
        "atol-qc-annotation "
        "--threads {threads} "
        "--mem {params.mem_gb} "
        "--fasta {input.fasta} "
        "--annot {input.gtf} "
        "--lineage_dataset {params.lineage_dataset} "
        "--lineages_path {params.lineages_path} "
        # "--db {input.db} "
        "--taxid {params.taxid} "
        # "--ete_ncbi_db {input.ete_ncbi_db} "
        "--outdir {params.outdir} "
        "--logs {params.outdir}/logs "
        "&> {log}"


rule annooddities:
    input:
        gtf=str_path(manifest.treeval_assembly.outputs_for("annotation").get("gtf")),
        fasta=str_path(manifest.treeval_assembly.outputs_for("ascc").get("PRIMARY")),
    output:
        stats=str_path(
            manifest.treeval_assembly.outputs_for("annotation").get(
                "annooddities_stats"
            )
        ),
        gff=str_path(
            manifest.treeval_assembly.outputs_for("annotation").get("annooddities_gff")
        ),
        summary=str_path(
            manifest.treeval_assembly.outputs_for("annotation").get(
                "annooddities_summary"
            )
        ),
    log:
        str_path(manifest.get_stage_logs("annotation"), "annooddities.primary.log"),
    benchmark:
        str_path(
            manifest.get_stage_logs("annotation"), "annooddities.primary.stats.jsonl"
        )
    shadow:
        "minimal"
    container:
        config["containers"]["annooddities"]
    resources:
        mem="64GB",
        runtime="12h",
    params:
        outdir=subpath(output["stats"], parent=True),
    shell:
        "annooddities "
        "--genome_fasta {input.fasta} "
        "--gff3_file {input.gtf} "
        "--output_prefix ao "
        "&> {log} "
        "&& "
        "mv ao.AnnoOddities.combined_statistics.json {output.stats} "
        "&& "
        "mv ao.AnnoOddities.gff {output.gff} "
        "&& "
        "mv ao.AnnoOddities.oddity_summary.txt {output.summary} "


# For now we just run annotation on the ascc output. In the future we need to
# account for curated genomes. See how this is implemented in
# workflow/rules/60_deposit_assembly_to_ena.smk
rule tiberius:
    input:
        fasta=str_path(manifest.treeval_assembly.outputs_for("ascc").get("PRIMARY")),
    output:
        gtf=str_path(manifest.treeval_assembly.outputs_for("annotation").get("gtf")),
    log:
        str_path(manifest.get_stage_logs("annotation"), "tiberius.primary.log"),
    benchmark:
        str_path(manifest.get_stage_logs("annotation"), "tiberius.primary.stats.jsonl")
    container:
        config["containers"]["tiberius"]
    resources:
        gpu=1,
        mem=lambda wildcards, attempt: f"{int(attempt*64)}G",  # scales with the longest contig
        runtime=lambda wildcards, attempt: int(attempt * 60),
    params:
        batch_size=16,
        model_cfg=get_tiberius_model_cfg,
    shell:
        "tiberius.py "
        "--genome {input.fasta} "
        "--model_cfg {params.model_cfg} "
        "--out {output.gtf} "
        "--batch_size {params.batch_size} "
        "--no_softmasking "
        "&> {log}"
