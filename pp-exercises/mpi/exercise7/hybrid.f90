program main  ! hybrid 'hello world' program

  use omp_lib
  implicit none
  include 'mpif.h'

  integer :: size, rank, ierr, len_name
  character(MPI_MAX_PROCESSOR_NAME) :: name

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)
  call mpi_get_processor_name(name, len_name, ierr)

  !$omp parallel

  write(6, "(2a,2(a,i3,a,i0))") & 
            "node ", name(1:len_name), &
            " : process ", rank, "/", size, &
            " : thread ", omp_get_thread_num(), "/", omp_get_num_threads()

  !$omp end parallel

  call mpi_finalize(ierr)
end
