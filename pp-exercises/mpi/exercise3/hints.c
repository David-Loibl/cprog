# include <stdio.h>
# include <mpi.h>

// make a type definition available everywhere
typedef struct myStruct { double x; int i; } myStruct;

// will become MPI reduction operator (is very similar to MPI_User_function)
typedef void myUserFunction(void* in, void* inout, int* len, int *type);

// call myUserFunction from another routine (substitute for MPI)
void sum(myUserFunction f, myStruct *x, myStruct *y, myStruct *z);

int main(int argc, char *argv[])  // user defined datatype and operator
{
    myStruct a, b, s;
    myUserFunction myFun;

    a.x = 1;
    a.i = 2;

    b.x = 10;
    b.i = 20;

    sum(myFun, &a, &b, &s);

    printf("%f %d\n", s.x, s.i);

    return 0;
}

void sum(myUserFunction fun, myStruct *x, myStruct *y, myStruct *z)
{
    int one = 1;
    int type = 0;

    z->x = x->x;
    z->i = x->i;

    fun(y, z, &one, &type);
}

void myFun(void* in, void* inout, int* len, int *type)
{
    myStruct *i = (myStruct *) in;
    myStruct *io = (myStruct *) inout;
    int j;

    for (j = 0; j < *len; j++) {
	io[j].x += i[j].x;
	io[j].i += i[j].i;
    }
}
