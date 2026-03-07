# workflow/rules/miru_reader.smk
from pathlib import Path

MIRU_DIR = config.get("miru", {}).get("repo_dir", "/Users/eagle/MIRUReader")
MIRU_PY  = str(Path(MIRU_DIR) / "MIRUReader.py")

rule mirureader:
    input:
        fasta = str(OUTDIR / "assembly" / "{sample}" / "contigs.fasta")
    output:
        txt = str(OUTDIR / "miru" / "{sample}.txt")
    log:
        str(OUTDIR / "logs" / "miru" / "{sample}.log")
    conda:
        "/Users/eagle/wgs_snakemake_fresh/config/mirureader.yaml"

    threads: 1
    shell:
        r"""
        set -euo pipefail
        mkdir -p "{OUTDIR}/miru" "{OUTDIR}/logs/miru"

        # Run from repo so relative data files resolve (MIRU_table, MIRU_primers, etc.)
        cd "{MIRU_DIR}"

        # Show tool presence in log (helpful when debugging)
        which primersearch >> "{log}" 2>&1 || true

        python "{MIRU_PY}" \
          -r "{input.fasta}" \
          -p "{wildcards.sample}" \
          > "{output.txt}" 2>> "{log}"
        """