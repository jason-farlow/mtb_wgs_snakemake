# workflow/rules/amr_annotation.smk

rule amrfinder:
    input:
        fasta = str(OUTDIR / "assembly" / "{sample}" / "contigs.fasta")
    output:
        tsv = str(OUTDIR / "amr" / "{sample}_amr.tsv")
    log:
        str(OUTDIR / "logs" / "amr" / "{sample}.log")
    conda:
        "../../envs/amr_typing.yaml"
    params:
        db_dir = lambda wc: config["amr"]["db_dir"]
    shell:
        r"""
        set -euo pipefail
        mkdir -p {OUTDIR}/amr {OUTDIR}/logs/amr
        amrfinder -n {input.fasta} -d {params.db_dir} --plus > {output.tsv} 2> {log}
        """


rule bakta_annotate:
    input:
        fasta = str(OUTDIR / "assembly" / "{sample}" / "contigs.fasta")
    output:
        gff = str(OUTDIR / "annotation" / "{sample}" / "{sample}.gff3"),
        faa = str(OUTDIR / "annotation" / "{sample}" / "{sample}.faa")
    log:
        str(OUTDIR / "logs" / "bakta" / "{sample}.log")
    conda:
        "../../envs/bakta.yaml"
    params:
        db = lambda wc: config["bakta"]["db"],
        genus = lambda wc: config["bakta"].get("genus", ""),
        species = lambda wc: config["bakta"].get("species", "")
    threads: 4
    shell:
        r"""
        set -euo pipefail
        mkdir -p {OUTDIR}/logs/bakta
        rm -rf {OUTDIR}/annotation/{wildcards.sample}

        GENUS="{params.genus}"
        SPECIES="{params.species}"

        EXTRA=""
        if [ -n "$GENUS" ]; then EXTRA="$EXTRA --genus $GENUS"; fi
        if [ -n "$SPECIES" ]; then EXTRA="$EXTRA --species $SPECIES"; fi

        bakta --db {params.db} \
              --output {OUTDIR}/annotation/{wildcards.sample} \
              --prefix {wildcards.sample} \
              --threads {threads} \
              $EXTRA \
              {input.fasta} > {log} 2>&1
        """