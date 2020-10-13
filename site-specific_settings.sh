#!/bin/bash

# This script should be consistent with the env-$SITE.sh settings
# $CANDLE_SETUP... variables are those explicitly used in setup.sh
# It would be nice in this script to only set variables that I have created, such as those that begin with $CANDLE_... that would be a useful rule for this file
# ASSUMPTIONS:
#   (1) The candle module is loaded as usual
#   (2) Running this script in interactive or batch mode (i.e., not on a login node) (the $CANDLE_... variables involving $SLURM_... variables will definitely be set if so)
#   (3) env-biowulf.sh has been sourced (the $CANDLE_... variables involving $TURBINE_LAUNCH_OPTIONS will definitely be set if so)


if [ "x$SITE" == "xbiowulf" ]; then

    CANDLE_SETUP_LOCAL_DIR="/lscratch/$SLURM_JOB_ID"

    CANDLE_SETUP_COMPILE_SWIFT_T=1
    CANDLE_SETUP_SWIFT_T=
    export CANDLE_DEP_MPI="/usr/local/OpenMPI/4.0.4/CUDA-10.2/gcc-9.2.0"
    export CANDLE_DEP_TCL="/data/BIDS-HPC/public/software/builds/tcl"
    export CANDLE_DEP_PY="/usr/local/Anaconda/envs/py3.7"
    export CANDLE_DEP_R="/usr/local/apps/R/4.0/4.0.0/lib64/R"
    export CANDLE_DEP_R_SITE="/usr/local/apps/R/4.0/site-library_4.0.0"
    export CANDLE_DEP_ANT="/usr/local/apps/ant/1.10.3"
    export CANDLE_LAUNCHER_OPTION="--with-launcher=/usr/local/slurm/bin/srun"

    CANDLE_SETUP_BUILD_SUPERVISOR_R_PACKAGES=1
    CANDLE_SETUP_R_LIBS=

    CANDLE_SETUP_JOB_LAUNCHER="srun"
    CANDLE_SETUP_MPI_HELLO_WORLD_LAUNCHER_OPTIONS="$TURBINE_LAUNCH_OPTIONS --ntasks=$SLURM_NTASKS --cpus-per-task=$SLURM_CPUS_PER_TASK"
    CANDLE_SETUP_BENCHMARK_TEST_RUN_LAUNCHER_OPTIONS="$TURBINE_LAUNCH_OPTIONS --ntasks=1"

    export CANDLE_DEFAULT_PYTHON_MODULE="python/3.7"
    export CANDLE_DEFAULT_R_MODULE="R/4.0.0"

    export CANDLE_KEYWORDS="model_script, workflow, walltime, worker_type, nworkers, nthreads, custom_sbatch_args, mem_per_cpu"

elif [ "x$SITE" == "xsummit" ]; then

    CANDLE_SETUP_LOCAL_DIR=$(pwd)

    CANDLE_SETUP_COMPILE_SWIFT_T=0
    CANDLE_SETUP_SWIFT_T="/gpfs/alpine/world-shared/med106/wozniak/sw/gcc-6.4.0/swift-t/2020-09-02"
    export CANDLE_DEP_MPI=
    export CANDLE_DEP_TCL=
    export CANDLE_DEP_PY=
    export CANDLE_DEP_R=
    export CANDLE_DEP_R_SITE=
    export CANDLE_DEP_ANT=
    export CANDLE_LAUNCHER_OPTION=

    CANDLE_SETUP_BUILD_SUPERVISOR_R_PACKAGES=0
    CANDLE_SETUP_R_LIBS="/gpfs/alpine/world-shared/med106/sw/R-190927/lib64/R/library"

    CANDLE_SETUP_JOB_LAUNCHER="jsrun"
    CANDLE_SETUP_MPI_HELLO_WORLD_LAUNCHER_OPTIONS="--nrs=12 --tasks_per_rs=1 --cpu_per_rs=7 --gpu_per_rs=1 --rs_per_host=6 --bind=packed:7 --launch_distribution=packed -E OMP_NUM_THREADS=7"
    CANDLE_SETUP_BENCHMARK_TEST_RUN_LAUNCHER_OPTIONS="--nrs=1 --tasks_per_rs=1 --cpu_per_rs=7 --gpu_per_rs=1 --rs_per_host=1 --bind=packed:7 --launch_distribution=packed -E OMP_NUM_THREADS=7"

    export CANDLE_DEFAULT_PYTHON_MODULE="/gpfs/alpine/world-shared/med106/sw/condaenv-200408/bin/python3.6"
    export CANDLE_DEFAULT_R_MODULE="/gpfs/alpine/world-shared/med106/wozniak/sw/gcc-6.4.0/R-3.6.1/lib64/R/bin/R"

    export CANDLE_KEYWORDS="model_script, workflow, walltime, nworkers"

fi


echo -e "\nSite-specific settings:\n"
echo "  \$CANDLE_SETUP_LOCAL_DIR:                           $CANDLE_SETUP_LOCAL_DIR"
echo "  \$CANDLE_SETUP_COMPILE_SWIFT_T:                     $CANDLE_SETUP_COMPILE_SWIFT_T"
echo "  \$CANDLE_SETUP_SWIFT_T:                             $CANDLE_SETUP_SWIFT_T"
echo "  \$CANDLE_DEP_MPI:                                   $CANDLE_DEP_MPI"
echo "  \$CANDLE_DEP_TCL:                                   $CANDLE_DEP_TCL"
echo "  \$CANDLE_DEP_PY:                                    $CANDLE_DEP_PY"
echo "  \$CANDLE_DEP_R:                                     $CANDLE_DEP_R"
echo "  \$CANDLE_DEP_R_SITE:                                $CANDLE_DEP_R_SITE"
echo "  \$CANDLE_DEP_ANT:                                   $CANDLE_DEP_ANT"
echo "  \$CANDLE_LAUNCHER_OPTION:                           $CANDLE_LAUNCHER_OPTION"
echo "  \$CANDLE_SETUP_BUILD_SUPERVISOR_R_PACKAGES:         $CANDLE_SETUP_BUILD_SUPERVISOR_R_PACKAGES"
echo "  \$CANDLE_SETUP_R_LIBS:                              $CANDLE_SETUP_R_LIBS"
echo "  \$CANDLE_SETUP_JOB_LAUNCHER:                        $CANDLE_SETUP_JOB_LAUNCHER"
echo "  \$CANDLE_SETUP_MPI_HELLO_WORLD_LAUNCHER_OPTIONS:    $CANDLE_SETUP_MPI_HELLO_WORLD_LAUNCHER_OPTIONS"
echo "  \$CANDLE_SETUP_BENCHMARK_TEST_RUN_LAUNCHER_OPTIONS: $CANDLE_SETUP_BENCHMARK_TEST_RUN_LAUNCHER_OPTIONS"
echo "  \$CANDLE_DEFAULT_PYTHON_MODULE:                     $CANDLE_DEFAULT_PYTHON_MODULE"
echo "  \$CANDLE_DEFAULT_R_MODULE:                          $CANDLE_DEFAULT_R_MODULE"
