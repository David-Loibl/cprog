program main  ! torus topology

  implicit none
  include 'mpif.h'
  integer :: size, rank, rank2, rank3, ierr
  integer :: comm_torus, comm_row
  integer :: partner_left, partner_right
  integer :: sum, sbuf, rbuf, i
  integer :: dims(2), coords(2)
  logical :: periods(2), remain_dims(2)
  character(8) :: arg

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)

  if (command_argument_count() /= 2) then
     write(0,*) "Usage: ring-torus dims1 dims2"
     call mpi_abort(mpi_comm_world, 1, ierr)
  endif

  call get_command_argument(1, arg) ;  read(arg, *) dims(1)
  call get_command_argument(2, arg) ;  read(arg, *) dims(2)

  if (dims(1) * dims(2) /= size) then
     write(0,*) "ring-torus: dims1 * dims2 /= n_procs"
     call mpi_abort(mpi_comm_world, 1, ierr)
  endif

  periods(1) = .true.
  periods(2) = .true. 
  remain_dims(1) = .false.
  remain_dims(2) = .true.

  call mpi_cart_create(MPI_COMM_WORLD, 2, dims, periods,.true.,comm_torus, ierr)
  call mpi_comm_rank(comm_torus, rank2, ierr)
  call mpi_cart_coords(comm_torus, rank2, 2, coords, ierr)

  call mpi_cart_sub(comm_torus, remain_dims, comm_row, ierr)
  call mpi_comm_rank(comm_row, rank3, ierr)
  
  write(6, "(5(a,i0),a)") &
      "ranks(orig,torus,row) = ", rank, ",", rank2, ",", rank3, &
      " : coords (x,y) = (", coords(1), ",", coords(2), ")" 

  call mpi_cart_shift(comm_row, 0, 1, partner_left, partner_right, ierr)

  sum = 0
  sbuf = rank3
  do 
     call mpi_sendrecv(sbuf, 1, MPI_INTEGER, partner_right, 0, &
                       rbuf, 1, MPI_INTEGER, partner_left, 0, &
                       comm_row, MPI_STATUS_IGNORE, ierr)
     sum = sum + rbuf
     sbuf = rbuf
     if (rbuf == rank3) exit
  enddo  

  write(6,"(3(ai0))") "torus-sum(", coords(1), ",", coords(2), ") = ", sum

  call mpi_finalize(ierr)
end
