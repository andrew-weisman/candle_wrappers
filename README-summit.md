# Summit installation

## First time

On a login node run:

```bash
mkdir -p /gpfs/alpine/world-shared/med106/weismana/sw/candle
```

Put the following in `/gpfs/alpine/world-shared/med106/weismana/sw/candle/env-initial.sh` (this is what should ultimately be implemented in an `lmod` module):

```bash
#!/bin/bash

version="initial" # this is the new installation name
export CANDLE="/gpfs/alpine/world-shared/med106/weismana/sw/candle/$version"
export PATH="$PATH:$CANDLE/bin"
export SITE="summit"
export DEFAULT_PYTHON_MODULE="/gpfs/alpine/world-shared/med106/sw/condaenv-200408/bin/python3.6"
export DEFAULT_R_MODULE="/gpfs/alpine/world-shared/med106/wozniak/sw/gcc-6.4.0/R-3.6.1/lib64/R/bin/R"
export CANDLE_R_LIBS="/gpfs/alpine/world-shared/med106/sw/R-190927/lib64/R/library"
export CANDLE_SWIFT_T="/gpfs/alpine/world-shared/med106/wozniak/sw/gcc-6.4.0/swift-t/2020-09-02"
export WORKFLOWS_ROOT="$CANDLE/Supervisor/workflows"
export PROCS=-1
```

Source that:

```bash
source /gpfs/alpine/world-shared/med106/weismana/sw/candle/env-initial.sh
```

Clone the wrappers repository into the new CANDLE installation:

```bash
mkdir -p "$CANDLE/checkouts"
git clone git@github.com:andrew-weisman/candle_wrappers "$CANDLE/checkouts/wrappers" # have to set up the GitHub ssh key before this line works
```

## Subsequent times

```bash
bsub -W 01:00 -nnodes 2 -P med106 -q debug -Is /bin/bash
source /gpfs/alpine/world-shared/med106/weismana/sw/candle/env-initial.sh
bash "$CANDLE/checkouts/wrappers/setup.sh"
```

## To-do

* Perhaps rerun the following block once the workflow sets or doesn't set the pertinent variables (at least for setting up CANDLE on Summit, I need to set $PROCS in env-initial.sh or else sourcing the env-summit.sh file dies; I should re-run the block unless the env-summit.sh file is called anyway in the workflows):

```bash
if [[ ${TURBINE_RESIDENT_WORK_WORKERS:-} == "" ]]
then
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi
```
