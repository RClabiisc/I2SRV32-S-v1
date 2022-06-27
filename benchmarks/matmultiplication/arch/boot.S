
#if __riscv_xlen == 64
# define STORE    sd
# define LOAD     ld
# define REGBYTES 8
#else
# define STORE    sw
# define LOAD     lw
# define REGBYTES 4
#endif

boot:
    li t6, 0x1800
    csrw mstatus, t6
    j _mstart

	.align 6
    .text
    .global _mstart
    .type _mstart, @function
#	.section .text,"ax",@progbits
#	.section .text,"ax",@progbits
#	.globl _mstart
/* Startup code */
_mstart:
    la t0, trap_entry
    csrw mtvec, t0  /* Store Trap Entry Location in mtvec CSR*/
    li	x1, 0
    li	x2, 0
    li	x3, 0
    li	x4, 0
    li	x5, 0
    li	x6, 0
    li	x7, 0
    li	x8, 0
    li	x9, 0
    li	x10, 0
    li	x11, 0
    li	x12, 0
    li	x13, 0
    li	x14, 0
    li	x15, 0
    li	x16, 0
    li	x17, 0
    li	x18, 0
    li	x19, 0
    li	x20, 0
    li	x21, 0
    li	x22, 0
    li	x23, 0
    li	x24, 0
    li	x25, 0
    li	x26, 0
    li	x27, 0
    li	x28, 0
    li	x29, 0
    li	x30, 0
    li	x31, 0
    
     # Initialize global pointer
    .option push
    .option norelax
1:  auipc gp, %pcrel_hi(__global_pointer$)
    addi  gp, gp, %pcrel_lo(1b)
    .option pop
    la sp, __stacktop

    la t0, trap_entry

    /* initialize global pointer */
#    la	gp, _gp
    lw      a0, 0(sp)                  # a0 = argc
    li      a2, 0                      # a2 = envp = NULL
    call    main
2:
    j 2b
ret

#init_bss:
#    /* init bss section */
#    la	a0, __bss_start
#    la	a1, __bss_end
#    li	a2, 0x0
#    jal	fill_block
#
#init_sbss:
#    /* init bss section */
#    la	a0, __sbss_start
#    la	a1, __sbss_end
#    li	a2, 0x0
#    jal	fill_block
#
#init_sbss2:
#    /* init bss section */
#    la	a0, __sbss2_start
#    la	a1, __sbss2_end
#    li	a2, 0x0
#    jal	fill_block
#
#write_stack_pattern:
#    /* init bss section */
#    la	a0, _stack_end  /* note the stack grows from top to bottom */
#    la	a1, __stack
#    li	a2, 0xABABABAB
#    jal	fill_block
#
#init_stack:
#    /* set stack pointer */
#    la	sp, _stack
#
#	j	vSyscallInit
#
/* When trap is an interrupt, this function is called */
/*interrupt:
	srli	t0,t0,1
	beq     t0,x0,softwareInterrupt
	LOAD	t0, 0x0(sp)
	addi	sp, sp, REGBYTES*/
trap_entry:
	/* Interupt is timer interrupt */
	j		ISR5
	mret
	j		ISR5
	mret
	j		ISR5
	mret
	j		ISR5
	mret
	j		ISR5
	mret
	j		ISR6
	mret

/* Fills memory blocks */
#fill_block:
#    bgeu	a0, a1, fb_end
#    sw		a2, 0(a0)
#    addi	a0, a0, 4
#    j		fill_block
#fb_end:
#    ret
