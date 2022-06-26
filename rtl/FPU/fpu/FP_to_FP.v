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

`define QNaN_DP 64'h7FF8000000000000
`define QNaN_SP 32'h7FC00000

module FP_to_FP
(
    input [63:0] INPUT,
    input [2:0] Rounding_Mode,
    input SP_DP,
    output reg [63:0] OUTPUT,
    output reg OVERFLOW,                        
    output reg UNDERFLOW,
    output reg INEXACT
);

wire [10:0] Zero_Exp_DP = {10{1'b1}};

wire sign = SP_DP ? INPUT[63] : INPUT[31];

wire [7:0] exp_INPUT_SP = INPUT[30:23];	
wire [10:0] exp_INPUT_DP = INPUT[62:52];

wire [22:0] man_INPUT_SP = INPUT[22:0];
wire [51:0] man_INPUT_DP = INPUT[51:0];

wire INPUT_NaN = SP_DP ? ((&exp_INPUT_DP) & (|man_INPUT_DP)) : ((&exp_INPUT_SP) & (|man_INPUT_SP));

always @(*) begin
    if(INPUT_NaN == 1'b1) begin
       OVERFLOW  <= 1'b0;
       UNDERFLOW <= 1'b0;
    end
    else if(SP_DP==1) begin
       OVERFLOW  <= exp_INPUT_DP > (Zero_Exp_DP + 127);
       UNDERFLOW <= exp_INPUT_DP < (Zero_Exp_DP - 128);	
    end
    else begin
       OVERFLOW  <= (exp_INPUT_SP == 8'hFF);
       UNDERFLOW <= (exp_INPUT_SP == 8'h00);
    end
end	

wire [7:0] exp_SP = OVERFLOW ? {8{1'b1}} : UNDERFLOW ? {8{1'b0}} : (exp_INPUT_DP - 896);
wire [22:0] man_SP = OVERFLOW ? {23{1'b0}} : UNDERFLOW ? {23{1'b0}} : man_INPUT_DP[51:29];

wire [10:0] exp_DP = OVERFLOW ? {11{1'b1}} : UNDERFLOW ? {11{1'b0}} : ({3'b000,exp_INPUT_SP} + 896);
wire [51:0] man_DP = OVERFLOW ? {23{1'b0}} : UNDERFLOW ? {23{1'b0}} : {man_INPUT_SP,{29{1'b0}}};

wire LSB = man_INPUT_DP[29];
wire Guard = man_INPUT_DP[28];          
wire Round = man_INPUT_DP[27];
wire Sticky = |man_INPUT_DP[26:0];
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
                Add_Rounding_Bit <= (sign & (Guard | Round | Sticky));
                end
        `RUP : begin
                Add_Rounding_Bit <= ((~sign) & (Guard | Round | Sticky));
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
    if(SP_DP == 1) begin
        if(INPUT_NaN == 1'b1) begin
            OUTPUT <= {{32{1'b0}},`QNaN_SP};
            INEXACT <= 1'b0;
        end
        else begin
            OUTPUT <= {{32{1'b0}},sign,exp_SP,man_SP} + Add_Rounding_Bit;
            INEXACT <= Add_Rounding_Bit;
        end
    end
    else begin
        if(INPUT_NaN == 1'b1) begin
            OUTPUT <= `QNaN_DP;
            INEXACT <= 1'b0;
        end
        else begin
            OUTPUT <= {sign,exp_DP,man_DP};   
            INEXACT <= 1'b0;
        end
    end
end

endmodule
