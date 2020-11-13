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
