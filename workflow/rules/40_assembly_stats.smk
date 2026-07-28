def get_all_assemblies(wildcards):
    expected_outputs = manifest.treeval_assembly.outputs
    all_outputs = []
    for pipeline, output_dict in expected_outputs.items():
        for output_type, output_file in output_dict.items():
            if output_file.is_file():
                all_outputs.append(str_path(output_file))

    if len(all_outputs) > 0:
        return all_outputs

    raise FileNotFoundError(
        f"Can't find any of the defined assembly outputs.\n\n{expected_outputs}\n"
    )


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
        "--tabular "
        "-j {threads} "
        "{input.assembly_files} "
        "> {output.stats} "
        "2> {log}"
