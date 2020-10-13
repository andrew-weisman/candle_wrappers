def check_input():

    # Note: Just checking required (not optional) keywords for now
    # The input we're referring to is basically that from the input file. This current script runs at the start of run_workflows.sh.

    import os

    print('')
    print('Keyword settings:')

    ################ Current keywords ######################################################################################
    # model_script
    model_script = os.getenv('MODEL_SCRIPT')
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

    # workflow
    workflow = os.getenv('WORKFLOW')
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

    # walltime
    walltime = os.getenv('WALLTIME')
    if walltime is None: # don't do error-checking for walltime
        print('ERROR: The "walltime" keyword is not set in the &control section of the input file')
        exit(1)
    print('walltime: {}'.format(walltime))

    # worker_type
    worker_type = os.getenv('WORKER_TYPE')
    valid_worker_types = ('cpu', 'k20x', 'k80', 'p100', 'v100', 'v100x')
    if worker_type is not None:
        worker_type = worker_type.lower()
        if worker_type not in valid_worker_types:
            #print('ERROR: The "worker_type" keyword in the &control section must be one of', valid_worker_types)
            print('WARNING: The "worker_type" keyword ({}) in the &control section must be one of'.format(worker_type), valid_worker_types)
            worker_type_is_valid = False
            #exit(1)
        else:
            worker_type_is_valid = True
        worker_type_is_set = True
    else:
        #print('ERROR: The "worker_type" keyword is not set in the &control section of the input file')
        print('WARNING: The "worker_type" keyword is not set in the &control section of the input file')
        worker_type_is_set = False
        #exit(1)
    #if worker_type_is_set and worker_type_is_valid:
    print('worker_type: {}'.format(worker_type))

    # nworkers
    nworkers = os.getenv('NWORKERS')
    if nworkers is not None:
        nworkers = int(nworkers)
        if nworkers < 1:
            #print('ERROR: The "nworkers" keyword in the &control section must be a positive integer')
            print('WARNING: The "nworkers" keyword ({}) in the &control section must be a positive integer'.format(nworkers))
            nworkers_is_valid = False
            #exit(1)
        else:
            nworkers_is_valid = True
        nworkers_is_set = True
    else:
        #print('ERROR: The "nworkers" keyword is not set in the &control section of the input file')
        print('WARNING: The "nworkers" keyword is not set in the &control section of the input file')
        nworkers_is_set = False
        #exit(1)
    #if nworkers_is_set and nworkers_is_valid:
    print('nworkers: {}'.format(nworkers))
    ########################################################################################################################


    ################ Deprecated keywords ###################################################################################
    # ngpus
    ngpus = os.getenv('NGPUS')
    if ngpus is not None:
        ngpus = int(ngpus)
        if ngpus < 1:
            #print('ERROR: The "ngpus" keyword in the &control section must be a positive integer')
            print('WARNING: The "ngpus" keyword ({}) in the &control section must be a positive integer'.format(ngpus))
            ngpus_is_valid = False
            #exit(1)
        else:
            ngpus_is_valid = True
        ngpus_is_set = True
    else:
        ngpus_is_set = False
    #if ngpus_is_set and ngpus_is_valid:
    if ngpus is not None:
        print('ngpus: {}'.format(ngpus))

    # gpu_type
    gpu_type = os.getenv('GPU_TYPE')
    if gpu_type is not None:
        gpu_type = gpu_type.lower()
        valid_gpu_types = ('k20x', 'k80', 'p100', 'v100')
        if gpu_type not in valid_gpu_types:
            #print('ERROR: The "gpu_type" keyword in the &control section must be one of', valid_gpu_types)
            print('WARNING: The "gpu_type" keyword ({}) in the &control section must be one of'.format(gpu_type), valid_gpu_types)
            gpu_type_is_valid = False
            #exit(1)
        else:
            gpu_type_is_valid = True
        gpu_type_is_set = True
    else:
        gpu_type_is_set = False
    #if gpu_type_is_set and gpu_type_is_valid:
    if gpu_type is not None:
        print('gpu_type: {}'.format(gpu_type))
    ########################################################################################################################


    ################ Handle deprecated keywords ############################################################################
    # Handle deprecated "gpu_type" keyword in favor of current "worker_type" keyword
    if (not worker_type_is_set) and (not gpu_type_is_set):
        print('ERROR: The "worker_type" keyword in the &control section must be set (to one of {})'.format(valid_worker_types))
        exit(1)
    if (not worker_type_is_set) and gpu_type_is_set:
        print('WARNING: The keyword "gpu_type" is deprecated; in the future you must instead use "worker_type", whose possible values are {}'.format(valid_worker_types))
        if gpu_type_is_valid:
            print('NOTE: We\'re using the setting of "gpu_type" ({}), for now, as the setting for "worker_type"'.format(gpu_type))
            worker_type = gpu_type
        else:
            print('ERROR: Attempting to use the setting of "gpu_type" ({}), for now, as the setting for "worker_type", but it is invalid'.format(gpu_type))
            exit(1)
    if worker_type_is_set and (not gpu_type_is_set):
        if worker_type_is_valid:
            pass
        else:
            print('ERROR: The "worker_type" keyword in the &control section must be one of', valid_worker_types)
            exit(1)
    if worker_type_is_set and gpu_type_is_set:
        print('ERROR: Both keywords "worker_type" and "gpu_type" are set. The former is current but the latter is deprecated; please remove "gpu_type" and re-submit.')
        exit(1)

    # Handle deprecated "ngpus" keyword in favor of current "nworkers" keyword
    if (not nworkers_is_set) and (not ngpus_is_set):
        print('ERROR: The "nworkers" keyword in the &control section must be set (to a positive integer)')
        exit(1)
    if (not nworkers_is_set) and ngpus_is_set:
        print('WARNING: The keyword "ngpus" is deprecated; in the future you must instead use "nworkers", which must be a positive integer')
        if ngpus_is_valid:
            print('NOTE: We\'re using the setting of "ngpus" ({}), for now, as the setting for "nworkers"'.format(ngpus))
            nworkers = ngpus
        else:
            print('ERROR: Attempting to use the setting of "ngpus" ({}), for now, as the setting for "nworkers", but it is invalid'.format(ngpus))
            exit(1)
    if nworkers_is_set and (not ngpus_is_set):
        if nworkers_is_valid:
            pass
        else:
            print('ERROR: The "nworkers" keyword in the &control section must be a positive integer')
            exit(1)
    if nworkers_is_set and ngpus_is_set:
        print('ERROR: Both keywords "nworkers" and "ngpus" are set. The former is current but the latter is deprecated; please remove "ngpus" and re-submit.')
        exit(1)
    ########################################################################################################################


    ################ Optional keywords #####################################################################################
    # nthreads
    nthreads = os.getenv('NTHREADS')
    if nthreads is not None:
        nthreads = int(nthreads)
        if nthreads < 1:
            print('ERROR: The "nthreads" keyword ({}) in the &control section must be a positive integer'.format(nthreads))
            exit(1)
    elif worker_type == 'cpu':
        print('WARNING: The keyword "nthreads" is not set in &control section; setting it to 1')
        #nthreads = 1 # good default number of tasks for a CPU job (see task_assignment_summary.lyx)
        nthreads = 1
    else:
        print('NOTE: The keyword "nthreads" has been automatically set to its default setting of 1')
        #nthreads = 7 # smallest of number of cores on node / number of GPUs on node for gpu partition
        #nthreads = 5 # good default number of tasks for a GPU job (see task_assignment_summary.lyx)
        nthreads = 1
    print('nthreads: {}'.format(nthreads))

    # custom_sbatch_args
    custom_sbatch_args = os.getenv('CUSTOM_SBATCH_ARGS', '')
    print('custom_sbatch_args: {}'.format(custom_sbatch_args))

    # mem_per_cpu
    mem_per_cpu = os.getenv('MEM_PER_CPU')
    if mem_per_cpu is not None:
        #mem_per_worker = int(round(float(mem_per_worker)))
        mem_per_cpu = float(mem_per_cpu)
    # elif worker_type == 'cpu':
    #     print('NOTE: The keyword "mem_per_worker" has been automatically set to its default setting of 7 for CPU jobs')
    #     #mem_per_worker = 7 # smallest of (rounded down to nearest integer) mem on node  / number of cores on node for norm partition
    #     mem_per_cpu = 7.5
    else:
        #print('NOTE: The keyword "mem_per_worker" has been automatically set to its default setting of 30 for GPU jobs')
        print('NOTE: The keyword "mem_per_cpu" has been automatically set to its default setting of 7.5 GB')
        #mem_per_worker = 30 # smallest of (rounded down to nearest integer) mem on node / number of GPUs on node for gpu partition
        mem_per_cpu = 7.5
    mem_per_cpu = int(mem_per_cpu)
    print('mem_per_cpu: {}'.format(mem_per_cpu))

    # # M_gpu (GB)
    # M_gpu = int(float(os.getenv('MEM_PER_GPU', '30')))
    # print('M_gpu: {}'.format(M_gpu))

    # # M_cpu (GB)
    # M_cpu = int(float(os.getenv('MEM_PER_CPU', '7.5')))
    # print('M_cpu: {}'.format(M_cpu))

    # # M_swi (GB)
    # M_swi = int(float(os.getenv('MEM_PER_SWIFTT', '4')))
    # print('M_swi: {}'.format(M_swi))

    # # sbatch_mem_per_cpu
    # sbatch_mem_per_cpu = os.getenv('SBATCH_MEM_PER_CPU')
    # if sbatch_mem_per_cpu is not None:
    #     sbatch_mem_per_cpu = int(sbatch_mem_per_cpu)
    # print('sbatch_mem_per_cpu: {}'.format(sbatch_mem_per_cpu))

    # # sbatch_cpus_per_task
    # sbatch_cpus_per_task = os.getenv('SBATCH_CPUS_PER_TASK')
    # if sbatch_cpus_per_task is not None:
    #     sbatch_cpus_per_task = int(float(sbatch_cpus_per_task))
    # print('sbatch_cpus_per_task: {}'.format(sbatch_cpus_per_task))
    ########################################################################################################################


    #return(model_script, workflow, walltime, worker_type, nworkers, ngpus, gpu_type, nthreads, custom_sbatch_args, M_gpu, M_cpu, M_swi, sbatch_mem_per_cpu, sbatch_cpus_per_task) # all variables processed above
    #return(workflow, walltime, worker_type, nworkers, nthreads, custom_sbatch_args, M_gpu, M_cpu, M_swi, sbatch_mem_per_cpu, sbatch_cpus_per_task) # just the ones we'll actually need
    return(workflow, walltime, worker_type, nworkers, nthreads, custom_sbatch_args, mem_per_cpu)


def print_homog_job(ntasks, custom_sbatch_args, gres, mem_per_cpu, cpus_per_task, ntasks_per_core, partition, walltime, ntasks_per_node, nodes):
    ntasks_part = ' --ntasks={}'.format(ntasks)
    if custom_sbatch_args == '':
        custom_sbatch_args_part = ''
    else:
        custom_sbatch_args_part = ' {}'.format(custom_sbatch_args)
    if gres is not None:
        gres_part = ' --gres=gpu:{}:1'.format(gres)
        #distribution_part = ' --distribution=cyclic'
    else:
        gres_part = ''
        #distribution_part = ''
    mem_per_cpu_part = ' --mem-per-cpu={}G'.format(mem_per_cpu)
    cpus_per_task_part = ' --cpus-per-task={}'.format(cpus_per_task)
    ntasks_per_core_part = ' --ntasks-per-core={}'.format(ntasks_per_core)
    partition_part = ' --partition={}'.format(partition)
    walltime_part = ' --time={}'.format(walltime) # total run time of the job allocation
    ntasks_per_node_part = ' --ntasks-per-node={}'.format(ntasks_per_node)
    nodes_part = ' --nodes={}'.format(nodes)
    #print('{}{}{}{}{}{}{}{}{}{}{}'.format(ntasks_part, custom_sbatch_args_part, gres_part, distribution_part, mem_per_cpu_part, cpus_per_task_part, ntasks_per_core_part, partition_part, walltime_part, ntasks_per_node_part, nodes_part))
    print('{}{}{}{}{}{}{}{}{}{}'.format(ntasks_part, gres_part, custom_sbatch_args_part, mem_per_cpu_part, cpus_per_task_part, ntasks_per_core_part, partition_part, walltime_part, ntasks_per_node_part, nodes_part))


def print_het_job(ntasks2, custom_sbatch_args2, gres2, mem_per_cpu2, cpus_per_task2, ntasks_per_core2, partition2, walltime2, ntasks_per_node2, nodes2):
    for ntasks, custom_sbatch_args, gres, mem_per_cpu, cpus_per_task, ntasks_per_core, partition, walltime, ntasks_per_node, nodes in zip(ntasks2, custom_sbatch_args2, gres2, mem_per_cpu2, cpus_per_task2, ntasks_per_core2, partition2, walltime2, ntasks_per_node2, nodes2):
        print_homog_job(ntasks, custom_sbatch_args, gres, mem_per_cpu, cpus_per_task, ntasks_per_core, partition, walltime, ntasks_per_node, nodes)


def determine_sbatch_settings(workflow, walltime, worker_type, nworkers, nthreads, custom_sbatch_args, mem_per_cpu):
    # All settings below are based on task_assignment_summary.lyx/pdf

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
        #f.write('export TURBINE_SBATCH_ARGS="{} --gres=gpu:{}:1 --mem-per-cpu={}G --cpus-per-task={} --ntasks-per-core={} --nodes={} --distribution=cyclic"\n'.format(custom_sbatch_args, gres, mem_per_cpu, cpus_per_task, ntasks_per_core, nodes))
        #f.write('export TURBINE_SBATCH_ARGS="{} --gres=gpu:{}:1 --mem-per-cpu={}G --cpus-per-task={} --ntasks-per-core={} --nodes={}"\n'.format(custom_sbatch_args, gres, mem_per_cpu, cpus_per_task, ntasks_per_core, nodes))
        f.write('export TURBINE_SBATCH_ARGS="--gres=gpu:{}:1 {} --mem-per-cpu={}G --cpus-per-task={} --ntasks-per-core={} --nodes={}"\n'.format(gres, custom_sbatch_args, mem_per_cpu, cpus_per_task, ntasks_per_core, nodes))
        #f.write('export TURBINE_LAUNCH_OPTIONS2="-n {} --map-by node"\n'.format(ntasks))
        #f.write('export TURBINE_LAUNCH_OPTIONS="-n {} --map-by node"\n'.format(ntasks)) # should be fixed in the latest Swift/T so no need for a different variable name
        f.write('export TURBINE_LAUNCH_OPTIONS="--ntasks={} --distribution=cyclic"\n'.format(ntasks)) # should be fixed in the latest Swift/T so no need for a different variable name
    else:
        f.write('export TURBINE_SBATCH_ARGS="{} --mem-per-cpu={}G --cpus-per-task={} --ntasks-per-core={} --nodes={}"\n'.format(custom_sbatch_args, mem_per_cpu, cpus_per_task, ntasks_per_core, nodes))
    f.write('export QUEUE={}\n'.format(partition))
    f.write('export PPN={}\n'.format(ntasks_per_node))

    f.close()


# Check the input settings and return the resulting required and optional variables that we'll need later (all required variables are checked but not yet all optional variables)
workflow, walltime, worker_type, nworkers, nthreads, custom_sbatch_args, mem_per_cpu = check_input()

# Determine the settings for the arguments to the sbatch, turbine, etc. calls
ntasks, gres, mem_per_cpu, cpus_per_task, ntasks_per_core, partition, ntasks_per_node, nodes = determine_sbatch_settings(workflow, walltime, worker_type, nworkers, nthreads, custom_sbatch_args, mem_per_cpu) # new

# Export variables we'll need later to a file in order to be sourced back in in run_workflows.sh
export_variables(workflow, ntasks, gres, custom_sbatch_args, mem_per_cpu, cpus_per_task, ntasks_per_core, partition, ntasks_per_node, nodes)
