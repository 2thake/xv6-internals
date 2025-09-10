#include "kernel/types.h"
#include "user/user.h"

// written by John Hughes
int main(void)
{
  printf("Time in seconds since UNIX epoch: %d\n", nanotime() / 1000000000); // convert to seconds and print
  exit(0);
}
