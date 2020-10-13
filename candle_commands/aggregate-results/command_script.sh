#!/bin/bash

# If CANDLE job results are requested to be aggregated, do so
# Run like "bash $CANDLE/wrappers/candle_commands/aggregate-results/command_script.sh <EXPT-DIR>", e.g.,
# "bash $CANDLE/wrappers/candle_commands/aggregate-results/command_script.sh /home/weismanal/notebook/2019-07-06/jurgen_benchmarking-upf/experiments/X002"
# ASSUMPTIONS: candle module has been loaded

# Function to get all the data from the CANDLE runs
function get_data(){
    # For each set of HPs...
    #for run_dir in $(ls $expt_dir/run); do
    for run_dir in "$expt_dir/run"/*; do

        # Get the result
        #result=$(cat $expt_dir/run/$run_dir/result.txt | awk -v result_format=$result_format '{printf(result_format,$0)}')
        result=$(awk -v result_format="$result_format" '{printf(result_format,$0)}' "$expt_dir/run/$run_dir/result.txt")

        # Get the CSV-formatted data
        hp_values=$(awk -v doprint=0 '{if($0~/^PARAMS:$/){doprint=1}; if(doprint==1 && $0~/^$/){doprint=0}; if(doprint){print}}' "$expt_dir/run/$run_dir/model.log" | tail -n +2 | awk '{printf("%s,",$2)}')
        hp_values="$result,$run_dir,${hp_values:0:${#hp_values}-1}"
        echo "$hp_values"

    done
}

# Experiment directory of the CANDLE job
expt_dir=$1
result_format=${2:-"%07.3f"} # optional variable for the format of the result (as in the input to a printf() function)

echo -n "Aggregating results from experiment directory \"$expt_dir\" using result format \"$result_format\" into file \"candle_results.csv\"... "

# Get the CSV-formatted header
run_dir=$(ls "$expt_dir/run" | head -n 1) # get the first run directory just so we can extract the hyperparameter names from one of the output files
hp_names=$(awk -v doprint=0 '{if($0~/^PARAMS:$/){doprint=1}; if(doprint==1 && $0~/^$/){doprint=0}; if(doprint){print}}' "$expt_dir/run/$run_dir/model.log" | tail -n +2 | awk '{printf("%s,",$1)}')
header="result,dirname,${hp_names:0:${#hp_names}-1}"

# Get the data from all the CANDLE runs
data=$(get_data "$expt_dir" "$result_format")

# Ensure the generated_files directory has been created
# shellcheck source=/dev/null
source "$CANDLE/wrappers/utilities.sh"; make_generated_files_dir

# Output the data sorted by the result
(
    echo "$header"
    echo "$data" | sort
) > "./generated_files/candle_results.csv" && echo "done" || echo "failed"
