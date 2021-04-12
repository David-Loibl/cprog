# include <math.h>

# define np 400
# define nnmax 7
# define ndr (2 * np)
# define pi2 (2.0 * 3.141592653589793)

extern int ldr[ndr][3];

void topol(double s[][3], double *q)
{
  double siga;
  double s11, s12, s13, s21, s22, s23, s31, s32, s33;
  double cc, cc1, cc2, cc3;
  double ss, ss1, ss2, ss3;
  int    idr, n, is;

  siga = 0.0;
  for (idr = 0; idr <= ndr/2; idr += ndr/2) {

      /*****   cc = 1 + s1*s2 + s2*s3 + s3*s1   *****/
      /*****   ss = s1 * ( s2 x s3 )            *****/

      #pragma omp parallel for default(none) \
          private(s11, s12, s13, s21, s22, s23, s31, s32, s33) \
          private(cc, cc1, cc2, cc3) \
          private(ss, ss1, ss2, ss3) \
          shared(s, ldr, idr) \
          reduction(+:siga)

      for (is = 1; is < ndr/2; is++) {

          s11 = s[ldr[idr+is][0]][0];
          s12 = s[ldr[idr+is][0]][1];
          s13 = s[ldr[idr+is][0]][2];

          s21 = s[ldr[idr+is][1]][0];
          s22 = s[ldr[idr+is][1]][1];
          s23 = s[ldr[idr+is][1]][2];

          s31 = s[ldr[idr+is][2]][0];
          s32 = s[ldr[idr+is][2]][1];
          s33 = s[ldr[idr+is][2]][2];

	  cc1 = s11 * s21 + s12 * s22 + s13 * s23;
	  cc2 = s21 * s31 + s22 * s32 + s23 * s33;
	  cc3 = s31 * s11 + s32 * s12 + s33 * s13;

	  cc  = 1.0 + cc1 + cc2 + cc3;

	  ss1 = s22 * s33 - s23 * s32;
	  ss2 = s23 * s31 - s21 * s33;
	  ss3 = s21 * s32 - s22 * s31;

	  ss  = s11 * ss1 + s12 * ss2 + s13 * ss3;

          siga += atan2(ss,cc);
      }
  }

  *q = siga / pi2;
}
