def get_keywords_to_check(bash_keyword_var):
    import os
    return(set(os.getenv(bash_keyword_var).split(', ')))


def check_input(keywords_to_check):

    # The input we're referring to is basically that from the input file. This current script runs at the start of run_workflows.sh.

    import os

    print('')
    print('Checking keywords {}'.format(keywords_to_check))
    print('')
    print('Keyword settings:')

    if 'model_script' in keywords_to_check:
        model_script = os.getenv('CANDLE_KEYWORD_MODEL_SCRIPT')
        if model_script is not None:
            try:
                with open(model_script):
                    pass
            except IOError:
                print('ERROR: The file "{}" from the "model_script" keyword cannot be opened'.format(model_script))
        else:
            print('ERROR: The "model_script" keyword is not set in the &control section of the input file')
            exit(1)
        print('model_script: {}'.format(model_script))

    if 'workflow' in keywords_to_check:
        workflow = os.getenv('CANDLE_KEYWORD_WORKFLOW')
        if workflow is not None:
            workflow = workflow.lower()
            valid_workflows = ('grid', 'bayesian')
            if workflow not in valid_workflows:
                print('ERROR: The "workflow" keyword ({}) in the &control section must be one of'.format(workflow), valid_workflows)
                exit(1)
        else:
            print('ERROR: The "workflow" keyword is not set in the &control section of the input file')
            exit(1)
        print('workflow: {}'.format(workflow))
    else:
        workflow = None

    if 'walltime' in keywords_to_check:
        walltime = os.getenv('CANDLE_KEYWORD_WALLTIME')
        if walltime is None: # don't do error-checking for walltime
            print('ERROR: The "walltime" keyword is not set in the &control section of the input file')
            exit(1)
        print('walltime: {}'.format(walltime))
    else:
        walltime = None

    if 'worker_type' in keywords_to_check:
        worker_type = os.getenv('CANDLE_KEYWORD_WORKER_TYPE')
        valid_worker_types = ('cpu', 'k20x', 'k80', 'p100', 'v100', 'v100x')
        if worker_type is not None:
            worker_type = worker_type.lower()
            if worker_type not in valid_worker_types:
                print('WARNING: The "worker_type" keyword ({}) in the &control section must be one of'.format(worker_type), valid_worker_types)
        else:
            print('WARNING: The "worker_type" keyword is not set in the &control section of the input file')
        print('worker_type: {}'.format(worker_type))
    else:
        worker_type = None

    if 'nworkers' in keywords_to_check:
        nworkers = os.getenv('CANDLE_KEYWORD_NWORKERS')
        if nworkers is not None:
            nworkers = int(nworkers)
            if nworkers < 1:
                print('WARNING: The "nworkers" keyword ({}) in the &control section must be a positive integer'.format(nworkers))
        else:
            print('WARNING: The "nworkers" keyword is not set in the &control section of the input file')
        print('nworkers: {}'.format(nworkers))
    else:
        nworkers = None

    if 'nthreads' in keywords_to_check:
        nthreads = os.getenv('CANDLE_KEYWORD_NTHREADS')
        if nthreads is not None:
            nthreads = int(nthreads)
            if nthreads < 1:
                print('ERROR: The "nthreads" keyword ({}) in the &control section must be a positive integer'.format(nthreads))
                exit(1)
        elif worker_type == 'cpu':
            print('WARNING: The keyword "nthreads" is not set in &control section; setting it to 1')
            nthreads = 1
        else:
            print('NOTE: The keyword "nthreads" has been automatically set to its default setting of 1')
            nthreads = 1
        print('nthreads: {}'.format(nthreads))
    else:
        nthreads = None

    if 'custom_sbatch_args' in keywords_to_check:
        custom_sbatch_args = os.getenv('CANDLE_KEYWORD_CUSTOM_SBATCH_ARGS', '')
        print('custom_sbatch_args: {}'.format(custom_sbatch_args))
    else:
        custom_sbatch_args = None

    if 'mem_per_cpu' in keywords_to_check:
        mem_per_cpu = os.getenv('CANDLE_KEYWORD_MEM_PER_CPU')
        if mem_per_cpu is not None:
            mem_per_cpu = float(mem_per_cpu)
        else:
            print('NOTE: The keyword "mem_per_cpu" has been automatically set to its default setting of 7.5 GB')
            mem_per_cpu = 7.5
        mem_per_cpu = int(mem_per_cpu)
        print('mem_per_cpu: {}'.format(mem_per_cpu))
    else:
        mem_per_cpu = None

    return(workflow, walltime, worker_type, nworkers, nthreads, custom_sbatch_args, mem_per_cpu)


def print_homog_job(ntasks, custom_sbatch_args, gres, mem_per_cpu, cpus_per_task, ntasks_per_core, partition, walltime, ntasks_per_node, nodes):
    ntasks_part = ' --ntasks={}'.format(ntasks)
    if custom_sbatch_args == '':
        custom_sbatch_args_part = ''
    else:
        custom_sbatch_args_part = ' {}'.format(custom_sbatch_args)
    if gres is not None:
        gres_part = ' --gres=gpu:{}:1'.format(gres)
    else:
        gres_part = ''
    mem_per_cpu_part = ' --mem-per-cpu={}G'.format(mem_per_cpu)
    cpus_per_task_part = ' --cpus-per-task={}'.format(cpus_per_task)
    ntasks_per_core_part = ' --ntasks-per-core={}'.format(ntasks_per_core)
    partition_part = ' --partition={}'.format(partition)
    walltime_part = ' --time={}'.format(walltime) # total run time of the job allocation
    ntasks_per_node_part = ' --ntasks-per-node={}'.format(ntasks_per_node)
    nodes_part = ' --nodes={}'.format(nodes)
    print('{}{}{}{}{}{}{}{}{}{}'.format(ntasks_part, gres_part, custom_sbatch_args_part, mem_per_cpu_part, cpus_per_task_part, ntasks_per_core_part, partition_part, walltime_part, ntasks_per_node_part, nodes_part))


def determine_sbatch_settings(workflow, walltime, worker_type, nworkers, nthreads, custom_sbatch_args, mem_per_cpu):
    # All settings below are based on task_assignment_summary.lyx/pdf on Andrew's computer for Biowulf

    import numpy as np

    # Already preprocessed parameters
    #workflow = 'grid'
    #walltime = '00:01:00'
    #custom_sbatch_args = ''
    #nworkers = 5
    #nthreads = 2
    #worker_type = 'cpu'

    # Contants
    ncores_cutoff = 16 # see more_cpus_tasks_etc.docx and cpus_tasks_etc.docx for justification
    ntasks_per_core = 1 # Biowulf suggests this for MPI jobs

    # Variables not needed to be customized
    W = nworkers
    if workflow == 'grid': # number of Swift/T processes S
        S = 1
    elif workflow == 'bayesian':
        S = 2

    # Variables to CONSIDER be customizable
    ntasks = W + S
    T = nthreads
    if worker_type == 'cpu': # CPU-only job
        gres = None
        nodes = int(np.ceil(ntasks*T/ncores_cutoff))
        ntasks_per_node = int(np.ceil(ntasks/nodes))

        if (ntasks_per_node*nodes) != ntasks:
            ntasks = ntasks_per_node * nodes # we may as well fill up all the resources we're allocating (can't do this for a GPU job, where we already ARE using all the resources [GPUs] we're allocating... remember we're reserving <nodes> GPUs)
            print('NOTE: Requested number of workers has automatically been increased from {} to {} in order to more efficiently use Biowulf\'s resources'.format(W,ntasks-S))

        if nodes == 1: # single-node job
            partition = 'norm'
        else: # multi-node job
            partition = 'multinode'
    else: # GPU job
        partition = 'gpu'
        gres = worker_type
        nodes = W
        ntasks_per_node = 1 + int(np.ceil(S/W))
    cpus_per_task = T

    # Print the sbatch command to work toward
    print('sbatch options that should be used:')
    print_homog_job(ntasks, custom_sbatch_args, gres, mem_per_cpu, cpus_per_task, ntasks_per_core, partition, walltime, ntasks_per_node, nodes)

    return(ntasks, gres, mem_per_cpu, cpus_per_task, ntasks_per_core, partition, ntasks_per_node, nodes)


def export_variables(workflow, ntasks, gres, custom_sbatch_args, mem_per_cpu, cpus_per_task, ntasks_per_core, partition, ntasks_per_node, nodes):

    f = open('preprocessed_vars_to_export.sh', 'w')

    # Export variables (well, print export statements for loading later) we'll need for later
    f.write('export WORKFLOW_TYPE={}\n'.format(workflow))
    f.write('export PROCS={}\n'.format(ntasks))
    if gres is not None:
        f.write('export TURBINE_SBATCH_ARGS="--gres=gpu:{}:1 {} --mem-per-cpu={}G --cpus-per-task={} --ntasks-per-core={} --nodes={}"\n'.format(gres, custom_sbatch_args, mem_per_cpu, cpus_per_task, ntasks_per_core, nodes))
        f.write('export TURBINE_LAUNCH_OPTIONS="--ntasks={} --distribution=cyclic"\n'.format(ntasks)) # should be fixed in the latest Swift/T so no need for a different variable name
    else:
        f.write('export TURBINE_SBATCH_ARGS="{} --mem-per-cpu={}G --cpus-per-task={} --ntasks-per-core={} --nodes={}"\n'.format(custom_sbatch_args, mem_per_cpu, cpus_per_task, ntasks_per_core, nodes))
    f.write('export QUEUE={}\n'.format(partition))
    f.write('export PPN={}\n'.format(ntasks_per_node))

    f.close()


# Get keywords to check from the Bash environment
keywords_to_check = get_keywords_to_check('CANDLE_KEYWORDS')

# Check the input settings and return the resulting required and optional variables that we'll need later (all required variables are checked but not yet all optional variables)
workflow, walltime, worker_type, nworkers, nthreads, custom_sbatch_args, mem_per_cpu = check_input(keywords_to_check)

# Determine the settings for the arguments to the sbatch, turbine, etc. calls
ntasks, gres, mem_per_cpu, cpus_per_task, ntasks_per_core, partition, ntasks_per_node, nodes = determine_sbatch_settings(workflow, walltime, worker_type, nworkers, nthreads, custom_sbatch_args, mem_per_cpu)

# Export variables we'll need later to a file in order to be sourced back in in run_workflows.sh
export_variables(workflow, ntasks, gres, custom_sbatch_args, mem_per_cpu, cpus_per_task, ntasks_per_core, partition, ntasks_per_node, nodes)
