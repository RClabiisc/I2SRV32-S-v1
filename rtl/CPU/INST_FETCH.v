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
`include "defines.v"

module INST_FETCH
(
    input CLK,
    input RST,

    input Branch_Taken__EX_MEM,                         //Branch decision calculated in EX stage from EX_MEM stage
    input Branch_Taken__MEM_WB,
    input [31:0] Branch_Target_Addr__EX_MEM,            //Branch Addr calculated in EX stage from EX_MEM stage
    
    input BPU__Branch_Taken__IF_ID,
    input [31:0] BPU__Branch_Target_Addr__IF_ID,
    
    input [31:0] CSR_mtvec,                             //Machine Trap-Vector Base-Address Register (mtvec)
    
    input Load__Stall,                                  //For dependancy between load and ALU instruction stall                                                                       
    
    input IF_ID_Freeze,                                 //To freeze the IF_ID stage
    
    input PC_Control__IRQ,                              //Sets PC to interrupt vector address
    
    input [5:0] Device_id,                              //                                                                      ********    
    
    output reg [31:0] PC__IF_ID,                        //PC output for IF_ID stage
    output reg [31:0] PC_4__IF_ID,                      //PC + 4 output for IF_ID stage
    
    output reg NOP__IF_ID,                              // NOP for IF_ID stage
    
    output  [31:0] pc,
    
    `ifdef itlb_def
    output reg vpn_to_ppn_req1
    `endif
    
    
);


parameter isr_inst_count = 3;  //for n instruction (log2(n) + 2)


wire [31:0] pc4;
reg [31:0] pc_reg;
wire [31:0] ISR_ADDRESS;


assign  pc = ((~PC_Control__IRQ) & (~Branch_Taken__MEM_WB) & BPU__Branch_Taken__IF_ID) ? BPU__Branch_Target_Addr__IF_ID : pc_reg;    //Load__Stall and IRQ functioning

assign ISR_ADDRESS = CSR_mtvec + ( Device_id << isr_inst_count );

assign  pc4 = pc + 32'd4;


always @(posedge CLK or posedge RST) begin
    if(RST) begin
        PC__IF_ID <= 32'b00;
    end
    else begin
        if(Branch_Taken__EX_MEM) begin
            PC__IF_ID <= Branch_Target_Addr__EX_MEM;
        end
        else if(~IF_ID_Freeze) begin
            PC__IF_ID <= pc; 
        end
    end
end



`ifdef itlb_def
always @(posedge CLK ) begin
    if(RST) begin
        pc_reg <= 32'b00;
        vpn_to_ppn_req1 <= 1'b1;
    end
    else if(~IF_ID_Freeze) begin
        pc_reg <= (Branch_Taken__EX_MEM ? Branch_Target_Addr__EX_MEM : pc4);
        vpn_to_ppn_req1 <= 1'b1;
    end
    else if(PC_Control__IRQ) begin
        pc_reg <=  ISR_ADDRESS;
        vpn_to_ppn_req1 <= 1'b0;
    end
    else begin
        vpn_to_ppn_req1 <= 1'b0;
    end
end
`else
always @(posedge CLK or posedge RST) begin
    if(RST) begin
        pc_reg <= 32'b00;
    end
    else begin
        if(~IF_ID_Freeze) begin
            pc_reg <= (Branch_Taken__EX_MEM ? Branch_Target_Addr__EX_MEM : (Load__Stall ? (pc_reg - 32'd4) : pc4));
        end
    end
end
`endif


always @(posedge RST or posedge CLK)
begin
    if(RST) begin
        PC_4__IF_ID <= 32'h4;
        NOP__IF_ID <= 1'b0;
    end
    else if(PC_Control__IRQ)
        NOP__IF_ID <= 1'b0;    
    else if(~IF_ID_Freeze) begin
        PC_4__IF_ID <= Load__Stall ? pc : pc4;
        NOP__IF_ID <= Branch_Taken__EX_MEM;
    end
end
endmodule
