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
module	intercon(i_clk, i_rst, roundORpriority,

	wbm_adr_i, wbm_dat_i, wbm_we_i, wbm_stb_i, wbm_sel_i, wbm_cyc_i, wbm_cti_i, wbm_bte_i,
	wbm_ack_o, wbm_rty_o, wbm_err_o, wbm_dat_o,
	wbs_adr_o, wbs_dat_o, wbs_we_o, wbs_stb_o, wbs_sel_o, wbs_cyc_o, wbs_cti_o, wbs_bte_o,
	wbs_ack_i, wbs_rty_i, wbs_err_i, wbs_dat_i);
	parameter			DW=32, AW=32;
	parameter           num_master = 2;
	parameter           num_slaves = 4;
    parameter slave_sel_bits = num_slaves > 1 ? $clog2(num_slaves) : 1;
//    parameter [num_slaves*AW-1:0] MATCH_ADDR = 0;
//    parameter [num_slaves*AW-1:0] MATCH_MASK = 0;

    parameter idle = 1'b0;
    parameter transaction = 1'b1;

    parameter [DW*num_slaves-1:0] MATCH_ADDR = {32'h5f100700, //Iterrupt Controller
    			32'h5f100800, //--
    			32'h5f100600, //UART
    			32'h00000000};//Main memory
    parameter [DW*num_slaves-1:0] MATCH_MASK = {{num_slaves-1{32'hfff00f00}},{32'hfff00000} };
    
    input i_clk;
    input i_rst;
    input roundORpriority;
    //Master Signals
    input [(num_master*AW-1):0] wbm_adr_i;
    input [(num_master*DW-1):0] wbm_dat_i;
    input [num_master-1:0]      wbm_we_i;
    input [num_master-1:0]      wbm_stb_i;
    input [num_master-1:0]      wbm_cyc_i;
    input [(num_master*3-1):0] wbm_cti_i;
    input [(num_master*2-1):0] wbm_bte_i;
    input [(num_master*4-1):0] wbm_sel_i;
    output [num_master-1:0] wbm_ack_o;    
    output [num_master-1:0] wbm_err_o;    
    output [num_master-1:0] wbm_rty_o;    
    output [(num_master*DW-1):0] wbm_dat_o;    
    //Slave Signals
    output [(num_slaves*AW-1):0] wbs_adr_o;
    output [(num_slaves*DW-1):0] wbs_dat_o;
    output [num_slaves-1:0]    wbs_we_o;
    output [num_slaves-1:0]    wbs_stb_o;
    output [(num_slaves*4-1):0]  wbs_sel_o;
    output [num_slaves-1:0]    wbs_cyc_o;
    output [(num_slaves*3-1):0]  wbs_cti_o;
    output [(num_slaves*2-1):0]  wbs_bte_o;
    input [num_slaves-1:0]     wbs_ack_i;
    input [num_slaves-1:0]     wbs_rty_i;
    input [num_slaves-1:0]     wbs_err_i;
    input [(num_slaves*DW-1):0]  wbs_dat_i;


    wire [AW-1:0] o_adr_int;
    wire [DW-1:0] o_dat_int;
    wire o_we_int;
    wire o_stb_int;
    wire o_cyc_int;
    wire [2:0] o_cti_int;
    wire [1:0] o_bte_int;
    wire [3:0] o_sel_int;
    wire [DW-1:0] s_dat_int;    
    wire ack_int;
    wire err_int;
    wire rty_int;
    
wb_bus_ctrl #(DW,AW,num_master) ctrl(.i_clk(i_clk), .i_rst(i_rst), .roundORpriority(roundORpriority),
.i_adr(wbm_adr_i), .i_dat(wbm_dat_i), .i_we(wbm_we_i), .i_stb(wbm_stb_i), .i_sel(wbm_sel_i), .i_cyc(wbm_cyc_i), .i_cti(wbm_cti_i),
.i_bte(wbm_bte_i), .o_ack(wbm_ack_o), .o_rty(wbm_rty_o), .o_err(wbm_err_o), .m_dat_o(wbm_dat_o),
//////////////////Internal Connections///////////////////////////////////////////////////////////////////////////////////////////
.o_adr(o_adr_int), .o_dat(o_dat_int), .o_we(o_we_int), .o_stb(o_stb_int), .o_cyc(o_cyc_int), .o_cti(o_cti_int), .o_bte(o_bte_int),
.i_ack(ack_int), .i_rty(rty_int), .i_err(err_int), .s_dat_i(s_dat_int), .o_sel(o_sel_int));

wb_mux #(DW,AW,num_slaves,MATCH_ADDR,MATCH_MASK) mux(
.wb_clk_i(i_clk),
.wb_rst_i(i_rst),
.wbm_adr_i(o_adr_int),
.wbm_dat_i(o_dat_int),
.wbm_sel_i(o_sel_int),
.wbm_we_i(o_we_int),
.wbm_cyc_i(o_cyc_int),
.wbm_stb_i(o_stb_int),
.wbm_cti_i(o_cti_int),
.wbm_bte_i(o_bte_int),
.wbm_dat_o(s_dat_int),
.wbm_ack_o(ack_int),
.wbm_err_o(err_int),
.wbm_rty_o(rty_int), 
// Wishbone Slave interface
.wbs_adr_o(wbs_adr_o),
.wbs_dat_o(wbs_dat_o),
.wbs_sel_o(wbs_sel_o), 
.wbs_we_o(wbs_we_o),
.wbs_cyc_o(wbs_cyc_o),
.wbs_stb_o(wbs_stb_o),
.wbs_cti_o(wbs_cti_o),
.wbs_bte_o(wbs_bte_o),
.wbs_dat_i(wbs_dat_i),
.wbs_ack_i(wbs_ack_i),
.wbs_err_i(wbs_err_i),
.wbs_rty_i(wbs_rty_i));

endmodule