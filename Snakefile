# pandas used to read and filter the CheckM2 output table (TSV file)
import pandas as pd

# USER-DEFINED SETTINGS

# Organism (taxon) to download genomes for when using the download step
# You can change this to any organism supported by NCBI
# Example: "Escherichia coli", "Staphylococcus aureus"
TAXON = "Streptococcus agalactiae"


# Number of CPU threads to use when running CheckM2
# Increase this if you have more cores available (faster runtime)
# Decrease if running on a smaller machine/server
THREADS = 18

# FILTERING THRESHOLDS

# Minimum genome completeness (%) required to pass filtering
# Higher value = stricter (fewer genomes pass, higher quality)
# Lower value = more lenient (more genomes pass, but may include lower-quality assemblies)
MIN_COMPLETENESS = 95.0


# Maximum contamination allowed
#0.12 = 12% contamination
# Lower value = stricter filtering
# If too few genomes pass, consider increasing this slightly
MAX_CONTAMINATION = 0.12

# Adjust MIN_COMPLETENESS if:
# - You need very high-quality genomes --> increase 
# - Too many genomes are being filtered out --> decrease

# Adjust MAX_CONTAMINATION if:
# - You want cleaner genomes --> decrease
# - Too few genomes pass filtering --> increase

# NOTE:
#Completeness is usually high across datasets,
#but contamination often varies widely (sometimes bimodal),
#so MAX_CONTAMINATION is often the more sensitive parameter.

#snakemake will run everything needed to produce these files
rule all:
    input:
        "results/all_results.tsv",
        "results/passed_results.tsv",
        "results/contamination_hist_percent.png", #added two more outputs, histogram and scatterplot to visualize raw data
        "results/completeness_scatterplot.png"
#RUN steps 1-3 if: 
#    you need to download genomes (WARNING: large datasets might not run to completion)
#    unzip files + flatten to prepare for step 4 (CheckM2)
#
## Step 1: Download genomes (USE THE SUBSAMPLE CODE FOR QUICKER TEST RUN)
##rule download_genomes:
##    output:
##        "data/genomes.zip"
##    shell:
##        """
##        mkdir -p data
##        datasets download genome taxon "{TAXON}" --include genome --filename {output}
##        """
#*************************************************************************************************************
# UNCOMMENT this block below and STEP 2 STEP 3 to download and run snakemake on a subsample 
#rule download_genomes:
#    output:
#        "data/genomes.zip"
#    shell:
#        """
#        mkdir -p data
#
#        datasets summary genome taxon "{TAXON}" --limit 20 --as-json-lines \
#        | dataformat tsv genome --fields accession --elide-header \
#        > data/accessions.txt
#
#        datasets download genome accession --inputfile data/accessions.txt --include genome --filename {output}
#        """
#*************************************************************************************************************
##-----------------------------
#
## Step 2: Unzip genomes
#rule unzip_genomes:
#    input:
#        "data/genomes.zip"
#    output:
#        directory("data/genomes")
#    shell:
#        """
#        rm -rf data/genomes
#        mkdir -p data/genomes
#        unzip -q {input} -d data/genomes
#        """
#
## Step 3: Put FASTA files into one directory
#rule flatten_fasta:
#    input:
#        "data/genomes"
#    output:
#        directory("data/genomes_flat")
#    shell:
#        """
#        rm -rf data/genomes_flat
#        mkdir -p data/genomes_flat
#        find {input} -name "*.fna" -exec cp {{}} data/genomes_flat/ \\;
#        #TO ONLY RUN ON 20 SUBSAMPLE, USE THE CODE BELOW
#        #find {input} -name "*.fna" | head -n 20 | xargs -I {{}} cp {{}} data/genomes_flat/
#        """
# -----------------------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------------
# Step 4: Run CheckM2 to evaluate genome quality
rule run_checkm2:
    input:
        "data/genomes_flat"  # directory of genome FASTA files (.fna)
    output:
        "results/checkm2_output/quality_report.tsv"
    shell:
        """
        #remove old results to avoid conflicts
        rm -rf results/checkm2_output

        #create output directory
        mkdir -p results/checkm2_output

        #run CheckM2 on all genomes in the input directory
        checkm2 predict \
            --input {input} \
            --output-directory results/checkm2_output \
            --threads {THREADS} \
            --force
        """


# Step 5: Save full CheckM2 output
rule save_all_results:
    input:
        "results/checkm2_output/quality_report.tsv"
    output:
        "results/all_results.tsv"
    shell:
        """
        #simply copy the full CheckM2 output for easier access
        cp {input} {output}
        """


# Step 6: Filter genomes based on quality thresholds
rule save_passed_results:
    input:
        "results/checkm2_output/quality_report.tsv"
    output:
        "results/passed_results.tsv"
    run:
        #read CheckM2 output table (tab-separated)
        df = pd.read_csv(input[0], sep="\t")

        #apply filtering conditions:
        # - keep genomes with high completeness
        # - keep genomes with low contamination
        passed = df[
            (df["Completeness"] >= MIN_COMPLETENESS) &
            (df["Contamination"] <= MAX_CONTAMINATION)
        ]

        # save only the genomes that passed filtering
        passed.to_csv(output[0], sep="\t", index=False)
#---------------------------- STEP 7 (visualize data as scatterplot of completeness and histogram of contamination) ------------
# Step 7:
rule make_plots:
    input:
        "results/all_results.tsv"  # uses the full (unfiltered) dataset
    output:
        contamination_hist="results/contamination_hist_percent.png",
        completeness_scatter="results/completeness_scatterplot.png"
    run:
        import pandas as pd
        import matplotlib
        matplotlib.use("Agg")  #allows plots to be saved without opening a GUI (important for servers)
        import matplotlib.pyplot as plt
        import numpy as np

        # load CheckM2 results table
        df = pd.read_csv(input[0], sep="\t")

        #make sure columns are numeric (in case of formatting issues)
        df["Completeness"] = pd.to_numeric(df["Completeness"], errors="coerce")
        df["Contamination"] = pd.to_numeric(df["Contamination"], errors="coerce")

        #remove rows with missing values in key columns
        df = df.dropna(subset=["Completeness", "Contamination"])

        # convert contamination from fraction to percent (e.g., 0.12 → 12%)
        df["Contamination_percent"] = df["Contamination"] * 100

        # Contamination Histogram

        # create bins from 0–100% in 1% increments
        bins = np.arange(0, 101, 1)

        plt.figure()
        plt.hist(df["Contamination_percent"], bins=bins)

        plt.title("Contamination Distribution (%)")
        plt.xlabel("Contamination (%)")
        plt.ylabel("Number of Genomes")

        plt.xlim(0, 100)  #make sure full percent range is shown

        #save figure to Snakemake output path
        plt.savefig(output.contamination_hist, dpi=300, bbox_inches="tight")
        plt.close()


        # Completeness Scatterplot

        plt.figure()

        # x-axis = genome index, y-axis = completeness
        # s controls dot size (increase if small dataset, decrease if large dataset)
        plt.scatter(range(len(df)), df["Completeness"], alpha=0.5, s=8)

        plt.title("Completeness Scatterplot")
        plt.xlabel("Genome Index")
        plt.ylabel("Completeness (%)")

        plt.ylim(0, 100)  # completeness is bounded between 0–100%

        # save figure
        plt.savefig(output.completeness_scatter, dpi=300, bbox_inches="tight")
        plt.close()
#how to run:
# snakemake --cores 4

#below need to already be installed
#snakemake
#datasets
#checkm2
#pandas

#snakemake --cores 6

