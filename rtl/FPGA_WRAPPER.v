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
// Create Date: 30.12.2015 11:19:02
// Design Name: 
// Module Name: FPGA_WRAPPER
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
`include "defines.v"

module FPGA_WRAPPER(rst_in,clk_in1_n,clk_in1_p,led,int_in
`ifdef UART_IMPL_PER
,srx_pad_i,stx_pad_o
//,rts_pad_o,cts_pad_i,dtr_pad_o,dsr_pad_i,ri_pad_i,dcd_pad_i
`endif
`ifdef SW_LED_IMPL
,sw1_i,sw2_i,sw3_i,led1_o,led2_o,led3_o
`endif
`ifdef TEST
,clk_int
,instr_int,blck_instr_int
`endif
`ifdef Demo_En
 ,vn_in
 ,vp_in
 ,pwm_o
 ,buzzer_o
 ,temp_set_in
 ,temp_set_en
 ,lcd_en_o
 ,lcd_rs_o
 ,lcd_rw_o
 ,lcd_data_o 
`endif
//,out_t0,out_t1,out_t2
);

`ifdef UART_IMPL_PER
input 								 srx_pad_i;
output 								 stx_pad_o;
//output 								 rts_pad_o;
//input 								 cts_pad_i;
//output 								 dtr_pad_o;
//input 								 dsr_pad_i;
//input 								 ri_pad_i;
//input 								 dcd_pad_i;
`endif

`ifdef SW_LED_IMPL
input sw1_i;
input sw2_i;
input sw3_i;
output led1_o;
output led2_o;
output led3_o;
`endif

input rst_in;
input clk_in1_n;
input clk_in1_p;
`ifdef TEST
output clk_int;
output [31:0] instr_int;
output [31:0] blck_instr_int;
`endif

input [2:0] int_in;
output [7:0] led;

`ifdef Demo_En
 input vn_in;
 input vp_in;
 input [7:0] temp_set_in;
 input temp_set_en;
 output pwm_o; 
 output buzzer_o; 
 output lcd_en_o;  
 output lcd_rs_o;  
 output lcd_rw_o;  
 output [3:0] lcd_data_o;
`endif


wire rst_VIO;

wire [31:0] out_t0;
wire [31:0] out_t1;
wire [31:0] out_t2;
wire [31:0] led_w;

wire clk_int;
wire clk_x2;

wire [31:0] wb_dat_emu;
wire [31:0] wb_dat_uart;
wire [31:0] p;
wire [1:0] clmode;
wire [31:0] pc_cache;
wire freeze;

wire [31:0] interrupt;

wire cache_flush_int;
wire cache_en_int;
//wire [31:0] led; 


wire [(`NUM_MASTER*`AW-1):0] wb_adr_o;
wire [(`NUM_MASTER*`DW-1):0] wb_dat_o;
wire [`NUM_MASTER-1:0]      wb_we_o;
wire [`NUM_MASTER-1:0]      wb_stb_o;
wire [`NUM_MASTER-1:0]      wb_cyc_o;
wire [(`NUM_MASTER*3-1):0] wb_cti_o;
wire [(`NUM_MASTER*2-1):0] wb_bte_o;
wire [(`NUM_MASTER*4-1):0] wb_sel_o;
wire [`NUM_MASTER-1:0] wb_ack_i;    
wire [`NUM_MASTER-1:0] wb_err_i;    
wire [`NUM_MASTER-1:0] wb_rty_i;    
wire [(`NUM_MASTER*`DW-1):0] wb_dat_i;    
//Slave Signals
wire [(`NUM_SLAVES*`AW-1):0] wbs_adr_o;
wire [(`NUM_SLAVES*`DW-1):0] wbs_dat_o;
wire [`NUM_SLAVES-1:0]    wbs_we_o;
wire [`NUM_SLAVES-1:0]    wbs_stb_o;
wire [(`NUM_SLAVES*4-1):0]  wbs_sel_o;
wire [`NUM_SLAVES-1:0]    wbs_cyc_o;
wire [(`NUM_SLAVES*3-1):0]  wbs_cti_o;
wire [(`NUM_SLAVES*2-1):0]  wbs_bte_o;
wire [`NUM_SLAVES-1:0]     wbs_ack_i;
wire [`NUM_SLAVES-1:0]     wbs_rty_i;
wire [`NUM_SLAVES-1:0]     wbs_err_i;
wire [(`NUM_SLAVES*`DW-1):0]  wbs_dat_i;

reg rst_int;
reg rst;

wire tick_en;
wire [2:0] int_in_clean;

// **   Debounce of inputs taken from push_button **  //
debouce db_int0(.reset(rst),.clk(clk_int),.noisy(int_in[0]),.clean(int_in_clean[0]));
debouce db_int1(.reset(rst),.clk(clk_int),.noisy(int_in[1]),.clean(int_in_clean[1]));
debouce db_int2(.reset(rst),.clk(clk_int),.noisy(int_in[2]),.clean(int_in_clean[2]));

`ifdef Demo_En
wire [15:0] adc_reg;
wire [63:0] lcd_reg;
wire temp_set_en_o;
reg [7:0] temp_set_reg;
debouce db_temp(.reset(rst),.clk(clk_int),.noisy(temp_set_en),.clean(temp_set_en_o));
//assign temp_set_en_o = temp_set_en;
always @(posedge temp_set_en_o or posedge rst) begin
    if(rst)
        temp_set_reg <= 8'b0010_0110;
    else
        temp_set_reg <= {temp_set_in[0],temp_set_in[1],temp_set_in[2],temp_set_in[3],temp_set_in[4],temp_set_in[5],temp_set_in[6],temp_set_in[7]};
end
`endif

                    // ******************** //                   
assign interrupt = {  26'b0, addr_exception, received, tick_en, int_in_clean};
//assign interrupt = {  26'b0, addr_exception, received, tick_en, int_in};
assign wbs_err_i[2] = 1'b0;
assign wbs_err_i[3] = 1'b0;
assign wbs_rty_i[2] = 1'b0;
assign wbs_rty_i[3] = 1'b0;

assign cache_flush_int = 1'b0;
assign cache_en_int = 1'b0;
//////////

////////////////////////Reset Synchroniser/////////////////////////////
//always @(posedge clk_int) begin
//#1  rst_int <= rst_VIO;
//    rst     <= rst_int;
//end

always @(posedge clk_int) begin
    #1  rst_int <= rst_in;
    rst     <= rst_int;
end

clk_wiz_0 clk_core
(
// Clock in ports
.clk_in1_p(clk_in1_p),    // input clk_in1_p
.clk_in1_n(clk_in1_n),    // input clk_in1_n
// Clock out ports
.clk_out1(clk_int),    // output clk_out1
.clk_out2(clk_x2));    // output clk_out2
`ifdef secded
ext_emulator_secded em2(.clk(clk_int),.rst(rst),.wb_dat_i(wbs_dat_i[31:0]),.wb_cyc_o(wbs_cyc_o[0]),.wb_adr_o(wbs_adr_o[31:0]),.wb_stb_o(wbs_stb_o[0]),
.wb_we_o(wbs_we_o[0]),.wb_sel_o(wbs_sel_o[3:0]),.wb_dat_o(wbs_dat_o[31:0]),.wb_cti_o(wbs_cti_o[2:0]),.wb_bte_o(wbs_bte_o[1:0]),.clmode(clmode),
.wb_ack_i(wbs_ack_i[0]),.wb_err_i(wbs_err_i[0]),.wb_rty_i(wbs_rty_i[0]));
`else
ext_emulator em1(.clk(clk_int),.rst(rst),.wb_dat_i(wbs_dat_i[31:0]),.wb_cyc_o(wbs_cyc_o[0]),.wb_adr_o(wbs_adr_o[31:0]),.wb_stb_o(wbs_stb_o[0]),
.wb_we_o(wbs_we_o[0]),.wb_sel_o(wbs_sel_o[3:0]),.wb_dat_o(wbs_dat_o[31:0]),.wb_cti_o(wbs_cti_o[2:0]),.wb_bte_o(wbs_bte_o[1:0]),.clmode(clmode),
.wb_ack_i(wbs_ack_i[0]),.wb_err_i(wbs_err_i[0]),.wb_rty_i(wbs_rty_i[0]));
`endif

`ifdef UART_IMPL_PER
uart_top  uart_snd(
  .wb_clk_i(clk_int), .wb_rst_i(rst), .wb_adr_i(wbs_adr_o[63:32]), .wb_dat_i(wbs_dat_o[63:32]),
  .wb_dat_o(wbs_dat_i[63:32]), 
  .wb_we_i(wbs_we_o[1]), 
  .wb_stb_i(wbs_stb_o[1]), 
  .wb_cyc_i(wbs_cyc_o[1]), 
  .wb_ack_o(wbs_ack_i[1]),  
  .wb_err_o(wbs_err_i[1]),
  .wb_rty_o(wbs_rty_i[1]),  
  .wb_sel_i(wbs_sel_o[7:4]),
  .int_o(int_o),
  .received(received),
  .stx_pad_o(stx_pad_o), 
  .srx_pad_i(srx_pad_i),
  .rts_pad_o(rts_pad_o), 
  .cts_pad_i(cts_pad_i), 
  .dtr_pad_o(dtr_pad_o), 
  .dsr_pad_i(dsr_pad_i), 
  .ri_pad_i(ri_pad_i), 
  .dcd_pad_i(dcd_pad_i)
`ifdef UART_HAS_BAUDRATE_OUTPUT
  , baud1_o
`endif);
`endif


`ifdef SW_LED_IMPL
SW_LED swl(
.sw1_i(sw1_i),.sw2_i(sw2_i),.sw3_i(sw3_i),.led1_o(led1_o),.led2_o(led2_o),.led3_o(led3_o),
.wb_dat_i(wbs_dat_o[127:96]),.wb_adr_i(wbs_adr_o[127:96]),.wb_sel_i(wbs_sel_o[15:12]),.wb_cti_i(wbs_cti_o[11:9]),.wb_bte_i(wbs_bte_o[7:6]),
.wb_dat_o(wbs_dat_i[127:96]),
.wb_ack_o(wbs_ack_i[3]),.wb_err_o(wbs_err_i[3]),.wb_rty_o(wbs_rty_i[3]),.wb_stb_i(wbs_stb_o[3]),.wb_cyc_i(wbs_cyc_o[3]),.wb_we_i(wbs_we_o[3]),
.wb_rst_i(rst),.wb_clk_i(clk_int),.irq_o(irq),.irq_ack(irq_ack));
`endif

intercon #(`DW,`AW,`NUM_MASTER,`NUM_SLAVES) incon1(.i_clk(clk_int), .i_rst(rst), .roundORpriority(1'b0),

.wbm_adr_i(wb_adr_o), .wbm_dat_i(wb_dat_o), .wbm_we_i(wb_we_o), .wbm_stb_i(wb_stb_o), .wbm_sel_i(wb_sel_o), .wbm_cyc_i(wb_cyc_o),
.wbm_cti_i(wb_cti_o), .wbm_bte_i(wb_bte_o),
.wbm_ack_o(wb_ack_i), .wbm_rty_o(wb_rty_i), .wbm_err_o(wb_err_i), .wbm_dat_o(wb_dat_i),

.wbs_adr_o(wbs_adr_o), .wbs_dat_o(wbs_dat_o), .wbs_we_o(wbs_we_o), .wbs_stb_o(wbs_stb_o), .wbs_sel_o(wbs_sel_o), .wbs_cyc_o(wbs_cyc_o),
.wbs_cti_o(wbs_cti_o), .wbs_bte_o(wbs_bte_o),
.wbs_ack_i(wbs_ack_i), .wbs_rty_i(wbs_rty_i), .wbs_err_i(wbs_err_i), .wbs_dat_i(wbs_dat_i));


cpu cpu1(.clk(clk_int),.clk_x2(clk_x2),.rst(rst),.led(lcd_reg),
        .wb_ack_i(wb_ack_i), .wb_err_i(wb_err_i), .wb_rty_i(wb_rty_i),
        .wb_dat_i(wb_dat_i),.wb_cyc_o(wb_cyc_o), .wb_adr_o(wb_adr_o), .wb_stb_o(wb_stb_o),
        .wb_we_o(wb_we_o), .wb_sel_o(wb_sel_o), .wb_dat_o(wb_dat_o),.wb_cti_o(wb_cti_o),
        .wb_bte_o(wb_bte_o),.cache_flush(cache_flush_int),.cache_en(cache_en_int),.tick_en(tick_en),
        .addr_exception(addr_exception),.interrupt(interrupt)
    `ifdef TEST
    ,.block_instr_int(blck_instr_int)
    `endif
    `ifdef itlb_def
    ,.vpn_to_ppn_req(vpn_to_ppn_req)
    `endif  
    );     

`ifdef Demo_En 

PWM pwm1(
 //wishbone slave interface
 .i_wb_clk(clk_int),.i_wb_rst(rst),.i_wb_cyc(wbs_cyc_o[2]),.i_wb_stb(wbs_stb_o[2]),
 .i_wb_we(wbs_we_o[2]),.i_wb_adr(wbs_adr_o[95:64]),.i_wb_data(wbs_dat_o[95:64]),
 .o_wb_data(wbs_dat_i[95:64]),.o_wb_ack(wbs_ack_i[2]),.o_pwm(pwm_o)
 ,.adc_reg(adc_reg),.temp_set_reg(temp_set_reg),.lcd_reg(),.o_buzzer(buzzer_o),.led(led)

 );

 XADC_INST_des  X1 
 (             
 .dclk_in(clk_int),    
 .reset_in(rst),   
 .adc_reg(adc_reg),    
 .vp_in(vp_in),      
 .vn_in(vn_in)     
 );   
    
 LCD LCD_inst
 (
 .clk (clk_int),
 .rst (rst),
 .en  (lcd_en_o), 
 .rs  (lcd_rs_o), 
 .rw  (lcd_rw_o),
 .data(lcd_data_o),
 .data_in(lcd_reg)
  );

vio_0 VIO( .clk(clk_int),.probe_out0(rst_VIO));
  
 `endif
    
endmodule
