#include <stdio.h>
#include <mpi.h>
#include <omp.h>

int main(int argc, char *argv[])  // hybrid 'hello world' program
{
    int size;
    int rank;
    int len;
    char name[MPI_MAX_PROCESSOR_NAME];

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Get_processor_name(name, &len);

    #pragma omp parallel
    {
        printf("node %s : process %3d/%d : thread %3d/%d\n", 
                name, rank, size, 
                omp_get_thread_num(), omp_get_num_threads());
    }

    MPI_Finalize();
    return 0;
}  
