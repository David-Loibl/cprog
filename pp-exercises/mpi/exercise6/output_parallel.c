# include <stdio.h>
# include <mpi.h>
# include "laplace.h"
# include "decomp.h"

void output_parallel(field v, int Lx, int Ly)
{
    int        y;
    MPI_File   fh;     // file handle
    MPI_Offset offset;

    MPI_File_open(MPI_COMM_WORLD, "laplace.dat2", 
		  MPI_MODE_CREATE + MPI_MODE_WRONLY,
		  MPI_INFO_NULL, &fh);

    for (y = 1; y <= Ly; y++) {
	offset = (decomp.coord_y * Ly + y - 1) * decomp.Nx
	       + (decomp.coord_x) * Lx;
        offset *= sizeof(double);
	MPI_File_seek(fh, offset, MPI_SEEK_SET);
	MPI_File_write(fh, &v[y][1], Lx, MPI_DOUBLE, MPI_STATUS_IGNORE);
    }
                
    MPI_File_close(&fh);
}
