import pandas as pd
import glob
import os

# Find all 5 TSV results
path = 'results/amr/'
all_files = glob.glob(os.path.join(path, "SRR*_amr.tsv"))

if not all_files:
    print("No AMR TSV files found in results/amr/! Check your Snakemake output.")
else:
    li = []
    for filename in all_files:
        # Read the TSV
        df = pd.read_csv(filename, sep='\t')
        
        # Get the SRR ID from the filename (e.g., SRR12368024)
        sample_id = os.path.basename(filename).split('_')[0]
        df.insert(0, 'Sample', sample_id)
        li.append(df)

    # Merge and save
    master_table = pd.concat(li, axis=0, ignore_index=True)
    master_table.to_csv('results/amr/BRUCELLA_AMR_MASTER_REPORT.csv', index=False)
    print(f"Successfully merged {len(all_files)} samples into results/amr/BRUCELLA_AMR_MASTER_REPORT.csv")
