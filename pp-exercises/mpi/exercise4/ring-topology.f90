program main  ! topology (process neighbours in 1 dimension)

  implicit none
  include 'mpif.h'
  integer :: size, rank, rank2, ierr
  integer :: comm_ring
  integer :: partner_left, partner_right
  integer :: sum, sbuf, rbuf, i

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)

  call mpi_cart_create(MPI_COMM_WORLD, 1, size, .true., .true., comm_ring, ierr)
  call mpi_cart_shift(comm_ring, 0, 1, partner_left, partner_right, ierr)
  call mpi_comm_rank(comm_ring, rank2, ierr)

  sum = 0
  sbuf = rank2
  do 
     call mpi_sendrecv(sbuf, 1, MPI_INTEGER, partner_right, 0, &
                       rbuf, 1, MPI_INTEGER, partner_left, 0, &
                       comm_ring, MPI_STATUS_IGNORE, ierr)
     sum = sum + rbuf
     sbuf = rbuf
     if (rbuf == rank2) exit
  enddo  

  write(6,"(3(a,i0))") "rank = ", rank, ", rank2 = ", rank2, " : sum = ", sum

  call mpi_finalize(ierr)
end
