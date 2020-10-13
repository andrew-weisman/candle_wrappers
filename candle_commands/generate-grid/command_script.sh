#!/bin/bash

# If a hyperparameter grid is requested to be generated, do so
# ASSUMPTIONS: candle module has been loaded

# Save all the arguments to this script to an array called args_arr
args_arr=($@)

echo -n "Generating hyperparameter grid into file \"hyperparameter_grid.txt\"... "

# Load site-specific settings so we know which Python to load below
# shellcheck source=/dev/null
source "$CANDLE/wrapppers/site-specific_settings.sh"

# Load a numpy-containing Python
# shellcheck source=/dev/null
source "$CANDLE/wrappers/utilities.sh"; load_python_env

# Ensure the generated_files directory has been created
# shellcheck source=/dev/null
source "$CANDLE/wrappers/utilities.sh"; make_generated_files_dir

# Run the script that generates the hyperparameter grid
python "$CANDLE/wrappers/candle_commands/generate-grid/generate_hyperparameter_grid.py" "${args_arr[@]}" && echo "done" || echo "failed"
