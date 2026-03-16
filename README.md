# Design Doc 


# Overview

Streptococcus agalactiae is a common commensal bacteria found in the gastrointestinal tract, upper respiratory tract, and vagina of healthy human adults. While it is usually harmless, it is responsible for causing severe neonatal invasive infections such as Septicemia (blood poisoning) and Meningitis (inflammation of the tissues around the brain and spinal chord) when exposed to S.agalactiae from their mother during childbirth (Tazi et al 2012). S.agalactiae can also cause serious infections in adults that are immunocompromised or are diagnosed with chronic conditions such as diabetes or liver disease.

Furthermore, S.agalactiae is a bacterial species that exhibits phenotypic variation even among isolates identified as the same species. Recent observations from a clinical collaborator revealed significant phenotypic differences among isolates that were all identified as S.agalactiae using MALDI-TOF mass spectrometry (which identifies bacterial species based on characteristic protein spectra, Singhal et al 2015).These observations raised questions about the genomic differences between isolates and whether it may contribute to the variation in phenotype. To investigate this further we must use comparative analysis on publicly available S.agalactiae genome assemblies from the National Center for Biotechnology Information (NCBI). 
 
However, the scale of available genomic data presents a significant problem, as more than 25,000 genome assemblies are available. Genome assemblies can vary greatly in quality, and poor quality assemblies may contain contaminated (contains foreign DNA)  or incomplete sequences that can impact results. While some assemblies in NCBI already include quality metrics, a majority do not. To address this we will use the tool CheckM2, a computational tool designed to estimate genome completeness and contamination. This project will focus on creating a pipeline that takes the accession numbers of our genomic assemblies, retrieves them from NCBI, and runs them through CheckM2, reporting a list of the accession numbers with their contamination and completeness scores. By evaluating these metrics across all available assemblies, we aim to distinguish the high quality assemblies from the low quality assemblies to ensure we have reliable, clean data to conduct further  analyses on. 

Sources:

https://www.sciencedirect.com/science/article/pii/S1369527411002116

https://pmc.ncbi.nlm.nih.gov/articles/PMC4525378/

## Context
Using publicly available Streptococcus agalactiae genomic assemblies on NCBI we will filter over 25,000 genomes by inputting a list of all their accession numbers into our pipeline, retrieve all the assemblies from NCBI, run then through CheckM2 with a specific threshold for both completeness and contamination, and output a file containing the accession numbers and their corresponding quality scores. 

# Goals
The goals of this project are:
* Develop a pipeline that retrieves genome assemblies from NCBI using accession numbers

* Evaluate genome quality using CheckM2

* Allow users to define custom completeness and contamination thresholds

* Output a filtered list of high-quality genome assemblies

* Provide documentation so the pipeline can be easily reproduced

# Non-Goals
The following tasks are outside the scope of this project:

* Performing comparative genomic analysis of the filtered genomes.

* Developing new genome assembly algorithms.

* Modifying the internal functionality of CheckM2.

* Our pipeline focuses only on data retrieval and its quality evaluation/filtering.


## Proposed Solution
1. Get accession numbers for Streptococcus agalactiae genomes from NCBI
We will first collect accession numbers for the S. agalactiae genome assemblies from the NCBI database, and these accession numbers will be the main input for our pipeline.
The accession numbers can be saved in a simple text file so the program can read them easily.
 
2. Test the pipeline on a small subset of genomes first
Since there are more than 25,000 genome assemblies available, we will start by using a smaller subset of accession numbers.
This will help us make sure the genomes download correctly, CheckM2 runs properly, and we understand the output format.
Testing on a smaller group will also make it easier to debug the code before running the full dataset.
 
3. Download the genome assemblies in FASTA format
Using the accession numbers, the pipeline will download the corresponding genome assemblies from NCBI.
The genomes will be downloaded in FASTA format and that also works with CheckM2. Automating this step is important because manually downloading thousands of genomes would take too much time.
 
4. Prepare the genome files for analysis
After the genomes are downloaded, we will make sure the files are organized so CheckM2 can read them properly.
We will also check if any genomes failed to download or if files are missing sequence data.
 
5. Run CheckM2 on the genome assemblies
Once the FASTA files are ready, we will run CheckM2 to estimate genome completeness and contamination.
CheckM2 will analyze each genome and produce a report with these quality scores.
This is the main step of the project because it tells us which genomes are high quality and which ones are not.
 
6. Read and organize the CheckM2 results
After CheckM2 finishes running, the pipeline will read the output report.
We will extract the accession number, completeness score, and contamination score for each genome. And these values will then be written into a simple output table so they are easy to review.
 
7. Filter genomes using quality thresholds
The user will be able to set a minimum completeness value and a maximum contamination value.
The pipeline will compare each genome’s scores to these thresholds, and genomes that meet the requirements will be kept, while genomes that fail will be filtered out.
 
8. Create the final output file
The final output file will list each accession number along with its completeness and contamination scores.
It will also show which genomes passed the filtering criteria.
 
9. Provide simple documentation on GitHub
We will include clear instructions in the GitHub repository explaining how to run the pipeline.
The documentation will describe what inputs are needed and how users can change the filtering thresholds.
The goal is to keep the instructions simple so others can easily use the project.


### Workflow

The pipeline workflow will follow these steps:

1. Input accession numbers
   The user provides a list of genome accession numbers.

2. Retrieve genome assemblies from NCBI
   The pipeline retrieves genome FASTA files using Biopython (Entrez).

3. Store genome assemblies locally
   Files are saved in the project data directory.

4. Run CheckM2 analysis
   CheckM2 evaluates genome completeness and contamination.

5. Parse CheckM2 output
   The pipeline extracts quality scores from the output report.

6. Apply quality thresholds
   Genomes are filtered based on completeness and contamination values.

7. Generate results
   The pipeline outputs a summary file containing accession numbers and quality metrics.


## Milestones
