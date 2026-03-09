#!/bin/bash
set -euo pipefail

snakemake \
  --cores 4 \
  --rerun-incomplete \
  --printshellcmds
