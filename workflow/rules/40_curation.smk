#!/usr/bin/env python3

curation_input = manifest.pipeline_input("curation")


# removing the manually excluded contigs has to happen after the split
rule remove_excluded_contigs:
    input:
        **curation_input,
        hap_file=str_path(
            curation_dir,
            f"{manifest.dataset_id}.hap{{hap}}.{manifest.assembly_version}.primary.curated.fa",
        ),
    output:
        hap_file=str_path(
            curation_dir,
            f"{manifest.dataset_id}.hap{{hap}}.{manifest.assembly_version}.primary.curated.fa.gz",
        ),
    log:
        str_path(log_dir_base, "remove_excluded_contigs.hap{hap}.log"),
    benchmark:
        str_path(log_dir_base, "remove_excluded_contigs.hap{hap}.stats.jsonl")
    container:
        config["containers"]["bbmap"]
    threads: 1
    resources:
        mem=lambda wildcards, attempt: f"{32* attempt}GB",
        runtime=lambda wildcards, attempt: int(10 * attempt),
    shell:
        "filterbyname.sh "
        "-Xmx{resources.mem_mb}m "
        "in={input.hap_file} "
        "names={input.exclude} "
        "include=f "
        "prefix=t "
        "out={output.hap_file} "
        "2> {log} "


rule pretext_to_asm:
    input:
        **curation_input,
        combined=str_path(curation_dir, f"{sample_id}.fasta"),
    output:
        **{k: temp(str_path(v).strip(".gz")) for k, v in curation_output.items()},
    log:
        str_path(log_dir_base, "pretext_to_asm.log"),
    benchmark:
        str_path(log_dir_base, "pretext_to_asm.stats.jsonl")
    container:
        config["containers"]["agp_tpf_utils"]
    threads: 1
    resources:
        mem=lambda wildcards, attempt: f"{8* attempt}GB",
        runtime=lambda wildcards, attempt: int(5 * attempt),
    params:
        output_pattern=str_path(curation_dir, f"{sample_id}.fa"),
    shell:
        "pretext-to-asm "
        "--assembly {input.combined} "
        "--pretext {input.agp} "
        "--output {params.output_pattern} "
        "&> {log}"


rule prepare_for_pretext_to_asm:
    input:
        combined=manifest.treeval_assembly.outputs_for("ascc").get("COMBINED"),
    output:
        combined=temp(str_path(curation_dir, f"{sample_id}.fasta")),
    log:
        str_path(log_dir_base, "prepare_for_pretext_to_asm.log"),
    benchmark:
        str_path(log_dir_base, "prepare_for_pretext_to_asm.stats.jsonl")
    container:
        config["containers"]["bbmap"]
    threads: 1
    resources:
        mem=lambda wildcards, attempt: f"{12* attempt}GB",
        runtime=lambda wildcards, attempt: int(5 * attempt),
    shell:
        "reformat.sh "
        "-Xmx{resources.mem_mb}m "
        "in={input.combined} "
        "out={output.combined} "
        "2> {log} "
