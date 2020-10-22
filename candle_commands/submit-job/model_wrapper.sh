#!/bin/bash

# Function to wrap the input model by wrapper lines of code
wrap_model() {
    cat "$1"
    echo ""
    cat "$2"
    echo ""
    cat "$3"
}

# Display timing/node/GPU information
echo "MODEL_WRAPPER.SH START TIME: $(date +%s)"
echo "HOST: $(hostname)"
echo "GPU: ${CUDA_VISIBLE_DEVICES:-NA}"

# Unload environment in which we built Swift/T
module unload $DEFAULT_PYTHON_MODULE

# Load a custom, SUPPlementary environment if it's set
if [ -n "$SUPP_MODULES" ]; then
    module load $SUPP_MODULES
fi

# Determine language to use to run the model
suffix=$(echo "$MODEL_SCRIPT" | rev | awk -v FS="." '{print tolower($1)}' | rev)

# Run a model written in Python
if [ "x$suffix" == "xpy" ]; then

    # Clear PYTHONHOME since historically that's caused us issues
    unset PYTHONHOME

    # If $PYTHON_BIN_PATH isn't null, prepend that to our $PATH
    if [ -n "$PYTHON_BIN_PATH" ]; then
        export PATH=$PYTHON_BIN_PATH:$PATH

    # Otherwise, load the $EXEC_PYTHON_MODULE if it's set, or $DEFAULT_PYTHON_MODULE if it's not
    else
        module load "${EXEC_PYTHON_MODULE:-$DEFAULT_PYTHON_MODULE}"
    fi

    # ALW: On 6/29/19, moving this from head.py; not sure why I put it there but there may have been a reason!
    # ALW: On 7/5/19, redoing this, found I did it because if it's an environment variable it gets added to sys.path too early (pretty much first-thing); doing it here appends to the path at the end!
    # # If it's defined in the environment, append $SUPP_PYTHONPATH to the Python path
    # export PYTHONPATH+=":$SUPP_PYTHONPATH"

    # Create a wrapped version of the model in wrapped_model.py
    wrap_model "$CANDLE/wrappers/templates/scripts/head.py" "$MODEL_SCRIPT" "$CANDLE/wrappers/templates/scripts/tail.py" > wrapped_model.py

    # Run wrapped_model.py
    echo "Using Python for execution: $(command -v python)"
    script_call="python${EXTRA_SCRIPT_ARGS:+ $EXTRA_SCRIPT_ARGS}"
    $script_call wrapped_model.py

# Run a model written in R
elif [ "x$suffix" == "xr" ]; then

    # This has also recently caused us issues though it's unclear why they didn't occur before 3/22/20
    unset R_LIBS

    # Load the default R module if a different module is not defined
    module load "${EXEC_R_MODULE:-$DEFAULT_R_MODULE}"

    # Create a wrapped version of the model in wrapped_model.R
    wrap_model "$CANDLE/wrappers/templates/scripts/head.R" "$MODEL_SCRIPT" "$CANDLE/wrappers/templates/scripts/tail.R" > wrapped_model.R

    # Run wrapped_model.R
    echo "Using Rscript for execution: $(command -v Rscript)"
    script_call="Rscript${EXTRA_SCRIPT_ARGS:+ $EXTRA_SCRIPT_ARGS}"
    $script_call wrapped_model.R

elif [ "x$suffix" == "xsh" ]; then

    # Create a wrapped version of the model in wrapped_model.sh
    #wrap_model "$CANDLE/wrappers/templates/scripts/head.sh" "$MODEL_SCRIPT" "$CANDLE/wrappers/templates/scripts/tail.sh" > wrapped_model.sh

    # George prefers it this way
    echo "source $CANDLE/wrappers/templates/scripts/head.sh" > wrapped_model.sh
    echo "source $MODEL_SCRIPT" >> wrapped_model.sh
    echo "source $CANDLE/wrappers/templates/scripts/tail.sh" >> wrapped_model.sh

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
