subroutine topol(s, q)

  implicit none

  real(8), parameter   :: pi2 = 2.0 * 3.141592653589793

  integer, parameter   :: np = 400
  integer, parameter   :: nnmax = 7
  integer, parameter   :: ndr = 2 * np 

  real(8), intent(in)  :: s(-nnmax+1:np,3)
  real(8), intent(out) :: q 
  real(8)              :: s1(np,3), s2(np,3), s3(np,3)
  integer              :: ldr(ndr,3)

  real(8)              :: siga
  real(8)              :: cc, cc1, cc2, cc3
  real(8)              :: ss, ss1, ss2, ss3
  integer              :: idr, n, is

  common /lattice/ ldr
  common /skratch/ s1,s2,s3

  siga = 0.0
  do idr = 0, ndr/2, ndr/2

     !$omp parallel do
     do n = 1,ndr/2
        s1(n,1) = s(ldr(idr+n,1),1)
        s1(n,2) = s(ldr(idr+n,1),2)
        s1(n,3) = s(ldr(idr+n,1),3)
     enddo

     !$omp parallel do
     do n = 1,ndr/2
        s2(n,1) = s(ldr(idr+n,2),1)
        s2(n,2) = s(ldr(idr+n,2),2)
        s2(n,3) = s(ldr(idr+n,2),3)
     enddo

     !$omp parallel do
     do n = 1,ndr/2
        s3(n,1) = s(ldr(idr+n,3),1)
        s3(n,2) = s(ldr(idr+n,3),2)
        s3(n,3) = s(ldr(idr+n,3),3)
     enddo

!     *****   cc = 1 + s1*s2 + s2*s3 + s3*s1   *****
!     *****   ss = s1 * ( s2 x s3 )

     !$omp parallel do default(none) &
     !$omp             shared(s1, s2, s3) &
     !$omp             private(is, cc, cc1, cc2, cc3, ss, ss1, ss2, ss3) &
     !$omp             reduction(+:siga)
     do is = 1, ndr/2
        cc1 = s1(is,1) * s2(is,1) + s1(is,2) * s2(is,2) + s1(is,3) * s2(is,3)
        cc2 = s2(is,1) * s3(is,1) + s2(is,2) * s3(is,2) + s2(is,3) * s3(is,3)
        cc3 = s3(is,1) * s1(is,1) + s3(is,2) * s1(is,2) + s3(is,3) * s1(is,3)
        cc  = 1.0 + cc1 + cc2 + cc3
        ss1 = s2(is,2) * s3(is,3) - s2(is,3) * s3(is,2)
        ss2 = s2(is,3) * s3(is,1) - s2(is,1) * s3(is,3)
        ss3 = s2(is,1) * s3(is,2) - s2(is,2) * s3(is,1)
        ss  = s1(is,1) * ss1 + s1(is,2) * ss2 + s1(is,3) * ss3
        siga = siga + atan2(ss,cc)
     enddo

  enddo

  q = siga / pi2

end
