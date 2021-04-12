program main  ! ordered I/O with serialisation by Ssend and Recv chain

  implicit none
  include 'mpif.h'
  integer :: size, rank, ierr
  integer :: sum, i

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)

  call mpi_scan(rank, sum, 1, MPI_INTEGER, MPI_SUM, MPI_COMM_WORLD, ierr)

  if (rank > 0 ) then
     call mpi_recv(i, 1, MPI_INTEGER, rank - 1, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
  endif

  write(6,"(x,a,i0,a,i0)") "partial sum(", rank, ") = ", sum

  if (rank < size - 1) then
     call mpi_ssend(i, 1, MPI_INTEGER, rank + 1, 0, MPI_COMM_WORLD, ierr)
  endif 

  call mpi_finalize(ierr)
end
