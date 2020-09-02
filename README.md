# candle_wrappers

Run an interactive session like:

```bash
sinteractive -n 3 -N 3 --ntasks-per-core=1 --cpus-per-task=16 --gres=gpu:k80:1,lscratch:400 --mem=20G --no-gres-shell
```

Set up the environment for a brand new CANDLE installation (this can and probably should be put in an `lmod` module):

```bash
version="dev_2" # this is the new installation name
export CANDLE="/data/BIDS-HPC/public/software/distributions/candle/$version"
export PATH="$CANDLE/bin:$PATH"
export SITE="biowulf"
export DEFAULT_PYTHON_MODULE="python/3.7"
export DEFAULT_R_MODULE="R/4.0.0"
export USE_OPENMPI="1"
```

Create the `$CANDLE` and `checkouts` directories:

```bash
mkdir "$CANDLE"
cd "$CANDLE"
mkdir "$CANDLE/checkouts"
```

Clone this repository (you may need to do the cloning *not* on a compute node):

```bash
git clone git@github.com:andrew-weisman/candle_wrappers.git "$CANDLE/checkouts/wrappers"
```

Run `setup.sh`:

```bash
bash "$CANDLE/checkouts/wrappers/setup.sh"
```
