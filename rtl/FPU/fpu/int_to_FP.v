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

module int_to_FP
(
    input [31:0] INPUT,
    input [2:0] Rounding_Mode,
    input SP_DP,
    input Signed_Unsigned,
    output reg [63:0] OUTPUT,
    output reg INEXACT
);

wire [7:0] Zero_Exp_SP = {7{1'b1}};
wire [10:0] Zero_Exp_DP = {10{1'b1}};

wire INPUT_zero = INPUT==0;

wire [31:0] INPUT_mag = Signed_Unsigned ? INPUT : INPUT[31] ? -INPUT : INPUT;

wire sign = Signed_Unsigned ? 1'b0 : INPUT[31];

wire [5:0] Leading_Zero_Count;
LZC  LZC (.i(INPUT_mag), .o(Leading_Zero_Count) );


wire [7:0] EXP_SP = INPUT_zero ? 0 : (Zero_Exp_SP + 31 - Leading_Zero_Count);
wire [10:0] EXP_DP = INPUT_zero ? 0 : (Zero_Exp_DP + 31 - Leading_Zero_Count);

wire [31:0] Sig_mag = INPUT_mag << Leading_Zero_Count;

wire LSB = Sig_mag[8];
wire Guard = Sig_mag[7];          
wire Round = Sig_mag[6];
wire Sticky = |Sig_mag[5:0];
reg Add_Rounding_Bit;


always @(*) begin
    case(Rounding_Mode)
        `RNE : begin
                Add_Rounding_Bit <= Guard & (LSB | Round | Sticky);
                end
        `RZ  : begin
                Add_Rounding_Bit <= 1'b0;
                end
        `RDN : begin
                Add_Rounding_Bit <= Signed_Unsigned ? 1'b0 : (sign & (Guard | Round | Sticky));
                end
        `RUP : begin
                Add_Rounding_Bit <= Signed_Unsigned ? 1'b0 : ((~sign) & (Guard | Round | Sticky));
                end
        `RMM : begin
                Add_Rounding_Bit <= Guard;
                end
        default: begin
                Add_Rounding_Bit <= 1'b0;
                end        
    endcase;
end

wire [22:0] Mantissa_SP = Sig_mag[30:8];
wire [51:0] Mantissa_DP = {Sig_mag[30:0] ,{21{1'b0}}};


always @(*) begin
    if(SP_DP==1) begin
        OUTPUT <= {sign,EXP_DP,Mantissa_DP};
        INEXACT <= 1'b0;
    end
    else begin
        OUTPUT <= {{32{1'b0}},sign,EXP_SP,Mantissa_SP} + Add_Rounding_Bit;
        INEXACT <= Add_Rounding_Bit;
    end   
end

endmodule






