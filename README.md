MTB WGS Snakemake Pipeline
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

This repository contains a reproducible Snakemake workflow for analysis of *Mycobacterium tuberculosis* whole-genome sequencing data.

Currently **stable and supported modules**:

- Read QC and trimming (fastp / FastQC)
- Genome assembly (SPAdes)
- Reference mapping and SNP calling (BWA + bcftools)
- Core SNP alignment and variant analysis
- Whole genome (wg)SNP tree for phylogenetic reconstruction (IQ-TREE)
- MIRU-VNTR allele calling for lineage identification


Overview of Analysis

This repository contains a reproducible workflow for analysis of Mycobacterium tuberculosis short and long read genome sequence data. The pipeline is implemented using Snakemake and is containerized for running on local workstations, HPC clusters, and cloud compute environments such as AWS.

The workflow performs read preprocessing/QC, de novo and mapped genome assembly, variant analysis, whoel genome SNP based phylogenetic analysis, and MIRU-VNTR allele calling. Antimicrobial resistance detection and genome annotation will be added to future distributions. 

The MTB WGS Snakemake pipeline processes paired-end FASTQ files through read trimming (fastp), genome assembly (SPAdes), sequencing and assembly QC (FastQC, MultiQC), reference-based SNP analysis (BWA or minimap2, samtools, bcftools), and phylogenetic reconstruction (IQ-TREE). Optional tools will incldue AMRFinderPlus and Bakta for antimicrobial resistance detection and genome annotation, respectively.


Pipeline Steps

Read Quality Control and Trimming

Raw paired end FASTQ sequencing reads are processed using the program fastp.
fastp removes sequencing adapters, trims low quality bases, and filters poor quality reads before downstream analysis.

Output from this step is a set of trimmed FASTQ files.

Genome Assembly

Trimmed sequencing reads are assembled using SPAdes.
SPAdes performs de novo genome assembly and produces draft genome contigs for each isolate.

Output from this step is a contigs.fasta file for each sample.

Sequencing and Assembly Quality Control

Sequencing and assembly quality metrics are generated using FastQC and MultiQC.
FastQC generates quality reports for each sequencing library and MultiQC aggregates the reports into a single summary report across all samples.

Output from this step is a MultiQC report summarizing sequencing quality and assembly statistics.

Reference Based SNP Analysis

Sequencing reads are aligned to the Mycobacterium tuberculosis H37Rv reference genome.
Read alignment is performed using minimap2 or BWA depending on configuration.
Alignment files are processed using samtools.
Variants are identified and filtered using bcftools.

These steps produce variant call files for each isolate and a core genome SNP alignment across samples.

Output from this step includes VCF files for each isolate and a core SNP alignment.

Phylogenetic Reconstruction

Phylogenetic relationships between isolates are inferred using IQ TREE.
IQ TREE performs maximum likelihood phylogenetic inference using the SNP alignment.

Output from this step is a maximum likelihood phylogenetic tree in Newick format.

MIRU Typing

Variable number tandem repeat typing can be performed using MIRUReader.
This provides traditional MIRU based genotyping profiles for each isolate.

Output from this step is a MIRU typing profile for each isolate.


⚠️ **Modules currently under development and not yet part of the stable release:**

- AMR detection
- Genome annotation
- MLST / cgMLST
- Plasmid detection

These modules exist in the repository but are **disabled by default in the configuration** and may change as development continues.

Users interested in these features should consider them **experimental** until the next release. Pleasde see descriptions below:


Antimicrobial Resistance Detection

Antimicrobial resistance genes and mutations are detected using AMRFinderPlus.
AMRFinderPlus identifies known resistance determinants using curated antimicrobial resistance databases.

Output from this step is a table of detected resistance genes and mutations for each isolate.

Genome Annotation

Genome annotation can optionally be performed using Bakta.
Bakta predicts coding sequences, proteins, and functional annotations for bacterial genomes.

Output from this step includes genome annotation files such as GFF files and protein FASTA files.

Pipeline Outputs

The pipeline generates several outputs including trimmed sequencing reads, quality control reports, genome assemblies, SNP variant calls, SNP alignments, phylogenetic trees, and MIRU-VNTR allele calls.

Workflow Features

The pipeline uses Snakemake for workflow management.
Bioinformatics tools are containerized using Docker.
The pipeline is modular and can be extended with additional analyses.
The workflow can run on local computers, HPC clusters, or cloud infrastructure.

Input Requirements

The pipeline expects paired end FASTQ sequencing files using the naming convention sampleID underscore 1 fastq.gz and sampleID underscore 2 fastq.gz.

The reference genome used for SNP analysis is the Mycobacterium tuberculosis H37Rv reference genome.

Example Test Dataset

An example MTB sequencing dataset is included in the directory test_data/example_mtb.
This dataset allows users to test the pipeline before running their own sequencing data.

Typical Use Cases

This workflow can be used for genomic surveillance of Mycobacterium tuberculosis, outbreak investigation, phylogenetic analysis of isolates, antimicrobial resistance monitoring, and training in microbial genomics.





