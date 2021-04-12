subroutine output_parallel(v, Lx, Ly)

  use module_decomp
  implicit none
  include "mpif.h"
  integer, intent(in) :: Lx, Ly
  real(8), intent(in) :: v(0:Lx + 1, 0:Ly + 1)
  integer             :: ierror, fh  ! file handle
  integer             :: y
  integer(MPI_OFFSET_KIND) :: offset

  call mpi_file_open(MPI_COMM_WORLD, "laplace.dat2", &
                     MPI_MODE_CREATE + MPI_MODE_WRONLY, &
                     MPI_INFO_NULL, fh, ierror)

  if (ierror /= MPI_SUCCESS) call die("mpi_file_open() failed")

  do y = 1, Ly
     offset = (decomp%coord_y * Ly + y - 1) * decomp%Nx &
            + (decomp%coord_x) * Lx
     offset = offset * 8
     call mpi_file_seek(fh, offset, MPI_SEEK_SET, ierror)
     call mpi_file_write(fh, v(1,y), Lx, MPI_REAL8, MPI_STATUS_IGNORE, ierror)
  enddo

  call mpi_file_close(fh, ierror)
end
