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
module icache(
clk,clk_x2, rst_n, freeze, freeze_in,stall_load, wr_data, we, re, hit_out,
i_addr, stall,
re_int, instr, vpn_to_ppn_req,vpn_to_ppn_req3,vpn_to_ppn_req7,eret_ack,freeze_hit_status,
virtual_addr,state_fsm,physical_tag
`ifdef itlb_def 
,tag_o_tlb, freeze_tlb_out, tag_hit,
 wb_ack_i, wb_err_i, wb_rty_i, wb_dat_i, wb_cyc_o, wb_stb_o, 
 wb_we_o, wb_adr_o, wb_bte_o, wb_cti_o, wb_sel_o,wb_dat_o
`endif
);

parameter offset_start_bit = 0;
parameter offset_last_bit = 4;
parameter index_start_bit = 5;
parameter index_last_bit = 11;
parameter tag_start_bit = 12;
parameter tag_last_bit = 31;
parameter tag_tlb_start_bit = 4;
parameter tag_tlb_last_bit = 23;
parameter tag_phy_start_bit = 0;
parameter tag_phy_last_bit = 19;
parameter tag_width=22;

integer temp;//,tempp;
integer j;

localparam state_we0 = 2'b01;
localparam state_we1 = 2'b10;

//----------------I/O declaration------------
input clk,clk_x2,rst_n,freeze,freeze_in;
input [255:0] wr_data;	
input we;	
input re;	
//input [31:0] addr_int;
input [31:0] i_addr;
input [31:0] virtual_addr;
input [1:0] state_fsm;
input stall;
input stall_load;
//input[31:0] i_addr_cache_my;
//input[4:0] i_addr_cache_my_full;
input re_int;
input vpn_to_ppn_req;
input vpn_to_ppn_req3;
input vpn_to_ppn_req7;
input eret_ack;
input freeze_hit_status;

output hit_out;
//output reg[255:0] rd_data;	
output reg[31:0] instr;
output reg [tag_phy_last_bit : tag_phy_start_bit] physical_tag;

//---------------------------------------------

//----------------ITLB Declarations------------
`ifdef itlb_def
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

output  [tag_phy_last_bit:tag_phy_start_bit] tag_o_tlb;
output  tag_hit;
output freeze_tlb_out;

//reg vpn_to_ppn_req;
wire [(tag_width-1+4):0] tag_out_tlb;
wire [tag_phy_last_bit : tag_phy_start_bit] tag;
wire vpn_to_ppn_req5;
reg vpn_to_ppn_req6;
reg hit_int_ejet;
reg hit;

`else
reg [tag_phy_last_bit : tag_phy_start_bit] tag;
`endif
//----------------------------------------

//--------Reg & Wire Definitions----------
wire wdirty;
wire [31:0] i_addr_min4;
wire [255:0] x,y;
reg lru_bit[0:127];
reg enable_set1;
reg flag;
reg we0,we1;
reg enable_tag0;
reg enable_tag1;
reg we_tag0,we_tag1;
reg enable_set0;
reg [1:0] state_we;
reg[1:0] nextstate_we;
reg[2:0] sel_inst;
wire [tag_phy_last_bit : tag_phy_start_bit] tag_w;
wire [(tag_last_bit - tag_start_bit):0] dout1,dout2;
wire freeze_icache_miss;
//---------------------------------------

//---------------ITLB Logic-------------------------
`ifdef itlb_def
assign tag_o_tlb = tag_out_tlb[tag_tlb_last_bit:tag_tlb_start_bit];
assign freeze_icache_miss = (state_fsm == 2'b01);
`endif
//--------------------------------------------------

assign hit_out = hit || ((vpn_to_ppn_req7 || eret_ack ) && freeze_hit_status) || hit_int_ejet;
assign wdirty = 1;
assign i_addr_min4 = i_addr - 32'd4;

always @(posedge clk )
    begin
    if(rst_n) 
        begin
         state_we <= #2 state_we0;
        end    
    else if(freeze==0 )//|| ~(freeze && rdy))
        begin
         state_we <= #2 nextstate_we;
        end
    end

always @(posedge clk )
    begin
    if(rst_n) 
            sel_inst <=3'b0;
    else
            sel_inst <= (vpn_to_ppn_req3 || vpn_to_ppn_req5|| ( vpn_to_ppn_req7 && ~freeze_hit_status )) ? virtual_addr[4:2] : ( stall_load ? i_addr_min4[4:2] :i_addr[4:2]) ;
    end
always @(posedge clk )
    begin
    if(rst_n) begin
            vpn_to_ppn_req6 <= 1'b0;
            hit_int_ejet <= 1'b0;
        end
    else begin
            vpn_to_ppn_req6 <= vpn_to_ppn_req5;
            hit_int_ejet <= eret_ack;
        end
    end

always @(posedge clk )
    begin
    if(rst_n) 
            physical_tag <=20'b0;
    else if( tag_hit && ~hit && (state_fsm != 2'b01))
            physical_tag <= tag_w;
    end

always @(*)
    begin
    if (rst_n)
        begin
        enable_set0<=0;
        enable_set1<=0;
        enable_tag0<=0;
        enable_tag1<=0;
        nextstate_we<=state_we0;
        hit<=0;
        we0<=1'b0;
        we1<=0;
        we_tag0<=0;
        we_tag1<=0;
        end
    else //if(freeze==0)
        begin
        enable_set1<=1;
        enable_tag1<=1;
        enable_set0<=1;
        enable_tag0<=1;
        case(state_we)               
            state_we0:
            begin 
              if(we)
                begin
                    hit<=1'b0;
                    we0<=1'b0;
                    we1<=0;
                    we_tag0<=0;
                    we_tag1<=0;
                    nextstate_we<=state_we1;
                end
                else  if(re)
                begin
                    we0<=1'b0;
                    we1<=0;
                    we_tag0<=0;
                    we_tag1<=0;
                    nextstate_we<=state_we0;
                    hit<= (tag_hit ? ((tag==dout2[(tag_last_bit - tag_start_bit):0])||(tag ==dout1[(tag_last_bit - tag_start_bit):0])) : 0) ;

                end
                else
                begin
                    hit<=1'b0;
                    we0<=1'b0;
                    we1<=0;
                    we_tag0<=0;
                    we_tag1<=0;
                    nextstate_we<=state_we0;
                end
            end
            state_we1:
            begin
//                tempp<= vpn_to_ppn_req3 ? virtual_addr[index_last_bit:index_start_bit]: i_addr[index_last_bit:index_start_bit];
                if(~lru_bit[temp])//(dout2[24:0] != addr[29:5]) //&&  (lru_bit[addr[4:0]]==1'b0))//tag not match
                begin
                    hit<=1'b0;
                    we1<=0;
                    we_tag1<=0;
                    we0<=1'b1;
                    we_tag0<=1;
                end
                else
                begin
                    hit<=0;
                    we1<=1;
                    we_tag1<=1;
                    we0<=1'b0;
                    we_tag0<=0;
                end
                nextstate_we<=state_we0;
            end
            default:
            begin
                we1<=0;
                we_tag1<=0;
                we0<=0;
                we_tag0<=0;
                hit<=0;
                nextstate_we<=state_we0;             
            end
        endcase
        end
    end

always@( posedge(clk) )
    begin
    if(rst_n)
        begin
        for(j=0;j<128;j=j+1)
        lru_bit[j]<=0;
        end
    else //if(freeze==0)
        begin
        temp<= vpn_to_ppn_req3 ? virtual_addr[index_last_bit:index_start_bit]: i_addr[index_last_bit:index_start_bit];
        if(state_we==state_we0 && re)
            begin
                if(hit) begin
                    if(tag==dout1[(tag_last_bit-tag_start_bit):0])
                        lru_bit[temp]<=1'b1;
                    else if(tag==dout2[(tag_last_bit-tag_start_bit):0])
                        lru_bit[temp]<=1'b0;
                    end
            end
        end
    end

`ifdef itlb_def
    assign tag = tag_out_tlb[tag_tlb_last_bit : tag_tlb_start_bit];
    assign tag_w = tag_out_tlb[tag_tlb_last_bit : tag_tlb_start_bit];
`else
always @(posedge clk )
    begin
    if(rst_n) 
            tag <=20'b0;
    else
            tag <= vpn_to_ppn_req3 ? virtual_addr[tag_last_bit:tag_start_bit] : i_addr[tag_last_bit:tag_start_bit] ;
    end
    assign tag_w = virtual_addr[tag_last_bit:tag_start_bit] ;
`endif

always@(*)//posedge clk or posedge rst_n)
    begin
    if(rst_n)
        begin
        instr<=0;
        end
    else begin
    if(hit) //&& ~(i_addr == virtual_addr))
            begin
            if (tag == dout2[(tag_last_bit-tag_start_bit):0]) 
                begin
                case(sel_inst)
                    3'b000: instr <= y[31:0];
                    3'b001: instr <= y[63:32];
                    3'b010: instr <= y[95:64];
                    3'b011: instr <= y[127:96];
                    3'b100: instr <= y[159:128];
                    3'b101: instr <= y[191:160];
                    3'b110: instr <= y[223:192];
                    3'b111: instr <= y[255:224];
                    default: instr <=0;
                endcase;
                end
            else
                begin
                case(sel_inst)
                    3'b000: instr <= x[31:0];
                    3'b001: instr <= x[63:32];
                    3'b010: instr <= x[95:64];
                    3'b011: instr <= x[127:96];
                    3'b100: instr <= x[159:128];
                    3'b101: instr <= x[191:160];
                    3'b110: instr <= x[223:192];
                    3'b111: instr <= x[255:224];
                    default: instr <=0;
                endcase;
                end
            end
        else 
            instr <= 32'b0;   
        end 
    end


//---------------Module instantiation------------------------------
//-----------------ITLB--------------------------------------------
`ifdef itlb_def
itlb itlb(
.clk(clk),
.clk_x2(clk_x2),
.rst(rst_n),
.vpn_to_ppn_req(vpn_to_ppn_req || vpn_to_ppn_req6 || vpn_to_ppn_req7),
.vpn((vpn_to_ppn_req3 || (vpn_to_ppn_req7 && ~freeze_hit_status )) ? virtual_addr[tag_last_bit:tag_start_bit]: ( stall_load ? i_addr_min4[tag_last_bit:tag_start_bit]: i_addr[tag_last_bit:tag_start_bit])), 
.freeze_tlb(freeze_in || freeze_icache_miss),
.tag_out(tag_out_tlb),
.freeze(freeze_tlb_out),
.tag_hit(tag_hit),
.vpn_to_ppn_req5(vpn_to_ppn_req5),
.wb_ack_i(wb_ack_i),.wb_err_i(wb_err_i),.wb_rty_i(wb_rty_i),.wb_dat_i(wb_dat_i),.wb_cyc_o(wb_cyc_o),
.wb_stb_o(wb_stb_o),.wb_we_o(wb_we_o),.wb_adr_o(wb_adr_o),.wb_bte_o(wb_bte_o),.wb_cti_o(wb_cti_o),
.wb_sel_o(wb_sel_o),.wb_dat_o(wb_dat_o)         );
`endif

///////////////////////////////////////////////////////////////
//// If tag bits match and line is valid then we have a hit //
/////////////////////////////////////////////////////////////

blk_mem_gen_v7_3 set0 (
  .clka(clk), // input clka
  .rsta(rst_n), // input rsta
  .ena(enable_set0 ), // input ena
  .wea(we0), // input [0 : 0] wea
  .addra((vpn_to_ppn_req3 || vpn_to_ppn_req5 || we0 || ( vpn_to_ppn_req7 && ~freeze_hit_status )) ? virtual_addr[index_last_bit:index_start_bit]: ( stall_load ? i_addr_min4[index_last_bit:index_start_bit] : i_addr[index_last_bit:index_start_bit] )), // input [4 : 0] addra
  .dina( wr_data), // input [127 : 0] dina
  .douta(x) // output [127 : 0] douta
);

blk_mem_gen_v7_3 set1 (
  .clka(clk), // input clka
  .rsta(rst_n), // input rsta
  .ena(enable_set1 ), // input ena
  .wea(we1), // input [0 : 0] wea
  .addra((vpn_to_ppn_req3 || vpn_to_ppn_req5 || we1 || ( vpn_to_ppn_req7 && ~freeze_hit_status )) ? virtual_addr[index_last_bit:index_start_bit]: ( stall_load ? i_addr_min4[index_last_bit:index_start_bit] : i_addr[index_last_bit:index_start_bit] )), // input [4 : 0] addra
  .dina(wr_data), // input [255 : 0] dina
  .douta(y) // output [255: 0] douta
);


blk_mem_gen_v7_3_2 tag0_v_dirty (
  .clka(clk), // input clka
  .rsta(rst_n), // input rsta
  .ena(enable_tag0 ), // input ena
  .wea(we_tag0), // input [0 : 0] wea
  .addra((vpn_to_ppn_req3 || vpn_to_ppn_req5 || we_tag0 || ( vpn_to_ppn_req7 && ~freeze_hit_status )) ? virtual_addr[index_last_bit:index_start_bit]: ( stall_load ? i_addr_min4[index_last_bit:index_start_bit] : i_addr[index_last_bit:index_start_bit] )), // input [4 : 0] addra
  .dina(physical_tag), // input [18 : 0] dina
  .douta(dout1) // output [18 : 0] douta
);

blk_mem_gen_v7_3_2 tag1_v_dirty (
  .clka(clk), // input clka
  .rsta(rst_n), // input rsta
  .ena(enable_tag1), // input ena
  .wea(we_tag1), // input [0 : 0] wea
  .addra((vpn_to_ppn_req3 || vpn_to_ppn_req5 || we_tag1 || ( vpn_to_ppn_req7 && ~freeze_hit_status )) ? virtual_addr[index_last_bit:index_start_bit]: ( stall_load ? i_addr_min4[index_last_bit:index_start_bit] : i_addr[index_last_bit:index_start_bit] )), // input [4 : 0] addra
  .dina(physical_tag), // input [24 : 0] dina
  .douta(dout2) // output [24 : 0] douta
);

endmodule
