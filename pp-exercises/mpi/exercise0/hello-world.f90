program main  ! hello world

  implicit none
  include 'mpif.h'
  integer :: size, rank, ierr
  integer :: len_name

  character(MPI_MAX_PROCESSOR_NAME) :: name

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)
  call mpi_get_processor_name(name, len_name, ierr)

  write(6, "(2(a,i3),2a)") " MPI: size = ", size, &
                                " rank = ", rank, &
                                " name = ", name(1:len_name)
  call mpi_finalize(ierr)
end
