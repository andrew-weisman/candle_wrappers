#!/bin/bash

# ASSUMPTIONS:
#   (1) candle module is loaded
#   (2) candle is run the normal way via "candle submit-job ...", which defines the variables:
#         $CANDLE_SUPP_MODULES (preprocess.py)
#         $CANDLE_KEYWORD_MODEL_SCRIPT (input file)
#         $CANDLE_PYTHON_BIN_PATH (preprocess.py)
#         $CANDLE_EXEC_PYTHON_MODULE (preprocess.py)
#         $CANDLE_EXTRA_SCRIPT_ARGS (preprocess.py)
#         $CANDLE_EXEC_R_MODULE (preprocess.py)
#         $CANDLE_SUPP_PYTHONPATH (via head.py; preprocess.py)
#         $CANDLE_SUPP_R_LIBS (via head.R; preprocess.py)


# Function to wrap the input model by wrapper lines of code
# I know this isn't so elegant but that's okay
wrap_model() {
    cat "$1"
    echo
    cat "$2"
    echo
    cat "$3"
}


# Display timing/node/GPU information
echo "MODEL_WRAPPER.SH START TIME: $(date +%s)"
echo "HOST: $(hostname)"
echo "GPU: ${CUDA_VISIBLE_DEVICES:-NA}"

# Unload environment in which we built Swift/T, as this is no longer needed, since Python is not necessarily used below
# This reverses in particular the Python loading we ran in run_workflows.sh
# shellcheck source=/dev/null
source "$CANDLE/wrappers/utilities.sh"; unload_python_env --unset-pythonhome

# Load a custom, SUPPlementary environment if it's set
if [ -n "$CANDLE_SUPP_MODULES" ]; then
    module load $CANDLE_SUPP_MODULES
fi

# Determine language to use to run the model
suffix=$(echo "$CANDLE_KEYWORD_MODEL_SCRIPT" | rev | awk -v FS="." '{print tolower($1)}' | rev)

# Write the run_candle_model_standalone.sh script here so that this job can be run completely standalone in the future if desired
m4 "$CANDLE/wrappers/commands/submit-job/run_candle_model_standalone.sh.m4" > ./run_candle_model_standalone.sh

# Run a model written in Python
if [ "x$suffix" == "xpy" ]; then

    # Clear PYTHONHOME since historically that's caused us issues
    # Note I'm commenting this out for now as it should be done in the unload_python_env() function above, and I can probably delete the current block in the near future
    #unset PYTHONHOME

    # If $CANDLE_PYTHON_BIN_PATH isn't null, prepend that to our $PATH
    if [ -n "$CANDLE_PYTHON_BIN_PATH" ]; then
        export PATH="$CANDLE_PYTHON_BIN_PATH:$PATH"

    # Otherwise, load the $CANDLE_EXEC_PYTHON_MODULE if it's set, or $CANDLE_DEFAULT_PYTHON_MODULE if it's not
    else
        if [ -n "$CANDLE_EXEC_PYTHON_MODULE" ]; then
            module load "$CANDLE_EXEC_PYTHON_MODULE"
        else
            # shellcheck source=/dev/null
            source "$CANDLE/wrappers/utilities.sh"; load_python_env
        fi
    fi

    # Create a wrapped version of the model in wrapped_model.py
    wrap_model "$CANDLE/wrappers/commands/submit-job/head.py" "$CANDLE_KEYWORD_MODEL_SCRIPT" "$CANDLE/wrappers/commands/submit-job/tail.py" > ./wrapped_model.py

    # Run wrapped_model.py
    echo "Using Python for execution: $(command -v python)"
    script_call="python${CANDLE_EXTRA_SCRIPT_ARGS:+ $CANDLE_EXTRA_SCRIPT_ARGS}"
    $script_call wrapped_model.py

# Run a model written in R
elif [ "x$suffix" == "xr" ]; then

    # This has also recently caused us issues though it's unclear why they didn't occur before 3/22/20
    unset R_LIBS

    # Load the default R module if a different module is not defined
    if [ -n "$CANDLE_EXEC_R_MODULE" ]; then
        module load "$CANDLE_EXEC_R_MODULE"
    else
        # shellcheck source=/dev/null
        source "$CANDLE/wrappers/utilities.sh"; load_r_env
    fi

    # Create a wrapped version of the model in wrapped_model.R
    wrap_model "$CANDLE/wrappers/commands/submit-job/head.R" "$CANDLE_KEYWORD_MODEL_SCRIPT" "$CANDLE/wrappers/commands/submit-job/tail.R" > ./wrapped_model.R

    # Run wrapped_model.R
    echo "Using Rscript for execution: $(command -v Rscript)"
    script_call="Rscript${CANDLE_EXTRA_SCRIPT_ARGS:+ $CANDLE_EXTRA_SCRIPT_ARGS}"
    $script_call wrapped_model.R

elif [ "x$suffix" == "xsh" ]; then

    # Create a wrapped version of the model in wrapped_model.sh
    #wrap_model "$CANDLE/wrappers/templates/scripts/head.sh" "$MODEL_SCRIPT" "$CANDLE/wrappers/templates/scripts/tail.sh" > wrapped_model.sh

    # George prefers it this way
    echo "source $CANDLE/wrappers/commands/submit-job/head.sh" > ./wrapped_model.sh
    echo "source $CANDLE_KEYWORD_MODEL_SCRIPT" >> wrapped_model.sh
    echo "source $CANDLE/wrappers/commands/submit-job/tail.sh" >> ./wrapped_model.sh

    # Run wrapped_model.sh
    # echo "Using Bash for execution: /bin/bash"
    # script_call="/bin/bash${EXTRA_SCRIPT_ARGS:+ $EXTRA_SCRIPT_ARGS}"
    # $script_call wrapped_model.sh

    # George probably prefers it this way
    echo "Using source for execution: source"
    source wrapped_model.sh

fi

# Display timing information
echo "MODEL_WRAPPER.SH END TIME: $(date +%s)"
