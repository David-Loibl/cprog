!==============================================================================
program main  ! master-worker

  implicit none
  include 'mpif.h'
  integer, parameter :: maxtask = 40
  integer :: rank, ierr
 
  call mpi_init(ierr)

  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)

  if (rank == 0) then
     call master(maxtask)
  else
     call worker()
  endif

  call mpi_finalize(ierr)
end

!------------------------------------------------------------------------------
subroutine master(maxtask)

  implicit none
  include 'mpif.h'
  integer, intent(in) :: maxtask
  integer :: size, status(MPI_STATUS_SIZE), ierr
  integer :: msg, task, dest

  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)

  do task = 1, maxtask
     call mpi_recv(msg, 0, MPI_INTEGER, MPI_ANY_SOURCE, 0, MPI_COMM_WORLD, status, ierr)
     call mpi_send(task, 1, MPI_INTEGER, status(MPI_SOURCE), 0, MPI_COMM_WORLD, ierr)
  enddo

  task = -1
  do dest = 1, size - 1
     call mpi_recv(msg, 0, MPI_INTEGER, dest, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
     call mpi_send(task, 1, MPI_INTEGER, dest, 0, MPI_COMM_WORLD, ierr)
  enddo
end

!------------------------------------------------------------------------------
subroutine worker()

  implicit none
  include 'mpif.h'
  integer :: rank, ierr
  integer :: msg, task

  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)

  do 
     call mpi_send(msg, 0, MPI_INTEGER, 0, 0, MPI_COMM_WORLD, ierr)
     call mpi_recv(task, 1, MPI_INTEGER, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr) 

     if (task < 0) exit
     write(6,*) "rank " , rank, ": working on task ", task
     call system("sleep 1")
  enddo

end

!==============================================================================
