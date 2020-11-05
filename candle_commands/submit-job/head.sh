#!/bin/bash

# ASSUMPTIONS:
#   (1) candle module is loaded
#   (2) In directory where params.json resides

#script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function candle_get_param {
    #python ${script_dir}/get_param.py "$@"
    python "$CANDLE/wrappers/commands/submit-job/get_param.py" "$@"
}


#GZ, not sure you want to append PATH, or PYTHONPATH
#export PATH=$PATH:$SUPP_PYTHONPATH # ALW: removing this as it's for Python scripts only
export candle_params=$(readlink -f params.json)
