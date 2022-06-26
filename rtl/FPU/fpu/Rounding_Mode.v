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

`define RNE 3'b000
`define RZ  3'b001
`define RDN 3'b010                    
`define RUP 3'b011
`define RMM 3'b100

module Rounding_Mode_SP
(
    input [32:0] EXP_FRAC,
    input [2:0] Rounding_Mode,
    input [2:0] Guard_Bits, 
    input Sign,
    output reg [32:0] OUT_EXP_FRAC,
    output reg INEXACT
);

wire LSB;
wire Guard;          
wire Round;
wire Sticky;
reg Add_Rounding_Bit;

assign LSB = EXP_FRAC[0];
assign Guard = Guard_Bits[2];
assign Round = Guard_Bits[1];
assign Sticky = Guard_Bits[0];

always @(*) begin
    case(Rounding_Mode)
        `RNE : begin
                Add_Rounding_Bit <= Guard & (LSB | Round | Sticky);
                end
        `RZ  : begin
                Add_Rounding_Bit <= 1'b0;
                end
        `RDN : begin
                Add_Rounding_Bit <= Sign & (Guard | Round | Sticky);
                end
        `RUP : begin
                Add_Rounding_Bit <= (~Sign) & (Guard | Round | Sticky);
                end
        `RMM : begin
                Add_Rounding_Bit <= Guard;
                end
        default: begin
                Add_Rounding_Bit <= 1'b0;
                end        
    endcase;
end

always @(*) begin
    OUT_EXP_FRAC = EXP_FRAC + {32'b00000000000000000000000000000000, Add_Rounding_Bit};
    
    INEXACT <= (Guard | Round | Sticky);
end
endmodule




module Rounding_Mode_DP
(
    input [64:0] EXP_FRAC,
    input [2:0] Rounding_Mode,
    input [2:0] Guard_Bits, 
    input Sign,
    output reg [64:0] OUT_EXP_FRAC,
    output reg INEXACT
);

wire LSB;
wire Guard;          
wire Round;
wire Sticky;
reg Add_Rounding_Bit;

assign LSB = EXP_FRAC[0];
assign Guard = Guard_Bits[2];
assign Round = Guard_Bits[1];
assign Sticky = Guard_Bits[0];

always @(*) begin
    case(Rounding_Mode)
        `RNE : begin
                Add_Rounding_Bit <= Guard & (LSB | Round | Sticky);
                end
        `RZ  : begin
                Add_Rounding_Bit <= 1'b0;
                end
        `RDN : begin
                Add_Rounding_Bit <= Sign & (Guard | Round | Sticky);
                end
        `RUP : begin
                Add_Rounding_Bit <= (~Sign) & (Guard | Round | Sticky);
                end
        `RMM : begin
                Add_Rounding_Bit <= Guard;
                end
        default: begin
                Add_Rounding_Bit <= 1'b0;
                end        
    endcase;
end

always @(*) begin
    OUT_EXP_FRAC = EXP_FRAC + {64'b0000000000000000000000000000000000000000000000000000000000000000, Add_Rounding_Bit};
    
    INEXACT <= (Guard | Round | Sticky);
end
endmodule



