/*The Parallel Hello World Program*/

#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char **argv) {
    // Initialize the MPI environment
    MPI_Init(&argc,&argv);

    // Get the number of processes
    int ntasks; // also called world_size
    MPI_Comm_size(MPI_COMM_WORLD, &ntasks);

    // Get the rank of the process
    int task; // also called world_rank
    MPI_Comm_rank(MPI_COMM_WORLD, &task);

    // Get the name of the processor
    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(processor_name, &name_len);

    // Get the topology address
    char *topology_addr; // char
    topology_addr = getenv("SLURM_TOPOLOGY_ADDR");

    // Get the hostname
    char hostname[50] = {'\0'};
    gethostname(hostname, 49);

    // Get the allocated GPU
    char *cuda_visible_devices; // char
    cuda_visible_devices = getenv("CUDA_VISIBLE_DEVICES");

    // Print off a hello world message
    printf("Hello from slurm topology address %s (hostname %s), processor %s, rank %d / %d (CUDA_VISIBLE_DEVICES=%s)\n", topology_addr, hostname, processor_name, task, ntasks, cuda_visible_devices);

    // Finalize the MPI environment
    MPI_Finalize();

}
