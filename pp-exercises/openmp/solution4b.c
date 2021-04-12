# include <stdio.h>
# include <stdlib.h>
# include <omp.h>

/*
* Parallelisation of this loop
*
*     for (i = 1; i < n; i++)
*        a[i] = a[i] + a[i - 1]
*
* with OpenMP (see the parallel region).
*
* Overhead: In the parallel version the total number of additions almost 
* doubles. 
*/

void get_omp_range(const int n, int *i1, int *i2, int *i_thread);

int main(int argc, char *argv[])
{
    const int n = 40;
    int a[n];
    int i, i1, i2, i_thread, n_thread;
    int *psum;

    for (i = 0; i < n; i++)
	a[i] = i;

    n_thread = omp_get_max_threads();
    psum = (int *) malloc(n_thread * sizeof(int));

    #pragma omp parallel private(i, i1, i2, i_thread)
    {
	get_omp_range(n, &i1, &i2, &i_thread);

	for (i = i1 + 1; i <= i2; i++)
	    a[i] = a[i] + a[i - 1];

        psum[i_thread] = a[i2];

	#pragma omp barrier
        
	if (i_thread == 0)
	    for (i = 1; i < n_thread; i++)
	        psum[i] = psum[i] + psum[i - 1];
	    
	#pragma omp barrier

	if (i_thread > 0) 
	    for (i = i1; i <= i2; i++)
		a[i] = a[i] + psum[i_thread - 1];
    }

    for (i = 0; i < n; i++)
	printf("%d\n", a[i]);

    return 0;
}


void get_omp_range(const int n, int *i1, int *i2, int *i_thread)
{
    int chunk, rest;
    int n_thread = omp_get_num_threads();

    *i_thread = omp_get_thread_num();

    chunk = n / n_thread;
    rest = n % n_thread;
    
    if (*i_thread < rest) {
	chunk++;
	*i1 = chunk * *i_thread;
    } else {
	*i1 = chunk * *i_thread + rest;
    }
    
    *i2 = *i1 + chunk - 1; 
}
