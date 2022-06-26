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
clk, rst_n, freeze, freeze_in, i_hit, m_line_full,
`ifdef itlb_def
 tag_hit,
`endif 
i_acc, i_we, i_data,
state, stall, vpn_to_ppn_req_out, vpn_to_ppn_req3, biu_cyc_i, biu_stb_i, biu_cab_i,
wb_ack_i, biu_sel_i   );
 
input clk,freeze, freeze_in, rst_n, i_hit, i_acc, wb_ack_i;
input[255:0] m_line_full;
output reg i_we;
output reg [255:0] i_data;
output reg biu_cyc_i,biu_stb_i,biu_cab_i;
//output reg[31:0] addr_latch;
output reg [3:0]biu_sel_i;
output reg[1:0] state;
output reg stall;
output vpn_to_ppn_req_out;
output reg vpn_to_ppn_req3;
reg vpn_to_ppn_req4;

`ifdef itlb_def
input tag_hit;
`endif 

wire mem_rdy;
reg[1:0] nextState;
reg [31:0] temp1,temp2,temp3,temp4;

integer count;
/* State Definitions*/
localparam START = 2'b00;//0;
localparam WAIT4read = 2'b10;
localparam SERVICE_MISS = 2'b01;
localparam WAIT4 = 2'b11;

//------------Assign logic--------------
assign mem_rdy = (count==8)?1:0;
assign vpn_to_ppn_req_out = (vpn_to_ppn_req3 || vpn_to_ppn_req4);
 
/* Clock state changes and handle reset */
always @(posedge clk)
    begin
    if(rst_n) 
        begin
        state <= START;
        end 
    else if((freeze==0) )//|| (freeze && (state==START)))
        begin
         state <= #2 nextState;
        end
    end

/* FSM Logic */
always @(*) 
    begin 
    if(rst_n)
        begin
        i_we <= 1'b0;
        i_data <= 0;        
        stall <= 1'b0;
        nextState <= START; 
        vpn_to_ppn_req3 <= 1'b0;
        end    
    else 
        begin
        case(state)
        START: 
            begin
            i_we<=0;
            i_data <= 0;
            temp2<=0;
            temp3<=0;
            temp4<=0;
            i_we<=0;   
            vpn_to_ppn_req3 <= 1'b0;
            if(i_hit)
                stall <=1'b0;
            else if(~freeze_in)
                stall <=1'b1;
            else                 
                stall <=1'b0;

            `ifdef itlb_def       
            if(tag_hit)
            `else       
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
                  
         SERVICE_MISS: 
            begin            
            stall <=1'b1;
            vpn_to_ppn_req3 <= 1'b0;
            if(mem_rdy)             
                begin                 
                i_we<=1;
                i_data <= 0;
                nextState<= WAIT4;               
                end              
            else if(i_acc & !i_hit)
                begin // Hold the inputs to unified mem
                i_we<=0;                
                i_data <= 0;
                nextState <= SERVICE_MISS;            
                end
            else           
                begin            
                nextState <= SERVICE_MISS;
                i_we<=0;
                i_data <= 0;
                end           
            end            
            
        WAIT4:
            begin
            i_we<=1'b1;
            nextState<=WAIT4read;//WAIT5;            
            i_data<=m_line_full;            
            stall <=1'b1;
            vpn_to_ppn_req3 <= 1'b0;
            end
                        
        WAIT4read:
            begin
            i_we<=1'b0;
            nextState<=START;//WAIT5;            
            i_data<=m_line_full;            
            stall <=1'b1;
            vpn_to_ppn_req3 <= 1'b1;
            end
            
        default: 
            begin 
            i_data<=0;
            i_we<=1'b0;
            stall <=1'b0;
            vpn_to_ppn_req3 <= 1'b0;
            nextState<=START;       
            // Leave everything at their defaults (see top)
            end
        endcase
        end
    end
    
always@(posedge clk )
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


always@(posedge clk)
    begin
    if(rst_n)
    vpn_to_ppn_req4 <=0;
    else 
    vpn_to_ppn_req4 <= vpn_to_ppn_req3;
    end


always@(*)
    begin
    if(rst_n)
        begin
        biu_cyc_i <= 0;
        biu_stb_i <= 0;
        biu_cab_i <= 0;
        biu_sel_i<=4'b0;
        end
    else if(state==SERVICE_MISS && count<8)
        begin
        biu_cyc_i <= 1;
        biu_stb_i <= 1;
        biu_cab_i <= 1;
        biu_sel_i<=4'b1;
        end
    else
        begin
        biu_cyc_i <= 0;
        biu_stb_i <= 0;
        biu_cab_i <= 0;
        biu_sel_i<=4'b0;
        end
    end

//always@(posedge clk)
// count_int<=count;


endmodule
