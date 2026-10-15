#!/usr/bin/env python3

import json
from pathlib import Path
import shutil
import tarfile


def main():
    try:
        dp_files = snakemake.input["dp_files"]
        package_dir = snakemake.output["package_dir"]
    except NameError:
        dp_files = Path("results/bpa_draft_assembly/filenames.json")
        package_dir = Path("results/bpa_draft_assembly/bpa_package")
    with open(dp_files, "rb") as f:
        bp_files_map = json.loads(f.read())

    # generate the package directory
    _ = package_dir.mkdir(parents=True, exist_ok=True)

    # copy the individual files
    for filetype, single_file in bp_files_map.get("single_files", {}).items():
        single_file_src = Path(single_file.get("path", ""))
        single_file_name = single_file.get("filename")
        single_file_dst = Path(package_dir, single_file_name)

        print(f"Copying {filetype} file from {single_file_src} to {single_file_dst}")
        if single_file_src.is_file():
            _ = shutil.copyfile(
                single_file_src,
                single_file_dst,
                follow_symlinks=True,
            )
        else:
            raise FileNotFoundError(single_file_src)

    # copy the multi-file objects
    for filetype, file_list in bp_files_map.get("file_lists", {}).items():
        tarfile_name = file_list.get("filename")
        tarfile_dst = Path(package_dir, tarfile_name)
        print(f"Generating {filetype} tarfile at {tarfile_dst}")
        with tarfile.open(tarfile_dst, "w|gz") as tar:
            for file_src in file_list.get("paths", []):
                file_src_path = Path(file_src)
                print(f"Adding {file_src_path} to {tarfile_dst}")
                if file_src_path.is_file():
                    tar.add(file_src_path, arcname=file_src_path.name)
                else:
                    raise FileNotFoundError(file_src_path)

    # compress the whole-directory objects
    for filetype, whole_directory in bp_files_map.get("directories", {}).items():
        directory_src = Path(whole_directory.get("path", ""))
        tarfile_name = whole_directory.get("filename")
        tarfile_dst = Path(package_dir, tarfile_name)
        print(f"Compressing {filetype} directory from {directory_src} to {tarfile_dst}")

        if directory_src.is_dir():
            with tarfile.open(tarfile_dst, "w|gz") as tar:
                tar.add(directory_src, arcname=directory_src.name)
        else:
            raise FileNotFoundError(directory_src)


if __name__ == "__main__":
    main()
