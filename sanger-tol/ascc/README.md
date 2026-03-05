### Notes

#### 2025-03-05

- With nf 25.10.4 and pipeline commit `65b4c1d`, FCSGX completes, but the
  pipeline crashes at `SANGERTOL_ASCC:ASCC:GENOMIC:ASCC_MERGE_TABLES`. It seems
  to be an error [reading the *.depth.txt
  fiile](https://github.com/sanger-tol/ascc/blob/65b4c1dc828202afc2a39d367789bc4fdc1cdd9d/bin/ascc_merge_tables.py#L84)
  using the wrong delimiter. CoverM was
  [added](https://github.com/sanger-tol/ascc/blob/65b4c1dc828202afc2a39d367789bc4fdc1cdd9d/CHANGELOG.md#added)
  in 0.6.0 so the bug shouldn't happen before that.
- Using nf 25.10 with pipeline release 0.5.3 results in the "manifest maps"
  error message.
- Using nf 25.04.8, pipeline version 0.5.3 and a local FCSGX database (on
  scratch), the DB gets loaded into RAM correctly but FCSGX fails with no error
  message. I think this might be because the DB didn't copy to scratch
  correctly, i.e. not the pipeline's fault.
- nf older than 25.10 can't stage the FCSGX database from S3 correctly (tried
  `25.04.7`,  `25.04.8` and `25.09.2-edge`)
- Pipeline commits `65b4c1d` and `f152744` both result in
  `java.util.ConcurrentModificationException` with nf 25.10.4, but this seems
  to be intermittent (doesn't happen every time)