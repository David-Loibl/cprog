# include <mpp/shmem.h>
# include "laplace.h"
# include "decomp.h"

void exchange_boundary(field v, int Lx, int Ly)
{
  int y;

  shmem_barrier_all();

  if (decomp.north >= 0) shmem_put64(&v[0][1],    &v[Ly][1], Lx, decomp.north);
  if (decomp.south >= 0) shmem_put64(&v[Ly+1][1], &v[1][1],  Lx, decomp.south);

  for (y = 1; y <= Ly; y++) {
     if (decomp.east >= 0) shmem_put64(&v[y][0],    &v[y][Lx], 1, decomp.east);
     if (decomp.west >= 0) shmem_put64(&v[y][Lx+1], &v[y][1],  1, decomp.west);
  }

  shmem_barrier_all();
}
