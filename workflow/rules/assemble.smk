# workflow/rules/assemble.smk
from pathlib import Path

OUTDIR = Path(config["outdir"]).resolve()

TRIM_DIR = OUTDIR / "trim"
ASM_DIR  = OUTDIR / "assembly"
LOG_DIR  = OUTDIR / "logs" / "assembly"

# tool paths from config.yaml (fallback to command name if not provided)
SPADES = config.get("tools", {}).get("spades", "spades.py")
SKESA  = config.get("tools", {}).get("skesa",  "skesa")

ASSEMBLER = config.get("assembly", {}).get("assembler", "spades").lower()

rule assemble:
    input:
        r1=str(TRIM_DIR / "{sample}_1.trim.fastq.gz"),
        r2=str(TRIM_DIR / "{sample}_2.trim.fastq.gz"),
    output:
        contigs=str(ASM_DIR / "{sample}" / "contigs.fasta"),
    log:
        str(LOG_DIR / "{sample}.log"),
    threads: int(config.get("assembly", {}).get("threads", 8))
    params:
        extra=config.get("assembly", {}).get("extra", ""),
        tmpdir=lambda wc: str(OUTDIR / "tmp" / "assembly" / wc.sample),
    priority: 100
    shell:
        r"""
        set -euo pipefail

        mkdir -p "$(dirname "{output.contigs}")" "{LOG_DIR}" "{params.tmpdir}"

        if [ "{ASSEMBLER}" = "spades" ]; then
            # SPAdes writes contigs to: <outdir>/contigs.fasta
            {SPADES} --careful \
                -1 "{input.r1}" \
                -2 "{input.r2}" \
                -t {threads} \
                -o "$(dirname "{output.contigs}")" \
                {params.extra} \
                &> "{log}"

        elif [ "{ASSEMBLER}" = "skesa" ]; then
            {SKESA} --reads "{input.r1}","{input.r2}" \
                {params.extra} \
                > "{output.contigs}" 2> "{log}"
        else
            echo "ERROR: Unknown assembler '{ASSEMBLER}'. Use 'spades' or 'skesa' in config.yaml under assembly: assembler" >&2
            exit 2
        fi
        """