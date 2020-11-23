#!/bin/bash

# The point of this script is for it to automatically complete new or even partial installations of CANDLE but to not re-install anything; that must be done explicitly if that's desired
# It should therefore run pretty quickly if everything is already installed, not changing anything significant
# We should be able to run this script without worrying about it overwriting something already there
# If the task is optional and takes a while, prompt the user whether s/he wants to undertake it
# All tasks that make modifications should be checked if they've already been done
# All prompts should have an interactive mode workaround
# This script should be run like 'bash "$CANDLE/checkouts/wrappers/setup.sh"''
# ASSUMPTIONS:
#   (1) The candle module is loaded as usual
#   (2) Running this script in interactive or batch mode (i.e., not on a login node) so that srun, jsrun, etc. (the launchers) can be run


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
    tmp_exec=$(command -v "$prog" || junk=assignment )
    [[ "x$tmp_exec" == "x" ]] && echo -e "\nWARNING: Program '$prog' not found\n" || echo -e "\nUsing $prog executable $tmp_exec\n"
}


# Settings for the current script
run_launcher=1 # default should be 1. This says whether to run any command that uses srun or jsrun for example
interactive=1 # default should be 1. This says whether to run any read or cp -i statements
set -e # exit when any command fails

# Set the site-specific settings
# shellcheck source=/dev/null
source "$CANDLE/checkouts/wrappers/site-specific_settings.sh"

# Enter the fast-access directory in order to speed up compilation
#cd "$CANDLE_SETUP_LOCAL_DIR"


#### Set up the directory structure and clone the necessary repositories ###########################################################
echo -e "\n\n :::: Setting up directory structure and cloning necessary repositories...\n"

# Create the necessary directories not already created using the instructions in setup-$SITE.md
[ -d "$CANDLE/builds" ] || mkdir "$CANDLE/builds"

# Check out the necessary software from GitHub
[ -d "$CANDLE/checkouts/Supervisor" ] || git clone --branch develop https://github.com/ECP-CANDLE/Supervisor "$CANDLE/checkouts/Supervisor"
[ -d "$CANDLE/checkouts/Benchmarks" ] || git clone --branch develop https://github.com/ECP-CANDLE/Benchmarks "$CANDLE/checkouts/Benchmarks"
if [ "x$CANDLE_SETUP_COMPILE_SWIFT_T" == "x1" ]; then
    [ -d "$CANDLE/checkouts/swift-t" ] || git clone https://github.com/swift-lang/swift-t "$CANDLE/checkouts/swift-t"
fi

# Create the build subdirectories
if [ "x$CANDLE_SETUP_BUILD_SUPERVISOR_R_PACKAGES" == "x1" ]; then
    [ -d "$CANDLE/builds/R/libs" ] || mkdir -p "$CANDLE/builds/R/libs"
else
    [ -d "$CANDLE/builds/R" ] || mkdir -p "$CANDLE/builds/R"
    [ -L "$CANDLE/builds/R/libs" ] || ln -s "$CANDLE_SETUP_R_LIBS" "$CANDLE/builds/R/libs"
fi
if [ "x$CANDLE_SETUP_COMPILE_SWIFT_T" == "x1" ]; then
    [ -d "$CANDLE/builds/swift-t-install" ] || mkdir "$CANDLE/builds/swift-t-install"
else
    [ -L "$CANDLE/builds/swift-t-install" ] || ln -s "$CANDLE_SETUP_SWIFT_T" "$CANDLE/builds/swift-t-install"
fi

# Create symbolic links in the main CANDLE directory
[ -L "$CANDLE/wrappers" ] || ln -s "$CANDLE/checkouts/wrappers" "$CANDLE/wrappers"
[ -L "$CANDLE/Supervisor" ] || ln -s "$CANDLE/checkouts/Supervisor" "$CANDLE/Supervisor"
[ -L "$CANDLE/Benchmarks" ] || ln -s "$CANDLE/checkouts/Benchmarks" "$CANDLE/Benchmarks"
if [ "x$CANDLE_SETUP_COMPILE_SWIFT_T" == "x1" ]; then
    [ -L "$CANDLE/swift-t" ] || ln -s "$CANDLE/checkouts/swift-t" "$CANDLE/swift-t"
fi
[ -L "$CANDLE/R" ] || ln -s "$CANDLE/builds/R" "$CANDLE/R"
[ -L "$CANDLE/swift-t-install" ] || ln -s "$CANDLE/builds/swift-t-install" "$CANDLE/swift-t-install"
####################################################################################################################################


#### Set up the non-Python environment #############################################################################################
echo -e "\n\n :::: Setting up the build environment...\n"

# Check the settings file $CANDLE/Supervisor/workflows/common/sh/env-$SITE.sh
check_file_before_continuing "$CANDLE/Supervisor/workflows/common/sh/env-$SITE.sh"

# shellcheck source=/dev/null
source "$CANDLE/Supervisor/workflows/common/sh/env-$SITE.sh"

# Output the executables to be used for Swift/T and Python
determine_executable swift-t
####################################################################################################################################


#### Test MPI communications using an MPI hello world script #######################################################################
echo -e "\n\n :::: Testing MPI communications...\n"

# Compile and run MPI hello world
echo " ::::: Using mpicc: $(command -v mpicc)"
#mpicc -o "$CANDLE_SETUP_LOCAL_DIR/hello" "$CANDLE/wrappers/test_files/hello.c"
mpicc -o "./hello" "$CANDLE/wrappers/test_files/hello.c"

if [ "x$run_launcher" == "x1" ]; then

    # if [ "$CANDLE_SETUP_LOCAL_DIR" != "$PWD" ]; then
    #     cd - &> /dev/null
    #     cp "$CANDLE_SETUP_LOCAL_DIR/hello" .
    # fi

    # shellcheck disable=SC2086
    $CANDLE_SETUP_JOB_LAUNCHER $CANDLE_SETUP_MPI_HELLO_WORLD_LAUNCHER_OPTIONS ./hello

    # if [ "$CANDLE_SETUP_LOCAL_DIR" != "$PWD" ]; then
    #     rm -f ./hello
    #     cd - &> /dev/null
    # fi

else
    echo "Skipping actual job launching since this was not requested"
fi

#rm -f "$CANDLE_SETUP_LOCAL_DIR/hello"
rm -f "./hello"
####################################################################################################################################


#### Install the R packages needed for the Supervisor workflows ####################################################################
echo -e "\n\n :::: Installing the R packages needed for the Supervisor workflows...\n"

pushd "$CANDLE_SETUP_LOCAL_DIR"

if [ "x$CANDLE_SETUP_BUILD_SUPERVISOR_R_PACKAGES" == "x1" ]; then
    if [ "$(find "$CANDLE/builds/R/libs" -maxdepth 1 | wc -l)" -eq 1 ]; then # if the directory is empty...
        curr_date=$(date +%Y-%m-%d_%H%M)
        "$CANDLE/Supervisor/workflows/common/R/install-candle.sh" |& tee -a "$CANDLE_SETUP_LOCAL_DIR/candle-r_installation_out_and_err-$SITE-$curr_date.txt"
        mv "$CANDLE_SETUP_LOCAL_DIR/candle-r_installation_out_and_err-$SITE-$curr_date.txt" "$CANDLE/wrappers/log_files"
    else
        echo "R packages probably already installed"
    fi
else
    echo -e "\nSkipping installation of R packages needed for the Supervisor workflows because we're assuming they're already set up\n"
fi

popd
####################################################################################################################################


#### Set up Python #################################################################################################################
# Note on Biowulf we cannot have this loaded while the R packages are installed above, or else we get an error when trying to install the openssl package; that's why we're setting up Python here, after the R package build
echo -e "\n\n :::: Setting up Python...\n"

# shellcheck source=/dev/null
source "$CANDLE/wrappers/utilities.sh"; load_python_env

# Output the executables to be used for Swift/T and Python
determine_executable python
####################################################################################################################################


#### Build Swift/T #################################################################################################################
echo -e "\n\n :::: Building Swift/T...\n"

pushd "$CANDLE_SETUP_LOCAL_DIR"

if [ "x$CANDLE_SETUP_COMPILE_SWIFT_T" == "x1" ]; then
    # Note: To rebuild Swift/T, I can do: “rm -rf $CANDLE/builds/R/libs/* $CANDLE/swift-t-install/* $CANDLE/Supervisor/workflows/common/ext/EQ-R/{libeqr.so,pkgIndex.tcl}"
    if [ "$(find "$CANDLE/swift-t-install/" -maxdepth 1 | wc -l)" -eq 1 ]; then # if the directory is empty...

        # Set up the settings file
        if [ "x$interactive" == "x1" ]; then
            cp -i "$CANDLE/wrappers/swift-t_setup/swift-t-settings-$SITE.sh" "$CANDLE/swift-t/dev/build/swift-t-settings.sh"
        else
            echo -e "\nNOT copying $CANDLE/wrappers/swift-t_setup/swift-t-settings-$SITE.sh to $CANDLE/swift-t/dev/build/swift-t-settings.sh\n"
        fi
        echo "Now edit $CANDLE/swift-t/dev/build/swift-t-settings.sh as appropriate (or the \$CANDLE_... variables in $CANDLE/wrappers/site-specific_settings.sh), comparing with $CANDLE/swift-t/dev/build/swift-t-settings.sh.template (or comparing that template with $CANDLE/wrappers/swift-t_setup/swift-t-settings.sh.template), if needed"
        check_file_before_continuing "$CANDLE/swift-t/dev/build/swift-t-settings.sh"

        # Do the build
        curr_date=$(date +%Y-%m-%d_%H%M)
        export NICE_CMD=""
        "$CANDLE/swift-t/dev/build/build-swift-t.sh" -v |& tee -a "$CANDLE_SETUP_LOCAL_DIR/swift-t_installation_out_and_err-$SITE-$curr_date.txt"
        mv "$CANDLE_SETUP_LOCAL_DIR/swift-t_installation_out_and_err-$SITE-$curr_date.txt" "$CANDLE/wrappers/log_files"
    else
        echo "Swift/T probably already built"
    fi
else
    echo -e "\nSkipping build of Swift/T because we're assuming it's already set up\n"
fi

popd
####################################################################################################################################


#### Build EQ-R ####################################################################################################################
echo -e "\n\n :::: Building EQ-R...\n"

pushd "$CANDLE_SETUP_LOCAL_DIR"

if [ "x$CANDLE_SETUP_COMPILE_SWIFT_T" == "x1" ]; then
    if [ "$(find "$CANDLE/Supervisor/workflows/common/ext/EQ-R/" -maxdepth 1 | wc -l)" -eq 3 ]; then # if the directory is essentially empty (only containing the eqr directory and EQR.swift file)...

        # Set up the settings file
        if [ "x$interactive" == "x1" ]; then
            cp -i "$CANDLE/wrappers/swift-t_setup/eqr_settings-$SITE.sh" "$CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr/settings.sh"
        else
            echo -e "\nNOT copying $CANDLE/wrappers/swift-t_setup/eqr_settings-$SITE.sh to $CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr/settings.sh\n"
        fi
        echo "Now edit $CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr/settings.sh as appropriate (or the \$CANDLE_... variables in $CANDLE/wrappers/site-specific_settings.sh), comparing with $CANDLE/Supervisor/workflows/common/ext/EQ-R/eqr/settings.template.sh (or comparing that template with $CANDLE/wrappers/swift-t_setup/eqr_settings.sh.template), if needed"
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
    echo -e "\nSkipping build of EQ-R because we're assuming it's already set up\n"
fi

popd
####################################################################################################################################


#### Optionally run a CANDLE benchmark just to see if that would work ##############################################################
echo -e "\n\n :::: Running a CANDLE benchmark on a single node...\n"

pushd "$CANDLE_SETUP_LOCAL_DIR"

#benchmark="$CANDLE/Benchmarks/Pilot1/P1B3/p1b3_baseline_keras2.py"
#benchmark="$CANDLE/Benchmarks/Pilot1/Uno/uno_baseline_keras2.py"
#benchmark="$CANDLE/Benchmarks/Pilot1/Combo/combo_baseline_keras2.py"
#benchmark="$CANDLE/Benchmarks/Pilot1/TC1/tc1_baseline_keras2.py"
benchmark="$CANDLE/Benchmarks/Pilot1/NT3/nt3_baseline_keras2.py"

echo -n "Would you like to try running a CANDLE benchmark using Python on a single node? (y/n)? "
if [ "x$interactive" == "x1" ]; then
    read -r response 0<&3
else
    echo -e "\nNOT running a CANDLE benchmark\n"
    response="n"
fi
if [ "x$response" == "xy" ]; then
    echo "Okay, running the benchmark now; hit Ctrl+C to kill the process; then re-run this script"
    echo -e " ::::: Using python: $(command -v python)\n"

    if [ "x$run_launcher" == "x1" ]; then
        # shellcheck disable=SC2086
        $CANDLE_SETUP_JOB_LAUNCHER $CANDLE_SETUP_SINGLE_TASK_LAUNCHER_OPTIONS python "$benchmark"
    else
        echo "Skipping actual job launching since this was not requested"
    fi

else
    echo "Okay, skipping the benchmark run"
fi

popd
####################################################################################################################################


#### Run two Swift/T hello world scripts ###########################################################################################
echo -e "\n\n :::: Running two Swift/T hello world tests...\n"

# Setup
echo -e " ::::: Using swift-t: $(command -v swift-t)\n"

# Ensure $TURBINE_LAUNCHER is set so that we can run Swift/T in interactive mode
export TURBINE_LAUNCHER="$CANDLE_SETUP_JOB_LAUNCHER"

# Test 1: Output is a single line saying hello
swift-t -n 3 "$CANDLE/wrappers/test_files/mytest2.swift"

# Test 2: Time-delayed printouts of some numbers
swift-t -n 3 -r "$CANDLE/wrappers/test_files" "$CANDLE/wrappers/test_files/myextension.swift"
####################################################################################################################################


#### Ensure permissions are correct ################################################################################################
echo -e "\n\n :::: Setting permissions recursively on CANDLE directory...\n"

chmod -R g=u,o=u-w "$CANDLE"
####################################################################################################################################


# Print whether the previous commands were successful
echo "Probably successful setup, but you still should check the output!"
