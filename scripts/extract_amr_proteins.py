import os
from Bio import SeqIO

# Correct the path to look up one level from the scripts folder
BASE_DIR = ".." 
SAMPLES = ["SRR12368024", "SRR12368025", "SRR12368034", "SRR12368036", "SRR12368047"]
OUTPUT_FILE = os.path.join(BASE_DIR, "results/annotation/rpoB_FULL_LENGTH.fasta")

os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)

with open(OUTPUT_FILE, "w") as out_f:
    for sample in SAMPLES:
        faa_path = os.path.join(BASE_DIR, f"results/annotation/{sample}/{sample}.faa")
        if not os.path.exists(faa_path):
            print(f"Skipping {sample}: .faa not found")
            continue
            
        # Get all proteins and sort by length
        records = list(SeqIO.parse(faa_path, "fasta"))
        records.sort(key=lambda x: len(x.seq), reverse=True)
        
        # The top 2 are always rpoB and rpoC
        # We'll take the top 5 just to be safe and find rpoB manually in MAFFT
        for i, rec in enumerate(records[:3]):
            rec.id = f"{sample}_TopGene_{i+1}_len_{len(rec.seq)}"
            SeqIO.write(rec, out_f, "fasta")
            print(f"Found {sample} Top {i+1}: {len(rec.seq)} aa")

print(f"\nSaved to: {OUTPUT_FILE}")
