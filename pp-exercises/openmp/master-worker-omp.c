# include <stdio.h>
# include <stdlib.h>
# include <omp.h>

struct {
    int maxtask;
    int task;
} taskinfo = { 0, 0 };

void work(void);
void get_task(int *nexttask);

int main(int argc, char *argv[])
{
    taskinfo.maxtask = 40;

    #pragma omp parallel
    work();

    return 0;
}

void get_task(int *nexttask)
{
    #pragma omp critical
    {
	if (taskinfo.task < taskinfo.maxtask) {
	    ++taskinfo.task;
	    *nexttask = taskinfo.task;
	} else {
            *nexttask = -1;
	}
    }
}

void work(void)
{
    int task;

    do
    {
	get_task(&task);

	if (task >= 0)
	{
	    printf("thread %d: working on task %d\n", 
		   (int) omp_get_thread_num(), task);
	    system("sleep 1");
	}
    }
    while (task >= 0);
}
