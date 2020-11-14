# Repository organization

This document describes and relates all files in the `candle_wrappers` repository. All file locations are relative to `$CANDLE/wrappers`.

    ├── README.md

*Description:* Starting place for learning how to use the files in this `candle_wrappers` repository, including setup/usage instructions and general notes. **Start here!**  
*Referenced by:* NA; top-level; rendered by default when going to [the current repository](https://github.com/andrew-weisman/candle_wrappers) on GitHub  
*References:* `setup-$SITE.md`, `repository_organization.md`

    ├── setup-$SITE.md

*Description:* Instructions on how to install `candle_wrappers` at the various sites, including initial setup, further setup, how to set up the `lmod` modules, and directory structure information  
*Referenced by:* `README.md`  
*References:* `setup.sh`, `lmod_modules/$SITE/*.lua`

    ├── setup.sh

*Description:* Installs CANDLE and related packages at the current `$SITE`, setting up the directory structure and cloning the necessary repositories, setting up the environment, testing MPI communications, installing the R packages needed for the Supervisor workflows, building Swift/T and EQ-R, running Swift/T hello world scripts, running a CANDLE benchmark, and ensuring permissions are correct on the new installation, some of which steps are optional  
*Referenced by:* `setup-$SITE.md`  
*References:* `site-specific_settings.sh`, `utilities.sh`, `test_files/{hello.c,mytest2.swift,myextension.swift}`, `log_files/*`, `swift-t_setup/{swift-t-settings.sh.template,swift-t-settings-$SITE.sh,eqr_settings.sh.template,eqr_settings-$SITE.sh}`

    ├── site-specific_settings.sh

*Description:* Sets all site-specific Bash variables in the `candle_wrappers` repository  
*Referenced by:* `setup.sh`, `utilities.sh`, `commands/submit-job/run_workflows.sh`  
*References:* NA

    └── utilities.sh

*Description:* Contains various utility functions for use in Bash scripts, e.g., correctly loading and unloading the Python or R environments either by `lmod` or by adding/subtracting from the path; creating a `candle_generated_files` directory in the submission directory  
*Referenced by:* `setup.sh`, `commands/generate-grid/command_script.sh`, `commands/submit-job/command_script.sh`, `commands/aggregate-results/command_script.sh`, `commands/submit-job/run_workflows.sh`, `commands/submit-job/model_wrapper.sh`, `commands/submit-job/run_candle_model_standalone.sh.m4`  
*References:* `site-specific_settings.sh`

    ├── test_files

*DIRECTORY:* Contains scripts used for testing the `candle_wrappers` setup process run from `setup.sh`

    │   ├── hello.c

*Description:* MPI hello world program that outputs the SLURM topology address, hostname, processor name, rank, number of tasks, and the visible CUDA device  
*Referenced by:* `setup.sh`  
*References:* NA

    │   ├── mytest2.swift

*Description:* Swift/T script that simply prints "HELLO" to the screen  
*Referenced by:* `setup.sh`  
*References:* NA

    │   ├── myextension.swift

*Description:* Swift/T script that prints the server and worker nodes to the screen and then prints seven numbers to the screen in a time-delayed fashion  
*Referenced by:* `setup.sh`  
*References:* `test_files/myextension.tcl`

    │   ├── myextension.tcl

*Description:* Tcl script that defines a function that doubles an inputted number and waits five seconds  
*Referenced by:* `test_files/myextension.swift`  
*References:* `test_files/pkgIndex.tcl`

    │   └── pkgIndex.tcl

*Description:* Package index for `myextension.tcl`  
*Referenced by:* `test_files/myextension.tcl`  
*References:* NA

    ├── log_files

*DIRECTORY:* Contains `.txt` log files from the `candle_wrappers` setup process initiated by `setup.sh`

    ├── swift-t_setup

*DIRECTORY:* Contains settings files (whose variables are largely set in `site-specific_settings.sh`) needed for the Swift/T and EQ-R setup processes

    │   └── swift-t-settings.sh.template

*Description:* Template `swift-t-settings.sh` file taken from the Swift/T source code (in `dev/build/swift-t-settings.sh`) used for building Swift/T; it's literally a direct copy of that file so that this version in `swift-t_setup` can be compared to continuously updated versions in the Swift/T source code  
*Referenced by:* `setup.sh`  
*References:* NA

    │   ├── swift-t-settings-$SITE.sh

*Description:* File directly modified from `swift-t-settings.sh.template` that contains variables mostly defined in `site-specific_settings.sh` used in the Swift/T build scripts  
*Referenced by:* `setup.sh`  
*References:* NA

    │   ├── eqr_settings.sh.template

*Description:* Template `eqr_settings.sh` file taken from the Supervisor code (in `workflows/common/ext/EQ-R/eqr/settings.template.sh`; yes, it's a different name) used for building EQ-R; it's literally a direct copy of that file so that this version in `swift-t_setup` can be compared to continuously updated versions in the Supervisor code  
*Referenced by:* `setup.sh`  
*References:* NA

    │   ├── eqr_settings-$SITE.sh

*Description:* File directly modified from `eqr_settings.sh.template` that contains variables mostly defined in `site-specific_settings.sh` used in the EQ-R build process  
*Referenced by:* `setup.sh`  
*References:* NA

    ├── lmod_modules

*DIRECTORY:* Contains mainly `.lua` files that are part of the `lmod` modules package used to load the various CANDLE environments that we set up

    │   └── $SITE

*DIRECTORY:* Contains site-specific `.lua` files

    │       ├── dev.lua

*Description:* `dev` `lmod` file used to set up the development CANDLE environment at `$SITE`  
*Referenced by:* `setup-$SITE.md`  
*References:* NA

    │       ├── main.lua

*Description:* `main` `lmod` file used to set up the main CANDLE environment at `$SITE`  
*Referenced by:* `setup-$SITE.md`  
*References:* NA

    │       └── README.md

*Description:* File containing the link paths for `lmod` at `$SITE`  
*Referenced by:* `setup-$SITE.md`  
*References:* NA

    ├── bin

*DIRECTORY:* Holds a single Bash script, the main `candle` program

    │   └── candle

*Description:* Runs the `command_script.sh` Bash script associated with each command to the `candle` program  
*Referenced by:* `README.md`  
*References:* `commands/$command/command_script.sh`

    ├── commands

*DIRECTORY:* Contains one directory for each command to the `candle` program; each directory should have the same name as the corresponding command

    │   ├── import-template

*DIRECTORY:* Contains the command that copies to the submission directory the contents of one of the subdirectories of the `examples` directory

    │   │   └── command_script.sh

*Description:* Main command script that copies over one of the templates in the `examples` directory to the submission (current) directory  
*Referenced by:* `bin/candle`  
*References:* NA

    │   ├── generate-grid

*DIRECTORY:* Contains the command and helper `Python` script generates a hyperparameter grid to copy to the `&param_space` section of the input file when running a grid search

    │   │   ├── command_script.sh

*Description:* Main command script that sets up and runs the `Python` script that generates a hyperparameter grid to copy to the `&param_space` section of the input file when running a grid search  
*Referenced by:* `bin/candle`  
*References:* `utilities.sh`, `commands/generate-grid/generate_hyperparameter_grid.py`

    │   │   └── generate_hyperparameter_grid.py

*Description:* `Python` script that calls a recursive function `make_set()` that expands some hyperparameter iterables to an unrolled parameter file  
*Referenced by:* `commands/generate-grid/command_script.sh`  
*References:* NA

    │   ├── submit-job

*DIRECTORY:* Contains the command and requisite scripts/files needed for running a Supervisor workflow

    │       ├── command_script.sh

*Description:* Main command script that processes the input (`.in`) file, splitting it up into three separate input files (submissions script, default model file, and workflow settings file, as in the old functionality) and executing the generated submission script, which ends with running `commands/submit-job/run_workflows.sh`  
*Referenced by:* `bin/candle`  
*References:* `utilities.sh`, `*.in`, `commands/submit-job/run_workflows.sh`

    │       ├── run_workflows.sh

*Description:* Nominally a `workflow.sh`-calling script that checks input settings via preprocess.py, sources variables set to be exported in preprocess.py, sets `$MODEL_PYTHON_DIR` and `$MODEL_PYTHON_SCRIPT` to a canonically CANDLE-compliant file, creates the experiments directory if not already present, maps user-friendly workflow keywords to Supervisor workflows, generates the commands to run (the workflow.sh scripts in Supervisor/workflows, or `python` via a launcher on an interactive node), and runs the generated commands or outputs them to screen if a dry run is requested  
*Referenced by:* `commands/submit-job/command_script.sh`  
*References:* `site-specific_settings.sh`, `utilities.sh`, `commands/submit-job/preprocess.py`, `commands/submit-job/restart.py`, `commands/submit-job/make_json_from_submit_params.sh`, `candle_compliant_wrapper.py` (indirectly through Supervisor), `commands/submit-job/dummy_cfg-prm.sh` (indirectly through Supervisor)

    │       ├── preprocess.py

*Description:* Script that checks keywords in the input file and writes a file containing the resulting variables to be exported in `run_workflows.sh` based on the `$SITE` characteristics  
*Referenced by:* `commands/submit-job/run_workflows.sh`  
*References:* NA

    │       ├── restart.py

*Description:* Script to restart `grid` workflow jobs that get killed prematurely; I haven't tested this in a while, and I believe? that the DOE team has replicated this functionality  
*Referenced by:* `commands/submit-job/run_workflows.sh`  
*References:* NA

    │       ├── make_json_from_submit_params.sh

*Description:* Script that I wrote to complement the `restart.py` script to restart `grid` workflow jobs that get killed prematurely; I haven't tested this in a while, and I believe? that the DOE team has replicated this functionality  
*Referenced by:* `commands/submit-job/run_workflows.sh`  
*References:* NA

    │       ├── candle_compliant_wrapper.py

*Description:* `python` script that should always be kept up-to-date-canonically-CANDLE-compliant and is probably called through the Supervisor via `model_runner.py` (by memory), which eventually gets called after the `workflow.sh` scripts are called inside `run_workflows.sh`. Note that if the model script is not canonically CANDLE-compliant, then this `candle_compliant_wrapper.py` script will never be called in the first place, which eliminates all the files below that are eventually called due to `candle_compliant_wrapper.py`. This script utilizes the CANDLE library to return the global parameters in a function called `initialize_parameters()` as usual, but further in the `run()` function defines a dummy history class, dumps the current set of HPs to a JSON file and to the screen, runs `model_wrapper.sh` (outputting its out/err to `subprocess_out_and_err.txt`), and populates and returns an instance of the HistoryDummy class with the contents of the `candle_value_to_return.json` file that was written through `model_wrapper.sh`  
*Referenced by:* `commands/submit-job/run_workflows.sh` (indirectly through Supervisor)  
*References:* `commands/submit-job/model_wrapper.sh`

    │       ├── model_wrapper.sh

*Description:* Script that displays timing/node/GPU information at the beginning and end, unloads the main Python distribution as it's no longer necessarily necessary, loads a supplementary set of modules if desired, writes a script to run the model standalone via `run_candle_model_standalone.sh.m4`, and, for a model script written in Python, R, or Bash, sets the particular Python or R versions desired for execution, wraps the model script in head and tail code snippets, and executes the wrapped model. Note this way of running the model script allows for languages aside from Python to be used and for less CANDLE-compliance explicitly required by the user due to the head and tail snippets bookending the model script  
*Referenced by:* `commands/submit-job/candle_compliant_wrapper.py`  
*References:* `utilities.sh`, `commands/submit-job/run_candle_model_standalone.sh.m4`, `commands/submit-job/{head,tail}.{py,R,sh}`, `$CANDLE_KEYWORD_MODEL_SCRIPT`

    │       ├── run_candle_model_standalone.sh.m4

*Description:* `.m4` file that's run using `m4` in `model_wrapper.sh` in order to create a Bash script that can be run standalone in order to show how the model script can be run completely outside of the wrapper scripts using e.g. `bash run_candle_model_standalone.sh`  
*Referenced by:* `commands/submit-job/model_wrapper.sh`  
*References:* `utilities.sh`

    │       ├── head.py

*Description:* Code snippet to prepend to the model script that appends supplementary `$PYTHONPATH` paths if desired and loads the current hyperparameter set from the `params.json` file written in `candle_compliant_wrapper.py` into a dictionary named `candle_params`  
*Referenced by:* `commands/submit-job/model_wrapper.sh`  
*References:* NA

    │       ├── tail.py

*Description:* Code snippet to append to the model script that asserts that a `history` object or `candle_value_to_return` variable is defined in the model script and creates a file called `candle_value_to_return.json` that dumps the relevant result into a JSON object of the `history.history` form  
*Referenced by:* `commands/submit-job/model_wrapper.sh`  
*References:* NA

    │       ├── head.R

*Description:* Code snippet to prepend to the model script that appends a supplementary `$R_LIBS` path if desired and loads the current hyperparameter set from the `params.json` file written in `candle_compliant_wrapper.py` into a data.frame named `candle_params`  
*Referenced by:* `commands/submit-job/model_wrapper.sh`  
*References:* NA

    │       ├── tail.R

*Description:* Code snippet to append to the model script that asserts that a `candle_value_to_return` variable is defined in the model script and creates a file called `candle_value_to_return.json` that dumps the relevant result into a JSON object of the `history.history` form  
*Referenced by:* `commands/submit-job/model_wrapper.sh`  
*References:* NA

    │       ├── head.sh

*Description:* Code snippet to prepend to the model script that loads the current hyperparameter set from the `params.json` file written in `candle_compliant_wrapper.py` into a function named `candle_get_param()`  
*Referenced by:* `commands/submit-job/model_wrapper.sh`  
*References:* `commands/submit-job/get_param.py`

    │       ├── get_param.py

*Description:* Python script to assist the model script in getting hyperparameter values from the `params.json` file written in `candle_compliant_wrapper.py`  
*Referenced by:* `commands/submit-job/head.sh`  
*References:* NA

    │       └── tail.sh

*Description:* Code snippet to append to the model script that asserts that a `$candle_value_to_return` variable is defined in the model script and creates a file called `candle_value_to_return.json` that dumps the relevant result into a JSON object of the `history.history` form  
*Referenced by:* `commands/submit-job/model_wrapper.sh`  
*References:* NA

    │       ├── dummy_cfg-prm.sh

*Description:* This is a dummy `cfg-prm.sh` of the typical format in Supervisor that sets the five variables needed in Supervisor for the mlrMBO workflow to values that are set elsewhere in the `candle_wrappers` workflow  
*Referenced by:* `commands/submit-job/run_workflows.sh` (indirectly through Supervisor)  
*References:* NA

    │   └── aggregate-results

*DIRECTORY:* Contains the command used to collect the results of the model run on each hyperparameter set alongside the corresponding HP set itself

    │       └── command_script.sh

*Description:* Main command script that outputs to a CSV file the hyperparameter list and corresponding result from all hyperparameter sets of the CANDLE run  
*Referenced by:* `bin/candle`  
*References:* `utilities.sh`

    ├── examples

*DIRECTORY:* Contains subdirectories corresponding to templates that can be imported and optionally edited in order to run `candle`

    │   ├── grid

*DIRECTORY:* Contains an example model script and input file for a grid search

    │   │   ├── grid_example.in

*Description:* Input file for running a sample grid search on a model script written in Python  
*Referenced by:* `commands/submit-job/command_script.sh`  
*References:* NA

    │   │   └── mnist_mlp.py

*Description:* Sample model script that trains a simple deep neural network on the MNIST dataset  
*Referenced by:* `commands/submit-job/model_wrapper.sh`  
*References:* NA

    │   ├── bayesian

*DIRECTORY:* Contains an example model script and input file for a Bayesian search

    │   │   ├── bayesian_example.in

*Description:* Input file for running a sample Bayesian search on a model script written in Python  
*Referenced by:* `commands/submit-job/command_script.sh`  
*References:* NA

    │   │   └── nt3_baseline_keras2.py

*Description:* Sample model script from a version of the NT3 Pilot 1 benchmark  
*Referenced by:* `commands/submit-job/model_wrapper.sh`  
*References:* NA

    │   └── r

*DIRECTORY:* Contains an example model script written in `R` and input file for a grid search

    │       └── r_example.in

*Description:* Input file for running a sample grid search on a model script written in R  
*Referenced by:* `commands/submit-job/command_script.sh`  
*References:* NA

    │       ├── feature-reduction.R

*Description:* Sample model script written in `R` by Ravi Ravichandran that performs simple feature reduction on the triple negative breast cancer dataset  
*Referenced by:* `commands/submit-job/model_wrapper.sh`  
*References:* NA

    │   ├── bash

*DIRECTORY:* Contains an example model script written in `bash` and input file for a grid search

    │   │   ├── bash_example.in

*Description:* Input file for running a sample grid search on a model script written in Bash  
*Referenced by:* `commands/submit-job/command_script.sh`  
*References:* NA

    │   │   └── model_script.sh

*Description:* Sample model script written in `bash` by George Zaki that executes a simple MNIST model  
*Referenced by:* `commands/submit-job/model_wrapper.sh`  
*References:* `examples/bash/mnist_mlp.py`

    │   │   ├── mnist_mlp.py

*Description:* `python` model exemplifying George Zaki's `bash` model script functionality  
*Referenced by:* `examples/bash/model_script.sh`  
*References:* NA

    ├── repository_organization.md

*Description:* The document that you are reading that describes every file in the `candle_wrappers` repository and defines the relationships between all files  
*Referenced by:* `README.md`  
*References:* NA

    16 directories
