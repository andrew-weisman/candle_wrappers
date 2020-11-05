# ASSUMPTIONS: None

import json, sys, argparse, os

candle_hyperparam_env = "candle_params"

def candle_get_param(name, param_file):
    """
        Return the value of a CANDLE hyperprarameter
        Argument:
            name: string
                The hyperparameter name
            param_fle: filename
                The CANDLE hyperparameter file

        Returns string
            The hyperparameter value
    """
    param_file = os.path.abspath(param_file)
    if not os.path.exists(param_file):
        raise Exception("ERROR: The hyperparameter file {0} does not exist".format(param_file))
    with open(param_file) as infile:
        hyperparams = json.load(infile)
        try:
            return hyperparams[name]
        except Exception as e:
            raise Exception('ERROR: The file "{0}" does not contain the hyperparameter:"{1}"'.format(param_file, name))  


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Return CANDLE hyperparameter value')
    parser.add_argument('hyperparameter', help='The name of the hyperparameter to be returned')
    parser.add_argument('--param_file', help='CANDLE hyperparameter file')

    args = parser.parse_args()
    if args.param_file == None:
        if os.getenv(candle_hyperparam_env) == None:
            raise Exception('ERROR: The environment variable "{0}" is not defined'.format(candle_hyperparam_env))
        else:
            param_file = os.getenv(candle_hyperparam_env)
    else:

        param_file = args.param_file
    print(candle_get_param(args.hyperparameter, param_file)) 
