#!/bin/bash


# Create the necessary directories
if [ ! -d "$CANDLE" ]; then
    mkdir "$CANDLE"
else
    echo "ERROR: Directory '$CANDLE' already exists"
    exit 1
fi
mkdir "$CANDLE"/{bin,checkouts,builds}
