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


module REG_FILE
(
    input CLK,
    input RST,
    
    input [4:0] RS1_Read_Addr,
    input [4:0] RS2_Read_Addr,
    input [4:0] RD_Write_Addr,
    input [31:0] RD_Write_Data,
    input Reg_Write_Enable__EX_MEM,
    
    input MEM_WB_Freeze,
    
    input RS1_Dec_Ctrl__IRQ,
    input RS2_Dec_Ctrl__IRQ,
    input WB_Ctrl__IRQ,
    
    output reg[31:0] RS1_Read_Data,
    output reg[31:0] RS2_Read_Data,
    
    output [63:0] led
);

reg [31:0] MEM[0:31];
reg [31:0] MEM_Shadow[4:3];

assign led = {MEM[14],MEM[15]};


always @ (posedge CLK) begin
    if(RST) begin
        MEM[0] <= 32'b0;
        MEM[1] <= 32'h103C;
        MEM[2] <= 32'h203C;      
        MEM[3] <= 32'h303C;
        MEM[4] <= 32'h403C;
        MEM[5] <= 32'h40404040; 
        MEM[6] <= 32'h00001000;                  
        MEM[7] <= 32'd0;                  
        MEM[8] <= 32'd0;
        MEM[9] <= 32'd0;
        MEM[10] <= 32'd0;
        MEM[11] <= 32'h00000001;
        MEM[12] <= 32'h00000020;
        MEM[13] <= 32'h00000300;
        MEM[14] <= 32'h00004000;
        MEM[15] <= 32'h00000005;
        MEM[16] <= 32'h00000050;
        MEM[17] <= 32'h00000500;
        MEM[18] <= 32'h00005000;                 
        MEM[19] <= 32'h22220000;                 
        MEM[20] <= 32'h33330000;
        MEM[21] <= 32'h44440000;
        MEM[22] <= 32'd0;
        MEM[23] <= 32'd0;
        MEM[24] <= 32'd0;
        MEM[25] <= 32'd0;
        MEM[26] <= 32'd0;
        MEM[27] <= 32'd0;
        MEM[28] <= 32'd0;
        MEM[29] <= 32'd0;
        MEM[30] <= 32'd0;            
        MEM[31] <= 32'd0;
        MEM_Shadow[3] <= 32'd0;
        MEM_Shadow[4] <= 32'd0;
    end
    else if (Reg_Write_Enable__EX_MEM & (|RD_Write_Addr) & (~WB_Ctrl__IRQ) & (~MEM_WB_Freeze)) begin
        MEM[RD_Write_Addr] <= RD_Write_Data;
    end
    else if (Reg_Write_Enable__EX_MEM & (|RD_Write_Addr) & (WB_Ctrl__IRQ) & (~MEM_WB_Freeze)) begin
        MEM_Shadow[RD_Write_Addr] <= RD_Write_Data;
    end        
end


always @(*) begin
    RS1_Read_Data <= RS1_Dec_Ctrl__IRQ ? MEM_Shadow[RS1_Read_Addr] : MEM[RS1_Read_Addr];
    RS2_Read_Data <= RS2_Dec_Ctrl__IRQ ? MEM_Shadow[RS2_Read_Addr] : MEM[RS2_Read_Addr];
end
endmodule

