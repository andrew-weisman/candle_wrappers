# Summit installation

## First time

Doing the following on the login node for now.

```bash
mkdir -p /gpfs/alpine/world-shared/med106/weismana/sw/candle
```
Putting the following in `/gpfs/alpine/world-shared/med106/weismana/sw/candle/env-initial.sh`:

```bash
#!/bin/bash

version="initial" # this is the new installation name
export CANDLE="/gpfs/alpine/world-shared/med106/weismana/sw/candle/$version"
export PATH="$PATH:$CANDLE/bin"
export SITE="summit"
export DEFAULT_PYTHON_MODULE="/gpfs/alpine/world-shared/med106/sw/condaenv-200408/bin/python3.6"
export DEFAULT_R_MODULE="/gpfs/alpine/world-shared/med106/wozniak/sw/gcc-6.4.0/R-3.6.1/lib64/R/bin/R"
```

Then sourcing that:

```bash
. /gpfs/alpine/world-shared/med106/weismana/sw/candle/env-initial.sh
```

```bash
mkdir "$CANDLE"
cd "$CANDLE"
mkdir "$CANDLE/checkouts"
git clone git@github.com:andrew-weisman/candle_wrappers "$CANDLE/checkouts/wrappers" # have to set up the GitHub ssh key before this line works
```

## Subsequent times

```bash
bsub -W 01:00 -nnodes 2 -P med106 -q debug -Is /bin/bash
. /gpfs/alpine/world-shared/med106/weismana/sw/candle/env-initial.sh
bash "$CANDLE/checkouts/wrappers/setup.sh"
```
