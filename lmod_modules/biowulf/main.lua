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
