//******************************************************************************
// Copyright (c) 2014 - 2018, Indian Institute of Science, Bangalore.
// All Rights Reserved. See LICENSE for license details.
//------------------------------------------------------------------------------

// Contributors
// Akshay Birari (akshay@alum.iisc.ac.in), Piyush Birla (piyush@alum.iisc.ac.in)
// Suseela Budi (suseela@alum.iisc.ac.in), Pradeep Gupta (gupta@alum.iisc.ac.in)
// Kavya Sharat (kavyasharat@alum.iisc.ac.in), Sumeet Bandishte (sumeet.bandishte30@gmail.com)
// Kuruvilla Varghese (kuru@iisc.ac.in)
`timescale 1ns / 1ps

//`define secded 1'b1
//`define DTLB 1'b1
//`define rom 1
//`define PWM_IMPL 1
//`define Demo_En 1
`define ila_debug 1
//`define itlb_def 1'b1
//`define test_tlb 1'b1
//`define hardware_test 1'b0

`define OR1200_ASIC_MULTP2_32X32
`define op32_branch 7'b1100011
`define op32_loadop 7'b0000011
`define op32_muldiv 7'b0110011
`define op32_storeop 7'b0100011
`define op64_imm_alu 7'b0011011
`define op64_alu 7'b0111011
`define op32_imm_alu 7'b0010011
`define op32_alu 7'b0110011
`define op_lui 7'b0110111
`define op_auipc 7'b0010111
`define jal 7'b1101111
`define jalr 7'b1100111
`define amo 7'b0101111
`define sys 7'b1110011

`define op32_fp_loadop 7'b0000111
`define op32_fp_storeop 7'b0100111

`define alu_addsub 3'b000
`define alu_slt 3'b010
`define alu_sltu 3'b011
`define alu_xor 3'b100
`define alu_or 3'b110
`define alu_and 3'b111
`define alu_sll 3'b001
`define alu_srlsra 3'b101

`define func_beq 3'b000
`define func_bne 3'b001
`define func_blt 3'b100
`define func_bge 3'b101
`define func_bltu 3'b110
`define func_bgeu 3'b111

`define func_sb 3'b000
`define func_sh 3'b001
`define func_sw 3'b010
`define func_sd 3'b011
`define func_lb 3'b000
`define func_lh 3'b001
`define func_lw 3'b010
`define func_ld 3'b011
`define func_lbu 3'b100
`define func_lhu 3'b101
`define func_lwu 3'b110
`define func_srl 7'b0000000
`define func_add 7'b0000000
`define func_sub 7'b0100000
`define func_sra 7'b0100000
`define func_muldiv 7'b0000001

`define func_mul 3'b000
`define func_mulh 3'b001
`define func_mulhsu 3'b010
`define func_mulhu 3'b011
`define func_div 3'b100
`define func_divu 3'b101
`define func_rem 3'b110
`define func_remu 3'b111

`define rdcyc 12'b110000000000
`define rdcych 12'b110010000000
`define rdtim 12'b110000000001
`define rdtimh 12'b110010000001
`define rdist 12'b110000000010
`define rdisth 12'b110010000010

`define ISR_ADDRESS 32'd800     // ISR address made 800 instead 400 not to clash with PTE when no ITLB

//   Commented on 27/09/2016    //
//   Since UART_IMPL is commented in this
//   File only, uart module added by sumeet is 
//   disabled. Peripheral added by kavya is added
//   instead of this

//sumit peripheral address
`define PERIPH_BASE 8'h5f
/*
`define UART_REG_RB 32'h5f000000
`define UART_REG_TR 32'h5f000000
`define UART_REG_IE 32'h5f000001
`define UART_REG_II 32'h5f000002
`define UART_REG_FC 32'h5f000003
`define UART_REG_LC 32'h5f000004
`define UART_REG_MC 32'h5f000005
`define UART_REG_LS 32'h5f000006
`define UART_REG_MS 32'h5f000007
`define UART_REG_SR 32'h5f000008
`define UART_REG_DL1 32'h5f000000
`define UART_REG_DL2 32'h5f000001
*/
////   *************   /////

`define MM_adrMask 32'hfffff000
`define MM_adrBase 32'h5f100000

`define NUM_MASTER 2
`define NUM_SLAVES 4
`define DW 32
`define AW 32



//`define TEST 1
`define CACHE_FLUSH_TEST
//Timer Counter Macros
//`define EXT_WALL_CLOCK 1              //Uncomment if an external clock is used for the 1Hz tick timer
`define WALL_CLOCK_COMP_VAL 27'd100000000
`define UART_IMPL_PER 1     //Changed from UART_IMPL to UART_IMPL_PER on 27-09-2016
//`define SW_LED_IMPL 1



//--------------- Defines added from Kavya defines ----------- //
//    27/09/2016     //

//`define TESTING 1
//`define UART_IMPL 1

`define XADC_BASE 16'h06 

//`define PERIPH_BASE  23'b00000000000000000000011//22'b0000000000000000000001//23'b00000000000000000000011//000000000000000000000111111

`define set_pend_act_stacksave 1
`define clear_pend_act_stackrestore 2
`define write_id_priority 3  
`define priority_compare 4
`define set_pending 5
`define find_max 6
`define set_active 7

`define interrupt_inactive 0
`define interrupt_pending 1
`define interrupt_active 2
`define TESTING 1

`define PWM_DC_REG 32'h5F100800
`define ADC_REG 32'h5F100804
`define TEMP_REG 32'h5F100808
`define LCD_REG 32'h5F10080C
`define BUZZER_REG 32'h5F100810
`define led_addr 32'h5F100814

`define SECDED_ADDRESS_REG 32'h100006F0
`define SECDED_DATA_REG 32'h100006F4
`define SECDED_ENABLE_REG 32'h100006F8

`define PTC_RPTC_CTRL_ECLK 1
`define PTC_RPTC_CTRL_CAPTE 8
`define PTC_RPTC_CTRL_OE 3
`define PTC_RPTC_CTRL_NEC 2
`define PTC_RPTC_CTRL_INTE 5
`define PTC_RPTC_CTRL_INT 6
`define PTC_RPTC_CTRL_EN 0 
`define PTC_RPTC_CTRL_CNTRRST 7
`define PTC_RPTC_CTRL_SINGLE 4
 
`define PTC_RPTC_CNTR 32'h100005F0
`define PTC_RPTC_HRC 32'h100005F4
`define PTC_RPTC_LRC 32'h100005F8
`define PTC_RPTC_CTRL 32'h100005FC

`ifdef DATA_BUS_WIDTH_8
 `define UART_ADDR_WIDTH 3
 `define UART_DATA_WIDTH 8
`else
 `define UART_ADDR_WIDTH 32
 `define UART_DATA_WIDTH 32
`endif

// Uncomment this if you want your UART to have
// 16xBaudrate output port.
// If defined, the enable signal will be used to drive baudrate_o signal
// It's frequency is 16xbaudrate

// `define UART_HAS_BAUDRATE_OUTPUT

// Register addresses; Not used as defined in defines.v

//`define UART_REG_RB	 32'h000006F0//`UART_ADDR_WIDTH'd0	// receiver buffer
//`define UART_REG_TR  32'h000006F0//`UART_ADDR_WIDTH'd0	// transmitter
//`define UART_REG_IE	32'h000006F4//`UART_ADDR_WIDTH'd1	// Interrupt enable
//`define UART_REG_II  32'h000006F8//`UART_ADDR_WIDTH'd2	// Interrupt identification
//`define UART_REG_FC  32'h000006F8//`UART_ADDR_WIDTH'd2	// FIFO control
//`define UART_REG_LC	32'h000006FC//`UART_ADDR_WIDTH'd3	// Line Control
//`define UART_REG_MC	32'h000005F0//`UART_ADDR_WIDTH'd4	// Modem control
//`define UART_REG_LS  32'h000005F4//`UART_ADDR_WIDTH'd5	// Line status
//`define UART_REG_MS  32'h000005F8//`UART_ADDR_WIDTH'd6	// Modem status
//`define UART_REG_SR  32'h000005FC//`UART_ADDR_WIDTH'd7	// Scratch register
//`define UART_REG_DL1	32'h000006F0//`UART_ADDR_WIDTH'd0	// Divisor latch bytes (1-2)
//`define UART_REG_DL2	32'h000006F4//`UART_ADDR_WIDTH'd1

`define UART_REG_RB	 32'h5F1006F0//`UART_ADDR_WIDTH'd0	// receiver buffer
`define UART_REG_TR  32'h5F1006F0//`UART_ADDR_WIDTH'd0	// transmitter
`define UART_REG_IE	 32'h5F1006F1//`UART_ADDR_WIDTH'd1	// Interrupt enable
`define UART_REG_II  32'h5F1006F2//`UART_ADDR_WIDTH'd2	// Interrupt identification
`define UART_REG_FC  32'h5F1006F3//`UART_ADDR_WIDTH'd2	// FIFO control
`define UART_REG_LC	 32'h5F1006F4//`UART_ADDR_WIDTH'd3	// Line Control
`define UART_REG_MC	 32'h5F1006F5//`UART_ADDR_WIDTH'd4	// Modem control
`define UART_REG_LS  32'h5F1006F6//`UART_ADDR_WIDTH'd5	// Line status
`define UART_REG_MS  32'h5F1006F7//`UART_ADDR_WIDTH'd6	// Modem status
`define UART_REG_SR  32'h5F1006F8//`UART_ADDR_WIDTH'd7	// Scratch register
`define UART_REG_DL1 32'h5F1006F0//`UART_ADDR_WIDTH'd0	// Divisor latch bytes (1-2)
`define UART_REG_DL2 32'h5F1006F1//`UART_ADDR_WIDTH'd1


// Interrupt Enable register bits
`define UART_IE_RDA	0	// Received Data available interrupt
`define UART_IE_THRE	1	// Transmitter Holding Register empty interrupt
`define UART_IE_RLS	2	// Receiver Line Status Interrupt
`define UART_IE_MS	3	// Modem Status Interrupt

// Interrupt Identification register bits
`define UART_II_IP	0	// Interrupt pending when 0
`define UART_II_II	3:1	// Interrupt identification

// Interrupt identification values for bits 3:1
`define UART_II_RLS	3'b011	// Receiver Line Status
`define UART_II_RDA	3'b010	// Receiver Data available
`define UART_II_TI	3'b110	// Timeout Indication
`define UART_II_THRE	3'b001	// Transmitter Holding Register empty
`define UART_II_MS	3'b000	// Modem Status

// FIFO Control Register bits
`define UART_FC_TL	1:0	// Trigger level

// FIFO trigger level values
`define UART_FC_1		2'b00
`define UART_FC_4		2'b01
`define UART_FC_8		2'b10
`define UART_FC_14	2'b11

// Line Control register bits
`define UART_LC_BITS	1:0	// bits in character
`define UART_LC_SB	2	// stop bits
`define UART_LC_PE	3	// parity enable
`define UART_LC_EP	4	// even parity
`define UART_LC_SP	5	// stick parity
`define UART_LC_BC	6	// Break control
`define UART_LC_DL	7	// Divisor Latch access bit

// Modem Control register bits
`define UART_MC_DTR	0
`define UART_MC_RTS	1
`define UART_MC_OUT1	2
`define UART_MC_OUT2	3
`define UART_MC_LB	4	// Loopback mode

// Line Status Register bits
`define UART_LS_DR	0	// Data ready
`define UART_LS_OE	1	// Overrun display
`define UART_LS_PE	2	// Parity display
`define UART_LS_FE	3	// Framing display
`define UART_LS_BI	4	// Break interrupt
`define UART_LS_TFE	5	// Transmit FIFO is empty
`define UART_LS_TE	6	// Transmitter Empty indicator
`define UART_LS_EI	7	// display indicator

// Modem Status Register bits
`define UART_MS_DCTS	0	// Delta signals
`define UART_MS_DDSR	1
`define UART_MS_TERI	2
`define UART_MS_DDCD	3
`define UART_MS_CCTS	4	// Complement signals
`define UART_MS_CDSR	5
`define UART_MS_CRI	6
`define UART_MS_CDCD	7

// FIFO parameter defines
`define UART_FIFO_WIDTH	8
`define UART_FIFO_DEPTH	16
`define UART_FIFO_POINTER_W	4
`define UART_FIFO_COUNTER_W	5
// receiver fifo has width 11 because it has break, parity and framing display bits
`define UART_FIFO_REC_WIDTH  11


`define VERBOSE_WB  0           // All activity on the WISHBONE is recorded
`define VERBOSE_LINE_STATUS 0   // Details about the lsr (line status register)
`define FAST_TEST   1           // 64/1024 packets are sent
//   --------------------------  //

`define mcycle      12'hb00
`define mtime       12'hb01
`define minstret    12'hb02
`define mcycleh     12'hb80
`define mtimeh      12'hb81
`define minstreth   12'hb82
`define mepc        12'h341
`define mstatus     12'h300
`define mtvec       12'h305
`define mcause      12'h342
`define mie         12'h304
`define minstret    12'hb02
`define mtvec_default 32'd800
`define mcause_default 32'h80000008
`define mie_default 32'h00000000
`define mstatus_default 32'h00001888        // this will change as other modes will be implemented 
`define mie_mask 32'hFFFFF888

`define misa      12'h301
`define misa_default 32'h40001101   // this will change as features will increase in processor
`define misa_mask 32'h40001101   // this will change as features will increase in processor

`define mvendorid      12'hf11
`define marchid      12'hf12
`define mimpid      12'hf13
`define mhartid      12'hf14
`define medeleg      12'hf14
`define mideleg      12'hf14
`define mbadaddr      12'h343

`define medeleg_default 32'h0   // this will change as other modes will be implemented 
`define mideleg_default 32'h0   // this will change as other modes will be implemented 
`define mbadaddr_default 32'h0   

`define fflags 12'h001
`define frm    12'h002
`define fcsr   12'h003

`define fcsr_default 32'h00000000

`define ffcsr_mask   32'h000000FF
`define fflags_mask  32'h0000001F
`define frm_mask     32'h000000E0

// ------ NON standard registers  ------  //
`define mtimecmp    12'h7c0
`define mtimecmph   12'h7c1
`define mepc_shadow 12'h7c2
`define counttick 12'h7c3
`define Num_tick 12'h7c4

// ------ NON standard registers for Interrupt Controller  ------  //

`define ENABLE_REG          12'h7d0
`define ACTIVE_REG          12'h7d1
`define PENDING_REG         12'h7d2
`define PRIORITY_REG0       12'h7d3
`define PRIORITY_REG1       12'h7d4
`define PRIORITY_REG2       12'h7d5
`define PRIORITY_REG3       12'h7d6
`define STACK_SAVE_REG      12'h7d7
`define STACK_SAVE_REG_S    12'h7d8  // shadow register for STACK_SAVE_REG 
