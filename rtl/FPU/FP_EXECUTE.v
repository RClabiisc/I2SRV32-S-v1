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

`define ADD 3'b000
`define MULT 3'b001
`define DIV 3'b010
`define SQRT 3'b011
`define COMPARE 3'b100
`define CONVERT 3'b101
`define FUSED_MULT_ADD 3'b110
`define TRANSFER 3'b111


(* keep_hierarchy = "yes" *) module FP_EXECUTE
(
    input RST,
    input CLK,
    
    // Input for forwarding unit
    input FP__Forward_RS1_MEM__ID_EX,
    input FP__Forward_RS2_MEM__ID_EX,
    input FP__Forward_RS3_MEM__ID_EX,
    input FP__Forward_RS1_WB__ID_EX,
    input FP__Forward_RS2_WB__ID_EX,
    input FP__Forward_RS3_WB__ID_EX,
    input FP__Forward_RS1_MEM_Int__ID_EX,
    input FP__Forward_RS1_WB_Int__ID_EX,
    input FP__Forward_RS1_MEM_Int_FP__ID_EX,              
    input FP__Forward_RS1_WB_Int_FP__ID_EX,   
    
    input [63:0] FP__RD_Data__EX_MEM,
    input [63:0] FP__RD_Data__MEM_WB,
    input [31:0] RD_Data__EX_MEM,                       //MEM stage RD data for forwarding from EX_MEM stage
    input [31:0] RD_Data__MEM_WB,                       //WB stage RD data for forwarding from MEM_WB stage
    input [31:0] FP__RD_Data_Int__EX_MEM,                       
    input [31:0] FP__RD_Data_Int__MEM_WB,                       
        
        
    // Input Control signals from ID stage
    input [2:0] FP__Fpu_Operation__ID_EX,
    input [2:0] FP__Fpu_Sub_Op__ID_EX,
    input [2:0] FP__Rounding_Mode__ID_EX, 
    input FP__SP_DP__ID_EX,
    input FP__Fpu_Inst__ID_EX,
    input [63:0] FP__RS1_Data__ID_EX,
    input [63:0] FP__RS2_Data__ID_EX,
    input [63:0] FP__RS3_Data__ID_EX,
    input [63:0] FP__Store_Data__ID_EX,
    output reg [63:0] FP__Store_Data__ex_mem,
    input FP__Load_Inst__ID_EX, 
    input FP__Store_Inst__ID_EX,
    output reg FP__Load_Inst__ex_mem, 
    output reg FP__Store_Inst__ex_mem,
    // Output write back data
    output reg [63:0] FP__RD_Data__ex_mem,
    output reg [31:0] FP__RD_Data_Int__ex_mem,
    
    
    input Branch_Taken__EX_MEM,                                     //Branch decision calculated in EX stage from EX_MEM stage
    
    
    input [4:0] FP__RD_Addr__ID_EX,
    input FP__Reg_Write_En__ID_EX,
    input [4:0] FP__RD_Addr_Int__ID_EX,
    input FP__Reg_Write_En_Int__ID_EX,
    output reg [4:0] FP__RD_Addr__ex_mem,
    output reg FP__Reg_Write_En__ex_mem,
    output reg [4:0] FP__RD_Addr_Int__ex_mem,
    output reg FP__Reg_Write_En_Int__ex_mem,
    
    output reg FP__SP_DP__ex_mem,
    
    
    
    // FPU stall signal
    output reg FPU__Stall,
    input FPU_Freeze,
    input FPU__Stall_disable,
    
    input Inst_Cache__Stall__reg,
    input Inst_Cache__Stall,
    
    input [2:0] frm,
    output [4:0] FPU_flags
);


wire [63:0] FP_source_1_int;
wire [63:0] FP_source_2_int;
wire [63:0] FP_source_3_int; 
wire [63:0] FP_Store_Data_int;                        

wire [63:0] OUTPUT;
wire INVALID;
wire DIVIDE_BY_ZERO;
wire OVERFLOW;
wire UNDERFLOW;
wire INEXACT;

reg [3:0] COUNT;
reg Counter_Reset;
reg Counter_Start;

reg [3:0] Operation_COUNT;

reg [63:0] OUTPUT__reg;

assign FP_source_1_int = (FP__Forward_RS1_MEM__ID_EX)     ? FP__RD_Data__EX_MEM          : 
                         (FP__Forward_RS1_WB__ID_EX)      ? FP__RD_Data__MEM_WB          : 
                         (FP__Forward_RS1_MEM_Int__ID_EX) ? {{32{1'b0}},RD_Data__EX_MEM} :
                         (FP__Forward_RS1_WB_Int__ID_EX)  ? {{32{1'b0}},RD_Data__MEM_WB} : 
                         (FP__Forward_RS1_MEM_Int_FP__ID_EX) ? {{32{1'b0}},FP__RD_Data_Int__EX_MEM} :
                         (FP__Forward_RS1_WB_Int_FP__ID_EX)  ? {{32{1'b0}},FP__RD_Data_Int__MEM_WB} : FP__RS1_Data__ID_EX;
                         
assign FP_source_2_int = (FP__Forward_RS2_MEM__ID_EX) ? FP__RD_Data__EX_MEM : 
                         (FP__Forward_RS2_WB__ID_EX)  ? FP__RD_Data__MEM_WB : FP__RS2_Data__ID_EX;
                         
assign FP_source_3_int = (FP__Forward_RS3_MEM__ID_EX) ? FP__RD_Data__EX_MEM : 
                         (FP__Forward_RS3_WB__ID_EX)  ? FP__RD_Data__MEM_WB : FP__RS3_Data__ID_EX;   
                         
assign FP_Store_Data_int = (FP__Forward_RS2_MEM__ID_EX) ? FP__RD_Data__EX_MEM : 
                           (FP__Forward_RS2_WB__ID_EX)  ? FP__RD_Data__MEM_WB : FP__Store_Data__ID_EX;
                           
assign FPU_flags = {INVALID,DIVIDE_BY_ZERO,OVERFLOW,UNDERFLOW,INEXACT};                           

always @(*) begin
    if(RST | Branch_Taken__EX_MEM) begin
        FP__RD_Data__ex_mem <= {64{1'b0}};
        FP__RD_Data_Int__ex_mem <= {32{1'b0}};
        
        FP__Store_Data__ex_mem <= {64{1'b0}};
        FP__Load_Inst__ex_mem <= 1'b0;  
        FP__Store_Inst__ex_mem <= 1'b0; 
        
        FP__RD_Addr__ex_mem <= 5'b0;    
        FP__Reg_Write_En__ex_mem <= 1'b0;     
        FP__RD_Addr_Int__ex_mem <= 5'b0;
        FP__Reg_Write_En_Int__ex_mem <= 1'b0;
        
        FP__SP_DP__ex_mem <= 1'b0;
    end
    else begin
        FP__RD_Data__ex_mem <= FP__Reg_Write_En_Int__ID_EX ? {64{1'b0}} : ((Inst_Cache__Stall__reg == 1'b1) ? OUTPUT__reg : OUTPUT);
        FP__RD_Data_Int__ex_mem <= FP__Reg_Write_En_Int__ID_EX ? ((Inst_Cache__Stall__reg == 1'b1) ? OUTPUT__reg[31:0] : OUTPUT[31:0]) : {32{1'b0}};
        
        FP__Store_Data__ex_mem <= FP_Store_Data_int;
        FP__Load_Inst__ex_mem <= FP__Load_Inst__ID_EX;
        FP__Store_Inst__ex_mem <= FP__Store_Inst__ID_EX;
        
        FP__RD_Addr__ex_mem <= FP__RD_Addr__ID_EX;     
        FP__Reg_Write_En__ex_mem <= FP__Reg_Write_En__ID_EX;      
        FP__RD_Addr_Int__ex_mem <= FP__RD_Addr_Int__ID_EX; 
        FP__Reg_Write_En_Int__ex_mem <= FP__Reg_Write_En_Int__ID_EX;  
        
        FP__SP_DP__ex_mem <= FP__SP_DP__ID_EX;
    end
end





always @(*) begin
    case(FP__Fpu_Operation__ID_EX)
        `ADD : begin
            Operation_COUNT <= FP__SP_DP__ID_EX ? 3 : 2;
        end
        
        `MULT : begin
            Operation_COUNT <= FP__SP_DP__ID_EX ? 2 : 1;     
        end
        
        `DIV : begin
            Operation_COUNT <= FP__SP_DP__ID_EX ? 14 : 5;
        end
        
        `SQRT : begin
            Operation_COUNT <= FP__SP_DP__ID_EX ? 11 : 4; 
        end
        
        `COMPARE : begin
            Operation_COUNT <= 0;  
        end
        
        `CONVERT : begin    
            Operation_COUNT = FP__SP_DP__ID_EX ? 1 : 1;    
        end
        
        `FUSED_MULT_ADD : begin
            Operation_COUNT = FP__SP_DP__ID_EX ? 7 : 5;   
        end
        
        `TRANSFER : begin
            Operation_COUNT <= 0;  
        end
                
        default: begin
            Operation_COUNT <= 0;  
        end
    endcase
end

always @ (posedge CLK) begin
    if (RST | Counter_Reset) begin
        COUNT <= 4'b0000;
    end
    else if (Counter_Start & ~FPU_Freeze) begin
        COUNT <= COUNT + 1'b1;
    end
end

always @(*) begin
    if (RST) begin
        Counter_Start <= 1'b0;
        Counter_Reset <= 1'b0;
        FPU__Stall <= 1'b0;
    end
    else begin
        Counter_Start <= FP__Fpu_Inst__ID_EX;
        
        Counter_Reset <= ((COUNT == Operation_COUNT) && (~FPU_Freeze)) ? 1'b1 : 1'b0;
        
        if ((COUNT != Operation_COUNT))
            FPU__Stall <= FPU__Stall_disable ? 1'b0 : FP__Fpu_Inst__ID_EX;    
        else
            FPU__Stall <= 1'b0;
    end
end



always @(posedge CLK) begin
    if(RST) begin
        OUTPUT__reg <= 64'b0;
    end
    else if ((Inst_Cache__Stall__reg == 1'b0) && (Inst_Cache__Stall == 1'b1)) begin
        OUTPUT__reg <= OUTPUT;
    end 
end


FPU Floating_point_unit ( .CLK(CLK), 
                          .RST(RST), 
                          .INPUT_1(FP_source_1_int), 
                          .INPUT_2(FP_source_2_int), 
                          .INPUT_3(FP_source_3_int), 
                          .Rounding_Mode((FP__Rounding_Mode__ID_EX == 3'b111) ? frm : FP__Rounding_Mode__ID_EX), 
                          .FPU_OPERATION(FP__Fpu_Operation__ID_EX), 
                          .FPU_SUB_OPERATION(FP__Fpu_Sub_Op__ID_EX), 
                          .SP_DP(FP__SP_DP__ID_EX),
                          .OUTPUT(OUTPUT), 
                          .INVALID(INVALID), 
                          .DIVIDE_BY_ZERO(DIVIDE_BY_ZERO), 
                          .OVERFLOW(OVERFLOW), 
                          .UNDERFLOW(UNDERFLOW), 
                          .INEXACT(INEXACT));



endmodule
