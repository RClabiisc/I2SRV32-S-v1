`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module ADD
(
    input [65:0] INPUT_1,
    input [65:0] INPUT_2,
    input [2:0] Rounding_Mode,
    input SP_DP,
    input ADD_SUB, 
    output reg [65:0] OUTPUT,
    output reg INVALID,
    output reg OVERFLOW,
    output reg UNDERFLOW,
    output reg INEXACT
);

wire [65:0] INPUT_1_DP;
wire [65:0] INPUT_2_DP;
wire [65:0] INPUT_2_DP_NEG;
wire [65:0] OUTPUT_DP;
wire [33:0] INPUT_1_SP;
wire [33:0] INPUT_2_SP;
wire [33:0] INPUT_2_SP_NEG;
wire [33:0] OUTPUT_SP;

wire INEXACT_SP;
wire INEXACT_DP;

assign INPUT_1_SP = SP_DP ? 34'b0000000000000000000000000000000000 : INPUT_1[33:0];
assign INPUT_2_SP = SP_DP ? 34'b0000000000000000000000000000000000 : INPUT_2[33:0];
assign INPUT_2_SP_NEG = SP_DP ? 34'b0000000000000000000000000000000000 : {INPUT_2_SP[33:32] , INPUT_2_SP[31]^1'b1 ,  INPUT_2_SP[30:0]};

assign INPUT_1_DP = SP_DP ? INPUT_1 : 66'b000000000000000000000000000000000000000000000000000000000000000000;
assign INPUT_2_DP = SP_DP ? INPUT_2 : 66'b000000000000000000000000000000000000000000000000000000000000000000;
assign INPUT_2_DP_NEG = SP_DP ? {INPUT_2[65:64] , INPUT_2[63]^1'b1 ,  INPUT_2[62:0]} : 66'b000000000000000000000000000000000000000000000000000000000000000000;



(* keep_hierarchy = "yes" *) FPAdd_8_23_comb_uid2 FPADD_SP( .X(INPUT_1_SP), .Y(ADD_SUB ? INPUT_2_SP_NEG : INPUT_2_SP), .RM(Rounding_Mode), .R(OUTPUT_SP), .INEXACT(INEXACT_SP));

(* keep_hierarchy = "yes" *) FPAdd_11_52_comb_uid2 FPADD_DP( .X(INPUT_1_DP), .Y(ADD_SUB ? INPUT_2_DP_NEG : INPUT_2_DP), .RM(Rounding_Mode), .R(OUTPUT_DP), .INEXACT(INEXACT_DP));


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
    endcase
end


wire [1:0] IN_1_EXC_BITS = SP_DP ? INPUT_1[65:64] : INPUT_1[33:32];
wire [1:0] IN_2_EXC_BITS = SP_DP ? INPUT_2[65:64] : INPUT_2[33:32];

wire IN_1_SNAN_BIT = SP_DP ? INPUT_1[51] : INPUT_1[22];
wire IN_2_SNAN_BIT = SP_DP ? INPUT_2[51] : INPUT_2[22];

wire IN_1_SIGN = SP_DP ? INPUT_1[63] : INPUT_1[31];
wire IN_2_SIGN = SP_DP ? INPUT_2[63] : INPUT_2[31];

always @(*) begin
    
    if (((IN_1_EXC_BITS == 2'b11) && (IN_1_SNAN_BIT == 1'b0)) || ((IN_2_EXC_BITS == 2'b11) && (IN_2_SNAN_BIT == 1'b0))) begin
        INVALID <= 1'b1;
    end
    else if ((IN_1_EXC_BITS == 2'b10) && (IN_2_EXC_BITS == 2'b10)) begin
        if (ADD_SUB == 1'b1) begin
            INVALID <= ((IN_1_SIGN == IN_2_SIGN)) ? 1'b1 : 1'b0;
        end
        else begin
            INVALID <= ((IN_1_SIGN != IN_2_SIGN)) ? 1'b1 : 1'b0;
        end
    end
    else begin
        INVALID <= 1'b0;
    end
    
end

endmodule
