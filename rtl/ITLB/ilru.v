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
// Create Date: 11.01.2017 12:24:26
// Design Name: 
// Module Name: lru
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


module ilru( clk,rst,access,addr_access,compare,lru_addr

    );
    
    input clk;
    input rst;
    input access;
    input [4:0] addr_access;
    input compare;
    
    output reg [4:0] lru_addr;
    
    reg [1:0]level_4;
    reg [3:0]level_3;
    reg [7:0]level_2;
    reg [15:0]level_1;
    reg [31:0]level_0;
    
    reg [4:0]lru_addr_int;
    
always @(posedge clk) begin
        if(rst) begin
            level_4 <=  2'b0;
            level_3 <=  4'b0;
            level_2 <=  8'b0;
            level_1 <= 16'b0;
            level_0 <= 32'b0;
        end
        else if(access) begin
        
            case(addr_access) 
            5'd0  : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b01;
                    level_2[1:0] <= 2'b01;
                    level_1[1:0] <= 2'b01;
                    level_0[1:0] <= 2'b01;
                    end
            5'd1  : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b01;
                    level_2[1:0] <= 2'b01;
                    level_1[1:0] <= 2'b01;
                    level_0[1:0] <= 2'b10;
                    end
            5'd2  : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b01;
                    level_2[1:0] <= 2'b01;
                    level_1[1:0] <= 2'b10;
                    level_0[3:2] <= 2'b01;
                    end
            5'd3  : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b01;
                    level_2[1:0] <= 2'b01;
                    level_1[1:0] <= 2'b10;
                    level_0[3:2] <= 2'b10;
                    end
            5'd4  : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b01;
                    level_2[1:0] <= 2'b10;
                    level_1[3:2] <= 2'b01;
                    level_0[5:4] <= 2'b01;
                    end
            5'd5  : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b01;
                    level_2[1:0] <= 2'b10;
                    level_1[3:2] <= 2'b01;
                    level_0[5:4] <= 2'b10;
                    end
            5'd6  : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b01;
                    level_2[1:0] <= 2'b10;
                    level_1[3:2] <= 2'b10;
                    level_0[7:6] <= 2'b01;
                    end
            5'd7  : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b01;
                    level_2[1:0] <= 2'b10;
                    level_1[3:2] <= 2'b10;
                    level_0[7:6] <= 2'b10;
                    end
            5'd8  : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b10;
                    level_2[3:2] <= 2'b01;
                    level_1[5:4] <= 2'b01;
                    level_0[9:8] <= 2'b01;
                    end
            5'd9  : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b10;
                    level_2[3:2] <= 2'b01;
                    level_1[5:4] <= 2'b01;
                    level_0[9:8] <= 2'b10;
                    end
            5'd10 : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b10;
                    level_2[3:2] <= 2'b01;
                    level_1[5:4] <= 2'b10;
                    level_0[11:10] <= 2'b01;
                    end
            5'd11 : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b10;
                    level_2[3:2] <= 2'b01;
                    level_1[5:4] <= 2'b10;
                    level_0[11:10] <= 2'b10;
                    end
            5'd12 : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b10;
                    level_2[3:2] <= 2'b10;
                    level_1[7:6] <= 2'b01;
                    level_0[13:12] <= 2'b01;
                    end
            5'd13 : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b10;
                    level_2[3:2] <= 2'b10;
                    level_1[7:6] <= 2'b01;
                    level_0[13:12] <= 2'b10;
                    end
            5'd14 : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b10;
                    level_2[3:2] <= 2'b10;
                    level_1[7:6] <= 2'b10;
                    level_0[15:14] <= 2'b01;
                    end
            5'd15 : begin
                    level_4 <= 2'b01;
                    level_3[1:0] <= 2'b10;
                    level_2[3:2] <= 2'b10;
                    level_1[7:6] <= 2'b10;
                    level_0[15:14] <= 2'b10;
                    end
            5'd16 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b01;
                    level_2[5:4] <= 2'b01;
                    level_1[9:8] <= 2'b01;
                    level_0[17:16] <= 2'b01;
                    end
            5'd17 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b01;
                    level_2[5:4] <= 2'b01;
                    level_1[9:8] <= 2'b01;
                    level_0[17:16] <= 2'b10;
                    end
            5'd18 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b01;
                    level_2[5:4] <= 2'b01;
                    level_1[9:8] <= 2'b10;
                    level_0[19:18] <= 2'b01;
                    end
            5'd19 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b01;
                    level_2[5:4] <= 2'b01;
                    level_1[9:8] <= 2'b10;
                    level_0[19:18] <= 2'b10;
                    end
            5'd20 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b01;
                    level_2[5:4] <= 2'b10;
                    level_1[11:10] <= 2'b01;
                    level_0[21:20] <= 2'b01;
                    end
            5'd21 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b01;
                    level_2[5:4] <= 2'b10;
                    level_1[11:10] <= 2'b01;
                    level_0[21:20] <= 2'b10;
                    end
            5'd22 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b01;
                    level_2[5:4] <= 2'b10;
                    level_1[11:10] <= 2'b10;
                    level_0[23:22] <= 2'b01;
                    end
            5'd23  : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b01;
                    level_2[5:4] <= 2'b10;
                    level_1[11:10] <= 2'b10;
                    level_0[23:22] <= 2'b10;
                    end
            5'd24 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b10;
                    level_2[7:6] <= 2'b01;
                    level_1[13:12] <= 2'b01;
                    level_0[25:24] <= 2'b01;
                    end
            5'd25 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b10;
                    level_2[7:6] <= 2'b01;
                    level_1[13:12] <= 2'b01;
                    level_0[25:24] <= 2'b10;
                    end
            5'd26 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b10;
                    level_2[7:6] <= 2'b01;
                    level_1[13:12] <= 2'b10;
                    level_0[27:26] <= 2'b01;
                    end
            5'd27 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b10;
                    level_2[7:6] <= 2'b01;
                    level_1[13:12] <= 2'b10;
                    level_0[27:26] <= 2'b10;
                    end
            5'd28 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b10;
                    level_2[7:6] <= 2'b10;
                    level_1[15:14] <= 2'b01;
                    level_0[29:28] <= 2'b01;
                    end
            5'd29 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b10;
                    level_2[7:6] <= 2'b10;
                    level_1[15:14] <= 2'b01;
                    level_0[29:28] <= 2'b10;
                    end
            5'd30 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b10;
                    level_2[7:6] <= 2'b10;
                    level_1[15:14] <= 2'b10;
                    level_0[31:30] <= 2'b01;
                    end
            5'd31 : begin
                    level_4 <= 2'b10;
                    level_3[3:2] <= 2'b10;
                    level_2[7:6] <= 2'b10;
                    level_1[15:14] <= 2'b10;
                    level_0[31:30] <= 2'b10;
                    end
            default: begin
                        level_4 <=  level_4;
                        level_3 <=  level_3;
                        level_2 <=  level_2;
                        level_1 <=  level_1;
                        level_0 <=  level_0;
                    end
            endcase
        
        end
        else begin
                level_4 <=  level_4;
                level_3 <=  level_3;
                level_2 <=  level_2;
                level_1 <=  level_1;
                level_0 <=  level_0;
        end
    end
    
    
always@(posedge clk)
    begin
        if(rst)
           lru_addr <= 5'b0;
        else
           lru_addr <= lru_addr_int;
    end
 
 
always@(*) begin
    if(rst) lru_addr_int <= 5'b0;
    else
    if(compare)
        begin
        if(level_4[0]== 1'b0) begin
            if(level_3[0]==1'b0) begin
                if(level_2[0]==1'b0) begin
                    if(level_1[0]==1'b0) begin
                        if(level_0[0]==1'b0) lru_addr_int <= 5'd0;
                        else                 lru_addr_int <= 5'd1;
                    end
                    else begin
                        if(level_0[2]==1'b0) lru_addr_int <= 5'd2;
                        else                 lru_addr_int <= 5'd3;
                    end
                end
                else begin
                    if(level_1[2]==1'b0) begin
                        if(level_0[4]==1'b0) lru_addr_int <= 5'd4;
                        else                 lru_addr_int <= 5'd5;
                    end
                    else begin
                        if(level_0[6]==1'b0) lru_addr_int <= 5'd6;
                        else                 lru_addr_int <= 5'd7;
                    end
                end
            end
            else begin
                if(level_2[2]==1'b0) begin
                    if(level_1[4]==1'b0) begin
                        if(level_0[8]==1'b0) lru_addr_int <= 5'd8;
                        else                 lru_addr_int <= 5'd9;
                    end
                    else begin
                        if(level_0[10]==1'b0) lru_addr_int <= 5'd10;
                        else                 lru_addr_int <= 5'd11;
                    end
                end
                else begin
                    if(level_1[6]==1'b0) begin
                        if(level_0[12]==1'b0) lru_addr_int <= 5'd12;
                        else                 lru_addr_int <= 5'd13;
                    end
                    else begin
                        if(level_0[14]==1'b0) lru_addr_int <= 5'd14;
                        else                 lru_addr_int <= 5'd15;
                    end
                end
            end
        end
        else begin
            if(level_3[2]==1'b0) begin
                if(level_2[4]==1'b0) begin
                    if(level_1[8]==1'b0) begin
                        if(level_0[16]==1'b0) lru_addr_int <= 5'd16;
                        else                 lru_addr_int <= 5'd17;
                    end
                    else begin
                        if(level_0[18]==1'b0) lru_addr_int <= 5'd18;
                        else                 lru_addr_int <= 5'd19;
                    end
                end
                else begin
                    if(level_1[10]==1'b0) begin
                        if(level_0[20]==1'b0) lru_addr_int <= 5'd20;
                        else                 lru_addr_int <= 5'd21;
                    end
                    else begin
                        if(level_0[22]==1'b0) lru_addr_int <= 5'd22;
                        else                 lru_addr_int <= 5'd23;
                    end
                end
            end
            else begin
                if(level_2[6]==1'b0) begin
                    if(level_1[12]==1'b0) begin
                        if(level_0[24]==1'b0) lru_addr_int <= 5'd24;
                        else                 lru_addr_int <= 5'd25;
                    end
                    else begin
                        if(level_0[26]==1'b0) lru_addr_int <= 5'd26;
                        else                 lru_addr_int <= 5'd27;
                    end
                end
                else begin
                    if(level_1[14]==1'b0) begin
                        if(level_0[28]==1'b0) lru_addr_int <= 5'd28;
                        else                 lru_addr_int <= 5'd29;
                    end
                    else begin
                        if(level_0[30]==1'b0) lru_addr_int <= 5'd30;
                        else                 lru_addr_int <= 5'd31;
                    end
                end
            end
        end
    end
    else lru_addr_int <= 5'd0;

end
        
        

 
    
endmodule
