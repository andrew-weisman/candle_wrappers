#!/bin/bash

# ASSUMPTIONS: None

outfile="candle_value_to_return.json"
if [ -z "$candle_value_to_return" ]
then
    echo "ERROR: The return environment variable "candle_value_to_return" is empty" 1>&2 
else
    cat > $outfile << EOM
    {
        "val_loss":[ $candle_value_to_return ],
        "val_corr":[ $candle_value_to_return ],
        "val_dice_coef":[ $candle_value_to_return ]
    }
EOM

fi
