#!/bin/bash

# If there are problems later, it may be that we reference run_workflows.sh below from itself since we call this script from it
# ASSUMPTIONS:
#   (1) candle module has been loaded
#   (2) the candle program has been called normally (so that the $CANDLE_SUBMISSION_DIR variable has been defined)

# Write a function to output the key-value pairs
output_json_format() {
    params=("$@")
    for var in "${params[@]}"; do
        echo -n "\"$var\": \"${!var}\", "
    done
}

# Get the variables we'd like to save
vars="$(grep "^setenv(" $CANDLE/wrappers/lmod_modules/biowulf/dev.lua | awk -v FS="setenv\\\(\"" '{split($2,arr,"\""); print arr[1]}')"
#vars+=" $(grep "^export " $CANDLE/wrappers/templates/scripts/submit_candle_job.sh | awk -v FS="export " '{split($2,arr,"="); print arr[1]}')"

for submit_script in submit_candle_job*.sh; do
    vars+=" $(grep "^export " $submit_script | awk -v FS="export " '{split($2,arr,"="); print arr[1]}')"
done

vars+=" $(grep "^[ ]*export " $CANDLE/wrappers/commands/submit-job/run_workflows.sh | awk -v FS="export " '{split($2,arr,"="); print arr[1]}')"
vars+=" SUPP_MODULES PYTHON_BIN_PATH EXEC_PYTHON_MODULE SUPP_PYTHONPATH EXTRA_SCRIPT_ARGS EXEC_R_MODULE RESTART_FROM_EXP RUN_WORKFLOW" # from $CANDLE/wrappers/templates/scripts/model_wrapper.sh, plus one more from run_workflows.sh

# Write the dictionary in JSON format
tmp=$(output_json_format $(echo $vars | awk -v RS=" " '{print}' | sort -u | grep -v "^$"))
echo "{${tmp:0:${#tmp}-2}}" > "$CANDLE_SUBMISSION_DIR/candle_generated_files/metadata.json"
