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

`define BPU_ENABLE 1
//`undef BPU_ENABLE


module Branch_Prediction_Unit
(
    input CLK,
    input RST,
    input [31:0] PC,
    
    input BPU__Stall,
    
    output reg Branch_Taken,
    output reg [31:0] Branch_Target_Addr,
    output BTB_Hit,
    
    output [10:0] PHT_Read_Index, 
    output [1:0] PHT_Read_Data,
    
    input [10:0] PHT_Write_Index,
    input [1:0] PHT_Write_Data,
    input PHT_Write_En,
    
    input GHR_Write_Data,
    input GHR_Write_En,
    
    input [31:0] BTB_Write_Addr,
    input [31:0] BTB_Write_Data,
    input BTB_Write_En,
    
    input RAS_RET_Inst_EX,
    input RAS_CALL_Inst,
    input [31:0] RAS_CALL_Inst_nextPC,
    
    input Branch_Taken__EX_MEM,
    
    input PC_Control__IRQ
);

wire Branch_Taken__DP;
wire [31:0] Branch_Target_Addr__BTB;
wire [31:0] Branch_Target_Addr__RAS;
wire RET_Inst__RAS;
wire RET_Addr_Valid__RAS;

assign RET_Inst__RAS = (Branch_Target_Addr__BTB[1:0] == 2'b11) ? 1'b1 : 1'b0;

`ifdef BPU_ENABLE
always @(*) begin
    if (RST) begin
        Branch_Taken <= 1'b0;
        Branch_Target_Addr <= 32'b0;
    end
    else begin
        if (PC_Control__IRQ == 1'b1) begin
            Branch_Taken <= 1'b0;
            Branch_Target_Addr <= 32'b0;
        end
        //next instruction when branch and jal and jalr.
        else if (Branch_Target_Addr__BTB[1:0] == 2'b00) begin
            Branch_Taken <= (Branch_Taken__DP & BTB_Hit) ? 1'b1 : 1'b0;
            Branch_Target_Addr <= {Branch_Target_Addr__BTB[31:2],2'b00};
        end 
        else if (Branch_Target_Addr__BTB[1:0] == 2'b01) begin
            Branch_Taken <= (BTB_Hit) ? 1'b1 : 1'b0;
            Branch_Target_Addr <= {Branch_Target_Addr__BTB[31:2],2'b00};
        end
        else if (Branch_Target_Addr__BTB[1:0] == 2'b10) begin
            Branch_Taken <= (BTB_Hit) ? 1'b1 : 1'b0;
            Branch_Target_Addr <= {Branch_Target_Addr__BTB[31:2],2'b00};
        end
        else if (Branch_Target_Addr__BTB[1:0] == 2'b11) begin//for jalr type
            Branch_Taken <= (BTB_Hit & RET_Addr_Valid__RAS) ? 1'b1 : 1'b0;
            Branch_Target_Addr <= {Branch_Target_Addr__RAS[31:2],2'b00};
        end
        else begin
            Branch_Taken <= 1'b0;
            Branch_Target_Addr <= 32'b0;
        end   
    end
end
`else
always @(*) begin
    if (RST) begin
        Branch_Taken <= 1'b0;
        Branch_Target_Addr <= 32'b0;
    end
    else begin
        Branch_Taken <= 1'b0;
        Branch_Target_Addr <= 32'b0;
    end
end
`endif


Direction_Predictor DP( .CLK(CLK),                           
                        .RST(RST),                           
                        .PC(PC), 
                        .BPU__Stall(BPU__Stall),                    
                        .Branch_Taken(Branch_Taken__DP),             
                        .PHT_Read_Index(PHT_Read_Index),    
                        .PHT_Read_Data(PHT_Read_Data),      
                        .PHT_Write_Index(PHT_Write_Index),        
                        .PHT_Write_Data(PHT_Write_Data),          
                        .PHT_Write_En(PHT_Write_En),                  
                        .GHR_Write_Data(GHR_Write_Data),                
                        .GHR_Write_En(GHR_Write_En));   
                        
                        
                        
Branch_Target_Buff BTB( .CLK(CLK),                        
                        .RST(RST),    
                        .BPU__Stall(BPU__Stall),                       
                        .BTB_Read_Addr(PC),     
                        .BTB_Read_Data(Branch_Target_Addr__BTB),
                        .BTB_Hit(BTB_Hit),             
                        .BTB_Write_Addr(BTB_Write_Addr),    
                        .BTB_Write_Data(BTB_Write_Data),    
                        .BTB_Write_En(BTB_Write_En));              

Return_Addr_Stack RAS( .CLK(CLK),
                       .RST(RST), 
                       .BPU__Stall(BPU__Stall),
                       .RET_Inst(RET_Inst__RAS), 
                       .RET_Target_Addr(Branch_Target_Addr__RAS), 
                       .RET_Addr_Valid(RET_Addr_Valid__RAS),
                       .RET_Inst_EX(RAS_RET_Inst_EX), 
                       .CALL_Inst(RAS_CALL_Inst), 
                       .CALL_Inst_nextPC(RAS_CALL_Inst_nextPC),
                       .Branch_Taken__EX_MEM(Branch_Taken__EX_MEM)); 
                       
endmodule 

 
