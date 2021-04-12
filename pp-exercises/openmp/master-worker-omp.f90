!==============================================================================
module taskinfo

  integer, save :: maxtask = 0
  integer, save :: task  = 0

end module taskinfo

!------------------------------------------------------------------------------
program main

  use taskinfo
  implicit none
  
  maxtask = 40

  !$omp parallel
  call work()
  !$omp end parallel

end

!------------------------------------------------------------------------------
subroutine get_task(nexttask)

  use taskinfo
  implicit none
  integer, intent(out) :: nexttask

  !$omp critical
  if (task < maxtask) then
     task = task + 1
     nexttask = task
  else
     nexttask = -1
  endif
  !$omp end critical

end

!------------------------------------------------------------------------------
subroutine work()

  implicit none
  integer :: task
  integer, external :: omp_get_thread_num

  do
     call get_task(task)

     if (task < 0) exit
     write(6,*) "thread ", omp_get_thread_num(), ": working on task ", task
     call system("sleep 1")
  enddo

end

!==============================================================================
