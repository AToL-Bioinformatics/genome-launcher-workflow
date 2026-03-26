Run the workflow like this:

```bash
snakemake \
    --profile profiles/local
```

The configfile is loaded from "config/config.yaml"

The path to the assembly manifest is specified in the configfile by the
manifest key.

```yaml
manifest: "path/to/manifest.yaml"
```

You can override this on the CLI using `--config
manifest=path/to/some/other/manifest.yaml`.