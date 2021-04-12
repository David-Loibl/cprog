#include <stdio.h>
#include <mpi.h>

typedef struct myStruct { double x; int i; } myStruct;

int main(int argc, char *argv[])  // ring with derived datatype
{
    int size, rank;
    int partner_left, partner_right;
    int len[2];
    myStruct sum, sbuf, rbuf;
    MPI_Aint disp[2];
    MPI_Datatype type[2];
    MPI_Datatype myType;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    partner_left  = (rank - 1 + size) % size;
    partner_right = (rank + 1) % size;

    len[0] = 1;
    len[1] = 1;

    MPI_Get_address(&sum.x, &disp[0]);
    MPI_Get_address(&sum.i, &disp[1]);
 
    disp[1] -= disp[0];
    disp[0] -= disp[0];

    type[0] = MPI_DOUBLE;
    type[1] = MPI_INT;

    MPI_Type_create_struct(2, len, disp, type, &myType);
    MPI_Type_commit(&myType);

    sum.x = 0;
    sum.i = 0;
    sbuf.x = rank;
    sbuf.i = rank;

    do {
	MPI_Sendrecv(&sbuf, 1, myType, partner_right, 0,
		     &rbuf, 1, myType, partner_left, 0, 
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	sum.x += rbuf.x;
	sum.i += rbuf.i;
	sbuf.x = rbuf.x;
	sbuf.i = rbuf.i;
    } while (rbuf.i != rank);
  
    printf("sums on rank %d: %f, %d\n", rank, sum.x, sum.i);
    
    MPI_Finalize();
    return 0;
}  
