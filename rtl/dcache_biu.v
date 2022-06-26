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

`include "defines.v"

module dcache_biu(
//wishbone and controller interfacee I/Os
proc_clk,clk_x2,proc_rst,
wb_clk_i, wb_rst_i, wb_ack_i, wb_err_i, wb_rty_i, wb_dat_i,
wb_cyc_o, wb_adr_o, wb_stb_o, wb_we_o, wb_sel_o, wb_dat_o,
wb_cti_o, wb_bte_o, clmode,lsustall,
cache_en,
lsu_op_port1,lsu_op_port2,dcache_freeze,cache_flush,
proc_data_in_port1,proc_data_in_port2,proc_addr_in_port1,proc_addr_in_port2,
freeze,proc_data_port1,proc_data_port2,

ll_i,sc_i,addr_exception
/////////////////////////    
);

input proc_rst;
input clk_x2;
input proc_clk;
input wb_clk_i;
input wb_rst_i;
input wb_ack_i;
input wb_err_i;
input wb_rty_i;
input [31:0] wb_dat_i;
input [1:0] clmode;
input cache_en;
input lsustall;
input ll_i;             //signal to latch the address as linked address
input sc_i;             //signal to initiate check of input address and write
output reg wb_cyc_o;
output reg [31:0] wb_adr_o;
output reg wb_stb_o;
output reg wb_we_o;
output reg [3:0] wb_sel_o;
output reg [31:0] wb_dat_o;
output reg [2:0] wb_cti_o;
output reg [1:0] wb_bte_o;
output reg freeze;
output reg [31:0] proc_data_port1;
output reg [31:0] proc_data_port2;
input [4:0] lsu_op_port1;
input [4:0] lsu_op_port2;
input dcache_freeze;
input cache_flush;
input [31:0] proc_data_in_port1;
input [31:0] proc_data_in_port2;
input [31:0] proc_addr_in_port1;
input [31:0] proc_addr_in_port2;
output addr_exception;
///////////////////

wire wb_cyc_o_int;
wire [31:0] wb_adr_o_int;
wire wb_stb_o_int;
wire wb_we_o_int;
wire [3:0] wb_sel_o_int;
wire [31:0] wb_dat_o_int;
wire [2:0] wb_cti_o_int;
wire [1:0] wb_bte_o_int;
wire [31:0] bus_addr;
wire bus_rq;
wire bus_we;
wire bus_re;
wire [31:0] biu_dat_o_int; 
wire [255:0] bus_data;
//wire [255:0] bus_data_i;
wire bus_rdy;
wire freeze_int;
wire [31:0] proc_data_port1_int;
wire [31:0] proc_data_port2_int;
wire prp_acs0_int;            //Check if peripheral access is required
wire prp_acs1_int;            //Check if peripheral access is required
reg [31:0] addr_comp;       //store the lr/sc address alongwith reservation for checking violations
reg reservation_bit;        //checks for reservation on the supplied address; gets set at posedge if LL instr. 
                            //gets reset at posedge if conflicting mem access or SC instruction
reg sc_int;                 //Latches the sc_i signal so that data being written back can be chosen to be 0 or 1; for SC instruction
reg reservation_int;
wire biu_prp_acs;
wire [3:0] biu_sel_i;

wire 				wb_cyc_tlb_o;          
wire               wb_stb_tlb_o;
wire               wb_we_tlb_o;	
wire  [31:0] 		wb_adr_tlb_o;	   
wire  [1:0]        wb_bte_tlb_o;
wire  [2:0] 		wb_cti_tlb_o;     
wire  [3:0]        wb_sel_tlb_o;
wire  [31:0]       wb_dat_tlb_o;
wire tlb_freeze_dcache;

//reg dat;
//reg dat1;

//always @(posedge proc_clk ) begin
//    if(proc_rst) begin
//        dat <= 1'b0;
//    end
//    else if ( (proc_addr_in_port1 == 32'h20004) )begin
//        dat <= 1'b1;
//    end
//    else
//        dat <= 1'b0;
//end
//always @(posedge proc_clk ) begin
//    if(proc_rst) begin
//        dat <= 1'b0;
//    end
//    else if ((proc_data_in_port1 == 32'h25338) &&  (proc_addr_in_port1 == 32'h253bc) )begin
//        dat1 <= 1'b1;
//    end
//    else
//        dat1 <= 1'b0;
//end

always @(posedge proc_clk) begin
    if(proc_rst) begin
        sc_int      <= 1'b0;
        reservation_int <= 1'b0;
    end
    else begin
        if(~freeze_int & ~dcache_freeze) begin
            sc_int      <= sc_i;                    //Latch SC signal
            reservation_int <= reservation_bit;     //Latch reservation status
        end
    end
end

assign prp_acs0_int = cache_en | (proc_addr_in_port1[31:24] == `PERIPH_BASE);    //Check if address is in peripheral address range or cache disabled
assign prp_acs1_int = cache_en | (proc_addr_in_port2[31:24] == `PERIPH_BASE);    //Check if address is in peripheral address range or cache disabled

//////////////////////For LR/SC Instruction address violation check
always @(posedge proc_clk ) begin
    if(proc_rst) begin
        addr_comp <= 32'b0;
        reservation_bit <= 1'b0;
    end
    else begin
        if(~freeze_int & ~dcache_freeze) begin
            if(ll_i) begin
                addr_comp <= proc_addr_in_port2;
                reservation_bit <= 1'b1;
            end
            else if(sc_i) begin
                addr_comp <= 32'b0;
                reservation_bit <= ~((lsu_op_port2[1] ^ lsu_op_port2[0]) & (proc_addr_in_port2 == addr_comp)); 
            end
            else begin
                reservation_bit <= ~((lsu_op_port1[1] ^ lsu_op_port1[0]) & (proc_addr_in_port1 == addr_comp) | 
                                   (lsu_op_port2[1] ^ lsu_op_port2[0]) & (proc_addr_in_port2 == addr_comp));
            end
        end
    end    
end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


always @(*) begin
#2  wb_cyc_o <= wb_cyc_o_int | wb_cyc_tlb_o;       //Tcq delay
    wb_adr_o <= wb_stb_tlb_o ?  wb_adr_tlb_o : wb_adr_o_int ;
    wb_stb_o <= wb_stb_o_int | wb_stb_tlb_o;
    wb_we_o <=  wb_we_o_int  | wb_we_tlb_o ; 
    wb_sel_o <= wb_stb_tlb_o ? wb_sel_tlb_o : wb_sel_o_int ;
    wb_dat_o <= wb_stb_tlb_o ? wb_dat_tlb_o : wb_dat_o_int ;
    wb_cti_o <= wb_stb_tlb_o ? wb_cti_tlb_o : wb_cti_o_int ;
    wb_bte_o <= wb_stb_tlb_o ? wb_bte_tlb_o : wb_bte_o_int ;
    freeze <= freeze_int;
    case({{1'b0},{sc_int}})
        2'b00:proc_data_port1 <= proc_data_port1_int;
        2'b01:proc_data_port1 <= reservation_int ? 32'd0 : 32'd1;
        2'b10:proc_data_port1 <= biu_dat_o_int;
        2'b11:proc_data_port1 <= reservation_int ? 32'd0 : 32'd1;
        default: proc_data_port1 <= 32'd0;
    endcase;
    proc_data_port2 <= proc_data_port2_int;    
    //proc_data_port2 <= prp_acs0 ? biu_dat_o_int : proc_data_port2_int;    prp_acs0 is always 0
end

or1200_wb_biu biu1(
.clk(proc_clk), .rst(proc_rst), .clmode(clmode), .freeze(dcache_freeze | tlb_freeze_dcache),
.wb_clk_i(wb_clk_i), .wb_rst_i(wb_rst_i), .wb_ack_i(wb_ack_i), .wb_err_i(wb_err_i), .wb_rty_i(wb_rty_i), .wb_dat_i(wb_dat_i),
.wb_cyc_o(wb_cyc_o_int), .wb_adr_o(wb_adr_o_int), .wb_stb_o(wb_stb_o_int), .wb_we_o(wb_we_o_int), .wb_sel_o(wb_sel_o_int), .wb_dat_o(wb_dat_o_int),
.wb_cti_o(wb_cti_o_int),.wb_bte_o(wb_bte_o_int),
.biu_adr_i(bus_addr), .biu_cyc_i(bus_rq), .biu_stb_i(bus_rq), .biu_we_i(bus_we & ~bus_re), .biu_sel_i(biu_sel_i), .biu_cab_i(bus_rq),
.biu_dat_o(biu_dat_o_int),
.bus_data(bus_data),.bus_rdy(bus_rdy),.prp_acs(biu_prp_acs));

dcache_top dt1(.rst(proc_rst),.clk(proc_clk),.clk_x2(clk_x2),.freeze(freeze_int),.dtop_freeze(dcache_freeze),.cache_flush(cache_flush),.bus_rq(bus_rq),.bus_data(bus_data),.bus_addr(bus_addr),.bus_re(bus_re),.bus_we(bus_we),
.lsustall(lsustall),.lsu_op_port1(lsu_op_port1),.lsu_op_port2(lsu_op_port2),.prp_acs0(prp_acs0_int),.prp_acs1(prp_acs1_int),.biu_prp_acs(biu_prp_acs),
.proc_data_in_port1(proc_data_in_port1),.proc_data_in_port2(proc_data_in_port2),.proc_addr_in_port1(proc_addr_in_port1),.proc_addr_in_port2(proc_addr_in_port2),
.proc_data_port1(proc_data_port1_int),.proc_data_port2(proc_data_port2_int),.bus_rdy(bus_rdy),.sc_chkdone(sc_i ? reservation_bit : 1'b1),
.biu_sel_o(biu_sel_i),.tlb_freeze_dcache(tlb_freeze_dcache),.wb_ack_i(wb_ack_i),.wb_err_i(wb_err_i),.wb_rty_i(wb_rty_i),.wb_dat_i(wb_dat_i),
.wb_cyc_o(wb_cyc_tlb_o),.wb_stb_o(wb_stb_tlb_o),.wb_we_o (wb_we_tlb_o ),.wb_adr_o(wb_adr_tlb_o), .wb_bte_o(wb_bte_tlb_o),
.wb_cti_o(wb_cti_tlb_o),.wb_sel_o(wb_sel_tlb_o),.wb_dat_o(wb_dat_tlb_o),.addr_exception(addr_exception)
);

endmodule
