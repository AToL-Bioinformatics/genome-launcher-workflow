def get_curation_files(wildcards):
    # raise ValueError(wildcards)
    #raise ValueError(manifest.busco_odb12_dataset_name)
    genomeassembly_files = [
        "PRIMARY_BUSCO_TABLE"
    ]
    ascc_files = [
        "PRIMARY_ABNORMAL_CHECK",
        "PRIMARY_CHECK_SUMMARY",
        "PRIMARY_REMOVED_SEQUENCES",
        "PRIMARY_MT_CONTIGS",
        "HAPLO_ABNORMAL_CHECK",
        "HAPLO_CHECK_SUMMARY",
        "HAPLO_REMOVED_SEQUENCES",
        "HAPLO_MT_CONTIGS"
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

    #raise ValueError(output_files)


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
