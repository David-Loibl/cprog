#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[])  // hello world
{
    int size;
    int rank;
    int len_name;
    char name[MPI_MAX_PROCESSOR_NAME];

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Get_processor_name(name, &len_name);

    printf("MPI: size = %3d rank = %3d name = %s\n", size, rank, name);

    MPI_Finalize();
    return 0;
}  
