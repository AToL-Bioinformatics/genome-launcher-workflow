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

# List non-optional curation files here
_curation_files = {
    f"{manifest.dataset_id}_{manifest.assembly_version}_hr.pretext": manifest.treeval_assembly.outputs_for(
        "treeval"
    ).get(
        "HIRES_PRETEXT"
    ),
    f"{manifest.dataset_id}_{manifest.assembly_version}_normal.pretext": manifest.treeval_assembly.outputs_for(
        "treeval"
    ).get(
        "NORMAL_PRETEXT"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_primary_ABNORMAL_CHECK.csv": manifest.treeval_assembly.outputs_for(
        "ascc"
    ).get(
        "PRIMARY_ABNORMAL_CHECK"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_secondary_ABNORMAL_CHECK.csv": manifest.treeval_assembly.outputs_for(
        "ascc"
    ).get(
        "HAPLO_ABNORMAL_CHECK"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_primary_contamination_check_merged_table.csv": manifest.treeval_assembly.outputs_for(
        "ascc"
    ).get(
        "PRIMARY_CHECK_SUMMARY"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_secondary_contamination_check_merged_table.csv": manifest.treeval_assembly.outputs_for(
        "ascc"
    ).get(
        "HAPLO_CHECK_SUMMARY"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_primary_removed_sequences.txt": manifest.treeval_assembly.outputs_for(
        "ascc"
    ).get(
        "PRIMARY_REMOVED_SEQUENCES"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_secondary_removed_sequences.txt": manifest.treeval_assembly.outputs_for(
        "ascc"
    ).get(
        "HAPLO_REMOVED_SEQUENCES"
    ),
}

# here are all the optional files that may or may not exist
optional_files_list = {
    f"{manifest.dataset_id}.{manifest.assembly_version}_primary_mito_contamination_recommendation.txt": manifest.treeval_assembly.outputs_for(
        "ascc"
    ).get(
        "PRIMARY_MT_CONTIGS"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_secondary_mito_contamination_recommendation.txt": manifest.treeval_assembly.outputs_for(
        "ascc"
    ).get(
        "HAPLO_MT_CONTIGS"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_mito_autofiltered.fasta.gz": manifest.treeval_assembly.outputs_for(
        "ascc"
    ).get(
        "MITO"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_mito_ABNORMAL_CHECK.csv": manifest.treeval_assembly.outputs_for(
        "ascc"
    ).get(
        "MITO_ABNORMAL_CHECK"
    ),
    f"{manifest.dataset_id}.{manifest.assembly_version}_mito_removed_sequences.txt": manifest.treeval_assembly.outputs_for(
        "ascc"
    ).get(
        "MITO_REMOVED_SEQUENCES"
    ),
}

# create a new dict that contains only the optional files that exist
_optional_files = {
    filename: filepath
    for filename, filepath in optional_files_list.items()
    if Path(filepath).exists()
}

# stick the non-optional files together with the optional ones that exist
_all_curation_files = {**_curation_files, **_optional_files}


# either of the lines in here appear to work, they just chuck slightly different error messages
def resolve_file(wildcards):
    # return _curation_files[wildcards.filename]
    return _all_curation_files.get(wildcards.filename, None)



rule generate_archive:
    input:
        "archive.tar.gz",


rule archive:
    input:
        expand(
            Path(curation_package_dir, "{filename}"),
            filename=_all_curation_files.keys(),
        ),
        expand(
            Path(curation_package_dir, "{assembly_haplotype}_busco_full_table.csv"),
            assembly_haplotype=assembly_haplotypes,
        ),
    output:
        archive="archive.tar.gz",
    params:
        curation_package_dir=curation_package_dir,
    shell:
        "echo {input} {output.archive}"
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


rule generate_curation_package:
    input:
        "archive.tar.gz",
        # "curation.tar.gz",


# rule compress_curation_package:
#     input:
#         expand(
#             Path(curation_package_dir, "{assembly_haplotype}_busco_full_table.csv"),
#             assembly_haplotype=assembly_haplotypes,
#         ),
#         hires_pretext=Path(
#             curation_package_dir,
#             f"{manifest.dataset_id}_{manifest.assembly_version}_hr.pretext",
#         ),
#         normal_pretext=Path(
#             curation_package_dir,
#             f"{manifest.dataset_id}_{manifest.assembly_version}_normal.pretext",
#         ),
#         # <list of non-optional files>,
#         # optional_files_list <- function
#     output:
#         tarfile="curation.tar.gz",
#     params:
#         curation_package_dir=curation_package_dir,
#     shell:
#         "tar -cv --directory {params.curation_package_dir} . "
#         "| gzip > {output.tarfile}"


# # raise ValueError(manifest.treeval_assembly.outputs_for("ascc").get("PRIMARY"))


# # what do?
# # - rename any duplicate files and put in the tmp folder
# # - move other files to the tmp folder
# # - compress tmp folder

rule rename_busco_files:
    input:
        get_busco_table_for_haplotype,
    output:
        Path(curation_package_dir, "{assembly_haplotype}_busco_full_table.csv"),
    wildcard_constraints:
        assembly_haplotype="|".join(assembly_haplotypes),
    shell:
        "cp {input} {output}"

# # put in here all the files that are non-optional and don't need to be re-named
# rule copy_pretext_maps:
#     input:
#         hires_pretext=manifest.treeval_assembly.outputs_for("treeval").get(
#             "HIRES_PRETEXT"
#         ),
#         normal_pretext=manifest.treeval_assembly.outputs_for("treeval").get(
#             "NORMAL_PRETEXT"
#         ),
#     output:
#         hires_pretext=Path(
#             curation_package_dir,
#             f"{manifest.dataset_id}_{manifest.assembly_version}_hr.pretext",
#         ),
#         normal_pretext=Path(
#             curation_package_dir,
#             f"{manifest.dataset_id}_{manifest.assembly_version}_normal.pretext",
#         ),
#     shell:
#         "cp {input.hires_pretext} {output.hires_pretext} ; "
#         "cp {input.normal_pretext} {output.normal_pretext} ; "
