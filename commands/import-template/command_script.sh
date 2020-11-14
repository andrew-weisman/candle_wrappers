#!/bin/bash

# If templates are requested to be imported to the current directory, do so
# ASSUMPTIONS: candle module is loaded

# Parameter
template=$1

echo -n "Importing the files for the CANDLE template \"$template\"... "

# Check for validity of the input parameter "template"
if ! (echo "$template" | grep -E -i "^bayesian$|^grid$|^r$|^bash$|^grid-summit$" &> /dev/null)

# If it's not a valid input...
then
    echo -e "\nError: Input argument \"$template\" is not one of {grid,bayesian,r,bash}"
    exit 1

# ...otherwise, copy over the corresponding template files
else
    template_lower=$(echo "$template" | awk '{print(tolower($0))}')
    cp -p "$CANDLE/wrappers/examples/$template_lower"/* . && echo "done" || echo "failed"
fi
