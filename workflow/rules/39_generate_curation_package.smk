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


rule generate_curation_package:
    input:
        "curation.tar.gz",


rule compress_curation_package:
    input:
        expand(
            Path(curation_package_dir, "{assembly_haplotype}_busco_full_table.csv"),
            assembly_haplotype=assembly_haplotypes,
        ),
        hires_pretext=Path(
            curation_package_dir,
            f"{manifest.dataset_id}_{manifest.assembly_version}_hr.pretext",
        ),
        # <list of non-optional files>,
        # optional_files_list <- function
    output:
        tarfile="curation.tar.gz",
    params:
        curation_package_dir=curation_package_dir,
    shell:
        "tar -cv --directory {params.curation_package_dir} . "
        "| gzip > {output.tarfile}"


# raise ValueError(manifest.get_dir("curation"))


# what do?
# - rename any duplicate files and put in the tmp folder
# - move other files to the tmp folder
# - compress tmp folder
rule rename_busco_files:
    input:
        get_busco_table_for_haplotype,
    output:
        Path(curation_package_dir, "{assembly_haplotype}_busco_full_table.csv"),
    wildcard_constraints:
        assembly_haplotype="|".join(assembly_haplotypes),
    shell:
        "cp {input} {output}"


rule copy_pretext_maps:
    input:
        hires_pretext=manifest.treeval_assembly.outputs_for("treeval").get(
            "HIRES_PRETEXT"
        ),
    output:
        hires_pretext=Path(
            curation_package_dir,
            f"{manifest.dataset_id}_{manifest.assembly_version}_hr.pretext",
        ),
    shell:
        "cp {input.hires_pretext} {output.hires_pretext} ; "
