def get_github_token(wildcards):
    """
    Use a resource to resolve the token at runtime, so the whole process
    doesn't stop if the token is missing.
    """
    token = os.getenv("ATOL_BIOINFORMATICS_ISSUES", None)
    if not token:
        raise WorkflowError(
            (
                "Set the ATOL_BIOINFORMATICS_ISSUES variable "
                "to update the assembly status on GitHub."
            )
        )
    return token


def assembly_status_input(wildcards):
    if wildcards.pipeline == "qc":
        flat_paths = [str_path(x) for x in manifest.reads.flat_paths("qc")]
        return flat_paths
    return (
        str_path(
            manifest.get_dir("results"),
            "upload_receipts",
            f"{wildcards.pipeline}.jsonl",
        ),
    )


assembly_status = {
    "ascc": "Decontaminated",
    "genomeassembly": "Assembled",
    "qc": "Reads QC done",
    "treeval": "Ready to curate",
}


rule update_assembly_status:
    input:
        receipts=assembly_status_input,
    output:
        response=str_path(
            manifest.get_dir("results"), "update_assembly_status", "{pipeline}.json"
        ),
    log:
        str_path("logs", "update_assembly_status", "{pipeline}.log"),
    benchmark:
        str_path("logs", "update_assembly_status", "{pipeline}.stats.jsonl")
    wildcard_constraints:
        pipeline="|".join(list(assembly_status.keys())),
    container:
        config["containers"]["curl"]
    resources:
        shell_exec="sh",
        token=get_github_token,
    params:
        workflow=(
            "https://api.github.com/repos/AToL-Bioinformatics/"
            "assembly-datasets/actions/workflows/"
            "on-pipeline-completion.yml/dispatches"
        ),
        status_update=lambda wildcards: assembly_status.get(wildcards.pipeline),
        assembly_dataset_id=sample_id,
    shell:
        "curl -L "
        "-X POST "
        '-H "Accept: application/vnd.github+json" '
        '-H "Authorization: Bearer {resources.token}" '
        '-H "X-GitHub-Api-Version: 2026-03-10" '
        "{params.workflow} "
        "-d '"
        "{{"
        '"ref":"main","inputs":'
        "{{"
        '"assembly_dataset_id":"{params.assembly_dataset_id}",'
        '"status_update":"{params.status_update}"'
        "}}"
        "}}' "
        "2> {log} "
        "| tee {output.response} >> {log} "
