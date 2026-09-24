def check_optional_curation_files(wildcards):
    existing_optional_files = [
        str_path(curation_package_dir, filename)
        for filename, filepath in optional_files_list.items()
        if Path(filepath).is_file()
    ]
    return existing_optional_files


def resolve_file(wildcards):
    return str_path(_all_curation_files.get(wildcards.filename))


curation_package_dir = Path(manifest.get_dir("curation"), "curation_package")


_curation_files = {
    f"{manifest.dataset_id}.{manifest.assembly_version}_primary_busco_full_table.csv": manifest.treeval_assembly.outputs_for(
        "genomeassembly"
    ).get(
        "PRIMARY_BUSCO_TABLE"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_secondary_busco_full_table.csv": manifest.treeval_assembly.outputs_for(
        "genomeassembly"
    ).get(
        "HAPLO_BUSCO_TABLE"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_hr.pretext": treeval_output.get(
        "HIRES_PRETEXT"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_normal.pretext": treeval_output.get(
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

# raise ValueError(list(type(x) for x in _all_curation_files.values()))


rule generate_curation_package:
    input:
        str_path(manifest.get_dir("curation"), "curation.tar.gz"),


rule compress_curation_package:
    input:
        expand(
            str_path(curation_package_dir, "{filename}"),
            filename=_curation_files.keys(),
        ),
        check_optional_curation_files,
    output:
        archive=str_path(manifest.get_dir("curation"), "curation.tar.gz"),
    log:
        str_path(log_dir_base, "compress_curation_package.log"),
    benchmark:
        str_path(log_dir_base, "compress_curation_package.stats.jsonl")
    container:
        config["containers"]["pigz"]
    threads: 4
    resources:
        runtime="20m"
    params:
        curation_package_dir=curation_package_dir,
    shell:
        "tar -cv --directory {params.curation_package_dir} . "
        "2> {log} "
        "| pigz -p {threads} > {output.archive}"


rule copy_curation_file:
    input:
        resolve_file,
    output:
        temp(str_path(curation_package_dir, "{filename}")),
    log:
        str_path(log_dir_base, "copy_curation_files", "{filename}.log"),
    benchmark:
        str_path(log_dir_base, "copy_curation_files", "{filename}.stats.jsonl")
    wildcard_constraints:
        filename="|".join(_all_curation_files.keys()),
    container:
        config["containers"]["pigz"]
    shell:
        "cp {input} {output} &> {log}"
