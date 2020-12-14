# Documentation for the CANDLE team

## Terminology and scope

Below I call the scripts I'm describing in this document the "wrapper scripts" or "wrappers," but this still a working name. "interface" may be a viable alternative. These scripts refer to contents of the entire [wrappers GitHub repository](https://github.com/andrew-weisman/candle_wrappers), and I named them as such because the whole point was to add functionality to CANDLE while "wrapping" around the current Supervisor code, leaving it as untouched as possible so that it wouldn't interfere in any way with how people currently run CANDLE.

The wrapper scripts contain code that (1) helps to set up and test these scripts alongside new clones of the [Supervisor](https://github.com/ECP-CANDLE/Supervisor/tree/develop) and [Benchmarks](https://github.com/ECP-CANDLE/Benchmarks/tree/develop) CANDLE repos, and (2) enables the running of CANDLE by accessing a central installation of it.

## Overview of wrapper scripts functionality

### For users

* **Run CANDLE as a central installation**. E.g., instead of cloning the Supervisor and Benchmarks repos as usual and then running a Supervisor workflow directly in the `Supervisor/workflows/<WORKFLOW>/test` directory, you would go to any arbitrary directory on the filesystem, create or edit an "input file" with workflow-specific instructions, and call CANDLE with the input file as an argument. This is similar to how other large HPC-enabled software packages are run, e.g., software for calculating electronic structure
* **Edit only a single text input file** to modify *everything* you would need to set in order to run a job, e.g., workflow type, hyperparameter space, number of workers, walltime, "default model" settings, etc.
* **Minimally modify a bare model script**, e.g., no need to add `initialize_parameters()` and `run()` functions (whose content occassionally changes) to a new model that you'd like to run using CANDLE. The wrapper scripts still work for canonically CANDLE-compliant model scripts such as the already-written main `.py` files used to run benchmarks
  * An additional benefit to using the minimal modification procedure is that the output of the model using each hyperparameter set is put in its own file, `subprocess_out_and_err.txt`
* **Run model scripts written in other languages** such as `R` and `bash`; minimal additions to the wrapper scripts are needed for adding additional language support
* **Perform a consistent workflow for testing and running model scripts**, e.g., (1) using `candle submit-job <INPUT-FILE>` with the input file keyword setting of `run_workflow=0` on an interactive node for testing modifications to a model script and (2) also using `candle submit-job <INPUT-FILE>` this time with the default keyword setting of `run_workflow=1` on a login node for running the model using CANDLE. As long as the wrapper scripts are set up properly and your model script runs successfully using `run_workflow=0`, you can be pretty confident that submitting the job using `run_workflow=1` will pick up and run without dying

### For developers

* **Modify only a single file ([`candle_compliant_wrapper.py`](https://github.com/andrew-weisman/candle_wrappers/blob/master/commands/submit-job/candle_compliant_wrapper.py)) whenever the CANDLE-compliance procedure changes**, e.g., if the benchmarks used the minimal modification to the main `.py` files rather than the traditional CANDLE-compliance procedure, there would be no need to update every benchmark whenever the CANDLE-compliance procedure changed
* **Edit only a single file ([`preprocess.py`](https://github.com/andrew-weisman/candle_wrappers/blob/master/commands/submit-job/preprocess.py)) in order to make system-specific changes** such as custom modification to the `$TURBINE_LAUNCH_OPTIONS` variable; no need to edit each Supervisor workflow's `workflow.sh` file
