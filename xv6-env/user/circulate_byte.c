#include "kernel/types.h"
#include "user/user.h"

// circulate_byte.c written by John Hughes
// student number 22788221
#define NUM_LOOPS 10000
#define NUM_CHILDREN 2
#define NUM_PIPES (NUM_CHILDREN+1)

// child process
void circulate(int (*p)[NUM_CHILDREN], int readpipe) {
    char buf;   // create char to store piped char
    while (read(p[readpipe][0], &buf, 1) > 0) // read from "start" pipe
        write(p[readpipe+1][1], &buf, 1); // write to "end" pipe
}

int main() {
    int p[NUM_PIPES][2];    // create array to store pipes
    for (int i = 0; i < NUM_PIPES; i++) pipe(p[i]);   // loop through array and create pipes

    int pids[NUM_CHILDREN]; // create array to store PIDs
    for (int i = 0; i < NUM_CHILDREN; i++)  // repeat for all children
        if ((pids[i] = fork()) == 0) {  // fork and store pids
            circulate(p, i);    // call child function
            exit(0);        // kill child
        }

    // Parent process
    char buf = 'A';
    printf("Parent sending: %c\n", buf);    // print opening message

    write(p[0][1], &buf, 1); // Write to first pipe to begin
    for (int i = 1; i <= NUM_LOOPS && read(p[NUM_CHILDREN][0], &buf, 1); i++) {    // Read from third pipe
            write(p[0][1], &buf, 1); // Write to first pipe
    }
    printf("Parent received %c in %d loops\n", buf, NUM_LOOPS);

    for (int i = 0; i < NUM_PIPES; i++){ // loop through each pipe
        close(p[i][0]);     // close read end
        close(p[i][1]);     // close write end
    }

    // Clean up and exit
    for (int i = 0; i < NUM_CHILDREN; i++)  // loop through each child pid
        kill(pids[i]);      // kill each child

    exit(0);
}
