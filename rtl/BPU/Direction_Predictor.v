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



module Direction_Predictor
(
    input CLK,
    input RST,
    input [31:0] PC,
    
    input BPU__Stall,
    
    output reg Branch_Taken,
    
    output reg [10:0] PHT_Read_Index, 
    output [1:0] PHT_Read_Data,
    
    input [10:0] PHT_Write_Index,
    input [1:0] PHT_Write_Data,
    input PHT_Write_En,
    
    input GHR_Write_Data,
    input GHR_Write_En
);

reg [4:0] GHR;
wire [4:0] PC_XOR_GHR;

reg [10:0] PHT_Write_Index__reg;
reg [1:0] PHT_Write_Data__reg;
reg PHT_Write_En__reg;

reg GHR_Write_Data__reg;
reg GHR_Write_En__reg;

assign PC_XOR_GHR = PC[12:8] ^ GHR;


always @(posedge CLK) begin
    if(RST) begin
        PHT_Write_Index__reg <= 11'b0;
        PHT_Write_Data__reg <= 2'b0;
        PHT_Write_En__reg <= 1'b0;
        GHR_Write_Data__reg <= 1'b0;
        GHR_Write_En__reg <= 1'b0;
    end 
    else if(~BPU__Stall) begin
        PHT_Write_Index__reg <= PHT_Write_Index;
        PHT_Write_Data__reg <= PHT_Write_Data;
        PHT_Write_En__reg <= PHT_Write_En;
        GHR_Write_Data__reg <= GHR_Write_Data;
        GHR_Write_En__reg <= GHR_Write_En;
    end 
end


always @(posedge CLK) begin
    if(RST) 
        GHR <= 5'b0;
    else if((GHR_Write_En__reg) & (~BPU__Stall))
        GHR <= {GHR[3:0],GHR_Write_Data__reg};
end

always @(*) begin
    if(RST) 
        PHT_Read_Index <= 11'b0;
    else 
        PHT_Read_Index <= {PC_XOR_GHR,PC[7:2]}; //PC[12:2]; //{PC_XOR_GHR,PC[7:2]}; 
end

always @(*) begin
    if(RST) 
        Branch_Taken <= 1'b0;
    else 
        Branch_Taken <= PHT_Read_Data[1];
end



PHT_mem PHT ( .clka(CLK),
              .wea((PHT_Write_En__reg) & (~BPU__Stall)),
              .addra(PHT_Write_Index__reg),
              .dina(PHT_Write_Data__reg),
              .clkb(CLK),
              .rstb(RST),
              .enb(~BPU__Stall),
              .addrb(PHT_Read_Index),
              .doutb(PHT_Read_Data));

endmodule
