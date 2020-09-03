#!/bin/bash

# The point of this script is for it to automatically complete new or even partial installations of CANDLE but to not re-install anything; that must be done explicitly if that's desired
# It should therefore run pretty quickly if everything is already installed, not changing anything significant
# We should be able to run this script without worrying about it overwritting something already there

check_file_before_continuing() {
    file_to_check=$1
    echo -n "Have you thoughly checked '$file_to_check' (y/n)? "
    read -r response
    if [ "x$response" != "xy" ]; then
        echo "Okay, go ahead and thoroughly check '$file_to_check' and re-run this script"
        exit 1
    fi
}

# Print commands just before execution
set -x

# Exit when any command fails
set -e

# Load the best Python module
module load "$DEFAULT_PYTHON_MODULE"

# Create the necessary directories not already created using the instructions in README.md
[ -d "$CANDLE/bin" ] || mkdir "$CANDLE/bin"
[ -d "$CANDLE/builds" ] || mkdir "$CANDLE/builds"

# Check out the necessary software from GitHub
[ -d "$CANDLE/checkouts/Supervisor" ] || git clone --branch develop https://github.com/ECP-CANDLE/Supervisor "$CANDLE/checkouts/Supervisor"
[ -d "$CANDLE/checkouts/Benchmarks" ] || git clone --branch develop https://github.com/ECP-CANDLE/Benchmarks "$CANDLE/checkouts/Benchmarks"
[ -d "$CANDLE/checkouts/swift-t" ] || git clone https://github.com/swift-lang/swift-t "$CANDLE/checkouts/swift-t"

# Create the build subdirectories
[ -d "$CANDLE/builds/R/libs" ] || mkdir -p "$CANDLE/builds/R/libs"
[ -d "$CANDLE/builds/swift-t-install" ] || mkdir "$CANDLE/builds/swift-t-install"

# Create symbolic links in the main CANDLE directory
[ -L "$CANDLE/wrappers" ] || ln -s "$CANDLE/checkouts/wrappers" "$CANDLE/wrappers"
[ -L "$CANDLE/Supervisor" ] || ln -s "$CANDLE/checkouts/Supervisor" "$CANDLE/Supervisor"
[ -L "$CANDLE/Benchmarks" ] || ln -s "$CANDLE/checkouts/Benchmarks" "$CANDLE/Benchmarks"
[ -L "$CANDLE/swift-t" ] || ln -s "$CANDLE/checkouts/swift-t" "$CANDLE/swift-t"
[ -L "$CANDLE/R" ] || ln -s "$CANDLE/builds/R" "$CANDLE/R"
[ -L "$CANDLE/swift-t-install" ] || ln -s "$CANDLE/builds/swift-t-install" "$CANDLE/swift-t-install"

# Load the CANDLE environment
check_file_before_continuing "$CANDLE/Supervisor/workflows/common/sh/env-biowulf.sh"
# shellcheck source=/dev/null
source "$CANDLE/Supervisor/workflows/common/sh/env-biowulf.sh"

# Test MPI communications
mpicc -o "$CANDLE/wrappers/test_files/hello" "$CANDLE/wrappers/test_files/hello.c"
srun --mpi=pmix --ntasks="$SLURM_NTASKS" --cpus-per-task="$SLURM_CPUS_PER_TASK" --mem=0 "$CANDLE/wrappers/test_files/hello"

# Set and enter the local scratch directory
LOCAL_DIR="/lscratch/$SLURM_JOB_ID"
cd "$LOCAL_DIR"

# Install the R packages needed for the Supervisor workflows
if [ "$(find "$CANDLE/builds/R/libs" -maxdepth 1 | wc -l)" -eq 1 ]; then # if the directory is empty...
    "$CANDLE/Supervisor/workflows/common/R/install-candle.sh" |& tee -a "$LOCAL_DIR/candle-r_installation_out_and_err.txt"
    mv "$LOCAL_DIR/candle-r_installation_out_and_err.txt" "$CANDLE/wrappers/log_files"
fi


# Build Swift/T
if [ "$(find "$CANDLE/swift-t-install/" -maxdepth 1 | wc -l)" -eq 1 ]; then # if the directory is empty...
    cp -i "$CANDLE/wrappers/swift-t_setup/swift-t-settings-biowulf.sh" "$CANDLE/swift-t/dev/build/swift-t-settings.sh"
    cp -i "$CANDLE/wrappers/swift-t_setup/build-turbine.sh" "$CANDLE/swift-t/dev/build/build-turbine.sh"
    echo "Now edit $CANDLE/swift-t/dev/build/swift-t-settings.sh as appropriate, comparing with $CANDLE/swift-t/dev/build/swift-t-settings.sh.template (or comparing that template with $CANDLE/wrappers/swift-t_setup/swift-t-settings.sh.template), if needed"
    check_file_before_continuing "$CANDLE/swift-t/dev/build/swift-t-settings.sh"
    export NICE_CMD=""
    "$CANDLE/swift-t/dev/build/build-swift-t.sh" -v |& tee -a "$LOCAL_DIR/swift-t_installation_out_and_err.txt"
    mv "$LOCAL_DIR/swift-t_installation_out_and_err.txt" "$CANDLE/wrappers/log_files"
fi


# Print whether the previous commands were successful
set +x
echo "Probably success"
