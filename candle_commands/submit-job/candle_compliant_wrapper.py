# This file should follow the current standard CANDLE-compliance procedure

def initialize_parameters():

    # Import needed environment variables
    import os
    candle_dir = os.getenv("CANDLE")
    default_model = os.getenv("DEFAULT_PARAMS_FILE")
    dl_backend = os.getenv("DL_BACKEND") # should be either keras or pytorch

    # This block is needed so that "import candle" works
    import sys
    sys.path.append(candle_dir+'/Benchmarks/common')
    if dl_backend == 'keras':
        import keras
    elif dl_backend == 'pytorch':
        import torch
    else:
        print('ERROR: Backend {} is not supported (DL_BACKEND must be exported to "keras" or "pytorch" in submission script)'.format(dl_backend))
        exit()
    print('Loaded {} backend'.format(dl_backend))

    # Instantiate the Benchmark class (the values of the prog and desc parameters don't really matter)
    import candle
    mymodel_common = candle.Benchmark(os.path.dirname(os.path.realpath(__file__)), default_model, dl_backend, prog='myprogram', desc='My CANDLE example')

    # Read the parameters (in a dictionary format) pointed to by the environment variable DEFAULT_PARAMS_FILE
    hyperparams = candle.finalize_parameters(mymodel_common)

    # Return this dictionary of parameters
    return(hyperparams)


def run(hyperparams):

    # Define the dummy history class; defining it here to keep this file aligned with the standard CANDLE-compliance procedure
    class HistoryDummy:
        def __init__(self, mynum):
            self.history = {'val_loss': [mynum], 'val_corr': [mynum], 'val_dice_coef': [mynum]}

    # Reformat a value that doesn't have an analogous field in the JSON format
    #hyperparams['datatype'] = str(hyperparams['datatype'])
    hyperparams['data_type'] = str(hyperparams['data_type'])

    # Write the current set of hyperparameters to a JSON file
    import json
    with open('params.json', 'w') as outfile:
        json.dump(hyperparams, outfile)

    # Run the wrapper script model_wrapper.sh where the environment is defined and the model (whether in Python or R) is called
    myfile = open('subprocess_out_and_err.txt','w')
    import subprocess, os
    print('Starting run of model_wrapper.sh from candle_compliant_wrapper.py...')
    subprocess.run(['bash', os.getenv("CANDLE")+'/wrappers/templates/scripts/model_wrapper.sh'], stdout=myfile, stderr=subprocess.STDOUT)
    print('Finished run of model_wrapper.sh from candle_compliant_wrapper.py')
    myfile.close()

    # Read in the history.history dictionary containing the result from the JSON file created by the model
    history = HistoryDummy(4444)
    import json
    with open('val_to_return.json') as infile:
        history.history = json.load(infile)
    return(history)


def main():
    hyperparams = initialize_parameters()
    run(hyperparams)


if __name__ == '__main__':
    main()
    import os
    if os.getenv("DL_BACKEND") == 'keras':
        try:
            from keras import backend as K
            K.clear_session()
        except AttributeError:
            pass
