# Installation


# Dependencies
The following packages must be downloaded in order to run the pipeline.

Python: https://www.python.org/downloads/

Snakemake: https://snakemake.readthedocs.io/en/stable/getting_started/installation.html

Miniconda: https://docs.conda.io/projects/conda/en/stable/user-guide/install/index.html

Pandas: https://pypi.org/project/pandas/

matplotlib

# How to install CheckM2

1. In order to download Checkm2, you need to have Anaconda downloaded to your system. Enter the following code into your bash terminal in VS code

```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

2. Now, install it by running the next line in your terminal

```
bash Miniconda3-latest-Linux-x86_64.sh
```

Press enter to scroll down, then type 'yes' to accept the license

3. Verify it works by running

```
conda --version
```

4. Now, we must create our conda environment to start running checkM2.

```
conda create -n checkm2_env python=3.8 -y
```

5. Activate the environment (environment must be activated when running CheckM2)

```
conda activate checkm2_env
```

6. install packages from the highest priority channel to avoid dependency conflicts

```
conda config --env --set channel_priority strict
```

7. Install checkM2

```
conda install -c conda-forge -c bioconda checkm2=1.0.1 -y
```

8. Download the Diamond database

```
checkm2 database --download
```

9. Checkm2 is now ready to be used! Confirm installation with

```
checkm2 testrun
```
if it installed, it should run.

# How to download Genomes

To download all of our genomes, uncomment rules 1-3 in the Snakefile (the first download_genomes rule, unzip_genomes, & flatten_fasta)

then run the following code in the terminal. This will download all available genomes for the selected taxon, unzip the files, then collect all of the fasta files into data/genomes_flat/

```
snakemake data/genomes_flat --cores 4
```

To download a small subsample (20 genomes) for faster testing, uncomment the second download_genomes rule included in the file then run the above code. This will create a smaller genome dataset that is useful for testing the pipeline.



