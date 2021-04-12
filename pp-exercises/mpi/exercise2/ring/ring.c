#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[])  // ring
{
    int size, rank;
    int partner_left, partner_right;
    int sum, sbuf, rbuf;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    partner_left  = (rank - 1 + size) % size;
    partner_right = (rank + 1) % size;

    sum = 0;
    sbuf = rank;

    do {
	MPI_Sendrecv(&sbuf, 1, MPI_INT, partner_right, 0,
		     &rbuf, 1, MPI_INT, partner_left, 0, 
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	sum += rbuf;
	sbuf = rbuf;
    } while (rbuf != rank);
  
    printf("%d %d\n", rank, sum);
    
    MPI_Finalize();
    return 0;
}  
