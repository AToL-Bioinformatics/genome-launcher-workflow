### Notes

#### 2025-03-05

- Using nf 25.10 with pipeline release 0.5.3 results in the "manifest maps"
  error message.
- nf older than 25.10 can't stage the FCSGX database from S3 correctly (tried
  `25.04.7`,  `25.04.8` and `25.09.2-edge`)
- Pipeline commits `65b4c1d` and `f152744` both result in
  `java.util.ConcurrentModificationException` with nf 25.10.4, but this seems
  to be intermittent (doesn't happen every time)