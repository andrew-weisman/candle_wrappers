#!/bin/bash

export CANDLE_DL_BACKEND="syscmd(echo -n $CANDLE_DL_BACKEND)"
export CANDLE_DEFAULT_MODEL_FILE="syscmd(echo -n $CANDLE_DEFAULT_MODEL_FILE)"
export CANDLE_MODEL_DESCRIPTION="syscmd(echo -n $CANDLE_MODEL_DESCRIPTION)"
export CANDLE_PROG_NAME="syscmd(echo -n $CANDLE_PROG_NAME)"

source "$CANDLE/wrappers/utilities.sh"; load_python_env --set-pythonhome

python "$CANDLE/wrappers/candle_commands/submit-job/candle_compliant_wrapper.py"
