#!/bin/bash

# ASSUMPTIONS: site-specific_settings.sh has been sourced
load_python_env() {
    if [ "x${CANDLE_DEFAULT_PYTHON_MODULE:0:1}" == "x/" ]; then # If $CANDLE_DEFAULT_PYTHON_MODULE actually contains a full path to the executable instead of a module name...
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


# ASSUMPTIONS: site-specific_settings.sh has been sourced
unload_python_env() {
    if [ "x${CANDLE_DEFAULT_PYTHON_MODULE:0:1}" == "x/" ]; then # If $CANDLE_DEFAULT_PYTHON_MODULE actually contains a full path to the executable instead of a module name...
        path_to_remove=$(dirname "$CANDLE_DEFAULT_PYTHON_MODULE")
        tmp2="$(tmp=$(echo "$PATH" | awk -v RS=":" '{print}' | head -n -1 | grep -v "$path_to_remove" | awk -v ORS=":" '{print}'); echo "${tmp:0:${#tmp}-1}")"
        export PATH="$tmp2"
    else
        module unload "$CANDLE_DEFAULT_PYTHON_MODULE"
    fi

    # If any extra arguments to load_python_env() are included, then unset $PYTHONHOME as well
    if [ ! $# -eq 0 ]; then
        unset PYTHONHOME
    fi
}


# ASSUMPTIONS: site-specific_settings.sh has been sourced
load_r_env() {
    if [ "x${CANDLE_DEFAULT_R_MODULE:0:1}" == "x/" ]; then # If $CANDLE_DEFAULT_R_MODULE actually contains a full path to the executable instead of a module name...
        path_to_add=$(dirname "$CANDLE_DEFAULT_R_MODULE")
        export PATH="$path_to_add:$PATH"
    else
        module load "$CANDLE_DEFAULT_R_MODULE"
    fi
}


# ASSUMPTIONS: site-specific_settings.sh has been sourced
unload_r_env() {
    if [ "x${CANDLE_DEFAULT_R_MODULE:0:1}" == "x/" ]; then # If $CANDLE_DEFAULT_R_MODULE actually contains a full path to the executable instead of a module name...
        path_to_remove=$(dirname "$CANDLE_DEFAULT_R_MODULE")
        tmp2="$(tmp=$(echo "$PATH" | awk -v RS=":" '{print}' | head -n -1 | grep -v "$path_to_remove" | awk -v ORS=":" '{print}'); echo "${tmp:0:${#tmp}-1}")"
        export PATH="$tmp2"
    else
        module unload "$CANDLE_DEFAULT_R_MODULE"
    fi
}


# ASSUMPTIONS: None
make_generated_files_dir() {
    dirname="./candle_generated_files"
    [ -d $dirname ] || mkdir $dirname
}
