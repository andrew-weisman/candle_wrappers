#!/bin/bash

# On the left are variables used in the Supervisor mlrMBO workflow; on the right are the settings that I should have set somewhere in the candle_wrappers repository
# Note: I should put these four keywords in preprocess.py and set the default values there, not here (and check them and export them without the _KEYWORD part of the name as usual)!!
# ASSUMPTION: candle is called normally (in order to set $CANDLE_WORKFLOW_SETTINGS_FILE)

PROPOSE_POINTS=${CANDLE_KEYWORD_PROPOSE_POINTS:-10} # 9
MAX_ITERATIONS=${CANDLE_KEYWORD_MAX_ITERATIONS:-10} # 3
MAX_BUDGET=${CANDLE_KEYWORD_MAX_BUDGET:-110} # 180
DESIGN_SIZE=${CANDLE_KEYWORD_DESIGN_SIZE:-10} # 9
PARAM_SET_FILE=${PARAM_SET_FILE:-$CANDLE_WORKFLOW_SETTINGS_FILE} # $EMEWS_PROJECT_ROOT/data/nt3_nightly.R
