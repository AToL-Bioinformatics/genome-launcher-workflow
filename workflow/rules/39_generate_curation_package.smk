def get_curation_files(wildcards):
    # raise ValueError(wildcards)
    # raise ValueError(manifest.busco_odb12_dataset_name)
    genomeassembly_files = [
        "PRIMARY_BUSCO_TABLE",  # NEEDS RENAMING PRIOR TO PUTTING IN DIRECTORY
        "HAPLO_BUSCO_TABLE",  # NEEDS RENAMING PRIOR TO PUTTING IN DIRECTORY
    ]
    ascc_files = [
        "PRIMARY_ABNORMAL_CHECK",
        "PRIMARY_CHECK_SUMMARY",
        "PRIMARY_REMOVED_SEQUENCES",  # NEEDS RENAMING PRIOR TO PUTTING IN DIRECTORY
        "PRIMARY_MT_CONTIGS",
        "HAPLO_ABNORMAL_CHECK",
        "HAPLO_CHECK_SUMMARY",
        "HAPLO_REMOVED_SEQUENCES",  # NEEDS RENAMING PRIOR TO PUTTING IN DIRECTORY
        "HAPLO_MT_CONTIGS",
        "COMBINED",
        "MITO", #OPTIONAL?
        "MITO_ABNORMAL_CHECK", #OPTIONAL?
        "MITO_REMOVED_SEQUENCES",  #OPTIONAL? # NEEDS RENAMING PRIOR TO PUTTING IN DIRECTORY
    ]
    output_files = []
    _treeval_output = manifest.treeval_assembly.outputs_for("treeval")
    _ascc_output = manifest.treeval_assembly.outputs_for("ascc")
    _genomeassembly_output = manifest.treeval_assembly.outputs_for("genomeassembly")
    raise ValueError(_genomeassembly_output)
    for filename in _treeval_output.values():
        output_files.append(filename)

    for filename in ascc_files:
        output_files.append(_ascc_output[filename])

    for filename in genomeassembly_files:
        output_files.append(_genomeassembly_output[filename])

    return output_files

    raise ValueError(output_files)


def get_busco_files(wildcards):
    busco_files_dict = {
        k: manifest.treeval_assembly.outputs_for("genomeassembly").get(k)
        for k in ["PRIMARY_BUSCO_TABLE", "HAPLO_BUSCO_TABLE"]
    }
    return busco_files_dict

    raise ValueError(busco_files_dict)


rule generate_curation_package:
    input:
        "curation.tar.gz",


rule compress_curation_package:
    input:
        get_curation_files,
    output:
        "curation.tar.gz",
    shell:
        "tar -cv {input} {output}"


# what do?
# - rename any duplicate files and put in the tmp folder
# - move other files to the tmp folder
# - compress tmp folder


rule rename_removed_sequence_files:
    input:
        "{dataset_id}.{assembly_version}_{pri_hap_mito}/autofilter/assembly_filtering_removed_sequences.txt",
    output:
        # need to figure out the temp directory thing
        "{dataset_id}.{assembly_version}_{pri_hap_mito}/autofilter/{dataset_id}.{assembly_version}_{pri_hap}_{pri_hap_mito}_assembly_filtering_removed_sequences.txt",
    shell:
        """
        cp {input} {output}
        """


# rule rename_busco_files:
#     input: "{dataset_id}.{assembly_version}.pacbio_hifi.phased/scaffolding/busco.{busco_odb12_dataset_name}_odb12/asm-busco/asm_hap1_scaffolds_final.fa/run_{busco_odb12_dataset_name}_odb12/full_table.tsv"
#     output: "{dataset_id}.{assembly_version}.pacbio_hifi.phased/scaffolding/busco.{busco_odb12_dataset_name}_odb12/asm-busco/asm_hap1_scaffolds_final.fa/run_{busco_odb12_dataset_name}_odb12/full_table.tsv"
