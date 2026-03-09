############################################################
# SNP MAPPING QC
############################################################

rule flagstat_qc:
    input:
        bam = str(SNP_OUT / "bam" / "{sample}.sorted.bam")
    output:
        str(SNP_OUT / "qc" / "{sample}.flagstat.txt")
    shell:
        """
        mkdir -p {SNP_OUT}/qc
        samtools flagstat {input.bam} > {output}
        """


rule depth_qc:
    input:
        bam = str(SNP_OUT / "bam" / "{sample}.sorted.bam")
    output:
        str(SNP_OUT / "qc" / "{sample}.depth.txt")
    shell:
        """
        mkdir -p {SNP_OUT}/qc
        samtools depth -a {input.bam} \
        | awk '{{sum+=$3; n++}} END {{print "mean_depth", sum/n}}' > {output}
        """


rule vcf_stats_qc:
    input:
        vcf = str(SNP_OUT / "vcf" / "{sample}.vcf.gz")
    output:
        str(SNP_OUT / "qc" / "{sample}.vcfstats.txt")
    shell:
        """
        mkdir -p {SNP_OUT}/qc
         bcftools stats {input.vcf} > {output}
        """
rule snp_qc_summary:
    input:
        expand(str(SNP_OUT / "qc" / "{sample}.flagstat.txt"), sample=SAMPLE_IDS),
        expand(str(SNP_OUT / "qc" / "{sample}.depth.txt"), sample=SAMPLE_IDS),
        expand(str(SNP_OUT / "qc" / "{sample}.vcfstats.txt"), sample=SAMPLE_IDS)
    output:
        str(SNP_OUT / "qc" / "snp_mapping_qc.complete")
    shell:
        """
        echo "All SNP QC complete" > {output}
        """
