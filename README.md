# How to use the files in this `candle_wrappers` repository

This repository contains:

1. Files needed to set up CANDLE as a central installation (so that you can run e.g. `module load candle`; "Setup" section [below](#Setup))
1. Wrapper scripts around the CANDLE Supervisor that can be used for running the workflows on an arbitrary model ("Usage" section [below](#Usage))

## Setup

See `setup-<SITE>.md` for the relevant site (e.g., [setup-biowulf.md](./setup-biowulf.md), [setup-summit.md](./setup-summit.md)) in order to set up CANDLE as a central installation at that site.

## Usage

Once setup is complete, run

* `module load candle` (or, e.g., `module load candle/dev`, whichever has been set up)
* `candle` (or `candle help`)

in order to output usage information to the screen. There are four commands (`import-template`, `generate-grid`, `submit-job`, `aggregate-results`) to the `candle` program that can be run.

## Notes

### Miscellaneous notes

* Each of the four `candle` commands has its own directory in the `commands` folder of this repository. The primary thing run when a command is called is the file `commands/<COMMAND>/command_script.sh`, which is the driver script for all other files in the `commands/<COMMAND>` directory.
* Keywords and workflows, discussed below, only apply to the `submit-job` command to `candle` and refer to settings in the `&control` section of the input file (a `.in` file). The `submit-job` command is the only `candle` command that utilizes an input file.
* See the file `repository_organization.md` for an overview of all the files in this repository, as well as the relationships between files.

### Site-specific settings

All site-specific information and settings in `candle_wrappers` should be located in **only**:

1. the site-specific READMEs (e.g., [setup-biowulf.md](./setup-biowulf.md) or [setup-summit.md](./setup-summit.md))
1. the file [site-specific_settings.sh](./site-specific_settings.sh)
1. the `export_bash_variables()` function in [preprocess.py](./commands/submit-job/preprocess.py)

### How to add a new keyword

1. Add the keyword and its default value (or else `None`, which indicates that it's required) in `site-specific_settings.sh` in all `$SITE`s to which the keyword applies
1. Add a block in the `check_keywords()` function of `preprocess.py` that checks the keyword
1. Process and/or export the keyword in the `export_bash_variables()` function of `preprocess.py` for all `$SITE`s to which the keyword applies

#### Keyword notes

* Note that *all* required or optional keywords based on the keys in the `$CANDLE_POSSIBLE_KEYWORDS_AND_DEFAULTS` variable in `site-specific_settings.sh` should be checked in the `check_keywords()` function of `preprocess.py`.
* All keywords present in the input file will be prepended with `CANDLE_KEYWORD_` and exported to the environment in `commands/submit-job/command_script.sh`. Thus, all *required* keywords will definitely be present in the environment as `$CANDLE_KEYWORD_<KEYWORD>`. Since they will be checked in the `check_keywords()` function of `preprocess.py` as specified above, then, if desired, we can safely use the variable `$CANDLE_KEYWORD_<KEYWORD>` in subsequent scripts.
* On the other hand, *optional* keywords will not necessarily be present in the environment as `$CANDLE_KEYWORD_<KEYWORD>`, but since they will be processed for the `$SITE`s to which they apply, they must be present as a key in the `checked_keywords` dictionary in `preprocess.py`. Thus, they can be accessed in the `export_bash_variables()` function in `preprocess.py` to be either processed or exported. And as they will have essentially been processed in `preprocess.py`, it makes sense to export them, if export is desired, with the `CANDLE_` prefix as opposed to `CANDLE_KEYWORD_`, which we want to reserve for keywords that have been specified in the input file.
* In summary, required keywords, such as `model_script`, `workflow`, and `project`, should be referenced in other files capitalized and prepended by `CANDLE_KEYWORD_`. While these required keywords are checked in `preprocess.py`, they do not need to be subsequently exported in the `export_bash_variables()` function. On the other hand, optional variables, since they need to be exported in `export_bash_variables()` since they are not necessarily set in the input file, should be referenced in other files capitalized and prepended by `CANDLE_` only.

### How to add new workflows

1. Add to the `valid_workflows` variable in the `check_keywords()` function in `preprocess.py`
1. Add to the two blocks with comments "# ADD HERE WHEN ADDING NEW WORKFLOWS!!" in `run_workflows.sh`
