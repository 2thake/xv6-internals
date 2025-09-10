# xv6-internals
This repository contains my modifications to the xv6 operating system for RISC-V. 
The full modified xv6 environment is included in the folder "xv6-env". All of my changes 
to the kernel and user space are marked with the comment "John Hughes".
<img width="776" height="314" alt="image" src="https://github.com/user-attachments/assets/eb855e35-87dc-4037-b161-897316d47e00" />


## Extensions Made
1. Page table printing (vmprint): kernel code to recursively print the contents 
   of a RISC-V page table, with cleanly formatted output on boot.
2. Nanotime syscall: a new system call that exposes a hardware 
   timer to user space, allowing "gettime" to be called from the command line, which prints the total number of seconds since the UNIX epoch.
3. Process synchronization with pipes: a user-level program that circulates a 
   byte between processes using pipes to coordinate scheduling, demonstrating interprocess communication.

In addition to the full xv6 environment, a "samples" folder is provided. This folder contains isolated source files for the page table printing and process synchronization, though this code is also present within the modified xv6 OS.

## Running the OS
To run the modified system, enter the "xv6-env" folder and build with "make" 
followed by "make qemu". Note that qemu must be installed. The samples folder is provided only for code review and 
reference.
