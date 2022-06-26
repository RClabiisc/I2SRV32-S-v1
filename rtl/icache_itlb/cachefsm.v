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
// Create Date: 15.12.2015 20:04:02
// Design Name: 
// Module Name: cachefsm
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

module cachefsm
(
clk,
rst_n,
freeze,
freeze_in,
i_hit,
m_line_full,
 `ifdef itlb_def
   tag_hit,
 `endif 
i_addr,
i_acc,
read,
i_we,
m_re, 
m_addr,i_data,
rdy,state,biu_cyc_i,biu_stb_i,biu_cab_i ,wb_dat_i,wb_ack_i,addr_latch,i_addr_int,i_addr_cache_my,biu_sel_i
);
 

input clk,freeze, freeze_in, rst_n, i_hit, i_acc, read,wb_ack_i;
input[255:0] m_line_full;
input [31:0] i_addr,i_addr_int,i_addr_cache_my;
`ifdef itlb_def
input tag_hit;
`endif 

reg[31:0] temp1,temp2,temp3,temp4;

output reg i_we, m_re,rdy;
output reg [31:0] m_addr;
output reg [255:0] i_data;
output reg[31:0] wb_dat_i;
output reg biu_cyc_i,biu_stb_i,biu_cab_i;
output reg[31:0] addr_latch;
output reg biu_sel_i;
wire mem_rdy;
/* Variables */
 output reg[1:0] state;
reg[1:0] nextState;
reg[31:0] addr_latch_int;
reg freeze_int;
integer count;
//integer count_int;

/* State Definitions*/
localparam START = 2'b00;//0;
localparam START1 = 2'b10;

localparam SERVICE_MISS = 2'b01;
localparam WAIT4 = 2'b11;

/* Clock state changes and handle reset */
always @(posedge clk,posedge rst_n)
begin
    if(rst_n) 
    begin
        state <= START;
    end 
    else if((freeze==0) )//|| (freeze && (state==START)))
    begin
        //if(i_hit)
        //state<=START;
        //else
        #2 state <= nextState;
    end
end


/* FSM Logic */
always @(*) 
    begin 
    if(rst_n)
        begin
        i_we <= 1'b0;
        m_re <= 1'b0;
        m_addr <= 32'h0;
        i_data <= 0;
        
        nextState <= START;
        
        end
    
    else 
    begin
        case(state)
        START: 
            begin
            m_re<=0;
            i_we<=0;
            m_addr<=0;
            i_data <= 0;
            temp2<=0;
            temp3<=0;
            temp4<=0;
            m_re<=0;
            i_we<=0;           
                `ifdef itlb_def       
                if(tag_hit)
                `else itlb_def       
                if(i_acc)
                `endif
                    begin
                    if(i_hit)
                    nextState<=START;
                    else
                    nextState<= SERVICE_MISS;
                end        
                else 
                    nextState<=START;
                end
            
        START1:
            begin
            m_re<=0;
            i_we<=0;
            m_addr<=0;
            i_data <= 0;
            if(i_acc && (i_hit==0))
                begin
                m_addr <= i_addr[31:0];
                m_re <= 1'b1;
                i_we<=0;
                i_data <= 0;            
                nextState <= SERVICE_MISS;            
                end
            else
                begin 
                m_addr <= 0;
                m_re <= 1'b0;
                i_we<=0;
                i_data<=0;                
                nextState<=START;
                end
            end
            
        SERVICE_MISS: 
            begin
            
            if(mem_rdy) begin 
            
                begin 
                
                m_re<=0;
                i_we<=1;
                m_addr<=0;
                i_data <= 0;
                nextState<= WAIT4;               
                end              
                end 
            //else
            //if(i_acc & i_hit)
            //begin
            //m_addr <= 0;
            //m_re <= 1'b0;
            
            //i_we<=0;
            //i_data <= 0;
            //nextState <=START;
            
            //end
            else if(i_acc & !i_hit)
                begin // Hold the inputs to unified mem
                m_addr <= i_addr[31:0];
                m_re <= 1'b1;
                i_we<=0;
                
                i_data <= 0;
                nextState <= SERVICE_MISS;            
                end
            else           
                begin            
                nextState <= SERVICE_MISS;
                i_we<=0;
                m_re<=0;
                i_data <= 0;
                m_addr<=0;            
                end           
            end
            
            
        WAIT4:
            begin
            m_re<=1'b0;
            m_addr<=0;
            i_we<=1'b1;
            nextState<=START;//WAIT5;            
            i_data<=m_line_full;            
            end
            
       default: 
            begin 
            m_re<=1'b0;
            m_addr<=0;
            i_data<=0;
            i_we<=1'b0;
            nextState<=START;
            
            // Leave everything at their defaults (see top)
            end
        endcase
    end
end
assign mem_rdy=  (count==8)?  1: 0;

always@(posedge clk or posedge rst_n)
begin
if(rst_n)
count<=0;
else
begin
if(state==SERVICE_MISS && ((wb_ack_i==1)) && (freeze==0))
count<=count+1;
else 

if(state==WAIT4)
count<=0;

else
count<=count;
end

end

always@(*)
begin
if(rst_n)
rdy<=0;
else
if(state==START)
//Changed on 08th march 2017
rdy<=i_acc && !(i_hit|freeze_in); 
//rdy<=0;
else
if(state==SERVICE_MISS)
rdy<=1;
else
rdy<=0;
end

//always@(posedge clk)
//begin
//if(freeze==0)
//#2 addr_latch_int<=i_addr;
//end

always@(posedge clk)
#2 freeze_int<=freeze;

always@(posedge clk or posedge rst_n)
begin
    if(rst_n)
        addr_latch<=0;//32'd524;
    else begin
    if((state==START) && (((rdy==0) || (rdy==1 && (i_addr[31:13]!=i_addr_cache_my [31:13]))) && (freeze==0)))// && (i_acc)  && !(i_hit))
        addr_latch <= i_addr; //i_addr;//addr_latch_int; //
        //i_addr;//addr_latch_int;//i_addr;
    end
end

always@(*)
    begin
    if(rst_n)
    begin
        biu_cyc_i <= 0;
        biu_stb_i <= 0;
        biu_cab_i <= 0;
        biu_sel_i<=0;
    end
    else if(state==SERVICE_MISS && count<8)
    begin
        biu_cyc_i <= 1;
        biu_stb_i <= 1;
        biu_cab_i <= 1;
        biu_sel_i<=1;
    end
    else
    begin
        biu_cyc_i <= 0;
        biu_stb_i <= 0;
        biu_cab_i <= 0;
        biu_sel_i<=0;
    end
end

//always@(posedge clk)
// count_int<=count;


endmodule
