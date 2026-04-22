#!/usr/bin/env python3


def get_haplotype_assemblies(wildcards):
    return {
        k: manifest.treeval_assembly.outputs_for("ascc").get(k)
        for k in ["PRIMARY", "HAPLO"]
    }


# TODO: generalise
rule reformat_fq_to_fa:
    input:
        ancient(Path("{folder}", "{file}.fastq.gz")),
    output:
        Path("{folder}", "{file}.fasta.gz"),
    log:
        Path(log_dir_base, "reformat", "{folder}", "{file}", "to_fasta.log"),
    wildcard_constraints:
        file="|".join(
            [
                str(yaml_manifest.replace_ext(x.name))
                for x in manifest.long_reads.flat_paths("qc")
            ]
        ),
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


rule reheader_for_treeval:
    input:
        unpack(get_haplotype_assemblies),
    output:
        combined=manifest.treeval_assembly.outputs_for("ascc").get("COMBINED"),
    log:
        Path(log_dir_base, "reheader_for_treeval.log"),
    container:
        config["containers"]["seqkit"]
    threads: 1
    resources:
        mem=lambda wildcards, attempt: f"{8* attempt}GB",
        runtime=lambda wildcards, attempt: int(20 * attempt),
    shell:
        "{{ "
        "seqkit replace -p ^ -r HAP1_ < {input.PRIMARY} ; "
        "seqkit replace -p ^ -r HAP2_ < {input.HAPLO} ; "
        "}} "
        "2> {log} "
        "| "
        "gzip > {output.combined}"
