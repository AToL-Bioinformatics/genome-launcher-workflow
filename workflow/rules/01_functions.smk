#!/usr/bin/env python3


def get_reads_path(name, stage):
    reads = manifest.reads.get(name)
    return reads.paths(stage)


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
