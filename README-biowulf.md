# Biowulf installation

## First time

On Helix or Biowulf, put the following in `/data/BIDS-HPC/public/software/distributions/candle/env-dev_3.sh` (this is what should ultimately be implemented in an `lmod` module):

```bash
version="dev_3" # this is the new installation name
export CANDLE="/data/BIDS-HPC/public/software/distributions/candle/$version"
export PATH="$PATH:$CANDLE/bin"
export SITE="biowulf"
export DEFAULT_PYTHON_MODULE="python/3.7"
export DEFAULT_R_MODULE="R/4.0.0"
```

Source that:

```bash
source /data/BIDS-HPC/public/software/distributions/candle/env-dev_3.sh
```

Clone the wrappers repository into the new CANDLE installation:

```bash
mkdir -p "$CANDLE/checkouts"
git clone git@github.com:andrew-weisman/candle_wrappers "$CANDLE/checkouts/wrappers" # have to set up the GitHub ssh key before this line works
```

## Subsequent times

```bash
sinteractive -n 3 -N 3 --ntasks-per-core=1 --cpus-per-task=16 --gres=gpu:k80:1,lscratch:400 --mem=20G --no-gres-shell
source /data/BIDS-HPC/public/software/distributions/candle/env-dev_3.sh
bash "$CANDLE/checkouts/wrappers/setup.sh"
```
