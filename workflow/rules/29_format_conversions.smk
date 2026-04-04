#!/usr/bin/env python3


def get_primary_assembly(wildcards):
    sample_id = ".".join([manifest.dataset_id, str(manifest.assembly_version)])
    return Path(
        "results/ascc",
        sample_id,
        f"{sample_id}_PRIMARY",
        "autofilter",
        f"{sample_id}_PRIMARY_autofiltered.fasta",
    )


# TODO: the manifest needs to know where this is
converted_assembly = replace_ext(get_primary_assembly(None), ".fasta.gz")


# TODO: generalise
rule reformat_fq_to_fa:
    input:
        Path("{folder}", "{file}.fastq.gz"),
    output:
        Path("{folder}", "{file}.fasta.gz"),
    log:
        Path(log_dir_base, "reformat", "{folder}", "{file}", "to_fasta.log"),
    wildcard_constraints:
        file="|".join([str(replace_ext(x.name)) for x in pacbio_reads.flat_paths("qc")]),
    container:
        config["containers"]["bbmap"]
    threads: 6
    resources:
        mem=lambda wildcards, attempt: f"{12* attempt}GB",
    shell:
        "reformat.sh "
        "-Xmx{resources.mem_mb}m "
        "threads={threads} "
        "in={input} "
        "int=f "
        "out={output} "
        "2> {log} "


rule compress_ascc_assemblies:
    input:
        get_primary_assembly,
    output:
        converted_assembly,
    log:
        Path(log_dir_base, "compress_ascc_assemblies.log"),
    container:
        config["containers"]["bbmap"]
    threads: 6
    resources:
        mem=lambda wildcards, attempt: f"{12* attempt}GB",
    shell:
        "reformat.sh "
        "-Xmx{resources.mem_mb}m "
        "threads={threads} "
        "in={input} "
        "int=f "
        "out={output} "
        "2> {log} "
