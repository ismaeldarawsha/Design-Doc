#here is some code i wrote that will take in threshold values for both contamination and completeness, and will return the results that ONLY meet those values.
#can edit this to fit in a snakefile when we put together our pipeline. it can be changed 
#to run this code with the sample data file, run this line in the terminal "python threshold_trialcode.py \ --input sample_data/ \ --output checkm2_out_test \ --threads 4 \ --min_completion 95 \ --max_contamination 0.12"

#dependencies
import subprocess
import pandas as pd
import argparse
import os

#defining our function that runs checkm2
#takes 3 inputs, the input_dir (where genome files are), output_dir (where results will be), theads (how many cpu threads there are. I usually just do 4 as google said that was the best value)
def run_checkm2(input_dir, output_dir, threads):
    #building the command that is given in the terminal
    cmd = [
        "checkm2", "predict",
        "--input", input_dir,
        "--output-directory", output_dir,
        "--threads", str(threads),
        "--force"
    ]
    #executes command in the shell
    subprocess.run(cmd, check=True)


#defining function that FILTERS out our checkm2 results.
#3 inputs, the output directory, the minimum completion score, and maximum allowed contamination score
def filter_results(output_dir, min_completion, max_contamination):
    #checkm2outputfile
    results_file = os.path.join(output_dir, "quality_report.tsv")
    
    #loading csv file into a pandas df
    df = pd.read_csv(results_file, sep="\t")

    #filtering the csv file based on the threshold values
    #keep only the rows where completeness is greater than or equal to threshold, and has contamination that is less than or equal to the threshold
    filtered_df = df[
        (df["Completeness"] >= min_completion) &
        (df["Contamination"] <= max_contamination)
    ]

    return filtered_df

#defining function to save our results
#writes the pandas ddf to a csv file
def save_filtered_results(filtered_df, output_dir):
    out_file = os.path.join(output_dir, "filtered_results.tsv")
    filtered_df.to_csv(out_file, sep="\t", index=False)

    #prints where filtered results are saved to
    print(f"Filtered results: {out_file}")


#our main function.
#creates our command line arg parse. basically creates our input command from the terminal
def main():
    parser = argparse.ArgumentParser(description="CheckM2 pipeline with filtering")

    parser.add_argument("--input", required=True, help="Input genome directory")
    parser.add_argument("--output", required=True, help="Output directory")
    parser.add_argument("--threads", type=int, default=4)
    parser.add_argument("--min_completion", type=float, default=90.0)
    parser.add_argument("--max_contamination", type=float, default=5.0)

    args = parser.parse_args()

    #running checkm2 now with the user inputs
    run_checkm2(args.input, args.output, args.threads)

    #filtering out our results based on our completion and contamination thresholds
    filtered_df = filter_results(
        args.output,
        args.min_completion,
        args.max_contamination
    )

    #saving filtered results
    save_filtered_results(filtered_df, args.output)

#script entry point
if __name__ == "__main__":
    main()