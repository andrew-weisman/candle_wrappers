# This file should follow the current standard CANDLE-compliance procedure (what I'm calling to be "canonically CANDLE-compliant" to contrast it with the easier "CANDLE-compliance" that these wrapper scripts enable)

def initialize_parameters():

    # Import relevant libraries
    import os, candle # note "candle" is put in the path by the lmod module file

    # Set variables from environment variables
    dl_backend = os.getenv('CANDLE_DL_BACKEND') # set in input file (and checked and exported in preprocess.py)
    default_model = os.getenv('CANDLE_DEFAULT_MODEL_FILE') # set in submit-job/command_script.sh
    desc = os.getenv('CANDLE_MODEL_DESCRIPTION') # set in run_workflows.sh
    prog_name = os.getenv('CANDLE_PROG_NAME') # set in run_workflows.sh

    # Build benchmark object
    myBmk = candle.Benchmark(os.path.dirname(os.path.realpath(__file__)), default_model, dl_backend, prog=prog_name, desc=desc)

    # Initialize parameters
    gParameters = candle.finalize_parameters(myBmk)

    return(gParameters)


def run(params):

    # Define the dummy history class; defining it here to keep this file aligned with the standard CANDLE-compliance procedure
    class HistoryDummy:
        def __init__(self, mynum):
            self.history = {'val_loss': [mynum], 'val_corr': [mynum], 'val_dice_coef': [mynum]}

    # Reformat a value that doesn't have an analogous field in the JSON format
    params['data_type'] = str(params['data_type'])

    # Write the current set of hyperparameters to a JSON file, and also print them to the screen
    print('Params:', params)
    import json
    with open('params.json', 'w') as outfile:
        json.dump(params, outfile)

    # Run the wrapper script model_wrapper.sh where the environment is defined and the model (whether in Python or R) is called
    with open('subprocess_out_and_err.txt', 'w') as myfile:
        import subprocess, os
        print('Starting run of model_wrapper.sh from candle_compliant_wrapper.py...')
        subprocess.run(['bash', os.getenv('CANDLE')+'/wrappers/commands/submit-job/model_wrapper.sh'], stdout=myfile, stderr=subprocess.STDOUT)
        print('Finished run of model_wrapper.sh from candle_compliant_wrapper.py')

    # Read in the history.history dictionary containing the result from the JSON file created by the model
    history = HistoryDummy(4444)
    import json
    with open('candle_value_to_return.json') as infile:
        history.history = json.load(infile)
    return(history)


def main():
    """
    CANDLE-compliant script that runs the model script by calling a Bash script (model_wrapper.sh) that wraps the model script and calls it.

    Note: The advantage of doing is this way as opposed to just importing the model script is that models written in other langugages (such as R and even Bash) can be used with CANDLE. Also, less work needs to be done to comply with the new CANDLE-compliance since we further wrap the user's model with heads/tails that they'd otherwise have to do themselves.

    Assumptions:
      (1) candle module has been loaded
      (2) the candle program has been called normally (via e.g. candle submit-job ...)
    """
    params = initialize_parameters()
    run(params)


if __name__ == '__main__':
    main()
    import os
    if os.getenv('CANDLE_DL_BACKEND') == 'keras': # it could instead be "pytorch"
        from tensorflow.keras import backend as K
        try:
            K.clear_session()
        except AttributeError: # theano does not have this function
            pass
