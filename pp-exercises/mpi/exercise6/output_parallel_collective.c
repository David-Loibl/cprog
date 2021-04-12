# include <stdio.h>
# include <mpi.h>
# include "laplace.h"
# include "decomp.h"

void output_parallel(field v, int Lx, int Ly)  // collective I/O
{
  int x, y, x_local, y_local, home_of_xy;
  MPI_File fh; // file handle
  MPI_Datatype vtype, filetype;
  MPI_Offset disp;


  MPI_File_open(MPI_COMM_WORLD, "laplace.dat2", 
		MPI_MODE_CREATE + MPI_MODE_WRONLY,
		MPI_INFO_NULL, &fh);

  MPI_Type_vector(Ly, Lx, Lx + 2, MPI_DOUBLE, &vtype);
  MPI_Type_vector(Ly, Lx, decomp.Nx, MPI_DOUBLE, &filetype);
  MPI_Type_commit(&vtype);
  MPI_Type_commit(&filetype);

  disp = (decomp.coord_y * Ly * decomp.Nx + decomp.coord_x * Lx) * sizeof(double);

  MPI_File_set_view(fh, disp, MPI_DOUBLE, filetype, "native", MPI_INFO_NULL);

  MPI_File_write_all(fh, &v[1][1], 1, vtype, MPI_STATUS_IGNORE);

  MPI_File_close(&fh);
  MPI_Type_free(&vtype);
  MPI_Type_free(&filetype);
}
