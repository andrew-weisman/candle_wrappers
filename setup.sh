#!/bin/bash

# The point of this script is for it to automatically complete new or even partial installations of CANDLE but to not re-install anything; that must be done explicitly if that's desired
# It should therefore run pretty quickly if everything is already installed, not changing anything significant
# We should be able to run this script without worrying about it overwritting something already there
# If the task is optional and takes a while, prompt the user whether s/he wants to undertake it
# All tasks that make modifications should be checked if they've already been done
# All prompts should have an interactive mode workaround


# Assume the HPC system uses srun


# This script should be run like 'bash "$CANDLE/checkouts/wrappers/setup.sh"'' with an optional 0 or 1 argument corresponding to whether interactive mode is desired (default interactive, i.e., 1)
# As stated in the READMEs at https://github.com/andrew-weisman/candle_wrappers, before running this setup.sh script we should have already set the environment (some equivalent of module load candle)
# Only on Biowulf do we build Swift/T

# Function asking whether the user has checked a particular configuration file
check_file_before_continuing() {
    file_to_check=$1
    echo -e -n "\n **** Have you thoughly checked '$file_to_check' (y/n)? "
    if [ "x$interactive" == "x1" ]; then
        TTY=$(/usr/bin/tty)
        exec 3<&0 < "$TTY"
        read -r response
    else
        echo -e "\nAssuming file '$file_to_check' has been thoroughly checked\n"
        response="y"
    fi
    if [ "x$response" != "xy" ]; then
        echo "Okay, go ahead and thoroughly check '$file_to_check' and re-run this script"
        exit 1
    else
        echo "Great, glad you checked it"
    fi
}

# Output the full path to the executable of the inputted program name, or else print out a warning message
determine_executable() {
    prog=$1
    tmp_exec=$(command -v "$prog")
    [[ "x$tmp_exec" == "x" ]] && echo -e "\nWARNING: Program '$prog' not found\n" || echo -e "\nUsing $prog executable $tmp_exec\n"
}

run_launcher=1 # default should be 1
interactive=${1:-1} # default should be 1
set -e # exit when any command fails

# Determine whether we're on Biowulf
[[ "x$SITE" == "xbiowulf" ]] && on_biowulf=1 || on_biowulf=0

# Set the fast-access directory in order to speed up compilation
if [ "x$on_biowulf" == "x1" ]; then
    LOCAL_DIR="/lscratch/$SLURM_JOB_ID"
else
    LOCAL_DIR=$(pwd)
fi

# Enter the fast-access directory
cd "$LOCAL_DIR"


#### Set up the directory structure and clone the necessary repositories ###########################################################
echo -e "\n\n :::: Setting up directory structure and cloning necessary repositories...\n"

# Create the necessary directories not already created using the instructions in README.md
[ -d "$CANDLE/bin" ] || mkdir "$CANDLE/bin"
[ -d "$CANDLE/builds" ] || mkdir "$CANDLE/builds"

# Check out the necessary software from GitHub
[ -d "$CANDLE/checkouts/Supervisor" ] || git clone --branch develop https://github.com/ECP-CANDLE/Supervisor "$CANDLE/checkouts/Supervisor"
[ -d "$CANDLE/checkouts/Benchmarks" ] || git clone --branch develop https://github.com/ECP-CANDLE/Benchmarks "$CANDLE/checkouts/Benchmarks"
if [ "x$on_biowulf" == "x1" ]; then
    [ -d "$CANDLE/checkouts/swift-t" ] || git clone https://github.com/swift-lang/swift-t "$CANDLE/checkouts/swift-t"
fi

# Create the build subdirectories
if [ "x$on_biowulf" == "x1" ]; then
    [ -d "$CANDLE/builds/R/libs" ] || mkdir -p "$CANDLE/builds/R/libs"
    [ -d "$CANDLE/builds/swift-t-install" ] || mkdir "$CANDLE/builds/swift-t-install"
else
    [ -d "$CANDLE/builds/R" ] || mkdir -p "$CANDLE/builds/R"
    [ -L "$CANDLE/builds/R/libs" ] || ln -s "$CANDLE_R_LIBS" "$CANDLE/builds/R/libs"
    [ -L "$CANDLE/builds/swift-t-install" ] || ln -s "$CANDLE_SWIFT_T" "$CANDLE/builds/swift-t-install"
fi

# Create symbolic links in the main CANDLE directory
[ -L "$CANDLE/wrappers" ] || ln -s "$CANDLE/checkouts/wrappers" "$CANDLE/wrappers"
[ -L "$CANDLE/Supervisor" ] || ln -s "$CANDLE/checkouts/Supervisor" "$CANDLE/Supervisor"
[ -L "$CANDLE/Benchmarks" ] || ln -s "$CANDLE/checkouts/Benchmarks" "$CANDLE/Benchmarks"
if [ "x$on_biowulf" == "x1" ]; then
    [ -L "$CANDLE/swift-t" ] || ln -s "$CANDLE/checkouts/swift-t" "$CANDLE/swift-t"
fi
[ -L "$CANDLE/R" ] || ln -s "$CANDLE/builds/R" "$CANDLE/R"
[ -L "$CANDLE/swift-t-install" ] || ln -s "$CANDLE/builds/swift-t-install" "$CANDLE/swift-t-install"
####################################################################################################################################


#### Set up the environment ########################################################################################################
echo -e "\n\n :::: Setting up the build environment...\n"

# Check the settings file $CANDLE/Supervisor/workflows/common/sh/env-$SITE.sh
check_file_before_continuing "$CANDLE/Supervisor/workflows/common/sh/env-$SITE.sh"

# Load the environment
if [ "x${DEFAULT_PYTHON_MODULE:0:1}" == "x/" ]; then # If $DEFAULT_PYTHON_MODULE actually contains a full path to the executable instead of a module name...
    path_to_add=$(tmp=$(echo "$DEFAULT_PYTHON_MODULE" | awk -v FS="/" -v OFS="/" '{$NF=""; print}'); echo "${tmp:0:${#tmp}-1}") # this strips the executable from the full path to the python executable set in $DEFAULT_PYTHON_MODULE (if it's not a module name of course)
    export PATH="$path_to_add:$PATH"
else
    module load "$DEFAULT_PYTHON_MODULE"
fi
# shellcheck source=/dev/null
source "$CANDLE/Supervisor/workflows/common/sh/env-$SITE.sh"

# Output the executables to be used for Swift/T and Python
determine_executable python
determine_executable swift-t
####################################################################################################################################


#### Test MPI communications using an MPI hello world script #######################################################################
echo -e "\n\n :::: Testing MPI communications...\n"

# Compile and run MPI hello world
echo " ::::: Using mpicc: $(command -v mpicc)"
#echo -e " ::::: Using srun: $(command -v srun)\n"
#mpicc -o "$CANDLE/wrappers/test_files/hello" "$CANDLE/wrappers/test_files/hello.c"
mpicc -o "$LOCAL_DIR/hello" "$CANDLE/wrappers/test_files/hello.c"

if [ "x$run_launcher" == "x1" ]; then
    if [ "x$SITE" == "xbiowulf" ]; then
        #srun "${TURBINE_LAUNCH_OPTIONS[@]}" --ntasks="$SLURM_NTASKS" --cpus-per-task="$SLURM_CPUS_PER_TASK" "$CANDLE/wrappers/test_files/hello"
        # shellcheck disable=SC2086
        srun $TURBINE_LAUNCH_OPTIONS --ntasks="$SLURM_NTASKS" --cpus-per-task="$SLURM_CPUS_PER_TASK" "$LOCAL_DIR/hello"
        ## Biowulf --> the above srun line indeed corresponds to this!
        #srun --mpi=pmix --ntasks=3 --cpus-per-task=16 --mem=0 "$CANDLE/wrappers/test_files/hello"
    elif [ "x$SITE" == "xsummit" ]; then
        # Summit
        jsrun --nrs=12 --tasks_per_rs=1 --cpu_per_rs=7 --gpu_per_rs=1 --rs_per_host=6 --bind=packed:7 --launch_distribution=packed -E OMP_NUM_THREADS=7 "$LOCAL_DIR/hello"
    fi
else
    echo "Skipping actual job launching since this was not requested"
fi

rm -f "$LOCAL_DIR/hello"
####################################################################################################################################


#### Install the R packages needed for the Supervisor workflows ####################################################################
echo -e "\n\n :::: Installing the R packages needed for the Supervisor workflows...\n"

if [ "x$on_biowulf" == "x1" ]; then
    if [ "$(find "$CANDLE/builds/R/libs" -maxdepth 1 | wc -l)" -eq 1 ]; then # if the directory is empty...
        curr_date=$(date +%Y-%m-%d_%H%M)
        "$CANDLE/Supervisor/workflows/common/R/install-candle.sh" |& tee -a "$LOCAL_DIR/candle-r_installation_out_and_err-$SITE-$curr_date.txt"
        mv "$LOCAL_DIR/candle-r_installation_out_and_err-$SITE-$curr_date.txt" "$CANDLE/wrappers/log_files"
    else
        echo "R packages probably already installed"
    fi
else
    echo -e "\nSkipping installation of R packages needed for the Supervisor workflows since we are not on Biowulf (and they are therefore already set up)\n"
fi
####################################################################################################################################


#### Build Swift/T #################################################################################################################
echo -e "\n\n :::: Building Swift/T...\n"

if [ "x$on_biowulf" == "x1" ]; then
    # Note: To rebuild Swift/T, I can do: “rm -rf $CANDLE/builds/R/libs/* $CANDLE/swift-t-install/* $CANDLE/Supervisor/workflows/common/ext/EQ-R/{libeqr.so,pkgIndex.tcl}"
    if [ "$(find "$CANDLE/swift-t-install/" -maxdepth 1 | wc -l)" -eq 1 ]; then # if the directory is empty...

        # Set up the settings file
        if [ "x$interactive" == "x1" ]; then
            cp -i "$CANDLE/wrappers/swift-t_setup/swift-t-settings-$SITE.sh" "$CANDLE/swift-t/dev/build/swift-t-settings.sh"
        else
            echo -e "\nNOT copying $CANDLE/wrappers/swift-t_setup/swift-t-settings-$SITE.sh to $CANDLE/swift-t/dev/build/swift-t-settings.sh\n"
        fi
        echo "Now edit $CANDLE/swift-t/dev/build/swift-t-settings.sh as appropriate (or the \$CANDLE_... variables in $CANDLE/Supervisor/workflows/common/sh/env-$SITE.sh), comparing with $CANDLE/swift-t/dev/build/swift-t-settings.sh.template (or comparing that template with $CANDLE/wrappers/swift-t_setup/swift-t-settings.sh.template), if needed"
        check_file_before_continuing "$CANDLE/swift-t/dev/build/swift-t-settings.sh"

        # Do the build
        curr_date=$(date +%Y-%m-%d_%H%M)
        export NICE_CMD=""
        "$CANDLE/swift-t/dev/build/build-swift-t.sh" -v |& tee -a "$LOCAL_DIR/swift-t_installation_out_and_err-$SITE-$curr_date.txt"
        mv "$LOCAL_DIR/swift-t_installation_out_and_err-$SITE-$curr_date.txt" "$CANDLE/wrappers/log_files"
    else
        echo "Swift/T probably already built"
    fi
else
    echo -e "\nSkipping build of Swift/T since we are not on Biowulf (and it is therefore already built)\n"
fi
####################################################################################################################################


#### Build EQ-R ####################################################################################################################
echo -e "\n\n :::: Building EQ-R...\n"

if [ "x$on_biowulf" == "x1" ]; then
    if [ "$(find "$CANDLE/Supervisor/workflows/common/ext/EQ-R/" -maxdepth 1 | wc -l)" -eq 3 ]; then # if the directory is essentially empty (only containing the eqr directory and EQR.swift file)...

        # Set up the settings file
        if [ "x$interactive" == "x1" ]; then
            cp -i "$CANDLE/wrappers/swift-t_setup/eqr_settings-$SITE.sh" "$CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr/settings.sh"
        else
            echo -e "\nNOT copying $CANDLE/wrappers/swift-t_setup/eqr_settings-$SITE.sh to $CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr/settings.sh\n"
        fi
        echo "Now edit $CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr/settings.sh as appropriate (or the \$CANDLE_... variables in $CANDLE/Supervisor/workflows/common/sh/env-$SITE.sh), comparing with $CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr/settings.template.sh (or comparing that template with $CANDLE/wrappers/swift-t_setup/eqr_settings.sh.template), if needed"
        check_file_before_continuing "$CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr/settings.sh"

        # Do the build
        curr_date=$(date +%Y-%m-%d_%H%M)
        (
            cd "$CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr"
            # shellcheck source=/dev/null
            source ./settings.sh
            ./bootstrap # this runs ``autoconf`` and generates ``./configure``
            ./configure --prefix="$PWD/.."
            make install
        ) |& tee -a "$CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr/eqr_installation_out_and_err-$SITE-$curr_date.txt"
        mv "$CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr/eqr_installation_out_and_err-$SITE-$curr_date.txt" "$CANDLE/wrappers/log_files"

    else
        echo "EQ-R probably already built"
    fi
else
    echo -e "\nSkipping build of EQ-R since we are not on Biowulf (and it is therefore already built)\n"
fi
####################################################################################################################################


#### Optionally run a CANDLE benchmark just to see if that would work ##############################################################
echo -e "\n\n :::: Running a CANDLE benchmark on a single node...\n"

echo -n "Would you like to try running a CANDLE benchmark using Python on a single node? (y/n)? "
if [ "x$interactive" == "x1" ]; then
    read -r response 0<&3
else
    echo -e "\nNOT running a CANDLE benchmark\n"
    response="n"
fi
if [ "x$response" == "xy" ]; then
    echo "Okay, running the benchmark now; hit Ctrl+C to kill the process; then re-run this script"
    #echo -e "\n ::::: Using srun: $(command -v srun)"
    echo -e " ::::: Using python: $(command -v python)\n"

    if [ "x$run_launcher" == "x1" ]; then
        if [ "x$SITE" == "xbiowulf" ]; then
            # shellcheck disable=SC2086
            srun $TURBINE_LAUNCH_OPTIONS --ntasks=1 python "$CANDLE/Benchmarks/Pilot1/P1B3/p1b3_baseline_keras2.py"
        elif [ "x$SITE" == "xsummit" ]; then
            # Summit
            #jsrun --nrs=1 --tasks_per_rs=1 --cpu_per_rs=7 --gpu_per_rs=1 --rs_per_host=6 --bind=packed:7 --launch_distribution=packed -E OMP_NUM_THREADS=7 python "$CANDLE/Benchmarks/Pilot1/P1B3/p1b3_baseline_keras2.py"
            jsrun --nrs=1 --tasks_per_rs=1 --cpu_per_rs=7 --gpu_per_rs=1 --rs_per_host=1 --bind=packed:7 --launch_distribution=packed -E OMP_NUM_THREADS=7 python "$CANDLE/Benchmarks/Pilot1/P1B3/p1b3_baseline_keras2.py"
        fi
    else
        echo "Skipping actual job launching since this was not requested"
    fi

else
    echo "Okay, skipping the benchmark run"
fi
####################################################################################################################################


#### Run two Swift/T hello world scripts ###########################################################################################
echo -e "\n\n :::: Running two Swift/T hello world tests...\n"

# Setup
BUILD_SCRIPTS_DIR="$CANDLE/wrappers/test_files"
echo -e " ::::: Using swift-t: $(command -v swift-t)\n"

# Test 1: Output is a single line saying hello
#swift-t -VV -n 3 "$BUILD_SCRIPTS_DIR/mytest2.swift"
swift-t -n 3 "$BUILD_SCRIPTS_DIR/mytest2.swift"

# Test 2: Time-delayed printouts of some numbers
#swift-t -VV -n 3 -r "$BUILD_SCRIPTS_DIR" "$BUILD_SCRIPTS_DIR/myextension.swift"
swift-t -n 3 -r "$BUILD_SCRIPTS_DIR" "$BUILD_SCRIPTS_DIR/myextension.swift"
####################################################################################################################################


# #### Ensure permissions are correct ################################################################################################
# echo -e "\n\n :::: Setting permissions recursively on CANDLE directory...\n"

# chmod -R g=u,o=u-w "$CANDLE"
# ####################################################################################################################################


# # Print whether the previous commands were successful
# echo "Probably successful setup, but you still should check the output!"
