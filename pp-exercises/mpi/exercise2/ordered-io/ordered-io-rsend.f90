program main  ! ordered I/O with Ready-Send

  implicit none
  include 'mpif.h'
  integer :: size, rank, request, ierr
  integer :: sum, i

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)

  call mpi_scan(rank, sum, 1, MPI_INTEGER, MPI_SUM, MPI_COMM_WORLD, ierr)

  if (rank /= 0) then
     call mpi_recv(i, 1, MPI_INTEGER, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)      
     call mpi_rsend(sum, 1, MPI_INTEGER, 0, 0, MPI_COMM_WORLD, ierr)
  else
     do i = 0, size - 1
        if (i > 0) then
           call mpi_irecv(sum, 1, MPI_INTEGER, i, 0, MPI_COMM_WORLD, request, ierr)
           call mpi_send(i, 1, MPI_INTEGER, i, 0, MPI_COMM_WORLD, ierr)
           call mpi_wait(request, MPI_STATUS_IGNORE, ierr)
        endif
        write(6,"(x,a,i0,a,i0)") "partial sum(", i, ") = ", sum
     enddo
  endif

  call mpi_finalize(ierr)
end
