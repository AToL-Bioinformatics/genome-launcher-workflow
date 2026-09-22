def get_busco_table_for_haplotype(wildcards):
    if wildcards.assembly_haplotype == "primary":
        return manifest.treeval_assembly.outputs_for("genomeassembly").get(
            "PRIMARY_BUSCO_TABLE"
        )
    if wildcards.assembly_haplotype == "secondary":
        return manifest.treeval_assembly.outputs_for("genomeassembly").get(
            "HAPLO_BUSCO_TABLE"
        )
    raise ValueError(f"unknown assembly_haplotype: {wildcards.assembly_haplotype}")


curation_package_dir = Path(manifest.get_dir("curation"), "curation_package")

assembly_haplotypes = ["primary", "secondary"]

_curation_files = {
    f"{manifest.dataset_id}_{manifest.assembly_version}_hr.pretext": treeval_output.get(
        "HIRES_PRETEXT"
    ),
    f"{manifest.dataset_id}_{manifest.assembly_version}_normal.pretext": treeval_output.get(
        "NORMAL_PRETEXT"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_primary_ABNORMAL_CHECK.csv": ascc_output.get(
        "PRIMARY_ABNORMAL_CHECK"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_secondary_ABNORMAL_CHECK.csv": ascc_output.get(
        "HAPLO_ABNORMAL_CHECK"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_primary_contamination_check_merged_table.csv": ascc_output.get(
        "PRIMARY_CHECK_SUMMARY"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_secondary_contamination_check_merged_table.csv": ascc_output.get(
        "HAPLO_CHECK_SUMMARY"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_primary_removed_sequences.txt": ascc_output.get(
        "PRIMARY_REMOVED_SEQUENCES"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_secondary_removed_sequences.txt": ascc_output.get(
        "HAPLO_REMOVED_SEQUENCES"
    ),
}

# here are all the optional files that may or may not exist
optional_files_list = {
    f"{manifest.dataset_id}.{manifest.assembly_version}_primary_mito_contamination_recommendation.txt": ascc_output.get(
        "PRIMARY_MT_CONTIGS"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_secondary_mito_contamination_recommendation.txt": ascc_output.get(
        "HAPLO_MT_CONTIGS"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_mito_autofiltered.fasta.gz": ascc_output.get(
        "MITO"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_mito_ABNORMAL_CHECK.csv": ascc_output.get(
        "MITO_ABNORMAL_CHECK"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_mito_removed_sequences.txt": ascc_output.get(
        "MITO_REMOVED_SEQUENCES"
    ),
}


_all_curation_files = {**_curation_files, **optional_files_list}


# either of the lines in here appear to work, they just chuck slightly different error messages
def resolve_file(wildcards):
    return _all_curation_files.get(wildcards.filename, None)


def check_optional_curation_files(wildcards):
    existing_optional_files = [
        Path(curation_package_dir, filename)
        for filename, filepath in optional_files_list.items()
        if Path(filepath).is_file()
    ]
    return existing_optional_files


rule generate_curation_package:
    input:
        "curation.tar.gz",


rule archive:
    input:
        expand(
            Path(curation_package_dir, "{filename}"),
            filename=_curation_files.keys(),
        ),
        expand(
            Path(curation_package_dir, "{assembly_haplotype}_busco_full_table.csv"),
            assembly_haplotype=assembly_haplotypes,
        ),
        check_optional_curation_files,
    output:
        archive="curation.tar.gz",
    params:
        curation_package_dir=curation_package_dir,
    shell:
        "tar -cv --directory {params.curation_package_dir} . "
        "| gzip > {output.archive}"


rule copy_file:
    input:
        resolve_file,
    output:
        Path(curation_package_dir, "{filename}"),
    wildcard_constraints:
        filename="|".join(_all_curation_files.keys()),
    shell:
        "cp {input} {output}"


rule rename_busco_files:
    input:
        get_busco_table_for_haplotype,
    output:
        Path(curation_package_dir, "{assembly_haplotype}_busco_full_table.csv"),
    wildcard_constraints:
        assembly_haplotype="|".join(assembly_haplotypes),
    shell:
        "cp {input} {output}"
