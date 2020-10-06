# Biowulf installation

## First time

Choose a version name, e.g., `2020-09-30`, and set this to the `version` Bash variable:

```bash
version="2020-09-30"
```

On Helix or Biowulf, put the following in `/data/BIDS-HPC/public/software/distributions/candle/env_for_lmod-$version.sh`:

```bash
#!/bin/bash

version="2020-09-30"
export CANDLE="/data/BIDS-HPC/public/software/distributions/candle/$version"
export PATH="$PATH:$CANDLE/bin"
export SITE="biowulf"
export DEFAULT_PYTHON_MODULE="python/3.7"
export DEFAULT_R_MODULE="R/4.0.0"
export PYTHONPATH="$PYTHONPATH:$CANDLE/Benchmarks/common"
```

Source that:

```bash
source /data/BIDS-HPC/public/software/distributions/candle/env_for_lmod-$version.sh
```

Clone the wrappers repository into the new CANDLE installation:

```bash
mkdir -p "$CANDLE/checkouts"
git clone git@github.com:andrew-weisman/candle_wrappers "$CANDLE/checkouts/wrappers" # probably have to set up the GitHub ssh key before this line works
```

## Subsequent times

```bash
version="2020-09-30"
sinteractive -n 3 -N 3 --ntasks-per-core=1 --cpus-per-task=16 --gres=gpu:k80:1,lscratch:400 --mem=20G --no-gres-shell
source /data/BIDS-HPC/public/software/distributions/candle/env_for_lmod-$version.sh
bash "$CANDLE/checkouts/wrappers/setup.sh"
```

## Setting up the `lmod` module

Put a file named, e.g., `main.lua` or `dev.lua`, in `/data/BIDS-HPC/public/candle_modulefiles` with settings corresponding to `env_for_lmod-$version.sh` above. For example:

```lua
-- Andrew built this on 9/30/20

whatis("Version: dev")
whatis("URL: https://cbiit.github.com/sdsi/candle")
whatis("Description: Open-source software platform providing highly scalable deep learning methodologies, including intelligent hyperparameter optimization. https://cbiit.github.com/sdsi/candle")

local app         = "candle"
local version     = "dev"
local base        = pathJoin("/data/BIDS-HPC/public/software/distributions/candle", version)

-- The following block is what should match the "export ..." lines of env_for_lmod-$version.sh
setenv("CANDLE", base)
append_path("PATH", pathJoin(base, "bin"))
setenv("SITE", "biowulf")
setenv("DEFAULT_PYTHON_MODULE", "python/3.7")
setenv("DEFAULT_R_MODULE", "R/4.0.0")
append_path("PYTHONPATH", pathJoin(base, "Benchmarks", "common"))

if (mode() == "load") then
    LmodMessage("[+] Loading  ", app, version, " ...")
end
if (mode() == "unload") then
    LmodMessage("[-] Unloading ", app, version, " ...")
end
```

Then, instead of running e.g. `source /data/BIDS-HPC/public/software/distributions/candle/env_for_lmod-$version.sh` as above, if the filename of the above file were `XXXX.lua`, you would just load it like `module load candle/XXXX`.

## Directory structure of `/data/BIDS-HPC/public/software/distributions/candle`

* Call each new version a date in the format `2020-09-30`
* Create the symbolic links `main` and `dev` to chosen versions, e.g.,

```bash
cd /data/BIDS-HPC/public/software/distributions/candle
ln -s 2020-09-30 dev
```

Once this is done, everything else, e.g., the `lmod` modulefiles, will fall into place.
