# include <stdio.h>
# include <mpi.h>

typedef struct myStruct { double x; int i; } myStruct;
MPI_Datatype myType;      // MPI datatype for myStruct
MPI_User_function myFun;  // reduction operation for myType
MPI_Op myOp;              // MPI operator for myFun

int main(int argc, char *argv[])  // user defined datatype and operator
{
    myStruct s, res;
    int rank, len[2];
    MPI_Aint disp[2];
    MPI_Datatype type[2];
 
    MPI_Init(&argc, &argv);

    len[0] = 1;
    len[1] = 1;

    MPI_Get_address(&s.x, &disp[0]);
    MPI_Get_address(&s.i, &disp[1]);
 
    disp[1] -= disp[0];
    disp[0] -= disp[0];

    type[0] = MPI_DOUBLE;
    type[1] = MPI_INT;

    MPI_Type_create_struct(2, len, disp, type, &myType);
    MPI_Type_commit(&myType);
    MPI_Op_create(myFun, 1, &myOp);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    s.x = rank;
    s.i = rank;

    MPI_Reduce(&s, &res, 1, myType, myOp, 0, MPI_COMM_WORLD);

    if (rank == 0) printf("result: %f, %i\n", res.x, res.i);

    MPI_Type_free(&myType);
    MPI_Op_free(&myOp);
    MPI_Finalize();
    return 0;
}

void myFun(void* in, void* inout, int* len, MPI_Datatype *type)
{
    myStruct *i = (myStruct *) in;
    myStruct *io = (myStruct *) inout;
    int j;

    if (*type == myType) {
	for (j = 0; j < *len; j++) {
	    io[j].x += i[j].x;
	    io[j].i += i[j].i;
	}
    } else {
	fputs("myFun: unknown type\n", stderr);
	MPI_Abort(MPI_COMM_WORLD, 1);
    }
}
