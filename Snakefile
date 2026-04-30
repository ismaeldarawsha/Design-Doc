#pandas for reading and filtering the CheckM2 output table
import pandas as pd

#organism we are downloading genomes for
TAXON = "Streptococcus agalactiae"
THREADS = 18
#filtering thresholds for genome quality
MIN_COMPLETENESS = 95.0
MAX_CONTAMINATION = 0.12

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
# Step 4: Run CheckM2
rule run_checkm2:
    input:
            "/home/ayounis/checkm2/genomes_combine"
         #"data/genomes_flat"
    output:
        "results/checkm2_output/quality_report.tsv"
    shell:
        """
        rm -rf results/checkm2_output
        mkdir -p results/checkm2_output
        checkm2 predict \
            --input {input} \
            --output-directory results/checkm2_output \
            --threads {THREADS} \
            --force
        """

# Step 5: Save all results
rule save_all_results:
    input:
        "results/checkm2_output/quality_report.tsv"
    output:
        "results/all_results.tsv"
    shell:
        """
        cp {input} {output}
        """

# Step 6: Filter results that pass thresholds
rule save_passed_results:
    input:
        "results/checkm2_output/quality_report.tsv"
    output:
        "results/passed_results.tsv"
    run:
        df = pd.read_csv(input[0], sep="\t")

        passed = df[
            (df["Completeness"] >= MIN_COMPLETENESS) &
            (df["Contamination"] <= MAX_CONTAMINATION)
        ]

        passed.to_csv(output[0], sep="\t", index=False)
#---------------------------- STEP 7 (visualize data as scatterplot of completeness and histogram of contamination) ------------
# Step 7:
rule make_plots:
    input:
        "results/all_results.tsv"
    output:
        contamination_hist="results/contamination_hist_percent.png",
        completeness_scatter="results/completeness_scatterplot.png"
    run:
        import pandas as pd
        import matplotlib
        matplotlib.use("Agg")  # lets matplotlib save plots without opening a window
        import matplotlib.pyplot as plt
        import numpy as np

        df = pd.read_csv(input[0], sep="\t")

        df["Completeness"] = pd.to_numeric(df["Completeness"], errors="coerce")
        df["Contamination"] = pd.to_numeric(df["Contamination"], errors="coerce")

        df = df.dropna(subset=["Completeness", "Contamination"])

        df["Contamination_percent"] = df["Contamination"] * 100

        #contamination histogram
        bins = np.arange(0, 101, 1)

        plt.figure()
        plt.hist(df["Contamination_percent"], bins=bins)
        plt.title("Contamination Distribution (%)")
        plt.xlabel("Contamination (%)")
        plt.ylabel("Number of Genomes")
        plt.xlim(0, 100)
        plt.savefig(output.contamination_hist, dpi=300, bbox_inches="tight")
        plt.close()

        #Completeness Scatterplot
        plt.figure()
        plt.scatter(range(len(df)), df["Completeness"], alpha=0.5, s=8) #adjust s = # to size each dot in the scatterplot, depending on sample size
        plt.title("Completeness Scatterplot")
        plt.xlabel("Genome Index")
        plt.ylabel("Completeness (%)")
        plt.ylim(0, 100)
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

