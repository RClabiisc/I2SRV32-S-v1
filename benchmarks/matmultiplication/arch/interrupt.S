/* */
# define LOAD lw
# define STORE sw
# define REGBYTES 4

# define FPSTORE    fsd
# define FPLOAD     fld

.global INT_Entry
.global ISR5
.global ISR6
.global INT_Exit


.macro INT_Entry
	csrc mstatus,8
	addi	sp, sp, -REGBYTES * 96

	STORE	x1, 64 * REGBYTES(sp)
	STORE	x2, 65 * REGBYTES(sp)
	STORE	x3, 66 * REGBYTES(sp)
	STORE	x4, 67 * REGBYTES(sp)
	STORE	x5, 68 * REGBYTES(sp)
	STORE	x6, 69 * REGBYTES(sp)
	STORE	x7, 70 * REGBYTES(sp)
	STORE	x8, 71 * REGBYTES(sp)
	STORE	x9, 72 * REGBYTES(sp)
	STORE	x10, 73 * REGBYTES(sp)
	STORE	x11, 74 * REGBYTES(sp)
	STORE	x12, 75 * REGBYTES(sp)
	STORE	x13, 76 * REGBYTES(sp)
	STORE	x14, 77 * REGBYTES(sp)
	STORE	x15, 78 * REGBYTES(sp)
	STORE	x16, 79 * REGBYTES(sp)
	STORE	x17, 80 * REGBYTES(sp)
	STORE	x18, 81 * REGBYTES(sp)
	STORE	x19, 82 * REGBYTES(sp)
	STORE	x20, 83 * REGBYTES(sp)
	STORE	x21, 84 * REGBYTES(sp)
	STORE	x22, 85 * REGBYTES(sp)
	STORE	x23, 86 * REGBYTES(sp)
	STORE	x24, 87 * REGBYTES(sp)
	STORE	x25, 88 * REGBYTES(sp)
	STORE	x26, 89 * REGBYTES(sp)
	STORE	x27, 90 * REGBYTES(sp)
	STORE	x28, 91 * REGBYTES(sp)
	STORE	x29, 92 * REGBYTES(sp)
	STORE	x30, 93 * REGBYTES(sp)
	STORE	x31, 94 * REGBYTES(sp)
    
    csrr    t0, mepc    
	STORE	t0, 95 * REGBYTES(sp)
	.endm   


.macro INT_Exit
	csrc mstatus,8
	LOAD	t0, 95 * REGBYTES(sp)
	csrw	mepc, t0

	LOAD	x1, 64 * REGBYTES(sp)
	LOAD	x4, 67 * REGBYTES(sp)
	LOAD	x5, 68 * REGBYTES(sp)
	LOAD	x6, 69 * REGBYTES(sp)
	LOAD	x7, 70 * REGBYTES(sp)
	LOAD	x8, 71 * REGBYTES(sp)
	LOAD	x9, 72 * REGBYTES(sp)
	LOAD	x10, 73 * REGBYTES(sp)
	LOAD	x11, 74 * REGBYTES(sp)
	LOAD	x12, 75 * REGBYTES(sp)
	LOAD	x13, 76 * REGBYTES(sp)
	LOAD	x14, 77 * REGBYTES(sp)
	LOAD	x15, 78 * REGBYTES(sp)
	LOAD	x16, 79 * REGBYTES(sp)
	LOAD	x17, 80 * REGBYTES(sp)
	LOAD	x18, 81 * REGBYTES(sp)
	LOAD	x19, 82 * REGBYTES(sp)
	LOAD	x20, 83 * REGBYTES(sp)
	LOAD	x21, 84 * REGBYTES(sp)
	LOAD	x22, 85 * REGBYTES(sp)
	LOAD	x23, 86 * REGBYTES(sp)
	LOAD	x24, 87 * REGBYTES(sp)
	LOAD	x25, 88 * REGBYTES(sp)
	LOAD	x26, 89 * REGBYTES(sp)
	LOAD	x27, 90 * REGBYTES(sp)
	LOAD	x28, 91 * REGBYTES(sp)
	LOAD	x29, 92 * REGBYTES(sp)
	LOAD	x30, 93 * REGBYTES(sp)
	LOAD	x31, 94 * REGBYTES(sp)


	addi	sp, sp, REGBYTES * 96
        csrs mstatus,8
	mret
	.endm


ISR5:
	INT_Entry
	jal ISR5_uart
	INT_Exit

ISR6:
	INT_Entry
	jal ISR6_addr_exception
	INT_Exit


