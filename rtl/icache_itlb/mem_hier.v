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
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.12.2015 20:03:02
// Design Name: 
// Module Name: icache
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module mem_hier
(
clk,
rst_n,
freeze_in,
//i_acc, 
i_addr,
instr_out,
stall_out,
wb_clk_i,wb_rst_i,wb_ack_i,wb_err_i,wb_rty_i,wb_dat_i,wb_cyc_o,
wb_stb_o,wb_we_o,wb_adr_o,wb_bte_o,wb_cti_o,wb_sel_o,wb_dat_o
);

input clk, rst_n;
//input i_acc;
input [31:0]  i_addr;
wire ctrl, irq_ctrl;
input freeze_in;

parameter offset_start_bit = 0;
parameter page_offset_start = 0;
parameter page_offset_last = 11;
parameter offset_last_bit = 4;
parameter index_start_bit = 5;
parameter index_last_bit = 11;
parameter tag_start_bit = 12;
parameter tag_last_bit = 31;
parameter tag_tlb_start_bit = 4;
parameter tag_tlb_last_bit = 23;
parameter tag_phy_start_bit = 0;
parameter tag_phy_last_bit = 19;

input				wb_clk_i;	// clock input
input				wb_rst_i;	// reset input
input				wb_ack_i;	// normal termination
input				wb_err_i;	// termination w/ error
input				wb_rty_i;	// termination w/ retry
input  [31:0]       wb_dat_i;
output				wb_cyc_o;
output              wb_stb_o;	// strobe output
output              wb_we_o;	// indicates write transfer
output [31:0] 		wb_adr_o;	
output [2:0]        wb_bte_o;
output [2:0] 		wb_cti_o;
output [3:0]        wb_sel_o;	// byte select outputs for the signals-byte select and extend
output [31:0]       wb_dat_o;	// output data bus

// Internal RISC interface

wire				biu_we_i;	// WB write enable

wire				i_hit;	// cycle valid output

wire [255:0] bus_line;	// output data bus
wire bus_rdy;   //interface to the dcache unit


output [31:0] instr_out;

wire [1:0] state;
wire [255:0]  i_line,x;
wire [18:0]  dout1;
output reg stall_out;

wire [31:0] i_addr_cache;
reg [31:0]  i_addr_cache_my;
reg stall_int;

reg stall;
wire [3:0] burst_len;
wire  m_re,i_we;
wire d_we,rdy;
wire [31:0] m_addr;
wire [255:0]       m_data;
wire[255:0] set_0,set_1;
wire [18:0] tag_0,tag_1;
wire [31:0] 			wb_dat_ii;	
wire i_acc_int;
wire i_acc;
wire [31:0] 			biu_dat_o;
wire we0,we1;
wire[255:0] y;
wire [1:0] state_we;
wire [18:0] dout2;
wire lru_bit_temp;
wire [31:0] instr;
wire [3:0] 	biu_sel_i;	// byte selects

//register to concatenate the words
wire [2:0] 			wb_cti_o;	// cycle type identifier
wire [1:0] 				wb_fsm_state_cur;
wire rd, wr,m_rdy_n;
wire [31:0] addr;
wire biu_cyc_i,biu_stb_i,biu_cab_i;

wire [255:0] bus_data;          
wire[4:0] temp1;
wire[255:0] i_data;
wire [31:0] addr_latch;
wire freeze;

wire				wb_cyc_o_int;
wire              wb_stb_o_int;	// strobe output
wire              wb_we_o_int;	// indicates write transfer
wire [31:0] 		wb_adr_o_int;	
wire [2:0]        wb_bte_o_int;
wire [2:0] 		wb_cti_o_int;
wire [3:0]        wb_sel_o_int;	// byte select outputs for the signals-byte select and extend
wire [31:0]       wb_dat_o_int;	// output data bus



`ifdef itlb_def
wire 				wb_cyc_tlb_o;          
wire               wb_stb_tlb_o;
wire               wb_we_tlb_o;	
wire  [31:0] 		wb_adr_tlb_o;	   
wire  [2:0]        wb_bte_tlb_o;
wire  [2:0] 		wb_cti_tlb_o;     
wire  [3:0]        wb_sel_tlb_o;
wire  [31:0]       wb_dat_tlb_o;

reg [31:0]  physical_adr;
wire [tag_phy_last_bit:tag_phy_start_bit] tag_o_tlb;
wire tag_hit;

assign    wb_cyc_o = wb_cyc_o_int | wb_cyc_tlb_o;      
assign    wb_adr_o = wb_stb_tlb_o ?  wb_adr_tlb_o : wb_adr_o_int ;
assign    wb_stb_o = wb_stb_o_int | wb_stb_tlb_o;
assign    wb_we_o  = wb_we_o_int  | wb_we_tlb_o ; 
assign    wb_sel_o = wb_stb_tlb_o ? wb_sel_tlb_o : wb_sel_o_int ;
assign    wb_dat_o = wb_stb_tlb_o ? wb_dat_tlb_o : wb_dat_o_int ;
assign    wb_cti_o = wb_stb_tlb_o ? wb_cti_tlb_o : wb_cti_o_int ;
assign    wb_bte_o = wb_stb_tlb_o ? wb_bte_tlb_o : wb_bte_o_int ;

assign freeze = freeze_tlb_out | freeze_in;
assign i_acc  = i_acc_int;

`else
assign    wb_cyc_o = wb_cyc_o_int;     
assign    wb_adr_o =  wb_adr_o_int ;
assign    wb_stb_o = wb_stb_o_int ;
assign    wb_we_o  = wb_we_o_int;  
assign    wb_sel_o = wb_sel_o_int ;
assign    wb_dat_o = wb_dat_o_int ;
assign    wb_cti_o = wb_cti_o_int ;
assign    wb_bte_o = wb_bte_o_int ;

assign freeze = freeze_in;
assign i_acc  = i_acc_int;

`endif 

assign i_acc_int = 1'b1;

or1200_wb_biu1 a1(
// RISC clock, reset and clock control
.clk(clk), 
.rst(rst_n), 
.clmode(2'b00),

// WISHBONE interface
.wb_clk_i(wb_clk_i), 
.wb_rst_i(wb_rst_i),
.wb_ack_i(wb_ack_i), .wb_err_i(wb_err_i),
.wb_rty_i(wb_rty_i), .wb_dat_i(wb_dat_i),
.wb_cyc_o(wb_cyc_o_int), .wb_adr_o(wb_adr_o_int), .wb_stb_o(wb_stb_o_int),
.wb_we_o(wb_we_o_int), .wb_sel_o(wb_sel_o_int), 
.wb_dat_o(wb_dat_o_int),
.wb_cti_o(wb_cti_o_int),
.wb_bte_o(wb_bte_o_int),
//to be removed///////////
// Internal RISC bus
.biu_adr_i(i_addr_cache & 32'hffffffe0), 
.biu_cyc_i(biu_cyc_i),
.biu_stb_i(biu_stb_i),
.biu_we_i(biu_we_i),
.biu_sel_i(biu_sel_i),
.biu_cab_i(biu_cab_i),
.biu_dat_o(biu_dat_o),
/////////////////////////		     
//risc-v proc interface
.bus_data(bus_data),
.bus_rdy(bus_rdy),
.burst_len(burst_len),
.wb_fsm_state_cur(wb_fsm_state_cur),
.bus_line(bus_line)
);

/*  Cache */
icache icache1(.clk(clk),//input
.rst_n(rst_n),//input
.freeze(freeze && ~stall_out), 
.freeze_in(freeze_in), 
.wr_data(i_data),
.we(i_we),
.re(i_acc_int),
.hit(i_hit),//output
.rd_data(i_line),//output
.state_we(state_we),
.dout1(dout1),.dout2(dout2),.x(x),.y(y),
.we0(we0),.we1(we1),
.lru_bit_temp(lru_bit_temp),
.temp1(temp1),
.addr_int(i_addr_cache[31:0]),
.i_addr(i_addr),
.stall(stall),
.re_int(i_acc_int),
.i_addr_cache_my(i_addr_cache_my[31:0]),
.instr(instr),
.i_addr_cache_my_full(i_addr_cache_my[4:0]),
.irq_ctrl(irq_ctrl|ctrl)
`ifdef itlb_def
,.tag_o_tlb(tag_o_tlb),.freeze_tlb_out(freeze_tlb_out),.tag_hit(tag_hit),
.wb_ack_i(wb_ack_i),.wb_err_i(wb_err_i),.wb_rty_i(wb_rty_i),.wb_dat_i(wb_dat_i)
,.wb_cyc_o(wb_cyc_tlb_o),.wb_stb_o(wb_stb_tlb_o),.wb_we_o(wb_we_tlb_o),.wb_adr_o(wb_adr_tlb_o)
,.wb_bte_o(wb_bte_tlb_o),.wb_cti_o(wb_cti_tlb_o),.wb_sel_o(wb_sel_tlb_o),.wb_dat_o(wb_dat_tlb_o)
`endif
);

assign #1 instr_out= instr;

`ifdef itlb_def
always@(*)
begin
    if(rst_n)
        stall_out<=0;
    else
            stall_out <= stall;

    //    stall_out <= stall || freeze_tlb_out;
//        stall_out<=(stall||stall_int);// && (!i_hit);
end
`else
always@(*)
begin
    if(rst_n)
        stall_out<=0;
    else
        stall_out <= stall;
//        stall_out<=(stall||stall_int);// && (!i_hit);
end
`endif
/*
always@(posedge clk or posedge rst_n)
begin
    if(rst_n)
#1        stall_int<=0;
    else
#2        stall_int<=stall && !(i_hit);
end
*/
//always @(*)
//begin
//    #2 i_addr_cache <= i_addr_cache_my;
//end

always@(posedge rst_n or posedge clk)
begin
    if(rst_n)
        i_addr_cache_my <= -4;
    else if(~stall & ~freeze)//||(freeze && i_hit && ((stall|stall_int)==0)))
        i_addr_cache_my<=i_addr;
end

`ifdef itlb_def
always@(posedge rst_n or posedge clk)
begin
    if(rst_n)
        physical_adr <= -4;
    else if(/*~stall & ~freeze &*/ tag_hit)//||(freeze && i_hit && ((stall|stall_int)==0)))
 //       physical_adr <= {tag_o_tlb, i_addr_cache_my[page_offset_last : page_offset_start]};
        physical_adr <= {tag_o_tlb, i_addr[page_offset_last : page_offset_start]};
end
assign i_addr_cache = physical_adr;
`else
assign i_addr_cache = i_addr_cache_my;
`endif

    cachefsm a3(.clk(clk),	
    .rst_n(rst_n),
    .freeze((freeze /*&& ~stall_out*/)), 
    .freeze_in (freeze_in),
    .i_hit(i_hit),
    //.mem_rdy(m_rdy_n),
    .m_line_full(bus_line),
 `ifdef itlb_def
    .tag_hit(tag_hit),
 `endif    
    .i_addr(i_addr),
    .i_acc(i_acc),
    .i_we(i_we),//output
    .m_re(m_re),
    .m_addr(m_addr),
    .i_data(i_data),
    .rdy(rdy),
    .state(state),
    .biu_cyc_i(biu_cyc_i),
    .biu_stb_i(biu_stb_i),
    .biu_cab_i (biu_cab_i),
    .biu_sel_i(biu_sel_i),
    .wb_dat_i(wb_dat_ii),
    .wb_ack_i(wb_ack_i && wb_stb_o_int),
    .addr_latch(addr_latch),
    .i_addr_int(i_addr),//_int)
    .i_addr_cache_my(i_addr_cache_my)
    );
    
    /* Top Level Routing Logic */
    
    always@(*) begin
        if(i_hit)
            stall = 0;
        else if(rdy==1)//||freeze)
            stall = 1;
    end

    assign biu_we_i = 1'b0;


endmodule