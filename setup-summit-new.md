# Summit setup

## Initial setup &mdash; do this just once

Choose a version name&mdash;going by the date is recommended, e.g., `2020-11-11`&mdash;and set this to the `version` Bash variable:

```bash
version="2020-11-11"
```

Put the following in `/gpfs/alpine/med106/world-shared/candle/env_for_lmod-$version.sh`:

```bash
#!/bin/bash

version="2020-11-11"
export CANDLE="/gpfs/alpine/med106/world-shared/candle/$version"
export PATH="$PATH:$CANDLE/wrappers/bin"
export SITE="summit-tf1"
export PYTHONPATH="$PYTHONPATH:$CANDLE/Benchmarks/common"
```

Source that:

```bash
source /gpfs/alpine/med106/world-shared/candle/env_for_lmod-$version.sh
```

Clone the wrappers repository into the new CANDLE installation:

```bash
mkdir -p "$CANDLE/checkouts"
git clone git@github.com:andrew-weisman/candle_wrappers "$CANDLE/checkouts/wrappers" # probably have to [set up the GitHub ssh key](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/checking-for-existing-ssh-keys) before this line works
```

## Further setup &mdash; once initial setup (above) has been done

```bash
export version="2020-11-11"
bsub -W 01:00 -nnodes 2 -P med106 -q debug -Is /bin/bash
source /gpfs/alpine/med106/world-shared/candle/env_for_lmod-$version.sh
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
append_path("PATH", pathJoin(base, "wrappers", "bin"))
setenv("SITE", "biowulf")
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
