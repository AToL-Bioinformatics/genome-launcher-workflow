

rule draft_assembly_package:
    input:
        str_path(manifest.get_dir("results"), "bpa_draft_assembly", "bpa_package"),


# TODO: This script should also handle the metadata / checksum / manifest
# generation
rule copy_files_for_dataportal_package:
    input:
        dp_files=str_path(
            manifest.get_dir("results"), "bpa_draft_assembly", "filenames.json"
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


rule generate_dataportal_filenames:
    input:
        manifest=config["manifest"],
    output:
        dp_files=str_path(
            manifest.get_dir("results"), "bpa_draft_assembly", "filenames.json"
        ),
    log:
        str_path(log_dir_base, "generate_dataportal_filenames.log"),
    benchmark:
        str_path(log_dir_base, "generate_dataportal_filenames.stats.jsonl")
    container:
        config["containers"]["atol_genome_launcher"]
    shell:
        "generate-dataportal-filenames "
        "{input.manifest} "
        "{output.dp_files} "
        "&> {log}"
