#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#define MAX_I 20
#define MAX_COUNT (1024 * 1024)

double buf[MAX_COUNT];

int main(int argc, char *argv[])  // ping pong
{
    int size, rank, partner, i, count, r, repetitions;
    double time, bandwidth;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (size != 2) {
        fprintf(stderr, "comm_size != 2\n");
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    if (rank == 0) {
        puts("message size    number of         time    bandwidth");
        puts("     [bytes]  repetitions         [us]       [MB/s]");
        puts("---------------------------------------------------");
    }
                     
    partner = 1 - rank;
    count = 1;
    repetitions = MAX_COUNT;

    for (i = 0; i <= MAX_I; i++) {
        time = MPI_Wtime();
        for (r = 0; r < repetitions; r++) {
            if (rank == 0) {
                MPI_Send(buf, count, MPI_DOUBLE, partner, 0, MPI_COMM_WORLD);
                MPI_Recv(buf, count, MPI_DOUBLE, partner, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            } else {
                MPI_Recv(buf, count, MPI_DOUBLE, partner, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
                MPI_Send(buf, count, MPI_DOUBLE, partner, 0, MPI_COMM_WORLD);
            }
        }
        time = MPI_Wtime() - time;
        time = time / (2.0 * repetitions);
        time = 1e6 * time;  // micro-seconds
        bandwidth = count * sizeof(double) / time;  // MByte/s

        if (rank == 0)
            printf("%12zd %12d %12.2f %12.2f\n", count * sizeof(double), repetitions, time, bandwidth);
        count = count * 2;
        repetitions = repetitions / 2;
    }

    MPI_Finalize();
    return 0;
}  
