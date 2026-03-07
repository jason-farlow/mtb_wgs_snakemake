# workflow/rules/trim.smk
from pathlib import Path

OUTDIR = Path(config["outdir"]).resolve()

FASTP = config.get("tools", {}).get("fastp", "fastp")

# workflow/rules/trim.smk

from pathlib import Path
FASTQ_DIR = Path(config["fastq_dir"])

rule fastp_trim:
    input:
        r1=lambda wc: str(FASTQ_DIR / f"{wc.sample}{config.get('r1_token','_1')}{config.get('fastq_ext','.fastq.gz')}"),
        r2=lambda wc: str(FASTQ_DIR / f"{wc.sample}{config.get('r2_token','_2')}{config.get('fastq_ext','.fastq.gz')}")
    output:
        r1=str(OUTDIR / "trim" / "{sample}_1.trim.fastq.gz"),
        r2=str(OUTDIR / "trim" / "{sample}_2.trim.fastq.gz"),
        json=str(OUTDIR / "trim" / "{sample}.fastp.json"),
        html=str(OUTDIR / "trim" / "{sample}.fastp.html")
    log:
        str(OUTDIR / "logs" / "fastp" / "{sample}.log")
    threads: 4
    shell:
        r"""
        set -euo pipefail
        mkdir -p {OUTDIR}/trim {OUTDIR}/logs/fastp
        fastp -i {input.r1} -I {input.r2} \
              -o {output.r1} -O {output.r2} \
              -j {output.json} -h {output.html} \
              -w {threads} > {log} 2>&1
        """