#!/usr/bin/env python3


def get_all_assemblies(wildcards, output_types=None):
    output_types = output_types or _FASTA_OUTPUT_TYPES
    expected_outputs = manifest.treeval_assembly.outputs
    all_outputs = []
    for pipeline, output_dict in expected_outputs.items():
        for output_type, output_file in output_dict.items():
            if output_type in output_types and output_file.is_file():
                all_outputs.append(str_path(output_file))

    if len(all_outputs) > 0:
        return all_outputs

    raise FileNotFoundError(
        f"Can't find any of the defined assembly outputs.\n\n{expected_outputs}\n"
    )


_FASTA_OUTPUT_TYPES = {
    "COMBINED",
    "HAP1",
    "HAP2",
    "HAPLO",
    "PRIMARY",
}


rule calculate_depth:
    input:
        stats=str_path(manifest.get_dir("assembly_stats"), "stats.tsv"),
        read_stats=[str_path(x) for x in manifest.long_reads.stats_paths("qc")],
    output:
        stats=str_path(manifest.get_dir("assembly_stats"), "stats.with_depth.tsv"),
    log:
        str_path(log_dir_base, "calculate_depth.log"),
    benchmark:
        str_path(log_dir_base, "calculate_depth.stats.jsonl")
    container:
        config["containers"]["atol_genome_launcher"]  # has pandas and numpy
    script:
        "../scripts/calculate_depth.py"


rule all_assembly_stats:
    input:
        assembly_files=get_all_assemblies,
    output:
        stats=str_path(manifest.get_dir("assembly_stats"), "stats.tsv"),
    log:
        str_path(log_dir_base, "all_assembly_stats.log"),
    benchmark:
        str_path(log_dir_base, "all_assembly_stats.stats.jsonl")
    container:
        config["containers"]["seqkit"]
    threads: lambda wildcards, input: len(input.assembly_files)
    resources:
        mem=lambda wildcards, attempt: f"{8* attempt}GB",
        runtime=lambda wildcards, attempt: int(20 * attempt),
    shell:
        "seqkit stats "
        "--all "
        "--skip-err " # stats exits 0 with no output otherwise
        "--tabular "
        "-j {threads} "
        "{input.assembly_files} "
        "> {output.stats} "
        "2> {log}"
