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
-- append_path("PATH", pathJoin(base, "wrappers/templates/scripts"))

if (mode() == "load") then
    LmodMessage("[+] Loading  ", app, version, " ...")
end
if (mode() == "unload") then
    LmodMessage("[-] Unloading ", app, version, " ...")
end
