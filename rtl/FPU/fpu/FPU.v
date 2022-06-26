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

`define SP 1'b0
`define DP 1'b1

`define ADD 3'b000
`define MULT 3'b001
`define DIV 3'b010
`define SQRT 3'b011
`define COMPARE 3'b100
`define CONVERT 3'b101
`define FUSED_MULT_ADD 3'b110
`define TRANSFER 3'b111

`define EQUAL           3'b000
`define LESS_THAN       3'b001
`define LESS_OR_EQUAL   3'b010
`define MIN             3'b100
`define MAX             3'b101

`define FP_TO_INT_SIGNED    3'b000
`define FP_TO_INT_UNSIGNED  3'b001
`define INT_TO_FP_SIGNED    3'b010
`define INT_TO_FP_UNSIGNED  3'b011
`define SIGN_INJECTION      3'b100
`define SIGN_INJECTION_NEG  3'b101
`define SIGN_INJECTION_XOR  3'b110
`define FP_TO_FP            3'b111

`define FMADD 3'b000
`define FMSUB 3'b001
`define FNMADD 3'b010
`define FNMSUB 3'b011

`define MOV_INT_FP  3'b000
`define MOV_FP_INT  3'b001
`define FCLASS      3'b100




(* keep_hierarchy = "yes" *) module FPU
(
    input CLK,
    input RST,
    input [63:0] INPUT_1,
    input [63:0] INPUT_2,
    input [63:0] INPUT_3,
    input [2:0] Rounding_Mode,
    input [2:0] FPU_OPERATION,
    input [2:0] FPU_SUB_OPERATION,
    input SP_DP,
    output reg [63:0] OUTPUT,
    output reg INVALID,
    output reg DIVIDE_BY_ZERO,
    output reg OVERFLOW,
    output reg UNDERFLOW,
    output reg INEXACT
);

reg [63:0] OUTPUT_int;
reg READY_int;
reg INVALID_int;
reg DIVIDE_BY_ZERO_int;
reg OVERFLOW_int;
reg UNDERFLOW_int;
reg INEXACT_int;
    
wire [65:0] OUTPUT_ADD;
wire [65:0] OUTPUT_MULT;
wire [65:0] OUTPUT_DIV;
wire [65:0] OUTPUT_SQRT;
wire [65:0] OUTPUT_FUSED_MULT_ADD = FPU_SUB_OPERATION[1] ? (SP_DP ? (OUTPUT_ADD ^ 66'h08000000000000000) : (OUTPUT_ADD ^ 66'h0000000080000000)) : OUTPUT_ADD;
wire [63:0] OUTPUT_COMPARE;
wire [63:0] OUTPUT_CONVERT;
wire [31:0] OUTPUT_TRANSFER;

wire INVALID_ADD;
wire INVALID_MULT;
wire INVALID_DIV;
wire INVALID_SQRT;
wire INVALID_COMPARE;
wire INVALID_CONVERT;

wire DIVIDE_BY_ZERO_DIV;

wire OVERFLOW_ADD;
wire OVERFLOW_MULT;
wire OVERFLOW_DIV;
wire OVERFLOW_SQRT;
wire OVERFLOW_CONVERT;

wire UNDERFLOW_ADD;
wire UNDERFLOW_MULT;
wire UNDERFLOW_DIV;
wire UNDERFLOW_SQRT;
wire UNDERFLOW_CONVERT;

wire INEXACT_ADD;
wire INEXACT_MULT;
wire INEXACT_DIV;
wire INEXACT_SQRT;
wire INEXACT_CONVERT;

reg [65:0] OUTPUT_FPC_IEEE;

wire [63:0] OUTPUT_IEEE_SP;
wire [63:0] OUTPUT_IEEE_DP;

wire [63:0] OUTPUT_IEEE = SP_DP ? OUTPUT_IEEE_DP : {{32{1'b0}},OUTPUT_IEEE_SP[31:0]};




wire [65:0] INPUT_1_FLOPOCO_SP;
wire [65:0] INPUT_2_FLOPOCO_SP;
wire [65:0] INPUT_3_FLOPOCO_SP;
wire [65:0] INPUT_1_FLOPOCO_DP;
wire [65:0] INPUT_2_FLOPOCO_DP;
wire [65:0] INPUT_3_FLOPOCO_DP;

wire [65:0] INPUT_1_FLOPOCO = SP_DP ? INPUT_1_FLOPOCO_DP : {{32{1'b0}},INPUT_1_FLOPOCO_SP[33:0]};
wire [65:0] INPUT_2_FLOPOCO = SP_DP ? INPUT_2_FLOPOCO_DP : {{32{1'b0}},INPUT_2_FLOPOCO_SP[33:0]};
wire [65:0] INPUT_3_FLOPOCO = SP_DP ? INPUT_3_FLOPOCO_DP : {{32{1'b0}},INPUT_3_FLOPOCO_SP[33:0]};

wire [65:0] INPUT_1_ADD = (FPU_OPERATION == `ADD) ? INPUT_1_FLOPOCO : (FPU_OPERATION == `FUSED_MULT_ADD) ? OUTPUT_MULT : {66{1'b0}};
wire [65:0] INPUT_2_ADD = (FPU_OPERATION == `ADD) ? INPUT_2_FLOPOCO : (FPU_OPERATION == `FUSED_MULT_ADD) ? INPUT_3_FLOPOCO : {66{1'b0}};
wire [65:0] INPUT_1_MULT = ((FPU_OPERATION == `MULT) | (FPU_OPERATION == `FUSED_MULT_ADD)) ? INPUT_1_FLOPOCO : {66{1'b0}};
wire [65:0] INPUT_2_MULT = ((FPU_OPERATION == `MULT) | (FPU_OPERATION == `FUSED_MULT_ADD)) ? INPUT_2_FLOPOCO : {66{1'b0}};
wire [65:0] INPUT_1_DIV = (FPU_OPERATION == `DIV) ? INPUT_1_FLOPOCO : {66{1'b0}};
wire [65:0] INPUT_2_DIV = (FPU_OPERATION == `DIV) ? INPUT_2_FLOPOCO : {66{1'b0}};
wire [65:0] INPUT_SQRT = (FPU_OPERATION == `SQRT) ? INPUT_1_FLOPOCO : {66{1'b0}};
wire [63:0] INPUT_1_COMPARE = (FPU_OPERATION == `COMPARE) ? INPUT_1 : {64{1'b0}};
wire [63:0] INPUT_2_COMPARE = (FPU_OPERATION == `COMPARE) ? INPUT_2 : {64{1'b0}};
wire [63:0] INPUT_1_CONVERT = (FPU_OPERATION == `CONVERT) ? INPUT_1 : {64{1'b0}};
wire [63:0] INPUT_2_CONVERT = (FPU_OPERATION == `CONVERT) ? INPUT_2 : {64{1'b0}};
wire [63:0] INPUT_TRANSFER = (FPU_OPERATION == `TRANSFER) ? INPUT_1 : {64{1'b0}};
wire [63:0] INPUT_1_IEEE_FPC_SP = ((SP_DP == `SP) | (FPU_OPERATION == `ADD) | (FPU_OPERATION == `MULT) | (FPU_OPERATION == `DIV) | (FPU_OPERATION == `SQRT) | (FPU_OPERATION == `FUSED_MULT_ADD)) ? INPUT_1 : {64{1'b0}};
wire [63:0] INPUT_2_IEEE_FPC_SP = ((SP_DP == `SP) | (FPU_OPERATION == `ADD) | (FPU_OPERATION == `MULT) | (FPU_OPERATION == `DIV) | (FPU_OPERATION == `SQRT) | (FPU_OPERATION == `FUSED_MULT_ADD)) ? INPUT_2 : {64{1'b0}};
wire [63:0] INPUT_3_IEEE_FPC_SP = ((SP_DP == `SP) | (FPU_OPERATION == `ADD) | (FPU_OPERATION == `MULT) | (FPU_OPERATION == `DIV) | (FPU_OPERATION == `SQRT) | (FPU_OPERATION == `FUSED_MULT_ADD)) ? INPUT_3 : {64{1'b0}};
wire [63:0] INPUT_1_IEEE_FPC_DP = ((SP_DP == `DP) | (FPU_OPERATION == `ADD) | (FPU_OPERATION == `MULT) | (FPU_OPERATION == `DIV) | (FPU_OPERATION == `SQRT) | (FPU_OPERATION == `FUSED_MULT_ADD)) ? INPUT_1 : {64{1'b0}};
wire [63:0] INPUT_2_IEEE_FPC_DP = ((SP_DP == `DP) | (FPU_OPERATION == `ADD) | (FPU_OPERATION == `MULT) | (FPU_OPERATION == `DIV) | (FPU_OPERATION == `SQRT) | (FPU_OPERATION == `FUSED_MULT_ADD)) ? INPUT_2 : {64{1'b0}};
wire [63:0] INPUT_3_IEEE_FPC_DP = ((SP_DP == `DP) | (FPU_OPERATION == `ADD) | (FPU_OPERATION == `MULT) | (FPU_OPERATION == `DIV) | (FPU_OPERATION == `SQRT) | (FPU_OPERATION == `FUSED_MULT_ADD)) ? INPUT_3 : {64{1'b0}};


always @ (*) begin
    if (RST) begin
        OUTPUT <= {64{1'b0}};
        INVALID <= 1'b0;
        DIVIDE_BY_ZERO <= 1'b0;
        OVERFLOW <= 1'b0;
        UNDERFLOW <= 1'b0;
        INEXACT <= 1'b0;    
    end
    else begin
        OUTPUT <= OUTPUT_int;
        INVALID <= INVALID_int;
        DIVIDE_BY_ZERO <= DIVIDE_BY_ZERO_int;
        OVERFLOW <= OVERFLOW_int;
        UNDERFLOW <= UNDERFLOW_int;
        INEXACT <= INEXACT_int;   
    end
end





always @(*) begin
    case(FPU_OPERATION)
        `ADD : begin
            OUTPUT_int = OUTPUT_IEEE;
            OUTPUT_FPC_IEEE = OUTPUT_ADD;
        end
        
        `MULT : begin
            OUTPUT_int = OUTPUT_IEEE;   
            OUTPUT_FPC_IEEE = OUTPUT_MULT;   
        end
        
        `DIV : begin
            OUTPUT_int = OUTPUT_IEEE;     
            OUTPUT_FPC_IEEE = OUTPUT_DIV; 
        end
        
        `SQRT : begin
            OUTPUT_int = OUTPUT_IEEE;    
            OUTPUT_FPC_IEEE = OUTPUT_SQRT; 
        end
        
        `COMPARE : begin
            OUTPUT_int = OUTPUT_COMPARE;  
            OUTPUT_FPC_IEEE = {66{1'b0}};
        end
        
        `CONVERT : begin
            OUTPUT_int = OUTPUT_CONVERT; 
            OUTPUT_FPC_IEEE = {66{1'b0}};       
        end
        
        `FUSED_MULT_ADD : begin
            OUTPUT_int = OUTPUT_IEEE; 
            OUTPUT_FPC_IEEE = OUTPUT_FUSED_MULT_ADD;  
        end
        
        `TRANSFER : begin
            OUTPUT_int = {{32{1'b0}},OUTPUT_TRANSFER}; 
            OUTPUT_FPC_IEEE = {66{1'b0}};       
        end
                
        default: begin
            OUTPUT_int = {64{1'b0}};  
            OUTPUT_FPC_IEEE = {66{1'b0}};      
        end
    endcase
end

always @(*) begin
    case(FPU_OPERATION)
        `ADD : begin
            INVALID_int <= INVALID_ADD;
            DIVIDE_BY_ZERO_int <= 1'b0;
            OVERFLOW_int <= OVERFLOW_ADD;
            UNDERFLOW_int <= UNDERFLOW_ADD;
            INEXACT_int <= INEXACT_ADD;
        end
        
        `MULT : begin
            INVALID_int <= INVALID_MULT;
            DIVIDE_BY_ZERO_int <= 1'b0;
            OVERFLOW_int <= OVERFLOW_MULT;
            UNDERFLOW_int <= UNDERFLOW_MULT;
            INEXACT_int <= INEXACT_MULT;            
        end
        
        `DIV : begin
            INVALID_int <= INVALID_DIV;
            DIVIDE_BY_ZERO_int <= DIVIDE_BY_ZERO_DIV;
            OVERFLOW_int <= OVERFLOW_DIV;
            UNDERFLOW_int <= UNDERFLOW_DIV;
            INEXACT_int <= INEXACT_DIV;  
        end
        
        `SQRT : begin
            INVALID_int <= INVALID_SQRT;
            DIVIDE_BY_ZERO_int <= 1'b0;
            OVERFLOW_int <= OVERFLOW_SQRT;
            UNDERFLOW_int <= UNDERFLOW_SQRT;
            INEXACT_int <= INEXACT_SQRT;    
        end
        
        `COMPARE : begin
            INVALID_int <= INVALID_COMPARE;
            DIVIDE_BY_ZERO_int <= 1'b0;
            OVERFLOW_int <= 1'b0;
            UNDERFLOW_int <= 1'b0;
            INEXACT_int <= 1'b0;   
        end
        
        `CONVERT : begin
            INVALID_int <= INVALID_CONVERT;
            DIVIDE_BY_ZERO_int <= 1'b0;
            OVERFLOW_int <= OVERFLOW_CONVERT;
            UNDERFLOW_int <= UNDERFLOW_CONVERT;
            INEXACT_int <= INEXACT_CONVERT;          
        end
        
        `FUSED_MULT_ADD : begin
            INVALID_int <= INVALID_MULT | INVALID_ADD;
            DIVIDE_BY_ZERO_int <= 1'b0;
            OVERFLOW_int <= OVERFLOW_ADD;
            UNDERFLOW_int <= UNDERFLOW_ADD;
            INEXACT_int <= INEXACT_ADD | INEXACT_MULT;    
        end
        
        `TRANSFER : begin
            INVALID_int <= 1'b0;
            DIVIDE_BY_ZERO_int <= 1'b0;
            OVERFLOW_int <= 1'b0;
            UNDERFLOW_int <= 1'b0;
            INEXACT_int <= 1'b0;       
        end
                
        default: begin
            INVALID_int <= 1'b0;
            DIVIDE_BY_ZERO_int <= 1'b0;
            OVERFLOW_int <= 1'b0;
            UNDERFLOW_int <= 1'b0;
            INEXACT_int <= 1'b0;       
        end
    endcase
end




ADD fpu_add(    .INPUT_1(INPUT_1_ADD), 
                .INPUT_2(INPUT_2_ADD), 
                .Rounding_Mode(Rounding_Mode), 
                .SP_DP(SP_DP), 
                .ADD_SUB(FPU_SUB_OPERATION[0]), 
                .OUTPUT(OUTPUT_ADD),
                .INVALID(INVALID_ADD),
                .OVERFLOW(OVERFLOW_ADD),
                .UNDERFLOW(UNDERFLOW_ADD),
                .INEXACT(INEXACT_ADD));
                
MULT fpu_mult(  .INPUT_1(INPUT_1_MULT), 
                .INPUT_2(INPUT_2_MULT), 
                .Rounding_Mode(Rounding_Mode), 
                .SP_DP(SP_DP),
                .OUTPUT(OUTPUT_MULT),
                .INVALID(INVALID_MULT),
                .OVERFLOW(OVERFLOW_MULT),
                .UNDERFLOW(UNDERFLOW_MULT),
                .INEXACT(INEXACT_MULT));
                
DIV fpu_div(    .INPUT_1(INPUT_1_DIV), 
                .INPUT_2(INPUT_2_DIV), 
                .Rounding_Mode(Rounding_Mode), 
                .SP_DP(SP_DP),
                .OUTPUT(OUTPUT_DIV),
                .INVALID(INVALID_DIV),
                .DIVIDE_BY_ZERO(DIVIDE_BY_ZERO_DIV),
                .OVERFLOW(OVERFLOW_DIV),
                .UNDERFLOW(UNDERFLOW_DIV),
                .INEXACT(INEXACT_DIV));               

SQRT fpu_sqrt(  .INPUT(INPUT_SQRT),
                .Rounding_Mode(Rounding_Mode), 
                .SP_DP(SP_DP),
                .OUTPUT(OUTPUT_SQRT),
                .INVALID(INVALID_SQRT),
                .OVERFLOW(OVERFLOW_SQRT),
                .UNDERFLOW(UNDERFLOW_SQRT),
                .INEXACT(INEXACT_SQRT)); 

COMPARE fpu_compare(    .INPUT_1(INPUT_1_COMPARE), 
                        .INPUT_2(INPUT_2_COMPARE),  
                        .SP_DP(SP_DP),
                        .OPERATION(FPU_SUB_OPERATION),
                        .OUTPUT(OUTPUT_COMPARE),
                        .INVALID(INVALID_COMPARE));    

CONVERT fpu_convert(    .INPUT_1(INPUT_1_CONVERT), 
                        .INPUT_2(INPUT_2_CONVERT),
                        .Rounding_Mode(Rounding_Mode),   
                        .SP_DP(SP_DP),
                        .OPERATION(FPU_SUB_OPERATION),
                        .OUTPUT(OUTPUT_CONVERT),
                        .INVALID(INVALID_CONVERT),
                        .OVERFLOW(OVERFLOW_CONVERT),
                        .UNDERFLOW(UNDERFLOW_CONVERT),
                        .INEXACT(INEXACT_CONVERT));

TRANSFER fpu_transfer(  .INPUT(INPUT_TRANSFER),
                        .SP_DP(SP_DP),
                        .OPERATION(FPU_SUB_OPERATION),
                        .OUTPUT(OUTPUT_TRANSFER));
                        
IEEE_TO_FLOPOCO_DP fpu_ieee_to_flopoco_dp_1(.X(INPUT_1_IEEE_FPC_DP),
                                            .R(INPUT_1_FLOPOCO_DP));
                                            
IEEE_TO_FLOPOCO_SP fpu_ieee_to_flopoco_sp_1(.X(INPUT_1_IEEE_FPC_SP[31:0]),
                                            .R(INPUT_1_FLOPOCO_SP[33:0]));
                                            
IEEE_TO_FLOPOCO_DP fpu_ieee_to_flopoco_dp_2(.X(INPUT_2_IEEE_FPC_DP),
                                            .R(INPUT_2_FLOPOCO_DP));
                                            
IEEE_TO_FLOPOCO_SP fpu_ieee_to_flopoco_sp_2(.X(INPUT_2_IEEE_FPC_SP[31:0]),
                                            .R(INPUT_2_FLOPOCO_SP[33:0]));
                                            
IEEE_TO_FLOPOCO_DP fpu_ieee_to_flopoco_dp_3(.X(INPUT_3_IEEE_FPC_DP),
                                            .R(INPUT_3_FLOPOCO_DP));
                                            
IEEE_TO_FLOPOCO_SP fpu_ieee_to_flopoco_sp_3(.X(INPUT_3_IEEE_FPC_SP[31:0]),
                                            .R(INPUT_3_FLOPOCO_SP[33:0]));

FLOPOCO_TO_IEEE_DP fpu_flopoco_to_ieee_dp(  .X(OUTPUT_FPC_IEEE),
                                            .R(OUTPUT_IEEE_DP));
                                            
FLOPOCO_TO_IEEE_SP fpu_flopoco_to_ieee_sp(  .X(OUTPUT_FPC_IEEE[33:0]),
                                            .R(OUTPUT_IEEE_SP[31:0]));
                                            

                                            
endmodule
