!==============================================================================
program main

! Parallelisation of this loop
!
!      do i = 2, n
!         a(i) = a(i) + a(i - 1)
!      enddo
!
! with OpenMP (see the parallel region). 
!
! Overhead: In the parallel version the total number of additions almost 
! doubles. 


  implicit none
  include 'omp_lib.h'

  integer, parameter :: n = 40
  integer :: a(n)
  integer :: i, i1, i2, i_thread, n_thread
  integer, allocatable :: psum(:)

  do i = 1, n
     a(i) = i
  enddo

  n_thread = omp_get_max_threads()

  allocate(psum(0:n_thread - 1))

  !$omp parallel private(i, i1, i2, i_thread)

  call get_omp_range(n, i1, i2, i_thread, psum)

  do i = i1 + 1, i2
     a(i) = a(i) + a(i - 1)
  enddo

  psum(i_thread) = a(i2)

  !$omp barrier
   
  if (i_thread == 0) then
     do i = 1, n_thread - 1
        psum(i) = psum(i) + psum(i - 1)
     enddo
  endif

  !$omp barrier

  if (i_thread > 0) then
     do i = i1, i2
        a(i) = a(i) + psum(i_thread - 1)
     enddo
  endif  

  !$omp end parallel
  
  do i = 1, n
     write(6,*) a(i)
  enddo

end

!------------------------------------------------------------------------------
subroutine get_omp_range(n, i1, i2, i_thread)

  implicit none
  include 'omp_lib.h'

  integer, intent(in)  :: n
  integer, intent(out) :: i1, i2, i_thread

  integer :: n_thread, chunk, rest

  n_thread = omp_get_num_threads()
  i_thread = omp_get_thread_num()

  chunk = n / n_thread
  rest = mod(n, n_thread)

  if (i_thread < rest) then
     chunk = chunk + 1
     i1 = chunk * i_thread
  else
     i1 = chunk * i_thread + rest
  endif 

  i1 = i1 + 1                    ! Fortran arrays begin with index 1
  i2 = i1 + chunk - 1 

end

!==============================================================================
