# include <stdio.h>
# include <mpi.h>
# include "laplace.h"
# include "decomp.h"

void output_parallel(field v, int Lx, int Ly)
{
  field      vv = field_alloc(decomp.Ny, decomp.Nx);
  int        x, y, x_local, y_local, home_of_xy;
  double     time;
  int        sizeof_double = sizeof(double);
  MPI_Aint   sizeof_v, target_disp, a0, a1;
  MPI_Win    win;

  sizeof_v = (Lx + 2) * (Ly + 2) * sizeof_double;

  MPI_Win_create(&v[0][0], sizeof_v, 1, MPI_INFO_NULL, MPI_COMM_WORLD, &win);
  MPI_Win_fence(0, win);

  time = MPI_Wtime();
  if (decomp.my_rank == 0) {
      for (y = 0; y <= decomp.Ny + 1; y++) {
	  for (x = 0; x <= decomp.Nx + 1; x++) {
	      global2local(x, y, &x_local, &y_local, &home_of_xy);

              MPI_Get_address(&v[0][0], &a0);
              MPI_Get_address(&v[y_local][x_local], &a1);

              target_disp = a1 - a0;

              MPI_Get(&vv[y][x], 1, MPI_DOUBLE,
		      home_of_xy, target_disp, 1, MPI_DOUBLE, win);
	  }
      }
  }

  MPI_Win_fence(0, win);
  time = MPI_Wtime() - time;  

  if (decomp.my_rank == 0) {
      fprintf(stderr,     "time(filling vv) = %8.2e s\n", time);
      output(vv, decomp.Nx, decomp.Ny);
  }

  MPI_Win_free(&win);
  field_free(vv);
}
