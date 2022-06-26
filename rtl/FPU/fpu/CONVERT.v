`timescale 1ns / 1ps

`define FP_TO_INT_SIGNED    3'b000
`define FP_TO_INT_UNSIGNED  3'b001
`define INT_TO_FP_SIGNED    3'b010
`define INT_TO_FP_UNSIGNED  3'b011
`define SIGN_INJECTION      3'b100
`define SIGN_INJECTION_NEG  3'b101
`define SIGN_INJECTION_XOR  3'b110
`define FP_TO_FP            3'b111

module CONVERT
(
    input [63:0] INPUT_1,
    input [63:0] INPUT_2,
    input [2:0] Rounding_Mode,
    input SP_DP,
    input [2:0] OPERATION,
    output reg [63:0] OUTPUT,
    output reg INVALID,
    output reg OVERFLOW,                        
    output reg UNDERFLOW,
    output reg INEXACT
);

wire Signed_Unsigned = (OPERATION == `FP_TO_INT_UNSIGNED) || (OPERATION == `INT_TO_FP_UNSIGNED);

wire [63:0] INPUT_FP_to_int = ((OPERATION == `FP_TO_INT_SIGNED) || (OPERATION == `FP_TO_INT_UNSIGNED)) ? INPUT_1 : {64{1'b0}};
wire [31:0] INPUT_int_to_FP = ((OPERATION == `INT_TO_FP_SIGNED) || (OPERATION == `INT_TO_FP_UNSIGNED)) ? INPUT_1[31:0] : {32{1'b0}};
wire [63:0] INPUT_1_SIGN_INJECTION = ((OPERATION == `SIGN_INJECTION) || (OPERATION == `SIGN_INJECTION_NEG) || (OPERATION == `SIGN_INJECTION_XOR)) ? INPUT_1 : {64{1'b0}};  
wire [63:0] INPUT_2_SIGN_INJECTION = ((OPERATION == `SIGN_INJECTION) || (OPERATION == `SIGN_INJECTION_NEG) || (OPERATION == `SIGN_INJECTION_XOR)) ? INPUT_2 : {64{1'b0}};                     
wire [63:0] INPUT_FP_to_FP = (OPERATION == `FP_TO_FP) ? INPUT_1 : {64{1'b0}};

wire [2:0] OPERATION_SIGN_INJECTION = (OPERATION == `SIGN_INJECTION) ? 3'b001 : (OPERATION == `SIGN_INJECTION_NEG) ? 3'b010 : (OPERATION == `SIGN_INJECTION_XOR) ? 3'b100 : 3'b000;

wire [31:0] OUTPUT_FP_to_int;
wire [63:0] OUTPUT_int_to_FP;
wire [63:0] OUTPUT_SIGN_INJECTION;
wire [63:0] OUTPUT_FP_to_FP;

wire INVALID_FP_to_int;

wire OVERFLOW_FP_to_int;
wire OVERFLOW_FP_to_FP;

wire UNDERFLOW_FP_to_int;
wire UNDERFLOW_FP_to_FP;

wire INEXACT_int_to_FP;
wire INEXACT_FP_to_FP;
                
FP_to_int FP_TO_INT( .INPUT(INPUT_FP_to_int), .SP_DP(SP_DP), .Signed_Unsigned(Signed_Unsigned), .Rounding_Mode(Rounding_Mode), .OUTPUT(OUTPUT_FP_to_int), .INVALID(INVALID_FP_to_int), .OVERFLOW(OVERFLOW_FP_to_int), .UNDERFLOW(UNDERFLOW_FP_to_int));

int_to_FP INT_TO_FP( .INPUT(INPUT_int_to_FP), .Rounding_Mode(Rounding_Mode), .SP_DP(SP_DP), .Signed_Unsigned(Signed_Unsigned), .OUTPUT(OUTPUT_int_to_FP), .INEXACT(INEXACT_int_to_FP));

SIGN_INJECTION SGNJ( .INPUT_1(INPUT_1_SIGN_INJECTION), .INPUT_2(INPUT_2_SIGN_INJECTION), .SP_DP(SP_DP), .OPERATION(OPERATION_SIGN_INJECTION), .OUTPUT(OUTPUT_SIGN_INJECTION));

FP_to_FP FP_TO_FP( .INPUT(INPUT_FP_to_FP), .Rounding_Mode(Rounding_Mode), .SP_DP(~SP_DP), .OUTPUT(OUTPUT_FP_to_FP), .OVERFLOW(OVERFLOW_FP_to_FP), .UNDERFLOW(UNDERFLOW_FP_to_FP), .INEXACT(INEXACT_FP_to_FP));

always @(*) begin
    if((OPERATION == `FP_TO_INT_SIGNED) || (OPERATION == `FP_TO_INT_UNSIGNED)) begin
        OUTPUT <= {{32{1'b0}}, OUTPUT_FP_to_int};
        INVALID <= INVALID_FP_to_int;
        OVERFLOW <= OVERFLOW_FP_to_int;
        UNDERFLOW <= UNDERFLOW_FP_to_int;
        INEXACT <= 1'b0;
    end
    else if((OPERATION == `INT_TO_FP_SIGNED) || (OPERATION == `INT_TO_FP_UNSIGNED)) begin
        OUTPUT <= OUTPUT_int_to_FP;
        INVALID <= 1'b0;
        OVERFLOW <= 1'b0;
        UNDERFLOW <= 1'b0;
        INEXACT <= INEXACT_int_to_FP;
    end
    else if((OPERATION == `SIGN_INJECTION) || (OPERATION == `SIGN_INJECTION_NEG) || (OPERATION == `SIGN_INJECTION_XOR)) begin
        OUTPUT <= OUTPUT_SIGN_INJECTION;
        INVALID <= 1'b0;
        OVERFLOW <= 1'b0;
        UNDERFLOW <= 1'b0;
        INEXACT <= 1'b0;
    end
    else if(OPERATION == `FP_TO_FP) begin
        OUTPUT <= OUTPUT_FP_to_FP;
        INVALID <= 1'b0;
        OVERFLOW <= OVERFLOW_FP_to_FP;
        UNDERFLOW <= UNDERFLOW_FP_to_FP;
        INEXACT <= INEXACT_FP_to_FP;
    end
    else begin
        OUTPUT <= {64{1'b0}};
        INVALID <= 1'b0;
        OVERFLOW <= 1'b0;
        UNDERFLOW <= 1'b0;
        INEXACT <= 1'b0;
    end 
end
endmodule
