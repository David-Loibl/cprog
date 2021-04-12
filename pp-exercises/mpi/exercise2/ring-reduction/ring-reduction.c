#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[])  // global and partial sum
{
    int size, rank;
    int sum, i;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    MPI_Reduce(&rank, &sum, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) printf("global sum = %d\n", sum);

    MPI_Scan(&rank, &sum, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);

    if (rank != 0) {
	MPI_Send(&sum, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
    } else {
	for (i = 0; i < size; i++) {
	    if (i > 0) MPI_Recv(&sum, 1, MPI_INT, i, 0, 
				MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	    printf("partial sum(%d) = %d\n", i, sum);
	}
    }

    MPI_Finalize();
    return 0;
}  
