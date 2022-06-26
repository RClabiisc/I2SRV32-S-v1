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
/////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2017 12:47:44
// Design Name: 
// Module Name: tlb
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
/////////////////////////////////////////////////////////////////

//////////Guidelines////////////////////////


module itlb
(
clk,
clk_x2,
rst,
vpn_to_ppn_req,
vpn,
freeze_tlb,
tag_out,freeze,
tag_hit, vpn_to_ppn_req5,
wb_ack_i,wb_err_i,wb_rty_i,wb_dat_i,wb_cyc_o,
wb_stb_o,wb_we_o,wb_adr_o,wb_bte_o,wb_cti_o,wb_sel_o,wb_dat_o
);

//change the following according to the design//////
`define VPN_MASK 'hFFFFF000

parameter tag_width=22;
parameter virtual_width=32;
parameter vpn_width=20;
parameter offset=12;

parameter dw = 32;
parameter aw = 32;
parameter bl = 8;


input clk, rst,clk_x2;
input [vpn_width-1:0] vpn; //virtual page number
input vpn_to_ppn_req;
input freeze_tlb;

output [(tag_width-1+4):0] tag_out; //Tag nothing but PPN
output reg freeze;
//output stall_out;
output tag_hit;
output vpn_to_ppn_req5;

//------------ Wishbone Signals -------------- 

//input				wb_clk_i;	// clock input
//input				wb_rst_i;	// reset input
input				wb_ack_i;	// normal termination
input				wb_err_i;	// termination w/ error
input				wb_rty_i;	// termination w/ retry
input  [31:0]       wb_dat_i;
output				wb_cyc_o;
output              wb_stb_o;	// strobe output
output              wb_we_o;	// indicates write transfer
output [31:0] 		wb_adr_o;	
output [1:0]        wb_bte_o;
output [2:0] 		wb_cti_o;
output [3:0]        wb_sel_o;	// byte select outputs for the signals-byte select and extend
output [31:0]       wb_dat_o;	// output data bus

//--------Wire Definitions----------------------
wire [51:0] write_data;
wire [4:0] write_addr;
wire we;
wire miss;
wire [25:0] output_data;

wire full;
wire empty;
wire wr_en;
wire rd_en;
wire [4:0] din;
wire [4:0] dout;
wire wb_ack;
wire valid_data;
wire [4:0] access_addr;
//wire [4:0] lru_reg_int;
wire [4:0] eva_reg_int;
wire [vpn_width-1:0] vpn;
reg [vpn_width-1:0] vpn_int;


//--------Reg definitions-----------------------
reg 					wb_cyc_o;	// cycle output
reg 					wb_stb_o;	// strobe output
reg 					wb_we_o;	// indicates write transfer
reg [aw-1:0] 			wb_adr_o;	// address bus outputs
reg [1:0]               wb_bte_o;
reg [3:0] 				wb_sel_o;	// byte select outputs
reg [2:0] 				wb_cti_o;	// cycle type identifier

reg  compare;
reg  read_cam;
reg [31:0] data_in;
//reg [4:0] lru_reg;
reg [4:0] eva_reg;
reg [1:0] state;
reg [1:0] next_state;
reg access;

parameter idle = 2'b00;
parameter send_entry_req = 2'b01;
//parameter wait_for_data = 2;
parameter replace = 2'b10;
parameter output_state = 2'b11;

assign tag_out = output_data;
assign tag_hit = valid_data;
assign we = wb_ack_i & wb_stb_o;
assign write_data = { {vpn_int}, {data_in} };
//assign write_addr = lru_reg;
assign write_addr = eva_reg;
//assign vpn = (virtual_addr & `VPN_MASK) >> offset;
assign vpn_to_ppn_req5 = read_cam;
assign wb_dat_o = 32'b0;

always @(posedge clk)
begin
        if(rst) begin
//            re <= 1'b0;
            vpn_int <= 20'b0;
        end
        else if(vpn_to_ppn_req & (state == idle) & (~miss)) begin
//            re <= 1'b1;
            vpn_int <= vpn;
        end
//        else re <= 1'b0;
end

always @(posedge clk)
begin
        if(rst)  access <= 1'b0;
        else if(~miss) access <= 1'b1;
        else access <= 1'b0;
end


always @(posedge clk)
begin
    if(rst) begin 
        state <= idle;
//        lru_reg = 5'b0;
        eva_reg = 5'b0;
    end
    else if (~(freeze_tlb)) begin  
        state <= next_state;
//        lru_reg = lru_reg_int;
        eva_reg = eva_reg_int;
    end
end

always @(*)
begin
    case (state)
        idle:   begin
                wb_cyc_o	=  1'b0;
                wb_stb_o    =  1'b0;
                wb_cti_o    =  3'b111;  
                wb_bte_o    =  2'b00;   
                wb_we_o     =  1'b0;
                wb_sel_o    =  4'hf;
                wb_adr_o    =  {aw{1'b0}};
                data_in     =  32'b0;
                read_cam    = 1'b0;
                compare     = 1'b0;
                    if(miss) begin
                        freeze  = 1'b1;
                        next_state = send_entry_req;
                    end
                    else  begin       
                        next_state = idle;
                        freeze  = 1'b0;
                    end
                end
                
        send_entry_req:   begin
                wb_cyc_o	=  1'b1;
                wb_stb_o    =  1'b1;
                wb_cti_o    =  3'b111;  
                wb_bte_o    =  2'b00;   
                wb_we_o     =  1'b0;
                wb_sel_o    =  4'hf;
                wb_adr_o    =  {10'b0,vpn_int,2'b0};
                freeze  = 1'b1;
                read_cam    = 1'b0;
                compare     = 1'b1;
                data_in     = wb_dat_i;
                    if(wb_ack) 
                        next_state  = replace;                   
                    else 
                        next_state  = send_entry_req;
                end
                   
        replace:   begin
                wb_cyc_o	=  1'b0;
                wb_stb_o    =  1'b0;
                wb_cti_o    =  3'b111;  
                wb_bte_o    =  2'b00;   
                wb_we_o     =  1'b0;
                wb_sel_o    =  4'hf;
                wb_adr_o    =  {aw{1'b0}};
                freeze  = 1'b1;
                read_cam    = 1'b0;
                compare     = 1'b0;
                next_state  = output_state;
                data_in     = wb_dat_i;
                end
                
        output_state: begin
                wb_cyc_o	=  1'b0;
                wb_stb_o    =  1'b0;
                wb_cti_o    =  3'b111;  
                wb_bte_o    =  2'b00;   
                wb_we_o     =  1'b0;
                wb_sel_o    =  4'hf;
                wb_adr_o    =  {aw{1'b0}};
                freeze  = 1'b1;
                compare     = 1'b0;
                read_cam    = 1'b1;
                next_state  = idle;  
                data_in     =  32'b0;
                         
                end       
                
        default:begin
                wb_cyc_o	=  1'b0;
                wb_stb_o    =  1'b0;
                wb_cti_o    =  3'b111;  
                wb_bte_o    =  2'b00;   
                wb_we_o     =  1'b0;
                wb_sel_o    =  4'hf;
                wb_adr_o    =  {aw{1'b0}};
                data_in     =  32'b0;
                freeze  = 1'b0;
                compare     = 1'b0;
                read_cam    = 1'b0;

                end
        endcase

end


assign wb_ack = wb_ack_i & !wb_err_i & !wb_rty_i; 

////////////////////////******** code by piyush ********////////////////////////

    reg compare_delayed;
    wire EVA_en;
    reg re;
    
    always @(posedge clk)
    begin
        compare_delayed = compare;
        re = (~(freeze_tlb)) & (vpn_to_ppn_req | read_cam);
        end

    assign EVA_en = compare & ( !(compare_delayed));

////////////////////////******** addition code by piyush ********////////////////////////


iregisters cam( .clk(clk), .rst(rst),
    .we(we), .re((~(freeze_tlb)) &  ((vpn_to_ppn_req && ~freeze )| read_cam)),  
    .write_addr(write_addr), 
    .write_data(write_data), 
    .vpn(read_cam? vpn_int : vpn), 
    .miss(miss), 
    .valid_data(valid_data),
    .output_data(output_data) , 
    .access_addr(access_addr)
    );
    
//ilru tlru( .clk(clk), .rst(rst),
//    .access((~(freeze_tlb)) & access),
//    .addr_access(access_addr),
//    .compare(compare),
//    .lru_addr(lru_reg_int)
    
//        );
    

    replacement_algo i_replacement_algo(.clk(clk), .clk_x2(clk_x2), .rst(rst), .re(re), .we(we), .hit(valid_data), .miss(miss), .access_addr(access_addr),
                                        .EVA_en(EVA_en), .EVA_addr(eva_reg_int)
                                        );

    endmodule