storage acacia:
    provider="s3",


rule stage_fcsgx:
    input:
        storage.s3("s3://pawsey1132.atol.refdata.fcsgx/fcsgx"),
    output:
        fcsgx=directory(Path("resources", "staging", "fcsgx")),
