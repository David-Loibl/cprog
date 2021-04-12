subroutine topol(s, q)

  implicit none

  real(8), parameter   :: pi2 = 2.0 * 3.141592653589793

  integer, parameter   :: np = 400
  integer, parameter   :: nnmax = 7
  integer, parameter   :: ndr = 2 * np 

  real(8), intent(in)  :: s(-nnmax+1:np,3)
  real(8), intent(out) :: q 
  integer              :: ldr(ndr,3)

  real(8)              :: siga
  real(8)              :: s11, s12, s13, s21, s22, s23, s31, s32, s33
  real(8)              :: cc, cc1, cc2, cc3
  real(8)              :: ss, ss1, ss2, ss3
  integer              :: idr, n, is

  common /lattice/ ldr

  siga = 0.0
  do idr = 0, ndr/2, ndr/2

     ! *****   cc = 1 + s1*s2 + s2*s3 + s3*s1   *****
     ! *****   ss = s1 * ( s2 x s3 )            *****

     !$omp parallel do default(none) &
     !$omp private(s11, s12, s13, s21, s22, s23, s31, s32, s33) &
     !$omp private(cc, cc1, cc2, cc3) &
     !$omp private(ss, ss1, ss2, ss3) &
     !$omp shared(s, ldr, idr) &
     !$omp reduction(+:siga)

     do is = 1, ndr/2
        s11 = s(ldr(idr+is,1),1)
        s12 = s(ldr(idr+is,1),2)
        s13 = s(ldr(idr+is,1),3)

        s21 = s(ldr(idr+is,2),1)
        s22 = s(ldr(idr+is,2),2)
        s23 = s(ldr(idr+is,2),3)

        s31 = s(ldr(idr+is,3),1)
        s32 = s(ldr(idr+is,3),2)
        s33 = s(ldr(idr+is,3),3)

        cc1 = s11 * s21 + s12 * s22 + s13 * s23
        cc2 = s21 * s31 + s22 * s32 + s23 * s33
        cc3 = s31 * s11 + s32 * s12 + s33 * s13

        cc  = 1.0 + cc1 + cc2 + cc3

        ss1 = s22 * s33 - s23 * s32
        ss2 = s23 * s31 - s21 * s33
        ss3 = s21 * s32 - s22 * s31

        ss  = s11 * ss1 + s12 * ss2 + s13 * ss3

        siga = siga + atan2(ss,cc)
     enddo

  enddo

  q = siga / pi2

end
