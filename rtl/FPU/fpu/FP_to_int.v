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

module FP_to_int
(
    input [63:0] INPUT,
    input SP_DP,
    input Signed_Unsigned,
    input [2:0] Rounding_Mode,
    output reg [31:0] OUTPUT,
    output reg INVALID,
    output reg OVERFLOW,                        
    output reg UNDERFLOW
    
);

wire [7:0] Zero_Exp_SP = {7{1'b1}};
wire [10:0] Zero_Exp_DP = {10{1'b1}};

wire sign;	
assign sign = SP_DP ? INPUT[63] : INPUT[31];

wire [7:0] exp_SP = INPUT[30:23];	
wire [10:0] exp_DP = INPUT[62:52];	

wire [23:0] man_SP = {exp_SP!=0,INPUT[22:0]};
wire [52:0] man_DP = {exp_DP!=0,INPUT[51:0]};	

wire INPUT_NaN = SP_DP ? ((&exp_DP) & (|INPUT[51:0])) : ((&exp_SP) & (|INPUT[22:0]));

wire [31:0] Max_Int_Signed  = (sign & ~INPUT_NaN) ? 32'b10000000000000000000000000000000 : 32'b01111111111111111111111111111111;
wire [31:0] Max_Int_Unsigned  = (sign & ~INPUT_NaN) ? 32'b00000000000000000000000000000000 : 32'b11111111111111111111111111111111;


wire INPUT_zero_SP = INPUT[30:0]==0;
wire INPUT_zero_DP = INPUT[62:0]==0;	

always @(*) begin
    if (INPUT_NaN == 1'b0) begin
        if(SP_DP==1) begin
            if(Signed_Unsigned==1) begin
                OVERFLOW  <= sign ?  1'b1 : exp_DP > (Zero_Exp_DP + 31);	
            end	
            else begin
                OVERFLOW  <= exp_DP > (Zero_Exp_DP + 30);
            end
            UNDERFLOW <= exp_DP < Zero_Exp_DP - 1;	
        end
        else begin
            if(Signed_Unsigned==1) begin
                OVERFLOW  <= sign ? 1'b1 : exp_SP > (Zero_Exp_SP + 31);	    
            end    
            else begin
                OVERFLOW  <= exp_SP > (Zero_Exp_SP + 30);	
            end	
            UNDERFLOW <= exp_SP < Zero_Exp_SP - 1;   
        end
    end
    else begin
        OVERFLOW  <= 1'b0;
        UNDERFLOW <= 1'b0;
    end
end				

always @(*) begin
    
    if ((INPUT_NaN == 1'b1) || (OVERFLOW == 1'b1) || (UNDERFLOW == 1'b1)) begin
        INVALID <= 1'b1;
    end
    else begin
        INVALID <= 1'b0;
    end
end

reg Add_Rounding_Bit;

wire [5:0] shift_SP = (31 - (exp_SP - Zero_Exp_SP));
wire [6:0] shift_DP = (63 - (exp_DP - Zero_Exp_DP));

wire [34:0] o1_SP = {man_SP,{8{1'b0}},3'b0} >> shift_SP;	
wire [31:0] o2_SP = o1_SP[34:3] + Add_Rounding_Bit;	

wire [34:0] o1_DP = {man_DP,{11{1'b0}},3'b0} >> shift_DP;	
wire [31:0] o2_DP = o1_DP[34:3] + Add_Rounding_Bit;	

wire LSB = o1_DP[3];
wire Guard = o1_DP[2];          
wire Round = o1_DP[1];
wire Sticky = o1_DP[0];


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



always @(*) begin
    if (SP_DP == 1) begin
        if (UNDERFLOW | INPUT_zero_DP)
            OUTPUT <= 0;
        else if (OVERFLOW | INPUT_NaN)
            if(Signed_Unsigned == 1)
                OUTPUT <= Max_Int_Unsigned;
            else
                OUTPUT <= Max_Int_Signed;
        else if (exp_DP==Zero_Exp_DP-1)
            OUTPUT <= 0;
        else
            if(Signed_Unsigned==1) begin
                OUTPUT <= o2_DP; 
            end    
            else begin
                OUTPUT <= sign ? -o2_DP : o2_DP;
            end
    end
    else begin
        if (UNDERFLOW | INPUT_zero_SP)
            OUTPUT <= 0;
        else if (OVERFLOW | INPUT_NaN)
            if(Signed_Unsigned == 1)
                OUTPUT <= Max_Int_Unsigned;
            else
                OUTPUT <= Max_Int_Signed;
        else if (exp_SP==Zero_Exp_SP-1)
            OUTPUT <= 0;
        else
            if(Signed_Unsigned==1) begin
                OUTPUT <= o2_SP; 
            end    
            else begin
                OUTPUT <= sign ? -o2_SP : o2_SP;
            end
    end
end
		
					


endmodule