

rule generate_curation_package:
    input:
        "curation.tar.gz",


rule compress_curation_package:
    input: []
    output:
        "curation.tar.gz",
    shell:
        "tar -cv {input} {output}"


raise ValueError(manifest.get_dir("curation"))

# what do?
# - rename any duplicate files and put in the tmp folder
# - move other files to the tmp folder
# - compress tmp folder



# rule rename_busco_files:
#     input: "{dataset_id}.{assembly_version}.pacbio_hifi.phased/scaffolding/busco.{busco_odb12_dataset_name}_odb12/asm-busco/asm_hap1_scaffolds_final.fa/run_{busco_odb12_dataset_name}_odb12/full_table.tsv"
#     output: "{dataset_id}.{assembly_version}.pacbio_hifi.phased/scaffolding/busco.{busco_odb12_dataset_name}_odb12/asm-busco/asm_hap1_scaffolds_final.fa/run_{busco_odb12_dataset_name}_odb12/full_table.tsv"
