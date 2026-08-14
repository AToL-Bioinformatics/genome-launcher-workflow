#!/usr/bin/env python3

import json
from pathlib import Path

import pandas as pd


def read_json_from_path(path_to_json_file: Path) -> dict[str, str | int | list[str]]:
    with open(path_to_json_file, "rb") as f:
        return json.load(f)


def main():
    stats_file = snakemake.input["stats"]
    read_stats_files = snakemake.input["read_stats"]

    long_read_bases = 0
    for read_stat_file in read_stats_files:
        read_stats = read_json_from_path(read_stat_file)
        long_read_bases += read_stats.get("base_count", 0)

    assembly_stats = pd.read_csv(stats_file, sep="\t")

    assembly_stats["sequencing_depth"] = (
        (long_read_bases / (assembly_stats["sum_len"] - assembly_stats["sum_n"]))
        .round(0)
        .astype(int)
    )

    assembly_stats.to_csv(snakemake.output["stats"], sep="\t")


if __name__ == "__main__":
    main()
