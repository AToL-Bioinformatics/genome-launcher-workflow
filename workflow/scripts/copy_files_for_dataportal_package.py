#!/usr/bin/env python3

import hashlib
import json
import logging
from pathlib import Path
import shutil
import tarfile


def md5sum(file: Path, blocksize: int = 65536) -> str:
    hash = hashlib.md5()
    with open(file, "rb") as f:
        for block in iter(lambda: f.read(blocksize), b""):
            hash.update(block)
    return hash.hexdigest()


def main():

    logger = logging.getLogger("copy_files_for_dataportal_package")
    logging.basicConfig(
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
        datefmt="%H:%M:%S",
        level=logging.INFO,
    )

    try:
        dp_filelist = Path(snakemake.input["dp_filelist"])
        dp_metadata = Path(snakemake.input["dp_metadata"])
        package_dir = Path(snakemake.output["package_dir"])

        fh = logging.FileHandler(snakemake.log[0])
        logger.handlers.clear()
        logger.addHandler(fh)

    except NameError as e:
        dp_filelist = Path("results/bpa_draft_assembly/filelist.json")
        dp_metadata = Path("results/bpa_draft_assembly/metadata.xlsx")
        package_dir = Path("results/bpa_draft_assembly/bpa_package")

    with open(dp_filelist, "rb") as f:
        bp_files_map = json.loads(f.read())

    # generate the package directory
    _ = package_dir.mkdir(parents=True, exist_ok=True)

    # accumulate files that need checksumming
    files_to_checksum = []

    # copy the metadata file
    metadata_file_name = bp_files_map.get("metadata", {}).get("filename", "")
    metadata_file_dst = Path(package_dir, metadata_file_name)
    logger.info(f"Copying metadata file from {dp_metadata} to {metadata_file_dst}.")
    _ = shutil.copyfile(
        dp_metadata,
        metadata_file_dst,
        follow_symlinks=True,
    )
    files_to_checksum.append(metadata_file_dst)

    # copy the individual files
    for filetype, single_file in bp_files_map.get("single_files", {}).items():
        required = single_file.get("required", True)
        single_file_src = Path(single_file.get("path", ""))
        single_file_name = single_file.get("filename")
        single_file_dst = Path(package_dir, single_file_name)

        logger.info(
            f"Copying {filetype} file from {single_file_src} to {single_file_dst}. Required is {required}."
        )
        if single_file_src.is_file():
            _ = shutil.copyfile(
                single_file_src,
                single_file_dst,
                follow_symlinks=True,
            )
        elif required is False:
            logger.warning(
                f"Source file {single_file_src} is missing, but not required. It will be skipped."
            )
        else:
            raise FileNotFoundError(single_file_src)

        files_to_checksum.append(single_file_dst)

    # copy the multi-file objects
    for filetype, file_list in bp_files_map.get("file_lists", {}).items():
        required = file_list.get("required", True)
        tarfile_name = file_list.get("filename")
        tarfile_dst = Path(package_dir, tarfile_name)
        logger.info(f"Generating {filetype} tarfile at {tarfile_dst}")
        with tarfile.open(tarfile_dst, "w|gz") as tar:
            for file_src in file_list.get("paths", []):
                file_src_path = Path(file_src)
                logger.info(f"Adding {file_src_path} to {tarfile_dst}")
                if file_src_path.is_file():
                    tar.add(file_src_path, arcname=file_src_path.name)
                elif required is False:
                    logger.warning(
                        f"Source file {file_src_path} is missing, but not required. It will be skipped."
                    )
                else:
                    raise FileNotFoundError(single_file_src)

        files_to_checksum.append(tarfile_dst)

    # compress the whole-directory objects
    for filetype, whole_directory in bp_files_map.get("directories", {}).items():
        required = whole_directory.get("required", True)
        directory_src = Path(whole_directory.get("path", ""))
        tarfile_name = whole_directory.get("filename")
        tarfile_dst = Path(package_dir, tarfile_name)
        logger.info(
            f"Compressing {filetype} directory from {directory_src} to {tarfile_dst}"
        )

        if directory_src.is_dir():
            with tarfile.open(tarfile_dst, "w|gz") as tar:
                for p in directory_src.iterdir():
                    logger.debug(p)
                    tar.add(p, arcname=p.name)
        elif required is False:
            logger.warning(
                f"Source directory {directory_src} is missing, but not required. It will be skipped."
            )
        else:
            raise FileNotFoundError(directory_src)

        files_to_checksum.append(tarfile_dst)

    # make an empty manifests file (for later use)
    manifest_file = Path(package_dir, bp_files_map.get("manifest", {}).get("filename"))
    with open(manifest_file, "wt") as f:
        json.dump({}, f)
    files_to_checksum.append(manifest_file)

    # calculate checksums
    checksum_file = Path(package_dir, bp_files_map.get("checksums", {}).get("filename"))
    logger.info(f"Writing checksums to {checksum_file}.")
    with open(checksum_file, "wt") as f:
        for file in files_to_checksum:
            logger.info(f"Calculating checksum for {file}.")
            checksum = md5sum(file)
            f.write(f"{file.name}    {checksum}\n")


if __name__ == "__main__":
    main()
