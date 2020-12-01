# Biowulf setup

## Initial setup &mdash; do this just once

Choose a version name&mdash;going by the date is recommended, e.g., `2020-09-30`&mdash;and set this to the `version` Bash variable:

```bash
version="2020-11-23"
```

On Helix or Biowulf, put the following in `/data/BIDS-HPC/public/software/distributions/candle/env_for_lmod-$version.sh`:

```bash
#!/bin/bash

version="2020-11-23"
export CANDLE="/data/BIDS-HPC/public/software/distributions/candle/$version"
export PATH="$PATH:$CANDLE/wrappers/bin"
export SITE="biowulf"
export PYTHONPATH="$PYTHONPATH:$CANDLE/Benchmarks/common"
```

Source that:

```bash
source /data/BIDS-HPC/public/software/distributions/candle/env_for_lmod-$version.sh
```

Clone the wrappers repository into the new CANDLE installation:

```bash
mkdir -p "$CANDLE/checkouts"
git clone git@github.com:andrew-weisman/candle_wrappers "$CANDLE/checkouts/wrappers" # probably have to [set up the GitHub ssh key](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/checking-for-existing-ssh-keys) before this line works
```

## Further setup &mdash; once initial setup (above) has been done

```bash
export version="2020-11-23"
sinteractive -n 3 -N 3 --ntasks-per-core=1 --cpus-per-task=16 --gres=gpu:k80:1,lscratch:400 --mem=20G --no-gres-shell
source /data/BIDS-HPC/public/software/distributions/candle/env_for_lmod-$version.sh
bash "$CANDLE/checkouts/wrappers/setup.sh"
```

## Directory structure of `/data/BIDS-HPC/public/software/distributions/candle`

* Call each new version a date in the format `2020-11-23`
* Create the symbolic links `main` and `dev` to chosen versions, e.g.,

```bash
cd /data/BIDS-HPC/public/software/distributions/candle
ln -s 2020-11-23 main
```

Once this is done, everything else, e.g., the `lmod` modulefiles, will fall into place.

## Setting up the `lmod` module

Put a file named, e.g., `main.lua` or `dev.lua`, in `/data/BIDS-HPC/public/candle_modulefiles` with settings corresponding to `env_for_lmod-$version.sh` above. For example:

```lua
-- Andrew built this on 11/23/20

whatis("Version: main")
whatis("URL: https://cbiit.github.com/sdsi/candle")
whatis("Description: Open-source software platform providing highly scalable deep learning methodologies, including intelligent hyperparameter optimization. https://cbiit.github.com/sdsi/candle")

local app         = "candle"
local version     = "main"
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

## Other notes

* The last time I ran the `setup.sh` script on Biowulf, EQ-R didn't seem to be actually set up even though the logs (see [here](https://github.com/andrew-weisman/candle_wrappers/blob/master/log_files/eqr_installation_out_and_err-biowulf-2020-11-23_1758.txt)) explicitly state that the built files were copied to the `EQR="$CANDLE/Supervisor/workflows/common/ext/EQ-R"` directory. So, on 11/25/20 I had to run `setup.sh` again, which seemed to produce the same exact log file but this time actually copied the built EQ-R files as expected. Just something to keep in mind going forward!
