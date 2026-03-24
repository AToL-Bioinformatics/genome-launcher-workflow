Run the workflow like this:

```bash
snakemake \
    --profile profiles/local \
    --config manifest=test-data/dummy.yaml \
```

You can also the path to the manifest in the manifest key

```yaml
manifest: "path/to/manifest.yaml"
```