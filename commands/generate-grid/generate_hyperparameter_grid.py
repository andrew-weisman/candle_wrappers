# This script outputs to the screen the entire space of the inputted variables, producing a file suitable to be an unrolled parameter file.
# Run this script without any arguments in order to see its usage and an example.

# Import relevant modules
import numpy as np
import sys
import os

# Obtain the arguments to the script call
arguments = sys.argv[1:]

# Make sure at least one set of variables is specified
if len(arguments) == 0:
    print('')
    print('Call this script with one or more strings of two-element lists containing (1) the variable name and (2) the values, which must be a list. Double-quote each string argument.')
    print('')
    print('A sample call would be:')
    print('')
    print('  module load python/3.7')
    print('  python $CANDLE/wrappers/commands/generate-grid/generate_hyperparameter_grid.py "[\'john\',np.arange(5,15,2)]" "[\'single_num\',[4]]" "[\'letter\',[\'x\',\'y\',\'z\']]" "[\'arr\',[[2,2],None,[2,2,2],[2,2,2,2]]]" "[\'smith\',np.arange(-1,1,0.2)]"')
    print('')
    exit()

# Create a list of the variable settings
variables = []
for argument in arguments:
    variables.append(eval(argument))

# Define a function for determining whether an object is a number
# Modified from https://stackoverflow.com/questions/354038/how-do-i-check-if-a-string-is-a-number-float
def is_number(obj):
    try:
        float(str(obj))
        return True
    except ValueError:
        return False
        
# Define a function to add to a string a name/value pair of a particular datatype
def add_to_set(set_str_base, name, value, dtype):

    # If the current variable is a string, wrap it in double quotes
    wrap_char = ''
    if isinstance(value, str):
        wrap_char = '"'
        
    # Define the string to be formatted
    tmp_str = '{}, "{}": {}{:' + dtype + '}{}'

    python_types = (False, True, None)
    json_types = ("false", "true", "null")
    comparisons = [value is x for x in python_types]
    #if value in python_types:
    if any(comparisons):
        #value = json_types[python_types.index(value)]
        value = json_types[comparisons.index(True)]

    # Return the formatted string
    return(tmp_str.format(set_str_base, name, wrap_char, value, wrap_char))

# Define a function to output each set of hyperparameters
def print_str(set_str, nhpset, f):
    nhpset += 1
    #print('{{"id": "hpset_{:05}"{}}}'.format(nhpset, set_str))
    f.write('{{"id": "hpset_{:05}"{}}}\n'.format(nhpset, set_str))
    return(nhpset)

# Define a recursive function that when initialized creates an unrolled parameter file
def make_set(variables, set_str_base, ivar, nhpset, f):

    # Get the current variable name and its set of values
    name = variables[ivar][0]
    values = variables[ivar][1]

    # If the values are numbers, determine whether they are integers or floats
    dtype = ''
    if is_number(values[0]):
        if ( np.round(values) == values ).all():
            dtype = 'd' # integer
            values = np.array(values, dtype='int32')
        else:
            dtype = 'f' # float

    # For every value of the current variable...
    for value in values:

        # Add the name/value pair to the string describing the current hyperparameter set
        set_str = add_to_set(set_str_base, name, value, dtype)

        # If we're not on the last variable...
        if ivar < len(variables)-1:

            # Call this function again setting set_str-->set_str_base, ivar+1-->ivar, updated current hyperparameter set index (nhpset), and the same "variables" value
            nhpset = make_set(variables, set_str, ivar+1, nhpset, f)

        else:

            # Otherwise, print the current hyperparameter set with a unique ID
            nhpset = print_str(set_str, nhpset, f)

    # Return the current hyperparameter set index
    return(nhpset)


# Call the make_set() function with initialized settings
with open(os.path.join(os.getenv('CANDLE_SUBMISSION_DIR'), 'candle_generated_files', 'hyperparameter_grid.txt'), 'w') as f:
    make_set(variables, '', 0, 0, f)
