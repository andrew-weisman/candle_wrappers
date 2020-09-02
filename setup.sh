#!/bin/bash

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

# Ensure we've checked through env-biowulf.sh before actually using it
env_file="$CANDLE/Supervisor/workflows/common/sh/env-biowulf.sh"
echo -n "Have you thoughly checked '$env_file' (y/n)? "
read -r response
if [ "x$response" != "xy" ]; then
    echo "Okay, go ahead and thoroughly check '$env_file' and re-run this script"
    exit 1
fi

# Load the CANDLE environment
# shellcheck source=/dev/null
source "$CANDLE/Supervisor/workflows/common/sh/env-biowulf.sh"

# Test MPI communications
mpicc -o "$CANDLE/wrappers/test_files/hello" "$CANDLE/wrappers/test_files/hello.c"
#mpirun -n 3 "$CANDLE/wrappers/test_files/hello"
#mpiexec -n 3 "$CANDLE/wrappers/test_files/hello"
#srun -n 3 "$CANDLE/wrappers/test_files/hello"
srun --mpi=pmix --ntasks="$SLURM_NTASKS" --cpus-per-task="$SLURM_CPUS_PER_TASK" --mem=0 "$CANDLE/wrappers/test_files/hello"


# Install the R packages needed for the Supervisor workflows
# Yes, it may appear that the wrong version of GCC is being used (probably due to the R paths) but so far we've found this is fine
LOCAL_DIR="/lscratch/$SLURM_JOB_ID"
cd "$LOCAL_DIR" && "$CANDLE/Supervisor/workflows/common/R/install-candle.sh" |& tee -a "$LOCAL_DIR/candle-r_installation_out_and_err.txt"
mv "$LOCAL_DIR/candle-r_installation_out_and_err.txt" "$CANDLE/wrappers/log_files"


# Print whether the previous commands were successful
set +x
echo "Success"
