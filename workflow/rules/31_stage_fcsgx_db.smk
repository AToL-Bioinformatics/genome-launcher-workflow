

envvars:
    "SNAKEMAKE_STORAGE_S3_ACCESS_KEY",
    "SNAKEMAKE_STORAGE_S3_SECRET_KEY",
    "SNAKEMAKE_STORAGE_S3_ENDPOINT_URL",


# can't run this in a container, Snakemake doesn't bind the storage directory
# properly. Takes ages as Snakemake needs to copy it locally twice.
rule stage_fcsgx:
    input:
        storage.s3("s3://pawsey1132.atol.refdata.fcsgx/fcsgx"),
    output:
        fcsgx=directory(Path("resources", "staging", "fcsgx")),
    resources:
        runtime=lambda wildcards, attempt: int(attempt * 180),
    shell:
        "cp -r {input} {output}"
