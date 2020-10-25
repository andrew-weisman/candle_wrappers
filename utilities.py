def are_functions_in_module(my_function_str_list, my_module_full_path):
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
    import sys
    exit(eval(sys.argv[1]))


if __name__ == '__main__':
    main()
