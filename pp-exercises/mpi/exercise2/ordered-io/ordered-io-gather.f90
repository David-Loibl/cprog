program main  ! ordered I/O with Gather

  implicit none
  include 'mpif.h'
  integer :: size, rank, ierr
  integer :: sum, i
  integer, allocatable :: all_sums(:)

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)

  call mpi_scan(rank, sum, 1, MPI_INTEGER, MPI_SUM, MPI_COMM_WORLD, ierr)

  allocate(all_sums(0:size-1))
  call mpi_gather(sum, 1, MPI_INTEGER, &
                  all_sums, 1, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)

  if (rank == 0) then
     do i = 0, size - 1
        write(6,"(x,a,i0,a,i0)") "partial sum(", i, ") = ", all_sums(i)
     enddo
  endif

  deallocate(all_sums)
  call mpi_finalize(ierr)
end
