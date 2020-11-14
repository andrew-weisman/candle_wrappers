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
export WORKFLOWS_ROOT="$CANDLE/Supervisor/workflows" # probably shouldn't be necessary but appears to be so since env-summit*.sh requires this variable
export PROCS="-1" # probably shouldn't be necessary but appears to be so since env-summit*.sh requires this variable
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

Put a file named, e.g., `tf1.lua`, in `/gpfs/alpine/med106/world-shared/lmod_modules` with settings corresponding to `env_for_lmod-$version.sh` above. For example:

```lua
-- ALW built this on 11/11/20

whatis("Version: tf1")
whatis("Description: Open-source software platform providing highly scalable deep learning methodologies")

local app         = "candle"
local version     = "tf1"
local base        = pathJoin("/gpfs/alpine/med106/world-shared/candle", version)

-- The following block is what should match the "export ..." lines of env_for_lmod-$version.sh
setenv("CANDLE", base)
append_path("PATH", pathJoin(base, "wrappers", "bin"))
setenv("SITE", "summit-tf1")
append_path("PYTHONPATH", pathJoin(base, "Benchmarks", "common"))
setenv("WORKFLOWS_ROOT", pathJoin(base, "Supervisor", "workflows")) -- probably shouldn't be necessary but appears to be so since env-summit*.sh requires this variable
setenv("PROCS", "-1") -- probably shouldn't be necessary but appears to be so since env-summit*.sh requires this variable

if (mode() == "load") then
    LmodMessage("[+] Loading  ", app, version, " ...")
end
if (mode() == "unload") then
    LmodMessage("[-] Unloading ", app, version, " ...")
end
```

Then, instead of running e.g. `source /gpfs/alpine/med106/world-shared/candle/env_for_lmod-$version.sh` as above, if the filename of the above file were `XXXX.lua`, you would just load it like `module load candle/XXXX`.

## Directory structure of `/gpfs/alpine/med106/world-shared/candle`

* Call each new version a date in the format `2020-11-11`
* Create the symbolic links `tf1`, `dev`, etc. to chosen versions, e.g.,

```bash
cd /gpfs/alpine/med106/world-shared/candle
ln -s 2020-11-11 tf1
```

Once this is done, everything else, e.g., the `lmod` modulefiles, will fall into place.

## Notes

### `env-summit-tf1.sh`

While `env-summit-tf1.sh` could be modified to get rid of "errors" in the setup scripts (which also occur in the actual CANDLE jobs) that look like...

```
output.txt:32:/usr/bin/uuidgen: /gpfs/alpine/world-shared/med106/sw/condaenv-200408/lib/libuuid.so.1: no version information available (required by /usr/bin/uuidgen)
```

...when doing so, it actually makes the CANDLE jobs die with what appear to be environment issues (importing tensorflow it seems) in `model_runner.py`. It is best to leave `env-summit-tf1.sh` as Justin figured it out to be! The `uuidgen` issues appear to be inconsequential, at least as of 11/13/20.

### Multiple processes per node

Note that on line 185 of `/gpfs/alpine/world-shared/med106/sw/condaenv-200408/lib/python3.6/site-packages/keras/utils/data_utils.py` I made the change from

```python
    datadir = os.path.join(datadir_base, cache_subdir)
    if not os.path.exists(datadir):
        os.makedirs(datadir)

    if untar:
```

to

```python
    datadir = os.path.join(datadir_base, cache_subdir)
    if not (os.path.isabs(fname) and untar==False and extract==False):
        if not os.path.exists(datadir):
            os.makedirs(datadir)

    if untar:
```

Without this change, when running `PPN != 1` as I am doing, multiple processes try to create `datadir` at the same time since it doesn't already exist, which can lead to crashing since `os.makedirs()` will die with a `FileExistsError` if the directory it's trying to make already exists (unless we use the `exist_ok=True` argument to `makedirs()`, which is probably too general of a change). While it seems like it checks for this, this is not robust to multiple processes checking the same `datadir` as when `PPN != 1`.

Note that at least for the `grid-summit` example, the condition in parentheses is true, so this matters.
