# workflow/rules/snp_phylo.smk
from pathlib import Path

OUTDIR = Path(config["outdir"]).resolve()

SAMTOOLS = config.get("tools", {}).get("samtools", "samtools")
BWA      = config.get("tools", {}).get("bwa", "bwa")
BCFTOOLS = config.get("tools", {}).get("bcftools", "bcftools")
TABIX    = config.get("tools", {}).get("tabix", "tabix")
SNPSITES = config.get("tools", {}).get("snp_sites", "snp-sites")
IQTREE   = config.get("tools", {}).get("iqtree", "iqtree2")

SNP_OUT = Path(config.get("snp", {}).get("outdir", str(OUTDIR / "snp"))).resolve()
REF = Path(config["snp"]["reference_fasta"]).as_posix()

MINCOV  = int(config["snp"].get("mincov", 10))
MINMAPQ = int(config["snp"].get("minmapq", 30))
MINBQ   = int(config["snp"].get("minbaseq", 20))
BCF_T   = int(config["snp"].get("bcftools_threads", 4))

rule ref_index:
    input:
        ref=REF
    output:
        fai=REF + ".fai",
        bwt=REF + ".bwt"
    log:
        str(OUTDIR / "logs" / "ref_index.log")
    shell:
        r"""
        mkdir -p {OUTDIR}/logs
        {SAMTOOLS} faidx {input.ref} &> {log}
        {BWA} index {input.ref} >> {log} 2>&1
        """

rule map_sort_bam:
    input:
        ref=REF,
        r1=str(OUTDIR / "trim" / "{sample}_1.trim.fastq.gz"),
        r2=str(OUTDIR / "trim" / "{sample}_2.trim.fastq.gz"),
        fai=REF + ".fai",
        bwt=REF + ".bwt"
    output:
        bam=str(SNP_OUT / "bam" / "{sample}.sorted.bam"),
        bai=str(SNP_OUT / "bam" / "{sample}.sorted.bam.bai")
    log:
        str(OUTDIR / "logs" / "bwa" / "{sample}.log")
    threads: 8
    shell:
        r"""
        mkdir -p $(dirname {output.bam}) {OUTDIR}/logs/bwa {SNP_OUT}/tmp
        {BWA} mem -t {threads} {input.ref} {input.r1} {input.r2} 2> {log} \
          | {SAMTOOLS} sort -@ {threads} -m 256M -T {SNP_OUT}/tmp/{wildcards.sample} -o {output.bam} - 2>> {log}
        {SAMTOOLS} index {output.bam} 2>> {log}
        """

rule lowcov_mask_bed:
    input:
        bam=str(SNP_OUT / "bam" / "{sample}.sorted.bam"),
        bai=str(SNP_OUT / "bam" / "{sample}.sorted.bam.bai"),
        ref=REF,
        fai=REF + ".fai"
    output:
        bed=str(SNP_OUT / "mask" / "{sample}.lowcov.bed")
    log:
        str(OUTDIR / "logs" / "mask" / "{sample}.log")
    shell:
        r"""
        mkdir -p {SNP_OUT}/mask {OUTDIR}/logs/mask
        {SAMTOOLS} depth -aa {input.bam} \
          | awk -v m={MINCOV} '$3 < m {{print $1"\t"($2-1)"\t"$2}}' \
          > {output.bed}
        echo "masked_positions_below_{MINCOV}bp: $(wc -l < {output.bed})" > {log}
        """

rule call_variants:
    input:
        bam=str(SNP_OUT / "bam" / "{sample}.sorted.bam"),
        bai=str(SNP_OUT / "bam" / "{sample}.sorted.bam.bai"),
        ref=REF,
        fai=REF + ".fai",
        bwt=REF + ".bwt"
    output:
        vcf=str(SNP_OUT / "vcf" / "{sample}.vcf.gz"),
        tbi=str(SNP_OUT / "vcf" / "{sample}.vcf.gz.tbi")
    log:
        str(OUTDIR / "logs" / "bcftools" / "{sample}.log")
    threads: 4
    shell:
        r"""
        mkdir -p {SNP_OUT}/vcf {OUTDIR}/logs/bcftools
        {BCFTOOLS} mpileup -f {input.ref} -q {MINMAPQ} -Q {MINBQ} -a DP -Ou {input.bam} 2> {log} \
          | {BCFTOOLS} call -mv -Ou 2>> {log} \
          | {BCFTOOLS} norm -f {input.ref} -Oz -o {output.vcf} 2>> {log}
        {TABIX} -p vcf {output.vcf} 2>> {log}
        """

##INFO=<ID=MQ,Number=1,Type=Integer,Description="Average mapping quality">

rule consensus_fasta:
    input:
        ref=REF,
        vcf=str(SNP_OUT / "vcf" / "{sample}.vcf.gz"),
        tbi=str(SNP_OUT / "vcf" / "{sample}.vcf.gz.tbi"),
        mask=str(SNP_OUT / "mask" / "{sample}.lowcov.bed")
    output:
        fa=str(SNP_OUT / "consensus" / "{sample}.fa")
    log:
        str(OUTDIR / "logs" / "consensus" / "{sample}.log")
    priority: 100
    shell:
        r"""
        mkdir -p {SNP_OUT}/consensus {OUTDIR}/logs/consensus
        {SAMTOOLS} faidx {input.ref} 2>> {log}
        {BCFTOOLS} consensus \
          -f {input.ref} \
          -m {input.mask} \
          -i 'TYPE="snp"' \
          --mark-del N \
          --mark-ins N \
          {input.vcf} > {output.fa} 2>> {log}
        sed -i '' "1s/^>.*/>{wildcards.sample}/" {output.fa}
        """

rule concat_pseudogenomes:
    input:
        expand(str(SNP_OUT / "consensus" / "{sample}.fa"), sample=SAMPLE_IDS)
    output:
        str(SNP_OUT / "all_samples.pseudogenomes.fasta")
    shell:
        r"""
        cat {input} > {output}
        """

rule snp_alignment:
    input:
        fa=str(SNP_OUT / "all_samples.pseudogenomes.fasta")
    output:
        aln=str(SNP_OUT / "core.snps.aln.fasta")
    log:
        str(OUTDIR / "logs" / "snp_sites.log")
    shell:
        r"""
        mkdir -p {OUTDIR}/logs
        {SNPSITES} -o {output.aln} {input.fa} &> {log} 2>&1
        """

rule iqtree_snp:
    input:
        aln=str(SNP_OUT / "core.snps.aln.fasta")
    output:
        tree=str(SNP_OUT / "core.snps.aln.fasta.treefile")
    log:
        str(OUTDIR / "logs" / "iqtree_snp.log")
    threads: int(config.get("iqtree", {}).get("threads", 4))
    params:
        model=lambda wc: config.get("iqtree", {}).get("model", "GTR+G"),
        bb=lambda wc: str(config.get("iqtree", {}).get("bootstrap", 1000)),
    shell:
        r"""
        mkdir -p {OUTDIR}/logs
        {IQTREE} -s {input.aln} -m {params.model} -B {params.bb} -T {threads} &> {log} 2>&1
        """