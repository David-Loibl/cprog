subroutine output_parallel(v, Lx, Ly)  ! collective I/O

  use module_decomp
  implicit none
  include "mpif.h"
  integer, intent(in) :: Lx, Ly
  real(8), intent(in) :: v(0:Lx + 1, 0:Ly + 1)
  integer             :: vtype, filetype, ierror, fh  ! "file handle"
  integer(MPI_OFFSET_KIND) :: disp

  call mpi_file_open(MPI_COMM_WORLD, "laplace.dat2", &
                     MPI_MODE_CREATE + MPI_MODE_WRONLY, &
                     MPI_INFO_NULL, fh, ierror)

  if (ierror /= MPI_SUCCESS) call die("mpi_file_open() failed")

  call mpi_type_vector(Ly, Lx, Lx + 2, MPI_REAL8, vtype, ierror)
  call mpi_type_vector(Ly, Lx, decomp%Nx, MPI_REAL8, filetype, ierror)
  call mpi_type_commit(vtype, ierror)
  call mpi_type_commit(filetype, ierror)

  disp = (decomp%coord_y * Ly * decomp%Nx + decomp%coord_x * Lx) * 8

  call mpi_file_set_view(fh, disp, MPI_REAL8, filetype, "native", &
                         MPI_INFO_NULL, ierror)

  call mpi_file_write_all(fh, v(1,1), 1, vtype, MPI_STATUS_IGNORE, ierror)

  if (ierror /= MPI_SUCCESS) call die("mpi_file_write_all() failed")

  call mpi_file_close(fh, ierror)

  call mpi_type_free(vtype, ierror)
  call mpi_type_free(filetype, ierror)

end
