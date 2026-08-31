#!/usr/bin/env python3


def _choose_assembly_to_deposit():
    """
    Return the name of the pipeline that needs to be completed before
    submission. Ensures that the pipeline results have been reported to Canopy
    before we try to Broker anything.
    """
    # If any of the curation input is present, the genome has been curated, and
    # we are brokering the output from curation. We might be able to avoid
    # brokering early by generating a "TODO" marker file in the curation
    # directory.
    if any([Path(x).exists() for x in curation_input.values()]):
        return "curation"
    return "ascc"


def get_chromosome_list_param(wildcards, input):
    cl = input.get("chromosome_list", None)

    if cl is None:
        return ""

    return f"--chromosome_list {input.chromosome_list}"


def get_sequencing_depth(wildcards, input):
    stats_file = input.stats
    fasta_file = input.fasta_file

    with open(stats_file, "rt") as f:
        lines = f.readlines()
        for line in lines[1:]:
            splits = line.rstrip("\n").split("\t")
            fn = splits[0]
            if fn in fasta_file:
                return splits[-1]

    raise ValueError(f"Stats for {fasta_file} not found in {stats_file}")


def get_submission_input(wildcards):
    submission_input = {}
    pipeline_value = _choose_assembly_to_deposit()

    if pipeline_value == "curation":
        # In this case we require a Chromosome List.
        submission_input["fasta_file"] = str_path(
            manifest.treeval_assembly.outputs_for("curation").get("HAP1")
        )
        submission_input["chromosome_list"] = str_path(
            manifest.pipeline_input("submission").get("chromosome_list")
        )
    elif pipeline_value == "ascc":
        primary = manifest.treeval_assembly.outputs_for("ascc").get("PRIMARY")
        submission_input["fasta_file"] = str_path(primary) + ".gz"
    else:
        raise ValueError(f"Unknown submission input {pipeline_value}")

    submission_input["assembly_run_list"] = (
        str_path(
            manifest.get_dir("receipts"), f"{pipeline_value}.assembly_run_list.json"
        ),
    )

    return submission_input


rule deposit_assembly_to_ena:
    input:
        str_path(
            manifest.get_dir("pipeline_output", pipeline="submission"),
            "assembly",
            "genome",
            sample_id,
            "submit",
            "receipt.xml",
        ),
        Path(manifest.get_dir("results"), "upload_receipts", "submission.jsonl"),
        Path(manifest.get_dir("results"), "update_assembly_status", "submission.json"),


rule submit_assembly_to_ena:
    input:
        unpack(get_submission_input),
        ena_manifest=str_path(
            manifest.get_dir("pipeline_output", pipeline="submission"),
            "assembly",
            "ena_manifest.txt",
        ),
    output:
        receipt=str_path(
            manifest.get_dir("pipeline_output", pipeline="submission"),
            "assembly",
            "genome",
            sample_id,
            "submit",
            "receipt.xml",
        ),
    log:
        str_path(log_dir_base, "deposit_assembly_to_ena.log"),
    benchmark:
        str_path(log_dir_base, "deposit_assembly_to_ena.stats.jsonl")
    container:
        config["containers"]["ena_webin_cli"]
    params:
        outdir=subpath(output.receipt, ancestor=4),
        webin_pass=webin_pass,
        webin_user=webin_user,
    shell:
        "ena-webin-cli "
        '-username "{params.webin_user}" '
        '-password "{params.webin_pass}" '
        "-context genome "
        "-manifest {input.ena_manifest} "
        "-outputDir {params.outdir} "
        "-submit "
        "&> {log}"


rule generate_ena_assembly_manifest:
    input:
        unpack(get_submission_input),
        manifest=config["manifest"],
        stats=str_path(manifest.get_dir("assembly_stats"), "stats.with_depth.tsv"),
    output:
        ena_manifest=str_path(
            manifest.get_dir("pipeline_output", pipeline="submission"),
            "assembly",
            "ena_manifest.txt",
        ),
    log:
        str_path(log_dir_base, "generate_ena_assembly_manifest.log"),
    benchmark:
        str_path(log_dir_base, "generate_ena_assembly_manifest.stats.jsonl")
    container:
        config["containers"]["atol_genome_launcher"]
    params:
        sequencing_depth=get_sequencing_depth,
        chromosome_list=get_chromosome_list_param,
    shell:
        "generate-ena-assembly-manifest "
        "--fasta_file {input.fasta_file} "
        "--sequencing_depth {params.sequencing_depth} "
        "{params.chromosome_list} "
        "{input.manifest} "
        "{output.ena_manifest} "
        "&> {log}"
