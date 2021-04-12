program main  ! ring

  implicit none
  include 'mpif.h'
  integer :: size, rank, ierr
  integer :: partner_left, partner_right
  integer :: sum, sbuf, rbuf

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)

  partner_left  = mod(rank - 1 + size, size)
  partner_right = mod(rank + 1, size)

  sum = 0
  sbuf = rank

  do 
     call mpi_sendrecv(sbuf, 1, MPI_INTEGER, partner_right, 0, &
                       rbuf, 1, MPI_INTEGER, partner_left, 0, &
                       MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
     sum = sum + rbuf
     sbuf = rbuf
     if (rbuf == rank) exit
  enddo  

  write(6,*) rank, sum

  call mpi_finalize(ierr)
end
