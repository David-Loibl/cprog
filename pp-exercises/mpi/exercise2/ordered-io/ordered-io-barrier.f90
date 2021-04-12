program main  ! ordered I/O with Barriers

  implicit none
  include 'mpif.h'
  integer :: size, rank, ierr
  integer :: sum, i

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)

  call mpi_scan(rank, sum, 1, MPI_INTEGER, MPI_SUM, MPI_COMM_WORLD, ierr)

  do i = 0, size - 1
     if (i == rank) then
        write(6,"(x,a,i0,a,i0)") "partial sum(", i, ") = ", sum
     endif
     call mpi_barrier(MPI_COMM_WORLD, ierr)
  enddo

  call mpi_finalize(ierr)
end
