storage acacia:
    provider="s3",


envvars:
    "SNAKEMAKE_STORAGE_S3_ACCESS_KEY",
    "SNAKEMAKE_STORAGE_S3_SECRET_KEY",
    "SNAKEMAKE_STORAGE_S3_ENDPOINT_URL"


rule stage_fcsgx:
    input:
        storage.s3("s3://pawsey1132.atol.refdata.fcsgx/fcsgx"),
    output:
        fcsgx=directory(Path("resources", "staging", "fcsgx")),
    shell:
        "cp -r {input} {output}"

