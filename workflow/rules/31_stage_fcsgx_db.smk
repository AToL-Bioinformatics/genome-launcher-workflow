#!/usr/bin/env python3


# Run this in a container and copy manually. If you try to use Snakemake's
# storage backend, two bad things happen: 1. the workflow blocks until the
# transfer completes; 2. the `snakemake-storage-plugin-s3` causes a `FATAL:
# container creation failed` error for ANY job that uses a container.
rule stage_fcsgx:
    output:
        fcsgx=directory(Path("resources", "staging", "fcsgx")),
    log:
        Path("logs", "staging", "stage_fcsgx.log"),
    container:
        config["containers"]["rclone"]
    resources:
        runtime=lambda wildcards, attempt: int(attempt * 180),
        shell_exec="sh",
    params:
        bucket=config["fcsgx_db"],
        s3_access_key_id=os.getenv("RCLONE_S3_ACCESS_KEY_ID"),
        s3_endpoint=os.getenv("RCLONE_S3_ENDPOINT"),
        s3_provider=os.getenv("RCLONE_S3_PROVIDER", "Ceph"),
        s3_secret_access_key=os.getenv("RCLONE_S3_SECRET_ACCESS_KEY"),
    shell:
        "rclone "
        "--s3-access-key-id {params.s3_access_key_id} "
        "--s3-endpoint {params.s3_endpoint} "
        "--s3-provider {params.s3_provider} "
        "--s3-secret-access-key {params.s3_secret_access_key} "
        "copy "
        ":s3:{params.bucket} "
        "{output} "
        "&> {log}"
