def check_keyword(keyword_key, possible_keywords_and_defaults, casting_func, is_valid, checked_keywords):
    """
    Check a given keyword in a robust, repeatable way.
    """

    # Import relevant library
    import os

    # If keyword_key is a possible keyword...
    if keyword_key in set(possible_keywords_and_defaults.keys()):

        # Obtain the keyword default value and from that whether it is required (if the default is None, then it must be required)
        keyword_default_value = possible_keywords_and_defaults[keyword_key]
        keyword_is_required = keyword_default_value is None

        # Load in the possible keyword value from the corresponding environment variable
        # If the variable is defined, we get a string, otherwise, we get None
        env_string = os.getenv('CANDLE_KEYWORD_'+keyword_key.upper())

        # If the keyword wasn't defined in the input file...
        if env_string is None:

            # If the keyword is required...
            if keyword_is_required:
                print('ERROR: Required keyword "{}" has not been set in the &control section of the input file'.format(keyword_key))
                exit(1)

            # If the keyword is optional...
            else:
                print('WARNING: Optional keyword "{}" has not been set in the &control section of the input file; it is being set to its default value of {}'.format(keyword_key, keyword_default_value))
                keyword_val = keyword_default_value

        # If the keyword WAS defined in the input file, then set its value to the appropriately casted, read-in value
        else:
            keyword_val = casting_func(env_string)

        # From the inputted is_valid() function, determine whether the keyword_val (whether read-in or the default value) is valid; if so...
        if is_valid(keyword_val):
            print('NOTE: Keyword "{}" has a valid value of {}'.format(keyword_key, keyword_val))
            checked_keywords[keyword_key] = keyword_val # update the running dictionary of checked keywords

        # If the keyword value is not actually valid...
        else:
            print('ERROR: Keyword "{}" has an invalid value of {}'.format(keyword_key, keyword_val))
            exit(1)

    # Return the running dictionary of checked keywords
    return(checked_keywords)


def no_validation(keyword_key):
    """
    Return a function always returning True in order to skip validation if desired.
    """
    print('WARNING: No error-checking done on "{}" keyword'.format(keyword_key))
    return(lambda keyword_val: True)


def dict_output(dict_to_output, message_to_output):
    """
    Output the contents of a dictionary in a visually appealing way.
    """

    # Get the maximum key length
    max_len = 0
    for key in dict_to_output.keys():
        if len(key) > max_len:
            max_len = len(key)

    # Construct the corresponding format string, with five spaces beyond the maximum key length
    format_str = '  {{:{}s}} {{}}'.format(max_len+5)

    # Output the desired message    
    print(message_to_output+'\n')

    # Output the dictionary key by key
    for key in dict_to_output.keys():
        print(format_str.format(key+':', dict_to_output[key]))


def check_keywords(possible_keywords_and_defaults_bash_var):
    """
    Check keywords from the input file.
    """

    # Import relevant library
    import os

    # Constants
    valid_workflows = ('grid', 'bayesian') # these are the CANDLE workflows (corresponding to upf and mlrMBO) that we've tested so far

    # Initialize the running dictionary of checked keywords
    checked_keywords = dict()

    # Obtain Python dictionary of the possible keywords and their default values
    possible_keywords_and_defaults_str = os.getenv(possible_keywords_and_defaults_bash_var) # do this normally
    #possible_keywords_and_defaults_str = "{'model_script': None, 'workflow': None, 'walltime': '00:05', 'nworkers': 1, 'project': None}" # do this just for testing
    possible_keywords_and_defaults = eval(possible_keywords_and_defaults_str)

    # Output the possible keywords and their default values
    dict_output(possible_keywords_and_defaults, 'Possible keywords and their default values:')

    # Validate the model_script keyword
    def is_valid(keyword_val):
        try:
            with open(keyword_val):
                is_valid2 = True
        except IOError:
            print('WARNING: The file "{}" from the "model_script" keyword cannot be opened for reading'.format(keyword_val))
            is_valid2 = False
        return(is_valid2)
    checked_keywords = check_keyword('model_script', possible_keywords_and_defaults, str, is_valid, checked_keywords)

    # Validate the workflow keyword
    def is_valid(keyword_val):
        if keyword_val.lower() not in valid_workflows:
            print('WARNING: The "workflow" keyword ({}) in the &control section must be one of'.format(keyword_val), valid_workflows)
            is_valid2 = False
        else:
            is_valid2 = True
        return(is_valid2)
    checked_keywords = check_keyword('workflow', possible_keywords_and_defaults, str, is_valid, checked_keywords)

    # Validate the walltime keyword
    checked_keywords = check_keyword('walltime', possible_keywords_and_defaults, str, no_validation('walltime'), checked_keywords)

    # Validate the worker_type keyword
    def is_valid(keyword_val):
        valid_worker_types = eval(os.getenv('CANDLE_VALID_WORKER_TYPES'))
        if keyword_val.lower() not in valid_worker_types:
            print('WARNING: The "worker_type" keyword ({}) in the &control section must be one of'.format(keyword_val), valid_worker_types)
            is_valid2 = False
        else:
            is_valid2 = True
        return(is_valid2)
    checked_keywords = check_keyword('worker_type', possible_keywords_and_defaults, str, is_valid, checked_keywords)

    # Validate the nworkers keyword
    def is_valid(keyword_val):
        if keyword_val < 1:
            print('WARNING: The "nworkers" keyword ({}) in the &control section must be a positive integer'.format(keyword_val))
            is_valid2 = False
        else:
            is_valid2 = True
        return(is_valid2)
    checked_keywords = check_keyword('nworkers', possible_keywords_and_defaults, int, is_valid, checked_keywords)

    # Validate the nthreads keyword
    def is_valid(keyword_val):
        if keyword_val < 1:
            print('WARNING: The "nthreads" keyword ({}) in the &control section must be a positive integer'.format(keyword_val))
            is_valid2 = False
        else:
            is_valid2 = True
        return(is_valid2)
    checked_keywords = check_keyword('nthreads', possible_keywords_and_defaults, int, is_valid, checked_keywords)

    # Validate the custom_sbatch_args keyword
    checked_keywords = check_keyword('custom_sbatch_args', possible_keywords_and_defaults, str, no_validation('custom_sbatch_args'), checked_keywords)

    # Validate the mem_per_cpu keyword
    def is_valid(keyword_val):
        if keyword_val < 1:
            print('WARNING: The "mem_per_cpu" keyword ({}) in the &control section must be a positive integer (expressing memory size in GB)'.format(keyword_val))
            is_valid2 = False
        else:
            is_valid2 = True
        return(is_valid2)
    checked_keywords = check_keyword('mem_per_cpu', possible_keywords_and_defaults, int, is_valid, checked_keywords)

    # Validate the project keyword
    checked_keywords = check_keyword('project', possible_keywords_and_defaults, str, no_validation('project'), checked_keywords)

    # Output the checked keywords and their validated values
    dict_output(checked_keywords, 'Checked and validated keywords from the &control section of the input file:')

    return(checked_keywords)


def export_bash_variables(keywords):
    """
    Write a file exporting Bash variables to be sourced by run_workflows.sh to properly run CANDLE jobs on each machine.

    The following can be obtained by reading the HPC system user guides (e.g., [Summit user guide](https://docs.olcf.ornl.gov/systems/summit_user_guide.html), [Biowulf user guide](https://hpc.nih.gov/docs/userguide.html)) and by carefully observing $CANDLE/swift-t/turbine/code/scripts/submit/lsf/turbine-lsf.sh.m4 and $CANDLE/swift-t/turbine/code/scripts/submit/slurm/turbine-slurm.sh.m4. Confirm variable settings by looking in, e.g., $CANDLE/Supervisor/workflows/upf/test.

    Also note that I anticipate some of the CANDLE calls to die upon submission to Summit due to PPN=6 below, as I have noticed Summit's scheduler being sensitive to the --rs_per_host option, to which $PPN gets mapped. This should probably lead to some simple logic in this script, preprocess.py, that checks that a reasonable value for the nworkers keyword is set. (This is probably not currently an issue due to PPN=1 being used by default.)
    """

    # Import relevant libraries
    import numpy as np
    import os

    # Constant
    file_containing_export_statements = 'generated_files/preprocessed_vars_to_export.sh'

    # General logic
    if keywords['workflow'] == 'grid':
        nswift_t_processes = 1
    elif keywords['workflow'] == 'bayesian':
        nswift_t_processes = 2
    ntasks_total = nswift_t_processes + keywords['nworkers']

    # Split into one block for each site
    site = os.getenv('SITE')
    if site == 'summit':

        ## Site-dependent logic
        nnodes = int(np.ceil(ntasks_total/6))

        # Write the file that exports the Bash environment variables
        with open(file_containing_export_statements, 'w') as f:
            f.write('export PROCS={}\n'.format(ntasks_total))
            f.write('export PPN=6\n')
            f.write('export TURBINE_LAUNCH_OPTIONS="--tasks_per_rs=1 --cpu_per_rs=7 --gpu_per_rs=1 --bind=packed:7 --launch_distribution=packed -E OMP_NUM_THREADS=7"\n')
            f.write('export PROJECT={}\n'.format(keywords['project']))
            f.write('export NODES={}\n'.format(nnodes))
            f.write('export WALLTIME={}\n'.format(keywords['walltime'])) # [hours:]minutes

    elif site == 'biowulf':

        ## Site-dependent logic
        # All settings below are based on task_assignment_summary.lyx/pdf on Andrew's computer

        # Contants
        ncores_cutoff = 16 # see more_cpus_tasks_etc.docx and cpus_tasks_etc.docx for justification
        ntasks_per_core = 1 # Biowulf suggests this for MPI jobs

        # Variables not needed to be customized
        W = keywords['nworkers']
        S = nswift_t_processes # number of Swift/T processes S

        # Variables to CONSIDER be customizable
        ntasks = ntasks_total
        T = keywords['nthreads']
        if keywords['worker_type'] == 'cpu': # CPU-only job
            gres = None
            nodes = int(np.ceil(ntasks*T/ncores_cutoff))
            ntasks_per_node = int(np.ceil(ntasks/nodes))

            if (ntasks_per_node*nodes) != ntasks:
                ntasks = ntasks_per_node * nodes # we may as well fill up all the resources we're allocating (can't do this for a GPU job, where we already ARE using all the resources [GPUs] we're allocating... remember we're reserving <nodes> GPUs)
                print('NOTE: Requested number of workers has automatically been increased from {} to {} in order to more efficiently use Biowulf\'s resources'.format(W, ntasks-S))

            if nodes == 1: # single-node job
                partition = 'norm'
            else: # multi-node job
                partition = 'multinode'
        else: # GPU job
            partition = 'gpu'
            gres = keywords['worker_type']
            nodes = W
            ntasks_per_node = 1 + int(np.ceil(S/W))
        cpus_per_task = T

        # Write the file that exports the Bash environment variables
        with open(file_containing_export_statements, 'w') as f:
            f.write('export PROCS={}\n'.format(ntasks))
            if gres is not None:
                f.write('export TURBINE_SBATCH_ARGS="--gres=gpu:{}:1 {} --mem-per-cpu={}G --cpus-per-task={} --ntasks-per-core={} --nodes={}"\n'.format(gres, keywords['custom_sbatch_args'], keywords['mem_per_cpu'], cpus_per_task, ntasks_per_core, nodes))
                f.write('export TURBINE_LAUNCH_OPTIONS="--ntasks={} --distribution=cyclic"\n'.format(ntasks))
            else:
                f.write('export TURBINE_SBATCH_ARGS="{} --mem-per-cpu={}G --cpus-per-task={} --ntasks-per-core={} --nodes={}"\n'.format(keywords['custom_sbatch_args'], keywords['mem_per_cpu'], cpus_per_task, ntasks_per_core, nodes))
            f.write('export QUEUE={}\n'.format(partition))
            f.write('export PPN={}\n'.format(ntasks_per_node))
            f.write('export WALLTIME={}\n'.format(keywords['walltime'])) # hours:minutes:seconds


def main():
    """
    Execute main function when run as a script.

    Assumptions:
      (1) command_script.sh has been run (i.e., candle submit-job ... has been run)
      (2) site-specific_settings.sh has been sourced
      (3) candle module is loaded
    """

    # Check the input settings and return the resulting required and optional variables (in a single dictionary) that we'll need later
    checked_keywords = check_keywords('CANDLE_POSSIBLE_KEYWORDS_AND_DEFAULTS')

    # Apply logic to the checked keywords and export the Bash variables needed for later to a file, to subsequently be sourced back in in run_workflows.sh
    export_bash_variables(checked_keywords)


if __name__ == "__main__":
    # execute only if run as a script
    main()
