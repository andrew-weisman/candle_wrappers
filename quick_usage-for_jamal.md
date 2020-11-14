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
# Enter a possibly empty directory on the alpine FS
cd /gpfs/alpine/med106/scratch/weismana/notebook/2020-11-13/testing_candle_installation/grid3

# Pre-fetch the MNIST data since Summit compute nodes can't access the Internet (this obviously has nothing to do with the wrapper scripts)
mkdir candle_generated_files
/gpfs/alpine/world-shared/med106/sw/condaenv-200408/bin/python -c "from keras.datasets import mnist; import os; (x_train, y_train), (x_test, y_test) = mnist.load_data(os.path.join(os.getcwd(), 'candle_generated_files', 'mnist.npz'))"

# Import the grid example specialized to Summit (two files will be copied over)
candle import-template grid-summit

# Submit the job to the queue
candle submit-job grid_example.in
```
