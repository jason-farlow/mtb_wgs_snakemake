Overview of Required Databases

The pipeline uses the following external resources:

Database	Tool	Purpose
AMRFinderPlus DB	AMRFinderPlus	Antimicrobial resistance gene detection
Bakta database	Bakta	Genome annotation
H37Rv reference genome	BWA / SNP workflow	Reference mapping for SNP phylogeny
Directory Structure

All databases should be stored under:

data/

Final structure should look like:

data
├── bakta_db
│   └── db-light
│       └── amrfinderplus-db
│           └── latest
└── refs
    └── mtb
        └── H37Rv.fasta
1. Reference Genome (H37Rv)

The pipeline requires the Mycobacterium tuberculosis H37Rv reference genome.

Create directory:

mkdir -p data/refs/mtb

Download reference genome:

cd data/refs/mtb

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/195/955/GCF_000195955.2_ASM19595v2/GCF_000195955.2_ASM19595v2_genomic.fna

Rename for simplicity:

mv GCF_000195955.2_ASM19595v2_genomic.fna H37Rv.fasta

The pipeline will automatically create the following indexes:

H37Rv.fasta.fai
H37Rv.fasta.bwt
H37Rv.fasta.ann
H37Rv.fasta.amb
H37Rv.fasta.pac
H37Rv.fasta.sa

These are generated automatically by the pipeline's ref_index rule.

2. AMRFinderPlus Database

The pipeline uses NCBI AMRFinderPlus to detect antimicrobial resistance genes.

Create database directory:

mkdir -p data/amrfinder_db

Download and install database:

amrfinder_update --database data/amrfinder_db

Verify installation:

amrfinder --database data/amrfinder_db --help

Expected output should include database version information.

3. Bakta Annotation Database

Genome annotation uses Bakta.

Create directory:

mkdir -p data/bakta_db

Download the light database (recommended):

bakta_db download --output data/bakta_db --type light

Expected structure:

data/bakta_db/
└── db-light

Verify database:

bakta_db list
4. Optional: Pre-configured AMRFinder Database inside Bakta

Some Bakta database versions include an internal AMRFinder database.

If using this configuration, the AMRFinder database may be located here:

data/bakta_db/db-light/amrfinderplus-db/latest

If using that path, ensure the pipeline config reflects this location.

Example:

amrfinder -d data/bakta_db/db-light/amrfinderplus-db/latest
5. Verify Database Installation

Run these commands to confirm installation:

amrfinder --help
bakta --help
bwa
samtools
6. Expected Final Database Layout

After installation, your database directory should look like:

data
├── amrfinder_db
│   ├── AMR_CDS
│   ├── AMRProt
│   └── version.txt
│
├── bakta_db
│   └── db-light
│
└── refs
    └── mtb
        └── H37Rv.fasta
7. Storage Requirements

Approximate disk usage:

Resource	Size
H37Rv reference	~4 MB
AMRFinder DB	~200 MB
Bakta light DB	~1.5 GB

Total recommended space:

~2 GB
8. Running the Pipeline After Setup

After installing databases, run the pipeline:

snakemake --cores 4 --use-conda
9. Test the Pipeline with Example Data

Example data is provided under:

test_data/example_mtb

Run the pipeline using the example dataset:

snakemake --cores 2 --use-conda

Expected outputs include:

results/mtb/snp/core.snps.aln.fasta
results/mtb/snp/core.snps.aln.fasta.treefile
results/mtb/multiqc/multiqc_report.html
10. Troubleshooting
AMRFinder database errors

If AMRFinder fails with database errors:

amrfinder_update --force_update --database data/amrfinder_db
Missing reference genome

If the pipeline reports:

MissingInputException: H37Rv.fasta

Verify:

data/refs/mtb/H37Rv.fasta

exists.

11. Reproducibility

All tool versions are controlled using Snakemake conda environments located in:

envs/

This ensures consistent results across:

local machines

HPC clusters

cloud environments (EC2)

12. Notes for Cloud / HPC Deployment

When deploying on EC2 or HPC:

Recommended directory layout:

/data/databases
/data/mtb_pipeline
/data/results

Database paths can be adjusted in:

config/config.yaml
