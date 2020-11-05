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
