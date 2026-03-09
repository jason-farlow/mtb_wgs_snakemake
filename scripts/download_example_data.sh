#!/bin/bash
set -euo pipefail

echo "Downloading MTB phylogeny example dataset..."

mkdir -p test_data

curl -L -o mtb_phylogeny_example_data.tar.gz https://github.com/jason-farlow/mtb_wgs_snakemake/releases/download/v1/mtb_phylogeny_example_data.tar.gz

echo "Extracting dataset..."

tar -xzf mtb_phylogeny_example_data.tar.gz

rm mtb_phylogeny_example_data.tar.gz

echo "Example dataset ready in test_data/example_mtb"
