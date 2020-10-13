#!/bin/bash

# This script is a wrapper that prepares multiple things prior to running the workflows... this should be called from submit_candle_job.sh

# Set the site-specific settings JUST ENOUGH TO SET $CANDLE_DEFAULT_PYTHON_MODULE as needed to run load_python_env() below
# shellcheck source=/dev/null
source "$CANDLE/wrapppers/site-specific_settings.sh"

# For running the workflows themselves (and for doing the preprocessing), load the module with which Swift/T was built
# shellcheck source=/dev/null
source "$CANDLE/wrappers/utilities.sh"; load_python_env --set-pythonhome


# Check the input settings, determine the sbatch settings, and export variables set in Python
python $CANDLE/wrappers/candle_commands/submit-job/preprocess.py
if [ $? -eq 0 ]; then
    source preprocessed_vars_to_export.sh #&& rm -f preprocessed_vars_to_export.sh
else
    exit
fi

# Simple settings
#export WORKFLOW_TYPE=${WORKFLOW_TYPE:-$(echo $WORKFLOW_SETTINGS_FILE | awk -v FS="/" '{split($NF,arr,"_workflow-"); print(arr[1])}')}
export EXPERIMENTS=${EXPERIMENTS:-"$(pwd)/experiments"}
export MODEL_PYTHON_DIR=${MODEL_PYTHON_DIR:-"$CANDLE/wrappers/templates/scripts"} # these are constants referring to the CANDLE-compliant wrapper Python script
export MODEL_PYTHON_SCRIPT=${MODEL_PYTHON_SCRIPT:-"candle_compliant_wrapper"}
export OBJ_RETURN=${OBJ_RETURN:-"val_loss"}
export MODEL_NAME=${MODEL_NAME:-"candle_job"}
#export PPN=${PPN:-"1"} # run one MPI process (GPU process) per node on Biowulf
export TURBINE_OUTPUT_SOFTLINK=${TURBINE_OUTPUT_SOFTLINK:-"last-exp"} # this is more descriptive than the default turbine-output symbolic link
export DL_BACKEND=${DL_BACKEND:-"keras"} # default to keras; only other choice is pytorch

# # Set a proportional number of processors and amount of memory to use on the node
# if [ -z "$CPUS_PER_TASK" ]; then
#     export CPUS_PER_TASK=14
#     if [ "x$(echo $GPU_TYPE | awk '{print tolower($1)}')" == "xk20x" ]; then
#         export CPUS_PER_TASK=16
#     fi
# fi
# if [ -z "$MEM_PER_NODE" ]; then
#     if [ "x$(echo $GPU_TYPE | awk '{print tolower($1)}')" == "xk20x" ] || [ "x$(echo $GPU_TYPE | awk '{print tolower($1)}')" == "xk80" ]; then
#         export MEM_PER_NODE="60G"
#     else
#         export MEM_PER_NODE="30G"
#     fi
# fi

# Create the experiments directory if it doesn't already exist
if [ ! -d $EXPERIMENTS ]; then
    mkdir -p $EXPERIMENTS && echo "Experiments directory created: $EXPERIMENTS"
fi

# If a restart is requested for a UPF job, then overwrite the WORKFLOW_SETTINGS_FILE accordingly
if [ -n "$RESTART_FROM_EXP" ]; then
    export WORKFLOW_TYPE="upf"
    # Ensure the metadata JSON file from the experiment from which we're restarting exists
    metadata_file=$EXPERIMENTS/$RESTART_FROM_EXP/metadata.json
    if [ ! -f $metadata_file ]; then
        echo "Error: metadata.json does not exist in the requested restart experiment $EXPERIMENTS/$RESTART_FROM_EXP"
        exit
    fi
    # Create the new restart UPF
    upf_new="upf_workflow-restart.txt"
    python $CANDLE/wrappers/analysis/restart.py $metadata_file > $upf_new
    # If the new UPF is empty, then there's nothing to do, so quit
    if [ -s $upf_new ]; then # if it's NOT empty...
        export WORKFLOW_SETTINGS_FILE="$(pwd)/$upf_new"
    else
        echo "Error: Job is complete; nothing to do"
        rm -f $upf_new
        exit
    fi
fi

# Do some workflow-dependent things
#if [ "x$WORKFLOW_TYPE" == "xupf" ]; then # if doing the UPF workflow...
if [ "x$WORKFLOW_TYPE" == "xgrid" ]; then # if doing the UPF workflow...
    # If a restart job is requested...
    export R_FILE=${R_FILE:-"NA"}
    #export PROCS=${PROCS:-$((NGPUS+1))}
    export WORKFLOW_TYPE="upf"
#elif [ "x$WORKFLOW_TYPE" == "xmlrMBO" ]; then # if doing the mlrMBO workflow...
elif [ "x$WORKFLOW_TYPE" == "xbayesian" ]; then # if doing the mlrMBO workflow...
    export R_FILE=${R_FILE:-"mlrMBO-mbo.R"}
    #export PROCS=${PROCS:-$((NGPUS+2))}
    export WORKFLOW_TYPE="mlrMBO"
fi

# Save the job's parameters into a JSON file
$CANDLE/wrappers/analysis/make_json_from_submit_params.sh

# If we want to run the wrapper using CANDLE...
if [ "${USE_CANDLE:-1}" -eq 1 ]; then
    if [ "x$WORKFLOW_TYPE" == "xupf" ]; then
        "$CANDLE/Supervisor/workflows/$WORKFLOW_TYPE/swift/workflow.sh" "$SITE" -a "$CANDLE/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh" "$WORKFLOW_SETTINGS_FILE"
    elif [ "x$WORKFLOW_TYPE" == "xmlrMBO" ]; then

        # From $CANDLE/Supervisor/workflows/mlrMBO/test/cfg-sys-nightly.sh:
        export SH_TIMEOUT=${SH_TIMEOUT:-}
        export IGNORE_ERRORS=0

        #"$CANDLE/Supervisor/workflows/$WORKFLOW_TYPE/swift/workflow.sh" "$SITE" -a "$CANDLE/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh" "$WORKFLOW_SETTINGS_FILE" "$MODEL_NAME"
        "$CANDLE/Supervisor/workflows/$WORKFLOW_TYPE/swift/workflow.sh" "$SITE" -a "$CANDLE/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh" "$CANDLE/wrappers/templates/scripts/dummy_cfg-prm.sh" "$MODEL_NAME"
    fi
# ...otherwise, run the wrapper alone, outside of CANDLE
else
    #srun $TURBINE_LAUNCH_OPTIONS --ntasks=1 python "$benchmark"
    #python "$MODEL_PYTHON_DIR/$MODEL_PYTHON_SCRIPT.py"
    TURBINE_LAUNCH_OPTIONS_2="--mpi=pmix --mem=0"
    echo srun $TURBINE_LAUNCH_OPTIONS_2 --ntasks=1 python "$MODEL_PYTHON_DIR/$MODEL_PYTHON_SCRIPT.py"
    srun $TURBINE_LAUNCH_OPTIONS_2 --ntasks=1 python "$MODEL_PYTHON_DIR/$MODEL_PYTHON_SCRIPT.py"
fi
