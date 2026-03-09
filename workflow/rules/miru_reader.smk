from pathlib import Path

MIRU_DIR = config.get("miru", {}).get("repo_dir", "resources/MIRUReader")

rule mirureader:
    input:
        fasta = str(OUTDIR / "assembly" / "{sample}" / "contigs.fasta")
    output:
        txt = str(OUTDIR / "miru" / "{sample}.txt")
    log:
        str(OUTDIR / "logs" / "miru" / "{sample}.log")
    conda:
        "../../config/mirureader.yaml"
    threads: 1
    shell:
        r"""
        set -euo pipefail
        mkdir -p "{OUTDIR}/miru" "{OUTDIR}/logs/miru"

        cd "{MIRU_DIR}"

        which primersearch >> "{log}" 2>&1 || true

        python "MIRUReader.py" \
          -r "{input.fasta}" \
          -p "{wildcards.sample}" \
          > "{output.txt}" 2>> "{log}"
        """
