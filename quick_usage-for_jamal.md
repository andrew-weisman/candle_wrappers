# Quick usage instructions for Jamal

ASSUMPTION: You're logged in to Summit.

## Step (1): Load the CANDLE module

In lieu of `module load candle` being set up (Summit staff are working on setting up CANDLE as user-managed software), you can load the `candle` module for the time being via:

```bash
source /gpfs/alpine/med106/world-shared/candle/env_for_lmod-tf1.sh
```

## Step (2): Run an example CANDLE-compliant model

asdf

## Step (3): Run an example **non**-CANDLE-compliant model

By example:

```bash
cd /gpfs/alpine/med106/scratch/weismana/notebook/2020-11-13/testing_candle_installation/grid3 # enter a possibly empty directory on the alpine FS
candle import-template grid-summit # import the grid example specialized to Summit (two files will be copied over)
candle submit-job grid_example.in # submit the job to the queue
```
