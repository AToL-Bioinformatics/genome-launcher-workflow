#!/usr/bin/env python3


def get_reads_path(name, stage):
    reads = manifest.reads.get(name)
    reads_paths = reads.paths(stage)
    reads_strings = {k: str_path(v) for k, v in reads_paths.items()}
    return reads_strings


def get_raw_reads(wildcards):
    return get_reads_path(wildcards.bpa_package_id, "raw")


def get_git_info():
    base_dir = Path.cwd()
    try:
        repo = Repo(base_dir)
    except InvalidGitRepositoryError as e:
        raise WorkflowError(
            (
                f"get_git_info couldn't detect a git repo at {base_dir}. "
                "This is required for storing pipeline results in the database."
            )
        )
    hash = repo.head.object.hexsha
    parsed = giturlparse.parse(repo.remotes[0].url)
    return {"git_repo": f"{parsed.owner}/{parsed.repo}", "git_commit_hash": hash}


def str_path(*args, **kwargs):
    """
    Path() objects aren't serialised properly if extended_benchmark is used.
    Use this function instead of Path() whenever the rule has benchmarking
    enabled.
    """
    return str(Path(*args, **kwargs))
