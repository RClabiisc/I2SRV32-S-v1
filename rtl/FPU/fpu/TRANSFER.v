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

`define MOV_INT_FP 3'b000
`define MOV_FP_INT 3'b001
`define FCLASS 3'b100


module TRANSFER
(
    input [63:0] INPUT,
    input SP_DP,
    input [2:0] OPERATION,
    output reg [31:0] OUTPUT
);

wire sign_SP = INPUT[31];
wire sign_DP = INPUT[63];

wire [7:0] exp_SP = INPUT[30:23];
wire [10:0] exp_DP = INPUT[62:52];

wire [22:0] man_SP = INPUT[22:0];
wire [51:0] man_DP = INPUT[51:0];

wire NEG_INFINITY = SP_DP ? ((sign_DP) & (&exp_DP) & !(|man_DP)) : ((sign_SP) & (&exp_SP) & !(|man_SP));

wire NEG_SUBNORMAL = SP_DP ? ((sign_DP) & !(|exp_DP) & (|man_DP)) : ((sign_SP) & !(|exp_SP) & (|man_SP));

wire NEG_ZERO = SP_DP ? ((sign_DP) & !(|exp_DP) & !(|man_DP)) : ((sign_SP) & !(|exp_SP) & !(|man_SP));

wire POS_ZERO = SP_DP ? ((~sign_DP) & !(|exp_DP) & !(|man_DP)) : ((~sign_SP) & !(|exp_SP) & !(|man_SP));

wire POS_SUBNORMAL = SP_DP ? ((~sign_DP) & !(|exp_DP) & (|man_DP)) : ((~sign_SP) & !(|exp_SP) & (|man_SP));

wire POS_INFINITY = SP_DP ? ((~sign_DP) & (&exp_DP) & !(|man_DP)) : ((~sign_SP) & (&exp_SP) & !(|man_SP));

wire SIGNALING_NAN = SP_DP ? ((&exp_DP) & ~man_DP[51] & (|man_DP)) : ((&exp_SP) & ~man_SP[22]  & (|man_SP));

wire QUIET_NAN = SP_DP ? ((&exp_DP) & man_DP[51]) : ((&exp_SP) & man_SP[22]);

wire NEG_NORMAL = SP_DP ? ((sign_DP) & ~NEG_INFINITY & ~NEG_SUBNORMAL & ~NEG_ZERO & ~SIGNALING_NAN & ~QUIET_NAN) : ((sign_SP) & ~NEG_INFINITY & ~NEG_SUBNORMAL & ~NEG_ZERO & ~SIGNALING_NAN & ~QUIET_NAN);

wire POS_NORMAL = SP_DP ? ((~sign_DP) & ~POS_INFINITY & ~POS_SUBNORMAL & ~POS_ZERO & ~SIGNALING_NAN & ~QUIET_NAN) : ((~sign_SP) & ~POS_INFINITY & ~POS_SUBNORMAL & ~POS_ZERO & ~SIGNALING_NAN & ~QUIET_NAN);


always @ (*) begin 
    case (OPERATION)
        `MOV_INT_FP : begin
            OUTPUT = INPUT[31:0];
        end
        
        `MOV_FP_INT : begin
            OUTPUT = INPUT[31:0];       
        end
        
        `FCLASS : begin
            OUTPUT = {{22{1'b0}}, QUIET_NAN,  SIGNALING_NAN, POS_INFINITY, POS_NORMAL, POS_SUBNORMAL, POS_ZERO, NEG_ZERO, NEG_SUBNORMAL, NEG_NORMAL, NEG_INFINITY};       
        end
        
        
        default : begin
                
        end
                                        
    endcase;
end

endmodule
