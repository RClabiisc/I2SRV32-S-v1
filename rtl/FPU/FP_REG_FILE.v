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


module FP_REG_FILE
(
    input RST,
    input CLK,
    
    input [4:0] FP__RS1_Read_Addr,
    input [4:0] FP__RS2_Read_Addr,
    input [4:0] FP__RS3_Read_Addr,
    
    input [4:0] FP__RD_Write_Addr,
    input [63:0] FP__RD_Write_Data,
    input FP__Reg_Write_En__EX_MEM,
    input FP__SP_DP__EX_MEM,
    input FP__MEM_WB_Freeze,
    
    output reg [63:0] FP__RS1_Read_Data,
    output reg [63:0] FP__RS2_Read_Data,
    output reg [63:0] FP__RS3_Read_Data,
    
    output [63:0] led
);


reg [63:0] MEMORY[0:31];

assign led = MEMORY[15];

always @ (posedge CLK) begin
    if(RST) begin
        MEMORY[0] <= 64'd00;
        MEMORY[1] <= 64'b1111111011011011011111110100011100111101011000111000100011011111; 
        MEMORY[2] <= 64'b0111111011011100000001101110000110110111100110101011000010001010;      
        MEMORY[3] <= 64'd00;
        MEMORY[4] <= 64'b0100011110101011010000110110100010010100011001001001110110000101;
        MEMORY[5] <= 64'b0100100110101111100101010001010101100111000100010010111010111100;
        MEMORY[6] <= 64'd00;                  
        MEMORY[7] <= 64'b0011101101000111101010000011101011101111111001011010101010000110;                  
        MEMORY[8] <= 64'b0100111111000010100101101000001111011110001000101011010010001010;
        MEMORY[9] <= 64'd00;
        MEMORY[10] <= 64'b1000101110100001011000010000110000111101111111100011010101010101;
        MEMORY[11] <= 64'b0100010000111111000001111000011101010010100100100110011001010011;
        MEMORY[12] <= 64'd00;
        MEMORY[13] <= 64'b0000101000010110100101011101001110011010111001001110101011001100;
        MEMORY[14] <= 64'd00;
        MEMORY[15] <= 64'hC1CD6F3458800000;
        MEMORY[16] <= 64'h40FE240000000000;
        MEMORY[17] <= 64'd00;
        MEMORY[18] <= 64'd00;                
        MEMORY[19] <= 64'hC0E64DC000000000;                 
        MEMORY[20] <= 64'hC0FE240000000000;
        MEMORY[21] <= 64'd00;
        MEMORY[22] <= 64'd00;
        MEMORY[23] <= 64'd00;
        MEMORY[24] <= 64'hC1CD6F3458800000;
        MEMORY[25] <= 64'h40FE240000000000;
        MEMORY[26] <= 64'hC1CD6F3458800000;
        MEMORY[27] <= 64'h40FE240000000000;
        MEMORY[28] <= 64'hC1CD6F3458800000;
        MEMORY[29] <= 64'h40FE240000000000;
        MEMORY[30] <= 64'd00;            
        MEMORY[31] <= 64'd00;
    end
    else if (FP__Reg_Write_En__EX_MEM & (~FP__MEM_WB_Freeze)) begin
        MEMORY[FP__RD_Write_Addr] <= FP__SP_DP__EX_MEM ? FP__RD_Write_Data : {{32{1'b1}},FP__RD_Write_Data[31:0]};
    end     
end


always @(*) begin
    FP__RS1_Read_Data <= MEMORY[FP__RS1_Read_Addr];
    FP__RS2_Read_Data <= MEMORY[FP__RS2_Read_Addr];
    FP__RS3_Read_Data <= MEMORY[FP__RS3_Read_Addr];
end


endmodule
