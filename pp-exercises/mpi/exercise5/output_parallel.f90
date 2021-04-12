subroutine output_parallel(v, Lx, Ly)

  use module_decomp
  implicit none
  include "mpif.h"
  integer, intent(in) :: Lx, Ly
  real(8), intent(in) :: v(0:Lx + 1, 0:Ly + 1)
  real(8)             :: vv(0:decomp%Nx + 1, 0:decomp%Ny + 1)
  integer             :: x, y, x_local, y_local, home_of_xy
  integer             :: sizeof_real8, win, ierr
  integer(MPI_ADDRESS_KIND) :: lb, extent_real8, sizeof_v, target_disp
  real(8)             :: time

  call mpi_type_get_extent(MPI_REAL8, lb, extent_real8, ierr)

  sizeof_real8 = extent_real8
  sizeof_v = (Lx + 2) * (Ly + 2) * sizeof_real8

  call mpi_win_create(v, sizeof_v, sizeof_real8, MPI_INFO_NULL, MPI_COMM_WORLD, win, ierr)
  call mpi_win_fence(0, win, ierr)

  time = mpi_wtime()
  if (decomp%my_rank == 0) then
     do y = 0, decomp%Ny + 1
        do x = 0, decomp%Nx + 1
           call global2local(x, y, x_local, y_local, home_of_xy)

           target_disp = y_local * (Lx + 2) + x_local

           call mpi_get(vv(x, y), 1, MPI_REAL8, &
                        home_of_xy, target_disp, 1, MPI_REAL8, win, ierr)
        enddo
     enddo
  endif

  call mpi_win_fence(0, win, ierr)
  time = mpi_wtime() - time

  if (decomp%my_rank == 0) then
     write(0,"(x,a,e8.2,a)") "time(filling vv) = ", time, " s"
     call output(vv, decomp%Nx, decomp%Ny)
  endif

  call mpi_win_free(win, ierr)
end
