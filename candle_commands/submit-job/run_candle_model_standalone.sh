#!/bin/bash

# Assumptions:
#   (1) candle module is loaded
#   (2) submit-job has been run at least once in order to generate this script as run_candle_model_standalone.sh

export CANDLE_DEFAULT_MODEL_FILE="$CANDLE_SUBMISSION_DIR/candle_generated_files/default_model.txt"
export CANDLE_MODEL_DESCRIPTION="Dummy model description"
export CANDLE_DL_BACKEND="keras"
export CANDLE_PROG_NAME="Dummy program name"

source "$CANDLE/wrappers/utilities.sh"; load_python_env --set-pythonhome

python "$CANDLE/wrappers/candle_commands/submit-job/candle_compliant_wrapper.py"
