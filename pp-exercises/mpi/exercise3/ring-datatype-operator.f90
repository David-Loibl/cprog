module module_my_struct

  type my_struct
     real(8) :: x
     integer :: i
  end type my_struct
  
  integer, save :: my_type  ! MPI datatype for type(my_struct)
  external      :: my_fun   ! reduction operation for my_type
  integer, save :: my_op    ! MPI operator for my_fun
end 


program main  ! user defined datatype and operator

  use module_my_struct
  implicit none
  include 'mpif.h'
  type(my_struct) :: s, res
  integer :: rank, len(2), type(2), ierror
  integer(MPI_ADDRESS_KIND) :: disp(2)

  call mpi_init(ierror)

  len(1) = 1
  len(2) = 1

  call mpi_get_address(s%x, disp(1), ierror)
  call mpi_get_address(s%i, disp(2), ierror)
 
  disp(2) = disp(2) - disp(1)
  disp(1) = disp(1) - disp(1)

  type(1) = MPI_REAL8
  type(2) = MPI_INTEGER

  call mpi_type_create_struct(2, len, disp, type, my_type, ierror)
  call mpi_type_commit(my_type, ierror)
  call mpi_op_create(my_fun, .true., my_op, ierror)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierror)

  s%x = rank
  s%i = rank

  call mpi_reduce(s, res, 1, my_type, my_op, 0, MPI_COMM_WORLD, ierror)

  if (rank == 0) write(6,*) "result: ", res%x, res%i

  call mpi_type_free(my_type, ierror)
  call mpi_op_free(my_op, ierror)
  call mpi_finalize(ierror)
end


subroutine my_fun(in, inout, len, type)

  use module_my_struct, exclude => my_fun
  implicit none
  include 'mpif.h'
  type(my_struct), intent(in) :: in(*)
  type(my_struct), intent(inout) :: inout(*)
  integer, intent(in) :: len, type
  integer :: i, ierror

  if (type == my_type) then   
     do i = 1, len
        inout(i)%x = inout(i)%x + in(i)%x
        inout(i)%i = inout(i)%i + in(i)%i
     enddo
  else
     write(0,*) "my_fun: unknown type"
     call mpi_abort(MPI_COMM_WORLD, 1, ierror)
  endif
end
