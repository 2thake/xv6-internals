#include "kernel/types.h"
#include "user/user.h"

#define NUM_LOOPS 5000
#define NUM_CHILDREN 3
#define NUM_PIPES (NUM_CHILDREN + 1)

static void
circulate(int (*p)[2], int idx)
{
    // Close all fds except the two this child uses
    for (int k = 0; k < NUM_PIPES; k++)
    {
        if (k != idx)
            close(p[k][0]); // keep read end of p[idx]
        if (k != idx + 1)
            close(p[k][1]); // keep write end of p[idx+1]
    }

    char buf;
    int n;
    while ((n = read(p[idx][0], &buf, 1)) == 1)
    {
        if (write(p[idx + 1][1], &buf, 1) != 1)
            exit(1);
    }
    // read() returns 0 on EOF or -1 on error; either way, exit
    exit(0);
}

int main(void)
{
    int p[NUM_PIPES][2];

    for (int i = 0; i < NUM_PIPES; i++)
    {
        if (pipe(p[i]) < 0)
        {
            printf("pipe(%d) failed\n", i);
            exit(1);
        }
    }

    for (int i = 0; i < NUM_CHILDREN; i++)
    {
        int pid = fork();
        if (pid < 0)
        {
            printf("fork failed\n");
            exit(1);
        }
        if (pid == 0)
            circulate(p, i);
    }

    // Parent: keep only p[0][1] (writer) and p[NUM_CHILDREN][0] (reader)
    for (int k = 0; k < NUM_PIPES; k++)
    {
        if (k != 0)
            close(p[k][1]);
        if (k != NUM_CHILDREN)
            close(p[k][0]);
    }

    char buf = 'A';
    int loops_done = 0;

    printf("Parent sending: %c\n", buf);

    if (write(p[0][1], &buf, 1) != 1)
    {
        printf("write failed\n");
    }
    else
    {
        while (loops_done < NUM_LOOPS)
        {
            int n = read(p[NUM_CHILDREN][0], &buf, 1);
            if (n != 1)
                break; // EOF or error
            if (write(p[0][1], &buf, 1) != 1)
                break;
            loops_done++;
        }
    }

    // Stop the ring: closing p[0][1] causes EOF to propagate through children
    close(p[0][1]);
    close(p[NUM_CHILDREN][0]);

    // Reap children cleanly
    for (int i = 0; i < NUM_CHILDREN; i++)
        wait(0);

    printf("Parent received %c in %d loops\n", buf, loops_done);
    exit(0);
}