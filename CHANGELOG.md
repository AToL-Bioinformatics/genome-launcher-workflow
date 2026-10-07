Changelog
=========

0.18.0 (2026-10-07)
-------------------

New

~~~
- Annotation config for Setonix. [Tom Harrop]
- Update Snakemake to 9.27.0. [Tom Harrop]
- Second profile for pawsey_gpu. [Tom Harrop]
- Second profile for pawsey_gpu. [Tom Harrop]
- Handle RAM / GPU allocation for Setonix. [Tom Harrop]
- Extra CPU for Pawsey. [Tom Harrop]

Changes
~~~~~~~

- Document Pawsey GPU config. [Tom Harrop]
- Document Pawsey GPU config. [Tom Harrop]

Fix

~~~
- Fix quoting in sbatch command. [Tom Harrop]

Other
~~~~~

- Add sbatch_export hack to profile for Pawsey Tiberius container. [Tom
  Harrop]
- Configure Tiberius runscript. [Tom Harrop]
- Merge branch 'main' into ac_merge. [Tom Harrop]
- Merge branch 'main' into annotation_config. [Tom Harrop]
- Seq_len param. [Tom Harrop]

0.17.5 (2026-10-05)
-------------------

- Merge pull request #48 from AToL-Bioinformatics/curation_files. [Amy
  Tims]

  Getting curation files package; uploading to Acacia
- Updating Snakefile. [Amy Tims]
- Updating filepath to curation.tar.gz in pipeline_flagfiles. [Amy Tims]
- Moving storage location of curation.tar.gz. [Amy Tims]
- Fixing Path bug. [Amy Tims]
- Merge branch 'main' into curation_files_merge. [Amy Tims]
- Merge branch 'main' of github.com:AToL-Bioinformatics/genome-launcher-
  workflow. [Tom Harrop]
- Merging with updated main. [Amy Tims]
- Merge pull request #49 from AToL-Bioinformatics/configs. [Amy Tims]

  adding comments to ascc.params.config
- Adding comments to ascc.params.config. [Amy Tims]
- Edits to pipeline uploader; tag dependencies. [Amy Tims]
- Updates to curation package. [Amy Tims]
- Update workflow/rules/39_generate_curation_package.smk. [Amy Tims, Tom
  Harrop]
- Update workflow/rules/39_generate_curation_package.smk. [Amy Tims, Tom
  Harrop]
- Update workflow/rules/39_generate_curation_package.smk. [Amy Tims, Tom
  Harrop]
- Update workflow/rules/39_generate_curation_package.smk. [Amy Tims, Tom
  Harrop]
- Update workflow/rules/39_generate_curation_package.smk. [Amy Tims, Tom
  Harrop]
- Apply suggestion from @TomHarrop. [Amy Tims, Tom Harrop]
- Merging main into curation_files branch. [Amy Tims]
- Curation package new draft. [Amy Tims]
- Calling new global vars. [Amy Tims]
- Adding pipeline outputs to globals. [Amy Tims]
- Attempting it the verbose way - finished? [Amy Tims]
- Attempting it the verbose way - in progress. [Amy Tims]
- Attempt 2 - with Tom's help. [Amy Tims]
- Fix conflict. [Amy Tims]
- Starting again. [Amy Tims]
- Attempt 1. [Amy Tims]
- Adding new rule to Snakefile. [Amy Tims]
- Starting to draft rules for generating curation package. [Amy Tims]

0.17.4 (2026-10-04)
-------------------

- Bump launcher. [Tom Harrop]

0.17.2 (2026-10-01)
-------------------

- Bump launcher. [Tom Harrop]

0.17.1 (2026-09-30)
-------------------

- Bump launcher. [Tom Harrop]

0.17.0 (2026-09-22)
-------------------

- Merge pull request #47 from AToL-Bioinformatics/45-add-annotation.
  [Tom Harrop]

  Add Annotation
- Bump launcher version. [Tom Harrop]
- WIP for pawsey config. [Tom Harrop]
- Modified submission for GPU. [Tom Harrop]
- Config for pawsey gpu. [Tom Harrop]
- Bump local launcher. [Tom Harrop]
- Upload annotation results. [Tom Harrop]
- Tiberius container override for Pawsey. [Tom Harrop]
- Get_tiberius_model_cfg (fixes #46) [Tom Harrop]

0.16.2 (2026-09-03)
-------------------

- New get_dir format. [Tom Harrop]
- Target name. [Tom Harrop]
- Redundant targe. [Tom Harrop]

0.16.1 (2026-09-02)
-------------------

- Bump launcher. [Tom Harrop]

0.16.0 (2026-09-01)
-------------------

- Bump launcher. [Tom Harrop]
- Live test. [Tom Harrop]
- Submission directory wrangling. [Tom Harrop]
- Todos. [Tom Harrop]
- Update CL param. [Tom Harrop]
- Bump launhcer. [Tom Harrop]
- Deposit the ASCC output unless there are curation materials. [Tom
  Harrop]

0.15.0 (2026-08-28)
-------------------

- Merge pull request #39 from AToL-Bioinformatics/deposit-assembly. [Tom
  Harrop]

  Deposit assembly
- Revert manifest. [Tom Harrop]
- Minor typo. [Tom Harrop]
- Fixes from manual test. [Tom Harrop]
- Add target. [Tom Harrop]
- Format. [Tom Harrop]
- Draft for assembly deposit. [Tom Harrop]

0.14.2 (2026-08-14)
-------------------

- Remove index. [Tom Harrop]
- Initial seq depth stat see #29. [Tom Harrop]

0.14.1 (2026-08-13)
-------------------

- Log git info for qc too. [Tom Harrop]

0.14.0 (2026-08-12)
-------------------

- Merge pull request #36 from AToL-Bioinformatics/broker_raw. [Tom
  Harrop]

  Broker raw reads to ENA and submit Runs
- Fix targets for launcher 0.16.1. [Tom Harrop]
- Update target names. [Tom Harrop]
- Keep receipts. [Tom Harrop]
- Keep receipts. [Tom Harrop]
- Keep receipts. [Tom Harrop]
- Keep receipts. [Tom Harrop]
- Test Run brokering from HPC. [Tom Harrop]

0.13.6 (2026-08-06)
-------------------

- Bump. [Tom Harrop]

0.13.5 (2026-07-31)
-------------------

- Check log_dir again. [Tom Harrop]
- Readme. [Tom Harrop]

0.13.4 (2026-07-31)
-------------------

- Only run upload_logs if there are files to upload. [Tom Harrop]

0.13.3 (2026-07-30)
-------------------

- Bump launcher version. [Tom Harrop]
- Tidy after upload. [Tom Harrop]

0.13.2 (2026-07-30)
-------------------

- Fix curation paths. [Tom Harrop]

0.13.1 (2026-07-30)
-------------------

- Can't run. [Tom Harrop]

0.13.0 (2026-07-29)
-------------------

- Merge pull request #30 from AToL-Bioinformatics/prod_updates_1. [Tom
  Harrop]

  Updates for production assemblies
- Add post curation script. [Tom Harrop]
- Bump launcher version. [Tom Harrop]
- Post_curation: run pretext-to-asm then remove manually excluded
  contigs fixes #20. [Tom Harrop]
- Update git targets. [Tom Harrop]
- Output proper json (for #17) [Tom Harrop]
- Fix stats job. [Tom Harrop]
- Launcher version. [Tom Harrop]
- Run seqkit to get stats addresses #29. [Tom Harrop]
- Report git results and upload the reports to object store fixes #17
  fixes #23. [Tom Harrop]
- Upload stats and receipts files (fixes #23) [Tom Harrop]
- Ensure reheader runs before upload (fixes #28) [Tom Harrop]
- Update step names in profile (fixes #27) [Tom Harrop]

0.12.1 (2026-05-15)
-------------------

- Bump launcher. [Tom Harrop]

0.12.0 (2026-05-15)
-------------------

- Merge pull request #18 from AToL-Bioinformatics/bench. [Tom Harrop]

  Fix benchmarking.
- Path() objects must be strings for rules with benchmarks. [Tom Harrop]

0.11.1 (2026-05-13)
-------------------

- Try workaround for <https://github.com/snakemake/snakemake/issues/3916>.
  [Tom Harrop]

0.11.0 (2026-05-13)
-------------------

- Merge pull request #16 from AToL-Bioinformatics/broker. [Tom Harrop]

  Broker
- Broker_raw_reads on copy partition. [Tom Harrop]
- Parse git info. Addresses #17. [Tom Harrop]
- Runscript for brokering. [Tom Harrop]
- Benchmark everything. [Tom Harrop]
- Don't clobber existing checksum files. [Tom Harrop]
- Upload with cURL and log stats. [Tom Harrop]
- Scaffold CURL step with trace. [Tom Harrop]
- Basic outline of ena uploading. [Tom Harrop]

0.10.4 (2026-05-08)
-------------------

- Bump. [Tom Harrop]

0.10.03 (2026-05-08)
--------------------

- Use the JSON manifest in the profile. [Tom Harrop]

0.10.2 (2026-05-08)
-------------------

- Bump. [Tom Harrop]

0.10.1 (2026-05-08)
-------------------

New

~~~
- Print the config as YAML for the README. [Tom Harrop]


0.10.0 (2026-05-07)
-------------------
- Switch to JSON manifest. [Tom Harrop]


0.9.4 (2026-05-06)
------------------
- Typo in resources. [Tom Harrop]


0.9.3 (2026-05-05)
------------------
- Typo in resources. [Tom Harrop]


0.9.2 (2026-05-05)
------------------

New
~~~

- Upload all logfiles. [Tom Harrop]

0.9.1 (2026-05-01)
------------------

New

~~~
- Update the status on GitHub. [Tom Harrop]

Other
~~~~~

- Update deployed readme. [Tom Harrop]
- Update deployed readme. [Tom Harrop]
- Include README in deployed repo. [Tom Harrop]
- Create LICENSE. [Tom Harrop]
- Update LICENSE. [Tom Harrop]

0.9.0 (2026-04-29)
------------------

- Merge pull request #15 from AToL-Bioinformatics/individual_dl. [Tom
  Harrop]

  Individual job for each file download.
- Update pacbio qc. [Tom Harrop]
- Individual job for each file download. Closes #14. [Tom Harrop]
- Individual job for each file download. Closes #14. [Tom Harrop]

0.8.0 (2026-04-24)
------------------

Changes

~~~~~~~
- Defer path logic to manifest (fixes #7) [Tom Harrop]

Other
~~~~~
- Merge pull request #12 from AToL-Bioinformatics/strings. [Tom Harrop]
- Minimap2 memory. [Tom Harrop]
- Profile tweaks. [Tom Harrop]
- Param tweaks. [Tom Harrop]
- Stop pipeline in we can't find the mitohifi ref. [Tom Harrop]
- Try NCBI_API_KEY. [Tom Harrop]
- Bug in launcher. [Tom Harrop]
- Ancient files to prevent re-downloading. [Tom Harrop]
- Send copy jobs to the copy queue on Pawsey. [Tom Harrop]
- Profile tweaks. [Tom Harrop]
- Mini spartan profile. [Tom Harrop]
- Run the fastq to fasta conversion earlier. [Tom Harrop]
- Merge. [Tom Harrop]
- Fix Snakefile conflict. [Tom Harrop]
- Typo. [Tom Harrop]


0.7.2 (2026-04-20)
------------------
- Rearrange targets. Configure FASTK_FASTK process (might help #13) [Tom
  Harrop]


0.7.1 (2026-04-17)
------------------

Fix
~~~
- Allow reformatting ONT reads to fasta. [Tom Harrop]


0.7.0 (2026-04-16)
------------------
- Config for GET_PAIRED_CONTACT_BED (fixes #11) [Tom Harrop]


0.6.12 (2026-04-16)
-------------------
- Seqkit runtime. [Tom Harrop]


0.6.10 (2026-04-15)
-------------------
- Fix reheader step for treeval. [Tom Harrop]


0.6.9 (2026-04-14)
------------------
- Treeval config. [Tom Harrop]


0.6.8 (2026-04-13)
------------------
- Reheader FASTA files for treeval (basic af, will need to fix) [Tom
  Harrop]
- Param tweaks. [Tom Harrop]
- Param tweaks. [Tom Harrop]


0.6.7 (2026-04-10)
------------------
- Hi-c info for CRAM. [Tom Harrop]


0.6.6 (2026-04-10)
------------------
- Pb qc flags. [Tom Harrop]


0.6.5 (2026-04-10)
------------------
- Try to disable full BTK pipeline. [Tom Harrop]


0.6.4 (2026-04-09)
------------------
- Bump genome launcher for download bug. [Tom Harrop]


0.6.2 (2026-04-09)
------------------

Changes
~~~~~~~

- Separate BUSCO datasets for genomeassembly and ascc. [Tom Harrop]

0.6.1 (2026-04-08)
------------------

- Update bucket mtime. [Tom Harrop]

0.6.0 (2026-04-08)
------------------

- Config for staging buckets manually. [Tom Harrop]
- Stage_any_bucket. [Tom Harrop]
- Stage_any_bucket. [Tom Harrop]
- Document BUSCO fix. [Tom Harrop]
- Tweak busco. [Tom Harrop]
- Tweak busco. [Tom Harrop]

0.5.1 (2026-04-04)
------------------

- Typo. [Tom Harrop]

0.5.0 (2026-04-04)
------------------

- Path. [Tom Harrop]
- Bbmap. [Tom Harrop]
- Treeval. [Tom Harrop]

0.4.0 (2026-04-03)
------------------

- Fix sample id. [Tom Harrop]
- Ascc paths' [Tom Harrop]
- Enable snakemake. [Tom Harrop]
- Major refactor of Pawsey profile (fixes #4) [Tom Harrop]
- Ascc. [Tom Harrop]
- Ascc. [Tom Harrop]
- Ascc. [Tom Harrop]
- Ascc. [Tom Harrop]
- Annotation config. [Tom Harrop]
- Annotation config. [Tom Harrop]
- Ascc. [Tom Harrop]
- Ascc. [Tom Harrop]
- Ascc. [Tom Harrop]
- Ascc. [Tom Harrop]
- Ascc. [Tom Harrop]
- Initial commit. [Tom Harrop]

0.3.4 (2026-04-02)
------------------

- Bump genome launcher. [Tom Harrop]

0.3.3 (2026-04-02)
------------------

- Acacia case insensitive. [Tom Harrop]

0.3.2 (2026-04-02)
------------------

- Typos. [Tom Harrop]

0.3.1 (2026-04-02)
------------------

- Typos. [Tom Harrop]

0.3.0 (2026-04-02)
------------------

- Post-assembly upload script. [Tom Harrop]

0.2.4 (2026-04-01)
------------------

- Mtime. [Tom Harrop]

0.2.3 (2026-04-01)
------------------

- Pipeline config. [Tom Harrop]

0.2.2 (2026-04-01)
------------------

- Nextflow lineage directory. [Tom Harrop]

0.2.0 (2026-04-01)
------------------

Changes

~~~~~~~
- Adapt for split config in next genomeassembly release. [Tom Harrop]


0.1.5 (2026-04-01)
------------------
- Workflow/rules/31_stage_fcsgx_db.smk. [Tom Harrop]
- Stage fcsgx db. [Tom Harrop]
- Stage fcsgx db. [Tom Harrop]
- Workflow. [Tom Harrop]
- Workflow. [Tom Harrop]
- Workflow. [Tom Harrop]
- Stage fcsgc. [Tom Harrop]
- Stage fcsgc. [Tom Harrop]
- Stage fcsgc. [Tom Harrop]
- Merge branch 'main' into stage_fcsgx. [Tom Harrop]
- Fcsgx. [Tom Harrop]
- Ok. [Tom Harrop]
- No point running stage_busco with qc, pawsey deletes it anyway. [Tom
  Harrop]


0.1.4 (2026-03-31)
------------------
- Genome launcher version. [Tom Harrop]
- Busco path. [Tom Harrop]


0.1.3 (2026-03-29)
------------------

Changes
~~~~~~~

- Format config at runtime (fixes #1) [Tom Harrop]

Other

~~~~~
- Fu nf. [Tom Harrop]
- Not working. [Tom Harrop]


0.1.2 (2026-03-27)
------------------
- I think default profile clobbers specific. [Tom Harrop]


0.1.1 (2026-03-27)
------------------
- Genomeassembly runscript first draft. [Tom Harrop]
- Adding run scripts, nextflow configs and yaml input examples for
  sanger-tol/genomeassembly and sanger-tol/curationpretext pipelines.
  [Amy Tims]
- Renaming. [Tom Harrop]


0.1.0 (2026-03-27)
------------------
- Idk. [Tom Harrop]
- Stage busco. [Tom Harrop]
- Refactor rule order. [Tom Harrop]


0.0.12 (2026-03-27)
-------------------
- Runtimes. [Tom Harrop]


0.0.11 (2026-03-26)
-------------------
- Preflight for pawsey. [Tom Harrop]
- Testing. [Tom Harrop]


0.0.10 (2026-03-26)
-------------------
- Requirements are config. [Tom Harrop]


0.0.9 (2026-03-26)
------------------
- Pawsey profile. [Tom Harrop]
- Map with data.table. [Tom Harrop]
- Map with data.table. [Tom Harrop]
- Nt blast. [Tom Harrop]
- Test storage upload limiter. [Tom Harrop]
- Limit the number of concurrent busco downloads. [Tom Harrop]
- Paths. [Tom Harrop]
- Paths. [Tom Harrop]
- Paths. [Tom Harrop]
- Paths. [Tom Harrop]
- Paths. [Tom Harrop]
- Paths. [Tom Harrop]
- File paths. [Tom Harrop]
- File paths. [Tom Harrop]
- Working but too many checkpoints. [Tom Harrop]


0.0.8 (2026-03-26)
------------------
- Specify containers in config. [Tom Harrop]


0.0.7 (2026-03-26)
------------------
- Add ont qc. [Tom Harrop]


0.0.3 (2026-03-24)
------------------
- Update config. [Tom Harrop]


0.0.2 (2026-03-24)
------------------
- Add profile. [Tom Harrop]


0.0.1 (2026-03-24)
------------------
- Initial commit. [Tom Harrop]
- Initial commit. [Tom Harrop]


