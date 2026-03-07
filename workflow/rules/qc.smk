rule fastqc:
    input:
        r1=lambda wc: SAMPLES[wc.sample]["r1"],
        r2=lambda wc: SAMPLES[wc.sample]["r2"]
    output:
        html1=str(OUTDIR / "fastqc" / "{sample}_1_fastqc.html"),
        zip1=str(OUTDIR / "fastqc" / "{sample}_1_fastqc.zip"),
        html2=str(OUTDIR / "fastqc" / "{sample}_2_fastqc.html"),
        zip2=str(OUTDIR / "fastqc" / "{sample}_2_fastqc.zip")
    log:
        str(OUTDIR / "logs" / "fastqc" / "{sample}.log")
    threads: 2
    shell:
        """
        mkdir -p {OUTDIR}/fastqc {OUTDIR}/logs/fastqc
        fastqc -o {OUTDIR}/fastqc {input.r1} {input.r2} &> {log}
        """

rule multiqc:
    input:
        expand(str(OUTDIR / "fastqc" / "{sample}_1_fastqc.zip"), sample=SAMPLE_IDS),
        expand(str(OUTDIR / "fastqc" / "{sample}_2_fastqc.zip"), sample=SAMPLE_IDS)
    output:
        str(OUTDIR / "multiqc" / "multiqc_report.html")
    log:
        str(OUTDIR / "logs" / "multiqc.log")
    shell:
        """
        mkdir -p {OUTDIR}/multiqc {OUTDIR}/logs
        multiqc -o {OUTDIR}/multiqc {OUTDIR}/fastqc &> {log}
        """
