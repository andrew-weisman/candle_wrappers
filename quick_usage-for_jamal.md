# Quick usage instructions for Jamal

**Assumption**: You're logged in to Summit.

## Step 1: Setup

```bash
# Load the CANDLE module; do the following for the time being in lieu of "module load candle", as Summit staff are currently "onboarding" CANDLE as user-managed software
source /gpfs/alpine/med106/world-shared/candle/env_for_lmod-tf1.sh

# Enter a possibly empty directory that is completely outside of the Supervisor/Benchmarks repositories on the alpine FS
cd /gpfs/alpine/med106/scratch/weismana/notebook/2020-11-13/testing_candle_installation
```

## Step 2: Run sample CANDLE-compliant models

This refers to model scripts that the developers refer to as "CANDLE-compliant" as usual (what I call "*canonically* CANDLE-compliant"). See the following notes for the changes that should be made to canonically CANDLE-compliant scripts.

### NT3 using UPF

```bash
# Import the UPF example (one file will be copied over)
candle import-template upf

# Submit the job to the queue
candle submit-job upf_example.in
```

### NT3 using mlrMBO

```bash
# Import the mlrMBO example (two files will be copied over)
candle import-template mlrmbo

# Submit the job to the queue
candle submit-job mlrmbo_example.in
```

## Step 3: Run sample **non**-CANDLE-compliant model scripts

This refers to model scripts that require bare-minimum changes to a raw model script e.g. downloaded from the Internet. (To summarize, these changes are (1) set the hyperparameters in the model script using a dictionary called `candle_params` and (2) ensure somewhere near the end of the script either the normal `history` object is defined or a metric of how well the hyperparameter set performed is returned as a number in the `candle_value_to_return` variable.)

### MNIST using UPF

```bash
# Pre-fetch the MNIST data since Summit compute nodes can't access the Internet (this obviously has nothing to do with the wrapper scripts)
mkdir candle_generated_files
/gpfs/alpine/world-shared/med106/sw/condaenv-200408/bin/python -c "from keras.datasets import mnist; import os; (x_train, y_train), (x_test, y_test) = mnist.load_data(os.path.join(os.getcwd(), 'candle_generated_files', 'mnist.npz'))"

# Import the grid example (two files will be copied over)
candle import-template grid

# Submit the job to the queue
candle submit-job grid_example.in
```

### NT3 using mlrMBO

```bash
# Import the bayesian example (two files will be copied over)
candle import-template bayesian

# Submit the job to the queue
candle submit-job bayesian_example.in
```

## Notes

### Development workflow

1. Testing: Run the model script in interactive mode but using the keyword setting `run_workflow = 0` in the input file
1. Production: Run the model script from a login node using the default keyword setting `run_workflow = 1` in the input file

### How a canonically CANDLE-compliant model script should be modified

#### Specifically required by the wrapper scripts

```python
def initialize_parameters(default_model='nt3_default_model.txt'):

    import os # ADD THIS LINE

    # Build benchmark object
    nt3Bmk = bmk.BenchmarkNT3(
        bmk.file_path,
        # default_model, # ORIGINAL LINE
        os.getenv('CANDLE_DEFAULT_MODEL_FILE'), # NEW LINE
        'keras',
        prog='nt3_baseline',
        desc='1D CNN to classify RNA sequence data in normal or tumor classes')

    # Initialize parameters
    gParameters = candle.finalize_parameters(nt3Bmk)

    return gParameters
```

#### Nothing to do with the wrapper scripts

You may need to add `K.clear_session()` prior to, say, `model = Sequential()`. Otherwise, once the same rank runs a model script a *second* time, we get a strange `InvalidArgumentError` error that kills Supervisor (see the comments in `/gpfs/alpine/med106/world-shared/candle/2020-11-11/checkouts/Benchmarks/Pilot1/NT3/nt3_candle_wrappers_baseline_keras2.py` for more details). It is wholly possible that this is a bug that has gotten fixed in subsequent versions of Keras/Tensorflow.

In addition, if you, say, pull a Benchmark model script out of the `Benchmarks` repository into your own separate directory, you may need to add a line like `sys.path.append(os.path.join(os.getenv('CANDLE'), 'Benchmarks', 'Pilot1', 'NT3'))`. This is demonstrated in the "NT3 using mlrMBO" section of Step 2.
