

rule draft_assembly_package:
    input:
        str_path(manifest.get_dir("results"), "bpa_draft_assembly", "bpa_package"),


# TODO: This script should also handle the metadata / checksum / manifest
# generation
rule copy_files_for_dataportal_package:
    input:
        dp_files=str_path(
            manifest.get_dir("results"), "bpa_draft_assembly", "filelist.json"
        ),
    output:
        package_dir=directory(
            str_path(manifest.get_dir("results"), "bpa_draft_assembly", "bpa_package")
        ),
    log:
        str_path(log_dir_base, "copy_files_for_dataportal_package.log"),
    benchmark:
        str_path(log_dir_base, "copy_files_for_dataportal_package.stats.jsonl")
    container:
        config["containers"]["atol_genome_launcher"]
    script:
        "../scripts/copy_files_for_dataportal_package.py"


rule generate_dataportal_metadata:
    input:
        manifest=config["manifest"],
        stats=str_path(manifest.get_dir("assembly_stats"), "stats.with_depth.tsv"),
        busco_primary=genomeassembly_output.get("PRIMARY_BUSCO_JSON"),
        busco_secondary=genomeassembly_output.get("HAPLO_BUSCO_JSON"),
    output:
        dp_filelist=str_path(
            manifest.get_dir("results"), "bpa_draft_assembly", "filelist.json"
        ),
        dp_metadata=str_path(
            manifest.get_dir("results"), "bpa_draft_assembly", "metadata.xlsx"
        ),
        dp_transfer_line=str_path(
            manifest.get_dir("results"), "bpa_draft_assembly", "transfer_line.txt"
        ),
        dp_email=str_path(
            manifest.get_dir("results"), "bpa_draft_assembly", "email.txt"
        ),
    log:
        str_path(log_dir_base, "generate_dataportal_metadata.log"),
    benchmark:
        str_path(log_dir_base, "generate_dataportal_metadata.stats.jsonl")
    # container:
    #     config["containers"]["atol_genome_launcher"]
    shell:
        "generate-dataportal-metadata "
        "--stats {input.stats} "
        "--busco_primary {input.busco_primary} "
        "--busco_secondary {input.busco_secondary} "
        "--dp_filelist {output.dp_filelist} "
        "--dp_metadata {output.dp_metadata} "
        "--dp_transfer_line {output.dp_transfer_line} "
        "--dp_email {output.dp_email} "
        "{input.manifest} "
        "&> {log}"
