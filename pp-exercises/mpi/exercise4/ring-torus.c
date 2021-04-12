#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char *argv[])  // torus topology
{
    MPI_Comm comm_ring, comm_torus, comm_row;
    int size, rank, rank2, rank3;
    int partner_left, partner_right;
    int sum, sbuf, rbuf, i;
    int dims[2], coords[2], periods[2], remain_dims[2];

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (argc != 3) {
        fprintf(stderr, "Usage: ring-torus dims1 dims2\n");
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    dims[0] = atoi(argv[1]);
    dims[1] = atoi(argv[2]);

    if (dims[0] * dims[1] != size) {
	fprintf(stderr, "ring-torus: dims1 * dims2 /= n_procs\n");
	MPI_Abort(MPI_COMM_WORLD, 1);
    }

    periods[0] = 1;
    periods[1] = 1; 
    remain_dims[0] = 0;
    remain_dims[1] = 1;

    MPI_Cart_create(MPI_COMM_WORLD, 2, dims, periods, 1, &comm_torus);
    MPI_Comm_rank(comm_torus, &rank2);
    MPI_Cart_coords(comm_torus, rank2, 2, coords);

    MPI_Cart_sub(comm_torus, remain_dims, &comm_row);
    MPI_Comm_rank(comm_row, &rank3);
  
    printf("ranks(orig,torus,row) = %d,%d,%d : coords (x,y) = (%d,%d)\n", 
	   rank, rank2, rank3, coords[0], coords[1]);

    MPI_Cart_shift(comm_row, 0, 1, &partner_left, &partner_right);

    sum = 0;
    sbuf = rank3;

    do {
	MPI_Sendrecv(&sbuf, 1, MPI_INT, partner_right, 0,
                     &rbuf, 1, MPI_INT, partner_left, 0, 
                     comm_row, MPI_STATUS_IGNORE);
	sum += rbuf;
	sbuf = rbuf;
    } while (rbuf != rank3);

    printf("torus-sum(%d,%d) = %d\n", coords[0], coords[1], sum);

    MPI_Finalize();
    return 0;
}
