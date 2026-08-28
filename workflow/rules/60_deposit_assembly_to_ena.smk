def choose_assembly_to_deposit(wildcards):
    pipeline = wildcards.pipeline
    if pipeline == "curation":
        return str_path(manifest.treeval_assembly.outputs_for("curation").get("HAP1"))
    elif pipeline == "ascc":
        primary = manifest.treeval_assembly.outputs_for("ascc").get("PRIMARY")
        return str_path(primary) + ".gz"
    else:
        raise ValueError(f"Don't have an assembly to deposit for pipeline {pipeline}")


def get_sequencing_depth(wildcards, input):
    stats_file = input.stats
    fasta_file = input.fasta_file

    with open(stats_file, "rt") as f:
        for line in f.readlines():
            splits = line.split("\t")
            fn = splits[0]
            if fn in fasta_file:
                return splits[-1]

    raise ValueError(f"Stats for {fasta_file} not found in {stats_file}")


# TODO: So far we are just uploading the ascc file, completely ignoring the
# Chromosome file.

# Change this to deposit the curated assembly too.
rule deposit_ascc_assembly_to_ena:
    input:
        str_path(
            manifest.get_dir("receipts"),
            "ena",
            "ascc",
            "receipt.xml",
        ),

rule deposit_assembly_to_ena:
    input:
        ena_manifest=str_path(
            manifest.get_dir("receipts"),
            "broker",
            "{pipeline}",
            "ena_manifest.txt",
        ),
        fasta_file=choose_assembly_to_deposit,
    output:
        receipt=str_path(
            manifest.get_dir("receipts"),
            "ena",
            "{pipeline}",
            "receipt.xml",
        ),
    log:
        log=str_path(log_dir_base, "deposit_assembly_to_ena", "{pipeline}.log"),
        stats=str_path(log_dir_base, "deposit_assembly_to_ena", "{pipeline}.json"),
    benchmark:
        str_path(log_dir_base, "deposit_assembly_to_ena", "{pipeline}.stats.jsonl")
    container:
        config["containers"]["ena_webin_cli"]
    params:
        outdir=subpath(output.receipt, parent=True),
        webin_pass=webin_pass,
        webin_user=webin_user,
    shell:
        "ena-webin-cli "
        "-username {params.webin_user} "
        "-password {params.webin_pass} "
        "-context genome "
        "-manifest {input.ena_manifest} "
        "-outputDir {params.outdir} "
        "-submit "


rule generate_ena_assembly_manifest:
    input:
        manifest=config["manifest"],
        fasta_file=choose_assembly_to_deposit,
        stats=str_path(manifest.get_dir("assembly_stats"), "stats.with_depth.tsv"),
        assembly_run_list=str_path(
            manifest.get_dir("receipts"), "{pipeline}.assembly_run_list.json"
        ),
    output:
        ena_manifest=str_path(
            manifest.get_dir("receipts"),
            "broker",
            "{pipeline}",
            "ena_manifest.txt",
        ),
    log:
        log=str_path(log_dir_base, "generate_ena_assembly_manifest", "{pipeline}.log"),
        stats=str_path(
            log_dir_base, "generate_ena_assembly_manifest", "{pipeline}.json"
        ),
    benchmark:
        str_path(
            log_dir_base, "generate_ena_assembly_manifest", "{pipeline}.stats.jsonl"
        )
    container:
        config["containers"]["atol_genome_launcher"]
    params:
        sequencing_depth=get_sequencing_depth,
    shell:
        "generate-ena-assembly-manifest "
        "--fasta_file {input.fasta_file} "
        "--sequencing_depth {params.sequencing_depth} "
        "{input.manifest} "
        "{output.ena_manifest} "
        "&> {log}"
