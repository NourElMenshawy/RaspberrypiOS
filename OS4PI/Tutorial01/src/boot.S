#include "mm.h"


/* Define everything here to go to .text.boot section in linker script
   which is placed at the beginning of kernel image */	

.text

.globl _start

_start:
	/* init UART (38400 8N1) */
	ldr	x4, =UART_BASE		// UART base
	mov	w5, #0x10		// IBRD
	str	w5, [x4, #0x24]
	mov	w5, #0xc300
	orr	w5, w5, #0x0001		// CR
	str	w5, [x4, #0x30]
	
	mrs x0, mpidr_el1 /*MPIDER_EL1 is mapped to the AARCH32 EDDVAFF0
	                  to access mrc p15,0, <rt>, c0, c0, 5 */
	and x0, x0,#0XFF /* check for processor ID*/
	cbz x0, master 
	b   proc_hang

proc_hang:	
	b proc_hang

/*Clean the .bss section by calling memzero
 In ARMv8 architecture, by convention, the first seven arguments are passed to the called  function via registers x0–x6.
 The memzero function accepts only two arguments:
 the start address (bss_begin) and the size of the section needed to be cleaned (bss_end -  bss_begin). */
master:
	adr x0, bss_begin
	adr x1, bss_end
	sub x1, x1,x0
	bl memzero

	adrp x0, stacktop
	mov sp, x0
	bl kernel_main
