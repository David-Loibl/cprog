program main  ! ping pong

  implicit none
  include 'mpif.h'
  integer :: size, rank, ierr, partner, i, count, r, repetitions
  integer, parameter :: max_i = 20
  integer, parameter :: max_count = 2**max_i
  real(8) :: buf(max_count), time, bandwidth

  call mpi_init(ierr)
  call mpi_comm_size(MPI_COMM_WORLD, size, ierr)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)

  if (size /= 2) then
     write(0,*) "comm_size != 2"
     call mpi_abort(MPI_COMM_WORLD, 1, ierr)
  endif

  if (rank == 0) then
     write(6,"(a)") "message size    number of         time    bandwidth"
     write(6,"(a)") "     [bytes]  repetitions         [us]       [MB/s]"
     write(6,"(a)") "---------------------------------------------------"
  endif
  
  partner = 1 - rank
  count = 1
  repetitions = max_count

  do i = 0, max_i
     time = mpi_wtime()
     do r = 1, repetitions
        if (rank == 0) then
           call mpi_send(buf, count, MPI_REAL8, partner, 0, MPI_COMM_WORLD, ierr)
           call mpi_recv(buf, count, MPI_REAL8, partner, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
        else
           call mpi_recv(buf, count, MPI_REAL8, partner, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
           call mpi_send(buf, count, MPI_REAL8, partner, 0, MPI_COMM_WORLD, ierr)
        endif
     enddo
     time = mpi_wtime() - time
     time = time / (2.0 * repetitions)
     time = 1e6 * time  ! micro-seconds
     bandwidth = count * 8 / time  ! MByte/s
     
     if (rank == 0) write(6,"(i12,x,i12,2(x,f12.2))") count * 8, repetitions, time, bandwidth
     count = count * 2
     repetitions = repetitions / 2
  enddo

  call mpi_finalize(ierr)
end
