#MTB WGS Snakemake Pipeline
Mycobacterium tuberculosis Whole Genome Sequencing Analysis Workflow

## Quick start

Clone the repository:

```bash
git clone https://github.com/jason-farlow/mtb_wgs_snakemake.git
cd mtb_wgs_snakemake

Create a local configuration file:

```bash
cp config/config.example.yaml config/config.yaml
```

Place paired-end FASTQ files in:

```
test_data/example_mtb/
```

Expected naming pattern:

```
SAMPLE_1.fastq.gz
SAMPLE_2.fastq.gz
```

Run the pipeline:

```bash
snakemake --use-conda --cores 4
```

Note: Large FASTQ test files are not included in the GitHub repository.  
Users must provide their own sequencing data in `test_data/example_mtb/`.


## Pipeline status

This repository contains a reproducible Snakemake workflow for whole genome SNP analysis of *Mycobacterium tuberculosis* NGS short read sequence data.

Currently **stable and supported modules**:

- Read QC and trimming (fastp / FastQC)
- Genome assembly (SPAdes)
- Reference mapping and SNP calling (BWA + bcftools)
- Core SNP alignment and variant analysis
- Whole genome (wg)SNP tree for phylogenetic reconstruction (IQ-TREE, newick-formatted ML phylogeny)
- MIRU-VNTR allele calling for lineage identification

Overview of Analysis

This repository accepts short read genome sequence data and is implemented using Snakemake. It is containerized for running on local workstations, HPC clusters, and cloud compute environments.

The workflow performs read preprocessing/QC, de novo and mapped genome assembly, variant analysis, whole genome SNP based phylogenetic analysis, and MIRU-VNTR allele calling. Output files include contigs.fasta files, .vcf files, a ML phylogeny in .nwk format, and MIRU based genotyping allele profiles for each isolate  generated as.txt files. 

Incorporating long read data (ONT), antimicrobial resistance detection (AMRFinderPlus),  genome annotation (Bakta), MLST/cgMLST, and additkional SNP filters will be added to future distributions.

⚠️ **Modules currently under development and not yet part of the stable release:**

- AMR detection
- Genome annotation
- MLST / cgMLST

These modules exist in the repository but are **disabled by default in the configuration** and may change as development continues.

Users interested in these features should consider them **experimental** until the next release. 

Please see descriptions below:

Input Requirements

Users must provide their own sequencing data in `test_data/example_mtb/` as stated above. The pipeline expects paired end FASTQ sequencing files using the naming convention sampleID underscore 1 fastq.gz (ID_R1,fastq.gz) and sampleID underscore 2 fastq.gz (ID_R2,fastq.gz). The reference genome used for SNP analysis is the Mycobacterium tuberculosis H37Rv reference genome.

Example Test Dataset

An example MTB sequencing dataset is included in the directory test_data/example_mtb.
This dataset allows users to test the pipeline before running their own sequencing data.

Typical Use Cases

This workflow can be used for genomic surveillance of Mycobacterium tuberculosis, outbreak investigation, phylogenetic analysis of isolates, antimicrobial resistance monitoring, and training in microbial genomics.





