!------------------------------------------------------------------------------
module module_my_struct  ! make a type definition available everywhere

  type my_struct
     real(8) :: x
     integer :: i
  end type my_struct

  external :: my_fun   ! will become MPI reduction operator
end 

!------------------------------------------------------------------------------
program main  ! hints for user defined datatype and operator

  use module_my_struct
  implicit none
  type(my_struct) :: a, b, s

  a%x = 1
  a%i = 2

  b%x = 10
  b%i = 20

  call sum(my_fun, a, b, s)  ! call my_fun from another routine (substitute for MPI)

  write(6,*) s%x, s%i
end

!------------------------------------------------------------------------------
subroutine sum(fun, x, y, z)

  use module_my_struct
  implicit none
  external :: fun
  type(my_struct), intent(in) :: x, y
  type(my_struct), intent(inout) :: z

  z%x = x%x
  z%i = x%i
  call fun(y, z, 1, 0)
end

!------------------------------------------------------------------------------
subroutine my_fun(in, inout, len, type)  ! very similar to MPI_User_function

  use module_my_struct, exclude => my_fun
  implicit none
  type(my_struct), intent(in) :: in(*)
  type(my_struct), intent(inout) :: inout(*)
  integer, intent(in) :: len, type
  integer :: i

  do i = 1, len
     inout(i)%x = inout(i)%x + in(i)%x
     inout(i)%i = inout(i)%i + in(i)%i
  enddo
end
