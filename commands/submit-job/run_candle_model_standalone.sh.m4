#!/bin/bash

# Needed directly in candle_compliant_wrapper.py
# Of course none of these variables matter if the model script is canonically CANDLE-compliant
export CANDLE_DL_BACKEND="syscmd(echo -n $CANDLE_DL_BACKEND)"
export CANDLE_DEFAULT_MODEL_FILE="syscmd(echo -n $CANDLE_DEFAULT_MODEL_FILE)"
export CANDLE_MODEL_DESCRIPTION="syscmd(echo -n $CANDLE_MODEL_DESCRIPTION)"
export CANDLE_PROG_NAME="syscmd(echo -n $CANDLE_PROG_NAME)"
export CANDLE_SUBMISSION_DIR="syscmd(echo -n $CANDLE_SUBMISSION_DIR)"

# Needed in model_wrapper.sh and the files it calls
# Of course none of these variables matter if the model script is canonically CANDLE-compliant
export CANDLE_SUPP_MODULES="syscmd(echo -n $CANDLE_SUPP_MODULES)"
export CANDLE_KEYWORD_MODEL_SCRIPT="syscmd(echo -n $CANDLE_KEYWORD_MODEL_SCRIPT)"
export CANDLE_PYTHON_BIN_PATH="syscmd(echo -n $CANDLE_PYTHON_BIN_PATH)"
export CANDLE_EXEC_PYTHON_MODULE="syscmd(echo -n $CANDLE_EXEC_PYTHON_MODULE)"
export CANDLE_EXTRA_SCRIPT_ARGS="syscmd(echo -n $CANDLE_EXTRA_SCRIPT_ARGS)"
export CANDLE_EXEC_R_MODULE="syscmd(echo -n $CANDLE_EXEC_R_MODULE)"
export CANDLE_SUPP_PYTHONPATH="syscmd(echo -n $CANDLE_SUPP_PYTHONPATH)"
export CANDLE_SUPP_R_LIBS="syscmd(echo -n $CANDLE_SUPP_R_LIBS)"

# Load a competent version of Python
source "$CANDLE/wrappers/utilities.sh"; load_python_env --set-pythonhome

# The point is to call a CANDLE-compliant script here
python "syscmd(echo -n $MODEL_PYTHON_DIR)/syscmd(echo -n $MODEL_PYTHON_SCRIPT).py"
