# candle_wrappers

This repository contains the files needed to set up CANDLE as a central installation (so that you can for example do `module load candle`) and will contain wrapper scripts around the CANDLE codebase that can be used for running the workflows.

All site-specific information and settings should be located in only:

1. the site-specific READMEs (e.g., [README-biowulf.md](./README-biowulf.md) or [README-summit.md](./README-summit.md))
1. the file [site-specific_settings.sh](./site-specific_settings.sh)
1. the `export_bash_variables()` function in the file [preprocess.py](./candle_commands/submit-job/preprocess.py)

After completing the setup steps outlined in [README-biowulf.md](./README-biowulf.md) or [README-summit.md](./README-summit.md), you should be able to run `module load candle` and get started running CANDLE by running `candle` without arguments (or running `candle help`).
