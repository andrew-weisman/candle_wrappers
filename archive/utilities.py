def are_functions_in_module(my_function_str_list, my_module_full_path):
    '''
    Determine whether all the functions in my_function_str_list are present in the model script specified by my_module_full_path.

    The problem with this is that if the model script is a pure script, then importing it in order to examine its functions will actually run it!
    '''
    try:
        with open(my_module_full_path):
            import os, importlib, sys
            dirname = os.path.dirname(my_module_full_path)
            basename = os.path.basename(my_module_full_path)
            if dirname not in sys.path:
                sys.path.append(dirname)
            my_module = importlib.import_module(basename.split('.py')[0])
            if len(set(dir(my_module)) - set(my_function_str_list)) == len(set(dir(my_module))) - len(set(my_function_str_list)):
                return(0)
            else:
                return(1)
    except IOError:
        print('ERROR: The file "{}" cannot be opened for reading'.format(my_module_full_path))
        exit(2)


def main():
    '''
    When run as a script whose argument runs a function in this module such as the are_functions_in_module() function above, then run that function and return what we tell it to return.

    Example usage in a Bash script (run_workflows.sh): python "$CANDLE/wrappers/utilities.py" "are_functions_in_module(['initialize_parameters', 'run'], '$CANDLE_KEYWORD_MODEL_SCRIPT')"
    '''
    import sys
    exit(eval(sys.argv[1]))


if __name__ == '__main__':
    main()
