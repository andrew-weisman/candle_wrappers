# Repository organization

    .
    ├── README.md

*Description:* Starting place for learning how to use the files in this `candle_wrappers` repository, including setup/usage instructions and general notes. **Start here!**  
*Referenced by:* NA; top-level; rendered by default when going to [the current repository](https://github.com/andrew-weisman/candle_wrappers) on GitHub  
*References:* `setup-$SITE.md`

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
*Referenced by:* `setup.sh`, `utilities.sh`  
*References:* NA

    └── utilities.sh

*Description:* Contains various utility functions for use in Bash scripts, e.g., correctly loading and unloading the Python or R environments either by `lmod` or by adding/subtracting from the path; creating a `candle_generated_files` directory in the submission directory  
*Referenced by:* `setup.sh`  
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
*References:* `myextension.tcl`

    │   ├── myextension.tcl

*Description:* Tcl script that defines a function that doubles an inputted number and waits five seconds  
*Referenced by:* `myextension.swift`  
*References:* `pkgIndex.tcl`

    │   └── pkgIndex.tcl

*Description:* Package index for `myextension.tcl`  
*Referenced by:* `myextension.tcl`  
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
    │   └── candle
    ├── commands
    │   ├── aggregate-results
    │   │   └── command_script.sh
    │   ├── generate-grid
    │   │   ├── command_script.sh
    │   │   └── generate_hyperparameter_grid.py
    │   ├── import-template
    │   │   └── command_script.sh
    │   └── submit-job
    │       ├── candle_compliant_wrapper.py
    │       ├── command_script.sh
    │       ├── dummy_cfg-prm.sh
    │       ├── get_param.py
    │       ├── head.py
    │       ├── head.R
    │       ├── head.sh
    │       ├── make_json_from_submit_params.sh
    │       ├── model_wrapper.sh
    │       ├── preprocess.py
    │       ├── restart.py
    │       ├── run_candle_model_standalone.sh.m4
    │       ├── run_workflows.sh
    │       ├── tail.py
    │       ├── tail.R
    │       └── tail.sh
    ├── examples
    │   ├── bash
    │   │   ├── bash_example.in
    │   │   ├── mnist_mlp.py
    │   │   └── model_script.sh
    │   ├── bayesian
    │   │   ├── bayesian_example.in
    │   │   └── nt3_baseline_keras2.py
    │   ├── grid
    │   │   ├── grid_example.in
    │   │   └── mnist_mlp.py
    │   └── r
    │       ├── feature-reduction.R
    │       └── r_example.in
    ├── repository_organization.md
    ├── utilities.py

    16 directories
