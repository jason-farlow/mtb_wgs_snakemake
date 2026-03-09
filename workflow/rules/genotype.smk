
ABRICATE = config.get("tools", {}).get("abricate", "abricate")

rule mlst:
    input:
        contigs=str(OUTDIR / "assembly" / "{sample}" / "contigs.fasta")
    output:
        tsv=str(OUTDIR / "mlst" / "{sample}.tsv")
    log:
        str(OUTDIR / "logs" / "mlst" / "{sample}.log")
    shell:
        """
        mkdir -p {OUTDIR}/mlst {OUTDIR}/logs/mlst
        mlst {input.contigs} > {output.tsv} 2> {log}
        """

ABRICATE = config.get("tools", {}).get("abricate", "abricate")

rule abricate:
    input:
        contigs=str(OUTDIR / "assembly" / "{sample}" / "contigs.fasta")
    output:
        tsv=str(OUTDIR / "abricate" / "{sample}.tsv")
    log:
        str(OUTDIR / "logs" / "abricate" / "{sample}.log")
    shell:
        """
        mkdir -p {OUTDIR}/abricate {OUTDIR}/logs/abricate
        abricate --db ncbi {input.contigs} > {output.tsv} 2> {log}
        """
