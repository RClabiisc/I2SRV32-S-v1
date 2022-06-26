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
clk,rst_n,freeze,freeze_in,wr_data,we,re,rd_data,hit,state_we,dout1,
dout2,x,y,we0,we1,lru_bit_temp,temp1,addr_int,i_addr,stall,
re_int,i_addr_cache_my,instr,i_addr_cache_my_full,rdy,irq_ctrl
`ifdef itlb_def ,tag_o_tlb,freeze_tlb_out,tag_hit
,wb_ack_i,wb_err_i,wb_rty_i,wb_dat_i,wb_cyc_o,
wb_stb_o,wb_we_o,wb_adr_o,wb_bte_o,wb_cti_o,wb_sel_o,wb_dat_o
`endif
);

parameter offset_start_bit = 0;
parameter offset_last_bit = 4;
parameter index_start_bit = 5;
parameter index_last_bit = 11;
parameter tag_start_bit = 12;
parameter tag_last_bit = 31;

integer temp,tempp;
integer j;

localparam state_we0 = 2'b01;
localparam state_we1 = 2'b10;

//----------------I/O declaration------------
input clk,rst_n,freeze,rdy,freeze_in;
input irq_ctrl;
input [255:0] wr_data;	
input we;	
input re;	
input [31:0] addr_int;
input [31:0] i_addr;
input stall;
input[31:0] i_addr_cache_my;
input[4:0] i_addr_cache_my_full;
input re_int;

output reg hit;
output reg[255:0] rd_data;	
output reg [1:0] state_we;
output[(tag_last_bit - tag_start_bit):0] dout1,dout2;
output reg[6:0] temp1;
output[255:0] x,y;
output reg[31:0] instr;
output reg we0,we1;
output reg lru_bit_temp;
//---------------------------------------------

//----------------ITLB Declarations------------
`ifdef itlb_def

parameter tag_tlb_start_bit = 4;
parameter tag_tlb_last_bit = 23;
parameter tag_phy_start_bit = 0;
parameter tag_phy_last_bit = 19;
parameter tag_width=22;

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
output [2:0]        wb_bte_o;
output [2:0] 		wb_cti_o;
output [3:0]        wb_sel_o;	// byte select outputs for the signals-byte select and extend
output [31:0]       wb_dat_o;	// output data bus

output  [tag_phy_last_bit:tag_phy_start_bit] tag_o_tlb;
output  tag_hit;
output freeze_tlb_out;

reg vpn_to_ppn_req;
wire [(tag_width-1+4):0] tag_out_tlb;

`endif
//----------------------------------------

//--------Reg & Wire Definitions----------
wire wdirty;
reg lru_bit[0:128];
reg enable_set1;
reg flag;
reg enable_tag0;
reg enable_tag1;
reg we_tag0,we_tag1;
reg enable_set0;
reg[1:0] nextstate_we;
//---------------------------------------

//---------------ITLB Logic-------------------------
`ifdef itlb_def
assign tag_o_tlb = tag_out_tlb[tag_tlb_last_bit:tag_tlb_start_bit];
`endif
//--------------------------------------------------

assign wdirty=1;

always @(posedge clk,posedge rst_n)
begin
if(rst_n) 
begin
#2 state_we<=state_we0;
end

else if(freeze==0 )//|| ~(freeze && rdy))
begin
#2 state_we<=nextstate_we;
end
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

    case(state_we)               
            state_we0:
            begin 
              if(we)
                begin
                    enable_set1<=1;
                    enable_tag1<=1;
                    enable_set0<=1;
                    enable_tag0<=1;
                    hit<=1'b0;
                    we0<=1'b0;
                    we1<=0;
                    we_tag0<=0;
                    we_tag1<=0;
                    nextstate_we<=state_we1;
                end
                else  if(re)
                begin
                    enable_tag0<=1;
                    enable_tag1<=1;
                    enable_set0<=1;
                    enable_set1<=1;
                    we0<=1'b0;
                    we1<=0;
                    we_tag0<=0;
                    we_tag1<=0;
                    nextstate_we<=state_we0;
                    `ifdef itlb_def
                    hit<= tag_hit ? ((tag_out_tlb[tag_tlb_last_bit:tag_tlb_start_bit]==dout2[(tag_last_bit - tag_start_bit):0])||(tag_out_tlb[tag_tlb_last_bit:tag_tlb_start_bit]==dout1[(tag_last_bit - tag_start_bit):0])) : 0;
                    `else
//                    hit<= ((addr_int[tag_last_bit:tag_start_bit]==dout2[(tag_last_bit - tag_start_bit):0])||(addr_int[tag_last_bit:tag_start_bit]==dout1[(tag_last_bit - tag_start_bit):0])) ;
                    hit<=((addr_int[tag_last_bit:tag_start_bit]==dout2[(tag_last_bit - tag_start_bit):0])||(addr_int[tag_last_bit:tag_start_bit]==dout1[(tag_last_bit - tag_start_bit):0]));
                    `endif
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
              enable_set1<=1;
                enable_tag1<=1;
                enable_set0<=1;
                enable_tag0<=1; 
                tempp<= addr_int[6:0];
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
              enable_set1<=1;
                enable_tag1<=1;
                enable_set0<=1;
                enable_tag0<=1; 
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



always@(posedge(clk))
begin
    if(rst_n)
    begin
    for(j=0;j<255;j=j+1)
    lru_bit[j]<=0;
    end
    else //if(freeze==0)
    begin
        temp<=addr_int[6:0];
        lru_bit_temp<=lru_bit[temp];
        temp1<=addr_int[6:0];
        if(state_we==state_we0 && re)
        begin
            `ifdef itlb_def
                if(hit) begin
                    if(tag_out_tlb[tag_tlb_last_bit:tag_tlb_start_bit]==dout1[(tag_last_bit-tag_start_bit):0])
                        lru_bit[temp]<=1'b1;
                    else if(tag_out_tlb[tag_tlb_last_bit:tag_tlb_start_bit]==dout2[(tag_last_bit-tag_start_bit):0])
                        lru_bit[temp]<=1'b0;
                    end
                else begin
                    if(addr_int[tag_last_bit:tag_start_bit]==dout1[(tag_last_bit-tag_start_bit):0])
                    lru_bit[temp]<=1'b1;
                else if(addr_int[tag_last_bit:tag_start_bit]==dout2[(tag_last_bit-tag_start_bit):0])
                    lru_bit[temp]<=1'b0;
                end
            `else
                if(addr_int[tag_last_bit:tag_start_bit]==dout1[(tag_last_bit-tag_start_bit):0])
                    lru_bit[temp]<=1'b1;
                else if(addr_int[tag_last_bit:tag_start_bit]==dout2[(tag_last_bit-tag_start_bit):0])
                    lru_bit[temp]<=1'b0;
            `endif
        end
    end

end

`ifdef itlb_def
always@(*)//posedge clk or posedge rst_n)
begin
if(rst_n)
    begin
    rd_data<=0;
    instr<=0;
    end
else
    begin
#2        if (hit ? (tag_out_tlb[tag_tlb_last_bit:tag_tlb_start_bit]==dout2[(tag_last_bit-tag_start_bit):0]) : (addr_int[tag_last_bit:tag_start_bit]==dout2[(tag_last_bit-tag_start_bit):0])) 
            begin
            rd_data<=y;
            case(addr_int[4:2])
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
        else if(addr_int[tag_last_bit:tag_start_bit]==dout1[(tag_last_bit-tag_start_bit):0]) 
            begin
            rd_data<=x;
            case(addr_int[4:2])
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
end
`else
always@(*)//posedge clk or posedge rst_n)
begin
if(rst_n)
    begin
    rd_data<=0;
    instr<=0;
    end
else
    begin
#2        if (addr_int[tag_last_bit:tag_start_bit]==dout2[(tag_last_bit-tag_start_bit):0]) 
            begin
            rd_data<=y;
            case(addr_int[4:2])
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
        else if(addr_int[tag_last_bit:tag_start_bit]==dout1[(tag_last_bit-tag_start_bit):0]) 
            begin
            rd_data<=x;
            case(addr_int[4:2])
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
end
`endif

`ifdef itlb_def
itlb itlb
(
.clk(clk),
.rst(rst_n),
.vpn_to_ppn_req((enable_set0 | enable_set1) & ~freeze),
.vpn(i_addr[tag_last_bit:tag_start_bit]),
.freeze_tlb(freeze_in),
.tag_out(tag_out_tlb),
.freeze(freeze_tlb_out),
.tag_hit(tag_hit),
.wb_ack_i(wb_ack_i),.wb_err_i(wb_err_i),.wb_rty_i(wb_rty_i),.wb_dat_i(wb_dat_i),.wb_cyc_o(wb_cyc_o),
.wb_stb_o(wb_stb_o),.wb_we_o(wb_we_o),.wb_adr_o(wb_adr_o),.wb_bte_o(wb_bte_o),.wb_cti_o(wb_cti_o),
.wb_sel_o(wb_sel_o),.wb_dat_o(wb_dat_o)
);
`endif


///////////////////////////////////////////////////////////////
//// If tag bits match and line is valid then we have a hit //
/////////////////////////////////////////////////////////////

blk_mem_gen_v7_3 set0 (
  .clka(clk), // input clka
  .rsta(rst_n), // input rsta
  .ena(enable_set0 & ~freeze), // input ena
  .wea(we0), // input [0 : 0] wea
  .addra(hit ? i_addr[index_last_bit:index_start_bit] : addr_int[index_last_bit:index_start_bit]), // input [4 : 0] addra
  .dina( wr_data), // input [127 : 0] dina
  .douta(x) // output [127 : 0] douta
);

blk_mem_gen_v7_3 set1 (
  .clka(clk), // input clka
  .rsta(rst_n), // input rsta
  .ena(enable_set1 & ~freeze), // input ena
  .wea(we1), // input [0 : 0] wea
  .addra(hit ? i_addr[index_last_bit:index_start_bit] : addr_int[index_last_bit:index_start_bit]), // input [7: 0] addra
  .dina(wr_data), // input [255 : 0] dina
  .douta(y) // output [255: 0] douta
);


blk_mem_gen_v7_3_2 tag0_v_dirty (
  .clka(clk), // input clka
  .rsta(rst_n), // input rsta
  .ena(enable_tag0 & ~freeze), // input ena
  .wea(we_tag0), // input [0 : 0] wea
  .addra(hit ? i_addr[index_last_bit:index_start_bit] : addr_int[index_last_bit:index_start_bit]), // input [7 : 0] addra
  .dina(addr_int[tag_last_bit:tag_start_bit]), // input [18 : 0] dina
  .douta(dout1) // output [18 : 0] douta
);

blk_mem_gen_v7_3_2 tag1_v_dirty (
  .clka(clk), // input clka
  .rsta(rst_n), // input rsta
  .ena(enable_tag1 & ~freeze), // input ena
  .wea(we_tag1), // input [0 : 0] wea
  .addra(hit ? i_addr[index_last_bit:index_start_bit] : addr_int[index_last_bit:index_start_bit]), // input [4 : 0] addra
  .dina(addr_int[tag_last_bit:tag_start_bit]), // input [24 : 0] dina
  .douta(dout2) // output [24 : 0] douta
);


endmodule