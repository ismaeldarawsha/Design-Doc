#pandas for reading and filtering the CheckM2 output table
import pandas as pd

#organism we are downloading genomes for
TAXON = "Streptococcus agalactiae"
THREADS = 4
#filtering thresholds for genome quality
MIN_COMPLETENESS = 95.0
MAX_CONTAMINATION = 0.12

#snakemake will run everything needed to produce these files
rule all:
    input:
        "results/all_results.tsv",
        "results/passed_results.tsv"

# Step 1: Download genomes
rule download_genomes:
    output:
        "data/genomes.zip"
    shell:
        """
        mkdir -p data
        datasets download genome taxon "{TAXON}" --include genome --filename {output}
        """

# Step 2: Unzip genomes
rule unzip_genomes:
    input:
        "data/genomes.zip"
    output:
        directory("data/genomes")
    shell:
        """
        rm -rf data/genomes
        mkdir -p data/genomes
        unzip -q {input} -d data/genomes
        """

# Step 3: Put FASTA files into one directory
rule flatten_fasta:
    input:
        "data/genomes"
    output:
        directory("data/genomes_flat")
    shell:
        """
        rm -rf data/genomes_flat
        mkdir -p data/genomes_flat
        find {input} -name "*.fna" -exec cp {{}} data/genomes_flat/ \\;
        """

# Step 4: Run CheckM2
rule run_checkm2:
    input:
        "data/genomes_flat"
    output:
        directory("results/checkm2_output")
    shell:
        """
        rm -rf results/checkm2_output
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

#how to run:
# snakemake --cores 4

#below need to already be installed
#snakemake
#datasets
#checkm2
#pandas
