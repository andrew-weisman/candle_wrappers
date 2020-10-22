# This file should follow the current standard CANDLE-compliance procedure

# # FROM UNO:
# def initialize_parameters(default_model='uno_default_model.txt'):

#     # Build benchmark object
#     unoBmk = benchmark.BenchmarkUno(benchmark.file_path, default_model, 'keras',
#                                     prog='uno_baseline', desc='Build neural network based models to predict tumor response to single and paired drugs.')

#     # Initialize parameters
#     gParameters = candle.finalize_parameters(unoBmk)
#     # benchmark.logger.info('Params: {}'.format(gParameters))

#     return gParameters

# FROM TC1:
# def initialize_parameters(default_model='tc1_default_model.txt'):

    # Build benchmark object
    # tc1Bmk = bmk.BenchmarkTC1(file_path, default_model, 'keras', prog='tc1_baseline', desc='Multi-task (DNN) for data extraction from clinical reports - Pilot 3 Benchmark 1')

    # Initialize parameters
    # gParameters = candle.finalize_parameters(tc1Bmk)

    # return gParameters

# FROM NT3:
# def initialize_parameters(default_model='nt3_default_model.txt'):

    # Build benchmark object
    # nt3Bmk = bmk.BenchmarkNT3(bmk.file_path, default_model, 'keras', prog='nt3_baseline', desc='1D CNN to classify RNA sequence data in normal or tumor classes')

    # Initialize parameters
    # gParameters = candle.finalize_parameters(nt3Bmk)

    # return gParameters

# NEW INITIALIZE_PARAMETERS() (starting from UNO):
def initialize_parameters():

    import os, candle # note "candle" is put in the path by the lmod module file

    default_model = os.getenv('CANDLE_DEFAULT_MODEL_FILE') # set in command_script.sh
    desc = os.getenv('CANDLE_MODEL_DESCRIPTION') # set in run_workflows.sh
    dl_backend = os.getenv('CANDLE_DL_BACKEND') # set in submission script (and checked in preprocess.py)
    prog_name = os.getenv('CANDLE_PROG_NAME') # set in run_workflows.sh

    # Ensure the deep learning backend can be imported, and, for the __main__ block at the end, have keras imported already
    try:
        if dl_backend == 'keras':
            import keras
        elif dl_backend == 'pytorch':
            import torch
    except ImportError:
        print('ERROR: Deep learning backend "{}" cannot be imported'.format(dl_backend))
        exit(1)
    print('NOTE: Successfully loaded deep learning backend "{}"'.format(dl_backend))

    # Build benchmark object
    myBmk = candle.Benchmark(os.path.dirname(os.path.realpath(__file__)), default_model, dl_backend, prog=prog_name, desc=desc)

    # Initialize parameters
    gParameters = candle.finalize_parameters(myBmk)

    return(gParameters)


# def initialize_parameters():

    # Import needed environment variables
    # import os
    # candle_dir = os.getenv("CANDLE")
    # default_model = os.getenv("DEFAULT_PARAMS_FILE")
    # dl_backend = os.getenv("DL_BACKEND") # should be either keras or pytorch

    # This block is needed so that "import candle" works
    # import sys
    # sys.path.append(candle_dir+'/Benchmarks/common')
    # if dl_backend == 'keras':
    #     import keras
    # elif dl_backend == 'pytorch':
    #     import torch
    # else:
    #     print('ERROR: Backend {} is not supported (DL_BACKEND must be exported to "keras" or "pytorch" in submission script)'.format(dl_backend))
    #     exit()
    # print('Loaded {} backend'.format(dl_backend))

    # Instantiate the Benchmark class (the values of the prog and desc parameters don't really matter)
    # import candle
    # mymodel_common = candle.Benchmark(os.path.dirname(os.path.realpath(__file__)), default_model, dl_backend, prog='myprogram', desc='My CANDLE example')

    # Read the parameters (in a dictionary format) pointed to by the environment variable DEFAULT_PARAMS_FILE
    # hyperparams = candle.finalize_parameters(mymodel_common)

    # Return this dictionary of parameters
    # return(hyperparams)


def run(params):

    print('Params:', params)


def main():
    params = initialize_parameters()
    run(params)


if __name__ == '__main__':
    main()
    if dl_backend == 'keras': # it could instead be "pytorch"
        from tensorflow.keras import backend as K
        try:
            K.clear_session()
        except AttributeError: # theano does not have this function
            pass

# if __name__ == '__main__':
    # main()
    # if K.backend() == 'tensorflow':
        # K.clear_session()

# if __name__ == '__main__':
    # main()
    # try:
        # K.clear_session()
    # except AttributeError:      # theano does not have this function
        # pass



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
