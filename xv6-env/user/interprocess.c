#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

/* COMP 20180 Assignment 3 Task 3.

Consider the following program. At the start, the parent process
creates a pipe and puts a single character into it. After that
the parent spawns two child processes. The first child process
prints "I am child A\n" two hundred times and then terminates.
The second child process prints "I am child B\n" two hundred times
and then also terminates. The parent process waits until both
children terminate and then stops.

Put this file into the user/ subfolder of your COMP20180-xv6-riscv/
folder and add $U/_interprocess\ line to UPROG= list in the xv6
Makefile. Change the number of simulated CPU harts in the Makefile
to 3 by setting CPUS=3

Build and run xv6, then start interprocess via xv6 shell:

$ interprocess
II  aamm  cchhiilldd  AB

II  aamm  cchhiilldd  AB

II  aamm  cchhiilldd  AB

II  aamm  cchhiilldd  AB

II  aamm  chcihlidl dA
BI
 Iam  acmh iclhd iAl
...

Observe that the outputs of the child processes are intermixed.

Modify the program below so that each child process attempts
to read a character from the pipe BEFORE its printf() and then
writes that character back into the pipe immediately AFTER its
printf(). If it is done correctly, after recompilation the outputs
of interprocess child processes no longer intermix:

$ interprocess
I am child A
I am child B
I am child A
I am child B
I am child A

Why does it happen? Please give an explanation in your Assignment
report.

*/

// Modifications here by John Hughes student number
// This function creates the child process that prints its message
// It takes 2 arguments, the name of the process and a pointer to the pipe
void create_child(char name, int *p)
{
  char buf;
  if (fork() == 0)
  {
    for (int j = 0; j < 200; j++)
    {
      read(p[0], &buf, 1);             // wait for the token
      printf("I am child %c\n", name); // write the message
      write(p[1], &buf, 1);            // send the token to the pipe
    }
    exit(0);
  }
}

int main(int argc, char *argv[])
{
  int p[2];
  char c = '$'; // character token

  pipe(p); // create pipe

  write(p[1], &c, 1); // write the character into the pipe

  create_child('A', p); // create process A
  create_child('B', p); // create process B

  for (int i = 0; i < 2; i++) // wait for the two child processes to finish
  {
    wait(0);
  }
  return 0;
}
