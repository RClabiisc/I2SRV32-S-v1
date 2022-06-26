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

(* keep_hierarchy = "yes" *) module SQRT
(
    input [65:0] INPUT,
    input [2:0] Rounding_Mode,
    input SP_DP,
    output reg [65:0] OUTPUT,
    output reg INVALID,
    output reg OVERFLOW,
    output reg UNDERFLOW,
    output reg INEXACT
);

wire [65:0] INPUT_DP;
wire [65:0] OUTPUT_DP;
wire [33:0] INPUT_SP;
wire [33:0] OUTPUT_SP;

wire INEXACT_SP;
wire INEXACT_DP;

assign INPUT_SP = SP_DP ? 34'b0000000000000000000000000000000000 : INPUT[33:0];

assign INPUT_DP = SP_DP ? INPUT : 66'b000000000000000000000000000000000000000000000000000000000000000000;


(* keep_hierarchy = "yes" *) FPSqrt_8_23 FPSQRT_SP( .X(INPUT_SP), .RM(Rounding_Mode), .R(OUTPUT_SP), .INEXACT(INEXACT_SP));

(* keep_hierarchy = "yes" *) FPSqrt_11_52 FPSQRT_DP( .X(INPUT_DP), .RM(Rounding_Mode), .R(OUTPUT_DP), .INEXACT(INEXACT_DP));


always @(*) begin
    if (SP_DP) begin
        OUTPUT <=  OUTPUT_DP;
    end
    else begin
        OUTPUT <=  {32'b00000000000000000000000000000000, OUTPUT_SP};
    end
end


wire [1:0] EXC_BITS = SP_DP ? OUTPUT_DP[65:64] : OUTPUT_SP[33:32];
wire EXP_ZERO = SP_DP ? !(|OUTPUT_DP[62:52]) : !(|OUTPUT_SP[30:23]);

always @(*) begin

    INEXACT <= SP_DP ? INEXACT_DP : INEXACT_SP;
    
    case(EXC_BITS)
        2'b00 : begin
            OVERFLOW <= 1'b0;
            UNDERFLOW <= 1'b1;
        end
        
        2'b01 : begin
            OVERFLOW <= 1'b0;
            if(EXP_ZERO == 1'b1)
                UNDERFLOW <= 1'b1;
            else
                UNDERFLOW <= 1'b0;
        end
                
        2'b10 : begin
            OVERFLOW <= 1'b1;
            UNDERFLOW <= 1'b0;
        end
                        
        default: begin
            OVERFLOW <= 1'b0;
            UNDERFLOW <= 1'b0;          
        end
    endcase;
end


wire [1:0] IN_EXC_BITS = SP_DP ? INPUT[65:64] : INPUT[33:32];

wire IN_SNAN_BIT = SP_DP ? INPUT[51] : INPUT[22];

wire IN_SIGN = SP_DP ? INPUT[63] : INPUT[31];



always @(*) begin

    if ((IN_EXC_BITS == 2'b11) && (IN_SNAN_BIT == 1'b0)) begin
        INVALID <= 1'b1;
    end
    else if (IN_SIGN == 1'b1) begin
        INVALID <= 1'b1;
    end
    else begin
        INVALID <= 1'b0;
    end
    
end

endmodule
