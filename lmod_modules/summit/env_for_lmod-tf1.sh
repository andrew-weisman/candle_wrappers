#!/bin/bash

version="2020-11-11"
export CANDLE="/gpfs/alpine/med106/world-shared/candle/$version"
export PATH="$PATH:$CANDLE/wrappers/bin"
export SITE="summit-tf1"
export PYTHONPATH="$PYTHONPATH:$CANDLE/Benchmarks/common"
export WORKFLOWS_ROOT="$CANDLE/Supervisor/workflows"
export PROCS=-1
