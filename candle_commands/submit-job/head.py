# ASSUMPTIONS: In directory where params.json resides

# Import relevant modules
import sys, os, json

# ALW: On 6/29/19, moving this to model_wrapper.sh; not sure why I put it here but there may have been a reason!
# ALW: On 7/5/19, redoing this, found I did it because if it's an environment variable it gets added to sys.path too early (pretty much first-thing); doing it here appends to the path at the end!
# If it's defined in the environment, append $SUPP_PYTHONPATH to the Python path
supp_pythonpath = os.getenv('CANDLE_SUPP_PYTHONPATH')
if supp_pythonpath is not None:
    for mystr in supp_pythonpath.split(':'):
        sys.path.append(mystr)

# Load the hyperparameter dictionary stored in the JSON file params.json
with open('params.json') as infile:
    candle_params = json.load(infile)
