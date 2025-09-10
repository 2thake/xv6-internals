/*
 * Page Table Printing Utility for xv6-riscv
 *
 * This file defines vmprint() and its recursive helper print_pagetable(),
 * which traverse and display the contents of a RISC-V three-level page table.
 *
 * The output is formatted to show the hierarchy of page table entries (PTEs),
 * including whether each PTE points to a lower-level table or maps a leaf
 * virtual address (VA) range to a physical address (PA) range. Indentation is
 * used to indicate depth in the recursion.
 *
 * This functionality was added as part of an operating systems assignment
 * to gain experience with virtual memory management, page table structures,
 * and kernel debugging in xv6.
 *
 * Note that this file only serves to showcase the code, and the actual implementation
 * is in vm.c in the xv6 system.
 *
 * Written by John Hughes
 */

#include "types.h"
#include "riscv.h"

// print_pagetable and vmprint written by John Hughes
static void print_pagetable(pagetable_t pagetable, const int level)
{
    for (int i = 0; i < 512; i++)
    {
        pte_t pte = pagetable[i];
        if (pte & PTE_V)
        {
            for (int j = 0; j < level; j++)
            { // formatting based on the recursion index
                printf(".. ");
            }
            uint64 pa = PTE2PA(pte); // find physical address using PTE2PA

            if (pte & (PTE_R | PTE_W | PTE_X))
            {                                                                                                // check if this PT is a leaf
                uint64 va = i << PGSHIFT;                                                                    // derive virtual address
                printf("%d: leaf pte: va %p-%p -> pa %p-%p\n", i, va, va + PGSIZE - 1, pa, pa + PGSIZE - 1); // print the contents
            }
            else
            {
                printf("%d: pte points to lower-level page table: pte %p -> pa %p\n", i, pte, pa);
                print_pagetable((pagetable_t)pa, level + 1); // if there is a lower level PT, call function recursively
            }
        }
    }
}

void vmprint(pagetable_t pagetable)
{
    printf("page table at physical address (pa) %p\n", pagetable); // print PT address
    print_pagetable(pagetable, 0);                                 // call print_pagetable with 0 recursion index
}
