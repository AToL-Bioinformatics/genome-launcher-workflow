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


# For now we just run annotation on the ascc output. In the future we need to
# account for curated genomes. See how this is implemented in
# workflow/rules/60_deposit_assembly_to_ena.smk


rule tiberius:
    input:
        fasta=manifest.treeval_assembly.outputs_for("ascc").get("PRIMARY"),
    output:
        gtf=Path(manifest.get_dir("annotation"), "tiberius.gtf"),
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
