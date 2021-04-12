module module_my_struct

  type my_struct
     real(8) :: x
     integer :: i
  end type my_struct
end


program main  ! ring with derived datatype

  use module_my_struct
  implicit none
  include 'mpif.h'
  integer :: size, rank, ierr
  integer :: partner_left, partner_right
  integer :: len(2), type(2), my_type
  integer(MPI_ADDRESS_KIND) :: disp(2)

  type(my_struct) :: sum, sbuf, rbuf

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)

  partner_left  = mod(rank - 1 + size, size)
  partner_right = mod(rank + 1, size)

  len(1) = 1
  len(2) = 1

  call mpi_get_address(sum%x, disp(1), ierr)
  call mpi_get_address(sum%i, disp(2), ierr)
 
  disp(2) = disp(2) - disp(1)
  disp(1) = disp(1) - disp(1)

  type(1) = MPI_REAL8
  type(2) = MPI_INTEGER

  call mpi_type_create_struct(2, len, disp, type, my_type, ierr)
  call mpi_type_commit(my_type, ierr)
  
  sum%x = 0
  sum%i = 0
  sbuf%x = rank
  sbuf%i = rank

  do 
     call mpi_sendrecv(sbuf, 1, my_type, partner_right, 0, &
                       rbuf, 1, my_type, partner_left, 0, &
                       MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
     sum%x = sum%x + rbuf%x
     sum%i = sum%i + rbuf%i
     sbuf%x = rbuf%x
     sbuf%i = rbuf%i
     if (rbuf%i == rank) exit
  enddo  

  write(6,*) "sums on rank ", rank, ": ", sum%x, sum%i

  call mpi_finalize(ierr)
end
