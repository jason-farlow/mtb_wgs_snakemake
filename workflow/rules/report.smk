rule final_report:
    input:
        multiqc = str(OUTDIR / "multiqc" / "multiqc_report.html"),
        tree = str(SNP_OUT / "core.snps.aln.fasta.treefile"),
        alignment = str(SNP_OUT / "core.snps.aln.fasta")
    output:
        report_tree = str(OUTDIR / "report" / "mtb_phylogeny.treefile"),
        report_alignment = str(OUTDIR / "report" / "core_snps_alignment.fasta"),
        report_multiqc = str(OUTDIR / "report" / "multiqc_report.html")
    shell:
        """
        mkdir -p {OUTDIR}/report

        cp {input.tree} {output.report_tree}
        cp {input.alignment} {output.report_alignment}
        cp {input.multiqc} {output.report_multiqc}
        """
