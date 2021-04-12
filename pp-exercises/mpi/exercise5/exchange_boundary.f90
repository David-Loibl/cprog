subroutine exchange_boundary(v, Lx, Ly)

  use module_decomp
  implicit none
  integer, intent(in)    :: Lx, Ly
  real(8), intent(inout) :: v(0:Lx + 1, 0:Ly + 1)
  integer                :: y, ierror

  call shmem_barrier_all()

  if (decomp%north >= 0) call shmem_put64(v(1, 0),    v(1, Ly), Lx, decomp%north)
  if (decomp%south >= 0) call shmem_put64(v(1, Ly+1), v(1, 1),  Lx, decomp%south) 

  do y = 1, Ly
     if (decomp%east >= 0) call shmem_put64(v(0, y),   v(Lx, y), 1, decomp%east)
     if (decomp%west >= 0) call shmem_put64(v(Lx+1,y), v(1, y),  1, decomp%west)
  enddo

  call shmem_barrier_all()
end
