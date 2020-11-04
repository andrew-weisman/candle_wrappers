# How to use the files in this `candle_wrappers` repository

This repository contains:

1. files needed to set up CANDLE as a central installation (so that you can for example do `module load candle`; "Setup" section below)
1. wrapper scripts around the CANDLE codebase that can be used for running the workflows ("Usage" section below)

## Setup

See `README-<SITE>.md` for the relevant site (e.g., [README-biowulf.md](./README-biowulf.md), [README-summit.md](./README-summit.md)) in order to set up CANDLE as a central installation.

## Usage

Once setup is complete, run

* `module load candle` (or, e.g., `module load candle/dev`, whichever has been set up)
* `candle` (or `candle help`)

in order to output usage information to the screen.

## Notes

### Site-specific settings

All site-specific information and settings in `candle_wrappers` should be located in only:

1. the site-specific READMEs (e.g., [README-biowulf.md](./README-biowulf.md) or [README-summit.md](./README-summit.md))
1. the file [site-specific_settings.sh](./site-specific_settings.sh)
1. the `export_bash_variables()` function in the file [preprocess.py](./candle_commands/submit-job/preprocess.py)

### How to add a new keyword

1. Add the keyword and its default value (or else `None`, which indicates that it's required) in `site-specific_settings.sh` in all `$SITE`s to which the keyword applies
1. Add a block in the `check_keywords()` function of `preprocess.py` that checks the keyword
1. Process and/or export the keyword in the `export_bash_variables()` function of `preprocess.py` for all `$SITE`s to which the keyword applies

#### Keyword notes

* Note that *all* required or optional keywords based on all the values of the `$CANDLE_POSSIBLE_KEYWORDS_AND_DEFAULTS` variable in `site-specific_settings.sh` should be checked in the `check_keywords()` function of `preprocess.py`.
* All keywords present in the input file will be prepended with `CANDLE_KEYWORD_` and exported to the environment in `submit-job/command_script.sh`. Thus, all *required* keywords will definitely be present in the environment as `CANDLE_KEYWORD_<KEYWORD>`. Since they will be checked in the `check_keywords()` function of `preprocess.py` as specified above, then, if desired, we can safely use the variable `CANDLE_KEYWORD_<KEYWORD>` in subsequent scripts.
* On the other hand, *optional* keywords will not necessarily be present in the environment as `CANDLE_KEYWORD_<KEYWORD>`, but as they will be processed for the `$SITE`s to which they apply, they must be present as a key in the `checked_keywords` dictionary in `preprocess.py`. Thus, they can be accessed in the `export_bash_variables()` function in `preprocess.py` to be either processed or exported. And as they will have essentially been processed in `preprocess.py`, it makes sense to export them, if export is desired, with the `CANDLE_` prefix as opposed to `CANDLE_KEYWORD_`, which we may want to reserve for keywords that can reliably be passed directly from the input file.
* Basically, required keywords, such as `model_script`, `workflow`, and `project`, should be referenced in other files capitalized and prepended by "CANDLE_KEYWORD_". While these required keywords are checked in `preprocess.py`, they do not need to be subsequently exported in the `export_bash_variables()` function. On the other hand, optional variables, since they need to be exported in `export_bash_variables()` since they are not necessarily set in the input file, should be referenced in other files capitalized and prepended by "CANDLE_" only.

### How to add new workflows

1. Add to the `valid_workflows` variable in the `check_keywords()` function in `$CANDLE/wrappers/candle_commands/submit-job/preprocess.py`
1. Add to the two blocks with comments "# ADD HERE WHEN ADDING NEW WORKFLOWS!!" in `$CANDLE/wrappers/candle_commands/submit-job/run_workflows.sh`
1. Test the new workflow functionality
