#!/bin/bash

# Assumptions:
#   (1) candle module is loaded
#   (2) This script is called the usual way, via "candle submit-job ..."

# This script is a wrapper that prepares multiple things prior to running the workflows (the workflow.sh files in Supervisor/workflows)... this should be called from $CANDLE/wrappers/candle_commands/submit-job/command_script.sh
# This script basically replaces the contents of the, e.g., upf-1.sh examples in the Supervisor/workflows directory that call the workflow.sh files

# Set the site-specific settings (needed for preprocess.py below)
# shellcheck source=/dev/null
source "$CANDLE/wrappers/site-specific_settings.sh"

# For running the workflows themselves (and for doing the preprocessing), load the Python module with which Swift/T was built; load a competent version of Python
# shellcheck source=/dev/null
source "$CANDLE/wrappers/utilities.sh"; load_python_env --set-pythonhome

# Check the input settings, determine the sbatch settings, and export variables set in Python
if python "$CANDLE/wrappers/candle_commands/submit-job/preprocess.py"; then
    echo "NOTE: preprocess.py was run successfully; now sourcing the variables it set in $CANDLE_SUBMISSION_DIR/candle_generated_files/preprocessed_vars_to_export.sh"
    source "$CANDLE_SUBMISSION_DIR/candle_generated_files/preprocessed_vars_to_export.sh"
else
    echo "ERROR: There was an error in preprocess.py"
    exit
fi

# Note that later we can put these as keywords model_description and prog_name in the input file if we want; for now, we're treating them as if they really don't matter, which they likely don't actually
export CANDLE_MODEL_DESCRIPTION=${CANDLE_MODEL_DESCRIPTION:-"Dummy model description"}
export CANDLE_PROG_NAME=${CANDLE_PROG_NAME:-"Dummy program name"}

# Set $MODEL_PYTHON_DIR and $MODEL_PYTHON_SCRIPT as appropriate. Bottom line is this needs to be set to a canonically CANDLE-compliant Python file
if [ "x$(echo "$CANDLE_KEYWORD_MODEL_SCRIPT" | rev | awk -v FS="." '{print $1}' | rev)" == "xpy" ]; then # if the model script is a Python file...
    echo "NOTE: Model script '$CANDLE_KEYWORD_MODEL_SCRIPT' is a Python file"
    if python "$CANDLE/wrappers/utilities.py" "are_functions_in_module(['initialize_parameters', 'run'], '$CANDLE_KEYWORD_MODEL_SCRIPT')"; then
        # echo "NOTE: $CANDLE_KEYWORD_MODEL_SCRIPT is likely CANDLE-compliant"
        tmp=$(dirname "$CANDLE_KEYWORD_MODEL_SCRIPT")
        export MODEL_PYTHON_DIR="$tmp"
        tmp=$(basename "$CANDLE_KEYWORD_MODEL_SCRIPT" | awk -v FS=".py" '{print $1}')
        export MODEL_PYTHON_SCRIPT="$tmp"
    else
        # echo "NOTE: $CANDLE_KEYWORD_MODEL_SCRIPT is likely NOT CANDLE-compliant"
        export MODEL_PYTHON_DIR=${MODEL_PYTHON_DIR:-"$CANDLE/wrappers/candle_commands/submit-job"}
        export MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-"candle_compliant_wrapper"}
    fi
else
    echo "NOTE: Model script '$CANDLE_KEYWORD_MODEL_SCRIPT' is not a Python file"
    export MODEL_PYTHON_DIR=${MODEL_PYTHON_DIR:-"$CANDLE/wrappers/candle_commands/submit-job"}
    export MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-"candle_compliant_wrapper"}
fi

# Export some other settings that weren't preprocessed in preprocess.py (i.e., these aren't based on the keywords in the input file)
export EXPERIMENTS=${EXPERIMENTS:-"$CANDLE_SUBMISSION_DIR/candle_generated_files/experiments"}
export OBJ_RETURN=${OBJ_RETURN:-"val_loss"}
export MODEL_NAME=${MODEL_NAME:-"candle_job"}
export TURBINE_OUTPUT_SOFTLINK=${TURBINE_OUTPUT_SOFTLINK:-"last-candle-job"} # this is more descriptive than the default turbine-output symbolic link

# Create the experiments directory if it doesn't already exist
if [ ! -d "$EXPERIMENTS" ]; then
    mkdir -p "$EXPERIMENTS" && echo "Experiments directory created: $EXPERIMENTS"
fi

# If a restart is requested for a UPF job, then overwrite the CANDLE_WORKFLOW_SETTINGS_FILE accordingly
if [ -n "$CANDLE_KEYWORD_RESTART_FROM_EXP" ]; then # corresponds to restart_from_exp keyword in input file... note I have not currently validated this keyword in preprocess.py as I am not validating the restart functionality as a whole for the time being
    candle_workflow="upf"
    # Ensure the metadata JSON file from the experiment from which we're restarting exists
    metadata_file=$EXPERIMENTS/$CANDLE_KEYWORD_RESTART_FROM_EXP/metadata.json
    if [ ! -f "$metadata_file" ]; then
        echo "Error: metadata.json does not exist in the requested restart experiment $EXPERIMENTS/$CANDLE_KEYWORD_RESTART_FROM_EXP"
        exit
    fi
    # Create the new restart UPF
    upf_new="$CANDLE_SUBMISSION_DIR/candle_generated_files/upf_workflow-restart.txt"
    python "$CANDLE/wrappers/candle_commands/submit-job/restart.py" "$metadata_file" > "$upf_new"
    # If the new UPF is empty, then there's nothing to do, so quit
    if [ -s "$upf_new" ]; then # if it's NOT empty...
        export CANDLE_WORKFLOW_SETTINGS_FILE="$upf_new"
    else
        echo "Error: Job is complete; nothing to do"
        rm -f "$upf_new"
        exit
    fi
fi

# Do some workflow-dependent things
# ADD HERE WHEN ADDING NEW WORKFLOWS!!
if [ "x$CANDLE_KEYWORD_WORKFLOW" == "xgrid" ]; then # if doing the UPF workflow...
    export R_FILE=${R_FILE:-"NA"}
    candle_workflow="upf"
elif [ "x$CANDLE_KEYWORD_WORKFLOW" == "xbayesian" ]; then # if doing the mlrMBO workflow...
    export R_FILE=${R_FILE:-"mlrMBO-mbo.R"}
    candle_workflow="mlrMBO"
fi

# Save the job's parameters into a JSON file
# This is probably for the restart functionality above
bash "$CANDLE/wrappers/candle_commands/submit-job/make_json_from_submit_params.sh"

# If we want to run the wrapper using CANDLE...
# ADD HERE WHEN ADDING NEW WORKFLOWS!!
if [ "${CANDLE_USE_CANDLE:-1}" -eq 1 ]; then
    if [ "x$candle_workflow" == "xupf" ]; then
        "$CANDLE/Supervisor/workflows/$candle_workflow/swift/workflow.sh" "$SITE" -a "$CANDLE/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh" "$CANDLE_WORKFLOW_SETTINGS_FILE"
    elif [ "x$candle_workflow" == "xmlrMBO" ]; then

        # From $CANDLE/Supervisor/workflows/mlrMBO/test/cfg-sys-nightly.sh:
        export SH_TIMEOUT=${SH_TIMEOUT:-}
        export IGNORE_ERRORS=0

        #"$CANDLE/Supervisor/workflows/$WORKFLOW_TYPE/swift/workflow.sh" "$SITE" -a "$CANDLE/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh" "$WORKFLOW_SETTINGS_FILE" "$MODEL_NAME"
        "$CANDLE/Supervisor/workflows/$candle_workflow/swift/workflow.sh" "$SITE" -a "$CANDLE/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh" "$CANDLE/wrappers/candle_commands/submit-job/dummy_cfg-prm.sh" "$MODEL_NAME"
    fi
# ...otherwise, run the wrapper alone, outside of CANDLE, nominally on an interactive node
else
    $CANDLE_SETUP_JOB_LAUNCHER $CANDLE_SETUP_SINGLE_TASK_LAUNCHER_OPTIONS python "$MODEL_PYTHON_DIR/$MODEL_PYTHON_SCRIPT.py"
fi
