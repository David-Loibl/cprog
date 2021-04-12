# include <math.h>

# define np 400
# define nnmax 7
# define ndr (2 * np)
# define pi2 (2.0 * 3.141592653589793)

extern double s1[np][3], s2[np][3], s3[np][3];
extern int    ldr[ndr][3];

void topol(double s[][3], double *q)
{
  double siga;
  double cc, cc1, cc2, cc3;
  double ss, ss1, ss2, ss3;
  int    idr, n, is;

  siga = 0.0;
  for (idr = 0; idr <= ndr/2; idr += ndr/2) {

      for (n = 1; n < ndr/2; n++) {
          s1[n][0] = s[ldr[idr+n][0]][0];
          s1[n][1] = s[ldr[idr+n][0]][1];
          s1[n][2] = s[ldr[idr+n][0]][2];
      }

      for (n = 1; n < ndr/2; n++) {
          s2[n][0] = s[ldr[idr+n][1]][0];
          s2[n][1] = s[ldr[idr+n][1]][1];
          s2[n][2] = s[ldr[idr+n][1]][2];
      }

      for (n = 1; n < ndr/2; n++) {
          s3[n][0] = s[ldr[idr+n][2]][0];
          s3[n][1] = s[ldr[idr+n][2]][1];
          s3[n][2] = s[ldr[idr+n][2]][2];
      }

      /*****   cc = 1 + s1*s2 + s2*s3 + s3*s1   *****/
      /*****   ss = s1 * ( s2 x s3 )            *****/

      for (is = 1; is < ndr/2; is++) {
          cc1 = s1[is][0] * s2[is][0] + s1[is][1] * s2[is][1] + s1[is][2] * s2[is][2];
          cc2 = s2[is][0] * s3[is][0] + s2[is][1] * s3[is][1] + s2[is][2] * s3[is][2];
          cc3 = s3[is][0] * s1[is][0] + s3[is][1] * s1[is][1] + s3[is][2] * s1[is][2];
          cc  = 1.0 + cc1 + cc2 + cc3;
          ss1 = s2[is][1] * s3[is][2] - s2[is][2] * s3[is][1];
          ss2 = s2[is][2] * s3[is][0] - s2[is][0] * s3[is][2];
          ss3 = s2[is][0] * s3[is][1] - s2[is][1] * s3[is][0];
          ss  = s1[is][0] * ss1 + s1[is][1] * ss2 + s1[is][2] * ss3;
          siga += atan2(ss,cc);
      }
  }

  *q = siga / pi2;
}
