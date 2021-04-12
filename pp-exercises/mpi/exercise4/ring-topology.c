#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[])  // topology (process neighbours in 1 dimension)
{
    MPI_Comm comm_ring;
    int size, rank, rank2;
    int partner_left, partner_right;
    int sum, sbuf, rbuf, i;
    int dim, period;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    dim = size;
    period = 1;

    MPI_Cart_create(MPI_COMM_WORLD, 1, &dim, &period, 1, &comm_ring);
    MPI_Cart_shift(comm_ring, 0, 1, &partner_left, &partner_right);
    MPI_Comm_rank(comm_ring, &rank2);

    sum = 0;
    sbuf = rank2;

    do {
	MPI_Sendrecv(&sbuf, 1, MPI_INT, partner_right, 0,
                     &rbuf, 1, MPI_INT, partner_left, 0, 
                     comm_ring, MPI_STATUS_IGNORE);
	sum += rbuf;
	sbuf = rbuf;
    } while (rbuf != rank2);

    printf("rank = %d, rank2 = %d : sum = %d\n", rank, rank2, sum);

    MPI_Finalize();
    return 0;
}
