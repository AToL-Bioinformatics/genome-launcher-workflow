#!/usr/bin/env python3


# TODO: the manifest needs to know where this is. See
# https://github.com/TomHarrop/atol-genome-launcher/issues/16
def get_filtered_assemblies(wildcards):
    return Path(
        "results/ascc",
        sample_id,
        f"{sample_id}_{wildcards.TYPE}",
        "autofilter",
        f"{sample_id}_{wildcards.TYPE}_autofiltered.fasta",
    )


def get_haplotype_assemblies(wildcards):
    return {
        k: expand(rules.compress_ascc_assemblies.output.compressed, TYPE=k)
        for k in ["PRIMARY", "HAPLO"]
    }


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
        runtime=lambda wildcards, attempt: int(60 * attempt),
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
        get_filtered_assemblies,
    output:
        compressed=Path(
            "results/ascc",
            sample_id,
            f"{sample_id}_{{TYPE}}",
            "autofilter",
            f"{sample_id}_{{TYPE}}_autofiltered.fasta.gz",
        ),
    log:
        Path(log_dir_base, "compress_ascc_assemblies", "{TYPE}.log"),
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

# FIXME this outputs uncompressed fasta
rule reheader_for_treeval:
    input:
        unpack(get_haplotype_assemblies),
    output:
        combined=Path(
            manifest.get_dir("pipeline_output", pipeline="ascc"),
            "PRIMARY_HAPLO_combined.fasta.gz",
        ),
    log:
        Path(log_dir_base, "reheader_for_treeval.log"),
    container:
        config["containers"]["seqkit"]
    threads: 1
    resources:
        mem=lambda wildcards, attempt: f"{2* attempt}GB",
        runtime=lambda wildcards, attempt: int(5 * attempt),
    shell:
        "{{ "
        "seqkit replace -p ^ -r HAP1_ < {input.PRIMARY} ; "
        "seqkit replace -p ^ -r HAP2_ < {input.HAPLO} ; "
        "}} "
        "2> {log} "
        "| "
        "gzip > {output.combined}"
