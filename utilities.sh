#!/bin/bash

# ASSUMPTIONS: site-specific_settings.sh has been sourced
load_python_env() {
    if [ "x${CANDLE_DEFAULT_PYTHON_MODULE:0:1}" == "x/" ]; then # If $CANDLE_DEFAULT_PYTHON_MODULE actually contains a full path to the executable instead of a module name...
        #path_to_add=$(tmp=$(echo "$CANDLE_DEFAULT_PYTHON_MODULE" | awk -v FS="/" -v OFS="/" '{$NF=""; print}'); echo "${tmp:0:${#tmp}-1}") # this strips the executable from the full path to the python executable set in $CANDLE_DEFAULT_PYTHON_MODULE (if it's not a module name of course)
        path_to_add=$(dirname "$CANDLE_DEFAULT_PYTHON_MODULE")
        export PATH="$path_to_add:$PATH"
    else
        module load "$CANDLE_DEFAULT_PYTHON_MODULE"
    fi

    # If any extra arguments to load_python_env() are included, then set $PYTHONHOME as well
    if [ ! $# -eq 0 ]; then
        tmp="$(dirname "$(dirname "$(command -v python)")")"
        export PYTHONHOME="$tmp"
    fi
}

# ASSUMPTIONS: None
make_generated_files_dir() {
    dirname="generated_files"
    [ -d $dirname ] || mkdir $dirname
}
