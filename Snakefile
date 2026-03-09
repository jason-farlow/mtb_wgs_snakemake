# Snakefile
configfile: "config/config.yaml"
from pathlib import Path

container: "docker://mtb_wgs_pipeline:1.0-amd64"

# Optional: avoid hardcoded workdir for portability
# workdir: "."

def infer_samples(fastq_dir, r1_token="_1", r2_token="_2", ext=".fastq.gz"):
    fastq_dir = Path(fastq_dir)
    r1_files = sorted(fastq_dir.glob(f"*{r1_token}*{ext}"))
    if not r1_files:
        raise ValueError(
            f"No R1 files found with token '{r1_token}' in {fastq_dir}. "
            f"Check config r1_token/r2_token and fastq_ext."
        )
    sample_ids = []
    samples = {}
    for r1 in r1_files:
        sid = r1.name.replace(r1_token + ext, "")
        r2 = fastq_dir / (sid + r2_token + ext)
        if not r2.exists():
            raise ValueError(f"Missing R2 for sample {sid}: expected {r2}")
        sample_ids.append(sid)
        samples[sid] = {"r1": str(r1), "r2": str(r2)}
    return sample_ids, samples

# ---- Global paths / settings (define BEFORE includes) ----
OUTDIR = Path(config.get("outdir", "results"))

# SNP output root (make it explicit and stable)
# If your snp rules are still hardcoded to results/snp, set this to "results/snp" for now.
SNP_OUT = Path(config.get("snp", {}).get("outdir", "results/snp"))

# Reference (expected by SNP rules)
REF = Path(config["snp"]["reference_fasta"]).as_posix()

# Infer samples ONCE using config tokens/ext
SAMPLE_IDS, SAMPLES = infer_samples(
    config["fastq_dir"],
    config.get("r1_token", "_1"),
    config.get("r2_token", "_2"),
    config.get("fastq_ext", ".fastq.gz")
)


# ---- Includes (after globals exist) ----
include: "workflow/rules/trim.smk"
include: "workflow/rules/assemble.smk"
include: "workflow/rules/qc.smk"
include: "workflow/rules/snp_phylo.smk"
include: "workflow/rules/snp_qc.smk"
include: "workflow/rules/genotype.smk"
include: "workflow/rules/amr_bakta.smk"
include: "workflow/rules/miru_reader.smk"
include: "workflow/rules/report.smk"

rule all:
    input:
        # 1) Trimming
        expand(str(OUTDIR / "trim" / "{sample}_1.trim.fastq.gz"), sample=SAMPLE_IDS),
        expand(str(OUTDIR / "trim" / "{sample}_2.trim.fastq.gz"), sample=SAMPLE_IDS),

        # 2) Assembly
        expand(str(OUTDIR / "assembly" / "{sample}" / "contigs.fasta"), sample=SAMPLE_IDS),

        # 3) MultiQC
        str(OUTDIR / "multiqc" / "multiqc_report.html"),

        # 4) Fixed VCFs + SNP Tree (from SNP_OUT)
        expand(str(SNP_OUT / "vcf" / "{sample}.vcf.gz"), sample=SAMPLE_IDS),
        str(SNP_OUT / "core.snps.aln.fasta.treefile"),

        # 5) SNP QC marker (optional)
        *(
            [str(SNP_OUT / "qc" / "snp_mapping_qc.complete")]
            if config.get("modules", {}).get("snp_qc", False) else []
        ),

        # 6) MLST (optional)
        *(
            expand(str(OUTDIR / "mlst" / "{sample}.tsv"), sample=SAMPLE_IDS)
            if config.get("modules", {}).get("mlst", False) else []
        ),

        # 7) AMRFinderPlus (optional)
        *(
            expand(str(OUTDIR / "amr" / "{sample}_amr.tsv"), sample=SAMPLE_IDS)
            if config.get("modules", {}).get("amr", False) else []
        ),

        # 8) Bakta annotation (optional)
        *(
            expand(str(OUTDIR / "annotation" / "{sample}" / "{sample}.gff3"), sample=SAMPLE_IDS)
            if config.get("modules", {}).get("annotation", False) else []
        ),
        # 8.5) MIRUReader (optional)
        *(
            expand(str(OUTDIR / "miru" / "{sample}.txt"), sample=SAMPLE_IDS)
            if config.get("modules", {}).get("miru", False) else []
        ),
        # 9) Final report directory
        str(OUTDIR / "report" / "multiqc_report.html"),
        str(OUTDIR / "report" / "mtb_phylogeny.treefile"),
        str(OUTDIR / "report" / "core_snps_alignment.fasta"),



        