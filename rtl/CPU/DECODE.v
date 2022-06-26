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

 
module DECODE
(
    input CLK,
    input RST,
    
    input [31:0] Instruction__IF_ID,                //Instruction from IF_ID stage
    
    input [31:0] PC__IF_ID,                         //the PC from IF_ID stage                                       ********
    input [31:0] PC_4__IF_ID,                       //the next instruction PC for storing in jal/jalr instructions from IF_ID stage
    output reg [31:0] pc_forw,                      //program counter sent to execute stage                         *********
    
    output reg [4:0] RS1_Addr__rf,                  //Source Regester - 1  Addr to RF
    output reg [4:0] RS2_Addr__rf,                  //Source Regester - 2  Addr to RF
    input [31:0] RS1_Data__rf,                      //Source Regester - 1  Data from RF
    input [31:0] RS2_Data__rf,                      //Source Regester - 2  Data from RF
    
    output reg Reg_Write_Enable__id_ex,             //Reg write-back control signal to ID_EX stage
    output reg [4:0] RD_Addr__id_ex,                //Destination Register Addr to ID_EX stage
    
    input Reg_Write_Enable__ID_EX,                  //Reg write-back control signal from ID_EX stage
    input Reg_Write_Enable__EX_MEM,                 //Reg write-back control signal from EX_MEM stage
    input [4:0] RD_Addr__ID_EX,                     //Destination Register Addr from ID_EX stage
    input [4:0] RD_Addr__EX_MEM,                    //Destination Register Addr from EX_MEM stage  
    output reg Forward_RS1_MEM__id_ex,              //MEM stage forwarding for RS1 control signal to ID_EX stage
    output reg Forward_RS2_MEM__id_ex,              //MEM stage forwarding for RS2 control signal to ID_EX stage
    output reg Forward_RS1_WB__id_ex,               //WB stage forwarding for rs1 control signal to ID_EX stage  
    output reg Forward_RS2_WB__id_ex,               //WB stage forwarding for rs2 control signal to ID_EX stage
    
    input FP__Reg_Write_En_Int__ID_EX,
    input FP__Reg_Write_En_Int__EX_MEM,
    input [4:0] FP__RD_Addr_Int__ID_EX,
    input [4:0] FP__RD_Addr_Int__EX_MEM,
    output reg Forward_RS1_MEM_FP__id_ex,           //MEM stage forwarding for RS1 control signal to ID_EX stage
    output reg Forward_RS2_MEM_FP__id_ex,           //MEM stage forwarding for RS2 control signal to ID_EX stage
    output reg Forward_RS1_WB_FP__id_ex,            //WB stage forwarding for rs1 control signal to ID_EX stage  
    output reg Forward_RS2_WB_FP__id_ex,            //WB stage forwarding for rs2 control signal to ID_EX stage
    
    
    input Branch_Taken__EX_MEM,                     //Branch decision calculated in EX stage from EX_MEM stage      
    input NOP__IF_ID,                               //Branch decision calculated in EX stage from EX_MEM stage register in IF_ID stage                                          
    
    output reg [4:0] Load_Store_Op__id_ex,          //Load Store Unit Operation to ID_EX stage
    output reg [31:0] Store_Data__id_ex,            //data for store signal to ID_EX stage
    input [4:0] Load_Store_Op__ID_EX,               //previous instruction Load Store Unit Operation from ID_EX stage
    
      
    output reg [1:0] Alu_Src_1_sel__id_ex,          //ALU source 1 select mux signals to ID_EX stage 
    output reg [1:0] Alu_Src_2_sel__id_ex,          //ALU source 2 select mux signals to ID_EX stage
    output reg [6:0] Opcode__id_ex,                 //Instruction[6:0]
    output reg [6:0] Funct7__id_ex,                 //Instruction[31:25]
    output reg [2:0] Funct3__id_ex,                 //Instruction[14:12]
    output reg JAL_Inst__id_ex,                     //Indicates JAL instruction
    output reg JALR_Inst__id_ex,                    //Indicates JALR instruction 
    output reg [31:0] RS1_Data__id_ex,              //Source Regester - 1  Data to ID_EX stage
    output reg [31:0] RS2_Data__id_ex,              //Source Regester - 2  Data to ID_EX stage
    output reg [5:0] Shamt__id_ex,                  //Shamt for alu
    output reg [31:0] Immediate__id_ex,             //immediate for alu
    output reg Branch_Inst__id_ex,                  //Indicates conditional branch instruction 
    output reg AMO_Inst__id_ex,                     //Indicates Atomic Instruction
    output reg [1:0] Mult_Op__id_ex,                //Specify Multiply unit operation
    output reg Mult_En__id_ex,                      //Multiply unit Enable signal
    output reg [1:0] Div_Op__id_ex,                 //Specify Divide unit operation
    output reg Div_En__id_ex,                       //Divide unit Enable signal
    
    output reg Load__Stall_id_ex,                   //For dependancy between load and ALU instruction stall to pipeline                                        
    input Mult_Div_unit__Stall,                     //Multiplier or Divider unit stalls    
   
    input BPU__Branch_Taken__IF_ID,
    input [31:0] BPU__Branch_Target_Addr__IF_ID,
    input [10:0] BPU__PHT_Read_Index__IF_ID,
    input [1:0] BPU__PHT_Read_Data__IF_ID, 
    input BPU__BTB_Hit__IF_ID,   
    output reg BPU__Branch_Taken__id_ex,
    output reg [31:0] BPU__Branch_Target_Addr__id_ex,
    output reg [10:0] BPU__PHT_Read_Index__id_ex,
    output reg [1:0] BPU__PHT_Read_Data__id_ex, 
    output reg BPU__BTB_Hit__id_ex,
    output reg [2:0] Branch_Type__id_ex,    
    
    //////////////////////
    //outputs to data cache 
    output reg [4:0] lsu_op_port2,
    output reg LR_Inst,                             //Indicates Atomic LR Instruction            
    output reg mret,               
    output [11:0] csr_adr,               
    output  csr_wr_en,  
    output  mepc_res,  
    ///////////////////////
    //I/O from the Interrupt controller interface
    input [31:0] inst_inj,          //Injected instruction stream from Interrupt interface
    input irq_ctrl,                 //Mux select line
    input irq_ctrl_wb,              //Write-back stage signal. Whether to use shadow registers for writeback or normal ones.
    output reg irq_ctrl_o,          //Signal to register file and to subsequent stages. For using shadow registers
    /////////////////////////////////////////////
    //Select Line to the system counters
    output reg [3:0] count_sel,     //Counter select lines; For RDCYC[H],RDTIM[H],RDINSTR[H] instructions
    ////////////////////////////////////
    //////////////////////////////////
    output eret,                //Signal the irq interface to jump out of interrupt
    ////////////////
    
    output [31:0] inst_out
);









wire [31:0] inst;

wire adder;
wire rs1_read_op;
wire rs2_read_op;
wire Load__Stall;

wire rs1_mem;
wire rs2_mem;
wire rs1_wb;
wire rs2_wb;

wire [4:0] load_store_op;
wire [4:0] rs1;               //rs1 id
wire [4:0] rs2;               //rs2 id
wire [4:0] rd;                //rd id
wire forw_rs1_mem_int;
wire forw_rs1_wb_int;
wire forw_rs2_mem_int;
wire forw_rs2_wb_int;
wire forw_rs1_mem_fp_int;
wire forw_rs1_wb_fp_int;
wire forw_rs2_mem_fp_int;
wire forw_rs2_wb_fp_int;


//wire forw_rs1_amo_wb_int;
wire c_strt;                    //counter start

reg [4:0] rdarray [0:2];

reg count[5:0];

wire amo;
reg uret;
assign eret = mret;

assign inst = irq_ctrl ? inst_inj : Instruction__IF_ID;
assign inst_out = inst;

assign rs1_read_op = ((inst[6:0] == `jalr) | (inst[6:0] == `op32_branch) | (inst[6:0] == `op32_loadop) | (inst[6:0] == `op32_storeop) | (inst[6:0] == `op32_fp_loadop) | (inst[6:0] == `op32_fp_storeop) | (inst[6:0] == `op32_imm_alu) |    
                     (inst[6:0] == `op32_alu) | (inst[6:0] == `op64_imm_alu) | (inst[6:0] == `op64_alu) | (inst[6:0] == `amo)  | ((inst[6:0] == `sys) && (inst[14] == 1'b0))) ? 1'b1 :   
                     (((inst[6:0] == `op_lui) | (inst[6:0] == `op_auipc) | (inst[6:0] == `jal)) ? 1'b0 : 1'b0); // whether rs1 has to be read or not
                     
assign rs2_read_op = ((inst[6:0] == `op32_branch) | (inst[6:0] == `op32_storeop) | (inst[6:0] == `op32_alu) | (inst[6:0] == `op64_alu) | amo) ? 1'b1 : 1'b0; 
                                                                     //whether rs2 has to be read or not 


assign csr_adr = ((inst[6:0] == `sys) && (Funct3__id_ex != 3'b0)) ? inst[31:20] : 12'b0;
assign csr_wr_en = ((inst[6:0] == `sys) && (Funct3__id_ex != 3'b0) && (rs1 != 5'b0)) ? 1'b1 : 1'b0;
assign mepc_res = irq_ctrl && (inst== 32'h341021F3);

assign forw_rs1_mem_int = (RD_Addr__ID_EX == rs1) & (rs1 != 0) & (Reg_Write_Enable__ID_EX ? 1'b1 : 1'b0);
assign forw_rs1_wb_int = (RD_Addr__EX_MEM == rs1) & (rs1 != 0) & (Reg_Write_Enable__EX_MEM ? 1'b1 : 1'b0);
assign forw_rs2_mem_int = (RD_Addr__ID_EX == rs2) & (rs2 != 0) & (Reg_Write_Enable__ID_EX ? 1'b1 : 1'b0);
assign forw_rs2_wb_int = (RD_Addr__EX_MEM == rs2) & (rs2 != 0) & (Reg_Write_Enable__EX_MEM ? 1'b1 : 1'b0);

assign forw_rs1_mem_fp_int = (FP__RD_Addr_Int__ID_EX == rs1) & (rs1 != 0) & (FP__Reg_Write_En_Int__ID_EX ? 1'b1 : 1'b0);
assign forw_rs1_wb_fp_int = (FP__RD_Addr_Int__EX_MEM == rs1) & (rs1 != 0) & (FP__Reg_Write_En_Int__EX_MEM ? 1'b1 : 1'b0);
assign forw_rs2_mem_fp_int = (FP__RD_Addr_Int__ID_EX == rs2) & (rs2 != 0) & (FP__Reg_Write_En_Int__ID_EX ? 1'b1 : 1'b0);
assign forw_rs2_wb_fp_int = (FP__RD_Addr_Int__EX_MEM == rs2) & (rs2 != 0) & (FP__Reg_Write_En_Int__EX_MEM ? 1'b1 : 1'b0);


//stall generation-load operation followed by any operation on same register 
assign Load__Stall = ((Load_Store_Op__ID_EX[1:0] == 2'b01) & ( (rs2_read_op & (rdarray[1] == rs2)) | ((rs1_read_op) & (rdarray[1] == rs1)) ) ) ? 1'b0 : 1'b0;



assign amo = (inst[6:0] == `amo);

//computation of shift register inputs 
assign rd = ((inst[6:0] == `op32_branch) | (inst[6:0] == `op32_storeop)) ? 5'b0 : inst[11:7];
assign rs1 = ((inst[6:0] == `op_lui) | (inst[6:0] == `op_auipc) | (inst[6:0] == `jal)) ? 5'b0 : inst[19:15];
assign rs2 = ((inst[6:0] == `op32_branch) | (inst[6:0] == `op32_storeop) | (inst[6:0] == `op32_alu) | (inst[6:0] == `op32_alu) | (inst[6:0] == `amo)) ? inst[24:20] : 5'b0;







always @(*) begin
    if((RST | Branch_Taken__EX_MEM | NOP__IF_ID | Mult_Div_unit__Stall)) begin
        Load__Stall_id_ex <= 1'b0;
    end
    else begin
        Load__Stall_id_ex <= Load__Stall;
    end
end


always @(*) begin
    if((RST | Branch_Taken__EX_MEM | NOP__IF_ID | Mult_Div_unit__Stall | Load__Stall)) begin    
        
        pc_forw <= 32'b0;
        
        RS1_Addr__rf <= 5'b0;
        RS2_Addr__rf <= 5'b0;
        
        Reg_Write_Enable__id_ex <= 1'b0;
        RD_Addr__id_ex <= 5'b0;
        
        Forward_RS1_MEM__id_ex = 1'b0;
        Forward_RS2_MEM__id_ex = 1'b0;
        Forward_RS1_WB__id_ex= 1'b0;
        Forward_RS2_WB__id_ex = 1'b0;
        
        Forward_RS1_MEM_FP__id_ex = 1'b0;
        Forward_RS2_MEM_FP__id_ex = 1'b0;
        Forward_RS1_WB_FP__id_ex= 1'b0;
        Forward_RS2_WB_FP__id_ex = 1'b0;
        
        Load_Store_Op__id_ex <= 5'b0;
        Store_Data__id_ex <= 32'b0;
        
        Alu_Src_1_sel__id_ex <= 2'b11;
        Alu_Src_2_sel__id_ex <= 2'b11;
        Opcode__id_ex <= 7'b0;
        Funct7__id_ex <= 7'b0;
        Funct3__id_ex <= 3'b0; 
        JAL_Inst__id_ex <= 1'b0;
        JALR_Inst__id_ex <= 1'b0;  
        RS1_Data__id_ex <= 32'b0;
        RS2_Data__id_ex <= 32'b0;
        Shamt__id_ex <= 6'b0;     
        Immediate__id_ex <= 32'b0;       
        Branch_Inst__id_ex <= 1'b0;  
        AMO_Inst__id_ex <= 1'b0;
        Mult_Op__id_ex <= 2'b00;
        Mult_En__id_ex <= 1'b0;
        Div_Op__id_ex <= 2'b00;
        Div_En__id_ex <= 1'b0;
        
        lsu_op_port2 <= 5'b0;
        LR_Inst <= 1'b0;
        mret <= 1'b0;
        
        irq_ctrl_o <= 1'b0;
        count_sel <= 4'b1111;
        uret <= 1'b0;
        
        BPU__Branch_Taken__id_ex <= 1'b0;              
        BPU__Branch_Target_Addr__id_ex <= 32'b0; 
        BPU__PHT_Read_Index__id_ex <= 11'b0;     
        BPU__PHT_Read_Data__id_ex <= 2'b0; 
        BPU__BTB_Hit__id_ex <= 1'b0;
        Branch_Type__id_ex <= 3'b0;      
    
    end
    else begin 
    
        //forward the program counter
        pc_forw <= PC__IF_ID;
    
        
        RS1_Addr__rf <= rs1;
        RS2_Addr__rf <= rs2;
    
    
        //decoding for writeback operation
        case(inst[6:0]) 
            `op_lui:            Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b1;
            `op_auipc:          Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b1;
            `jal:               Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b1;
            `jalr:              Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b1;
            `op32_branch:       Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b0;
            `op32_loadop:       Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b1;
            `op32_storeop:      Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b0;
            `op32_imm_alu:      Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b1;
            `op32_alu:          Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b1;
            `op64_imm_alu:      Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b1;
            `op64_alu:          Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b1;
            `amo:               Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b1;
            `sys:               Reg_Write_Enable__id_ex <= Load__Stall ? 1'b0 : 1'b1;
            default:            Reg_Write_Enable__id_ex <= 1'b0;
        endcase
    
        //decoding of src and dest register addresses
        RD_Addr__id_ex <= Load__Stall ? 5'b0 : rd;
    
    
        //forwarding signals assignment
        Forward_RS1_MEM__id_ex = rs1_read_op ? forw_rs1_mem_int : 1'b0;           //rs1 feedback from ex/mem stage
        Forward_RS2_MEM__id_ex = rs2_read_op ? forw_rs2_mem_int : 1'b0;             //rs2 feedback from ex/mem stage
        Forward_RS1_WB__id_ex = rs1_read_op ? forw_rs1_wb_int : 1'b0;                //rs1 feedback from mem/wb stage
        Forward_RS2_WB__id_ex = rs2_read_op ? forw_rs2_wb_int : 1'b0;               //rs2 feedback from mem/wb stage
        
        //forwarding signals assignment
        Forward_RS1_MEM_FP__id_ex = rs1_read_op ? forw_rs1_mem_fp_int : 1'b0;           //rs1 feedback from ex/mem stage
        Forward_RS2_MEM_FP__id_ex = rs2_read_op ? forw_rs2_mem_fp_int : 1'b0;             //rs2 feedback from ex/mem stage
        Forward_RS1_WB_FP__id_ex = rs1_read_op ? forw_rs1_wb_fp_int : 1'b0;                //rs1 feedback from mem/wb stage
        Forward_RS2_WB_FP__id_ex = rs2_read_op ? forw_rs2_wb_fp_int : 1'b0;               //rs2 feedback from mem/wb stage
            
        
        //decoding for load-store operation
        casez({inst[6:0],inst[14:12]}) 
           ({`op32_loadop,`func_lb}):      Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b00001;
           ({`op32_loadop,`func_lh}):      Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b00101;
           ({`op32_loadop,`func_lw}):      Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b01001;
           ({`op32_loadop,`func_ld}):      Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b01101;
           ({`op32_loadop,`func_lbu}):     Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b10001;
           ({`op32_loadop,`func_lhu}):     Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b10101;
           ({`op32_loadop,`func_lwu}):     Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b11001;
           ({`op32_storeop,`func_sb}):     Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b00010;
           ({`op32_storeop,`func_sh}):     Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b00110;
           ({`op32_storeop,`func_sw}):     Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b01010;
           ({`op32_storeop,`func_sd}):     Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b01110;
           ({`op32_fp_loadop,`func_lw}):   Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b01001;
           ({`op32_fp_loadop,`func_ld}):   Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b01101;
           ({`op32_fp_storeop,`func_sw}):  Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b01010;
           ({`op32_fp_storeop,`func_sd}):  Load_Store_Op__id_ex <= Load__Stall ? 5'b0 : 5'b01110;
           ({`amo,3'b010}):                Load_Store_Op__id_ex <= (inst[31:27] == 5'b00010) ? 5'b00000 : 5'b01010;      //store for all atomic instructions except LR             
            default:                       Load_Store_Op__id_ex <= 5'b00000;
        endcase   
        
        //store-unit data generation
        Store_Data__id_ex <= Load__Stall ? 32'b0 : ((inst[6:0] == `jalr) | (inst[6:0] == `jal)) ? PC_4__IF_ID : RS2_Data__rf;  
        
        
        case(inst[6:0]) 
            `op_lui: begin
                Alu_Src_1_sel__id_ex <= 2'b00;                      //dummy values
                Alu_Src_2_sel__id_ex <= 2'b00;                      //dummy values
            end
            `op_auipc: begin
                Alu_Src_1_sel__id_ex <= 2'b10;                      //select immediate from mux
                Alu_Src_2_sel__id_ex <= 2'b01;                      //select program counter from mux
            end
            `jal: begin
                Alu_Src_1_sel__id_ex <= 2'b10;                      //select immediate from mux
                Alu_Src_2_sel__id_ex <= 2'b01;                      //select program counter from mux
            end
            `jalr: begin
                Alu_Src_1_sel__id_ex <= 2'b00;                      //select rs1 from mux
                Alu_Src_2_sel__id_ex <= 2'b10;                      //select immediate from mux
            end
            `op32_branch: begin
                Alu_Src_1_sel__id_ex <= 2'b10;                       //select immediate from mux
                Alu_Src_2_sel__id_ex <= 2'b01;                       //select program counter from mux
            end             
            `op32_loadop: begin
                Alu_Src_1_sel__id_ex <= 2'b00;                      //select rs1 as one of the inputs
                Alu_Src_2_sel__id_ex <= 2'b10;                      //select immediate as the second input
            end
            `op32_storeop: begin
                Alu_Src_1_sel__id_ex <= 2'b00;                      //select rs1 as one of the inputs
                Alu_Src_2_sel__id_ex <= 2'b10;                      //select immediate as the second input
            end
            `op32_imm_alu: begin
                Alu_Src_1_sel__id_ex <= 2'b00;                      //select rs1 as input
                Alu_Src_2_sel__id_ex <= 2'b10;                      //select immediate as input
            end
            `op32_alu: begin
                Alu_Src_1_sel__id_ex <= 2'b00;                      //select rs1 as input
                Alu_Src_2_sel__id_ex <= 2'b00;                      //select rs2 as input
            end     
            `amo: begin
                Alu_Src_1_sel__id_ex <= 2'b11;                      //select rs1 data as input
                Alu_Src_2_sel__id_ex <= 2'b00;                      //select rs2 data as input
            end
            `sys: begin
                Alu_Src_2_sel__id_ex <= 2'b11;                      
                if ((Funct3__id_ex == 3'b001) ||(Funct3__id_ex == 3'b010) || (Funct3__id_ex ==3'b011))
                    Alu_Src_1_sel__id_ex <= 2'b00; 
                else                     
                    Alu_Src_1_sel__id_ex <= 2'b10; 
            end
            `op32_fp_loadop: begin
                Alu_Src_1_sel__id_ex <= 2'b00;                      //select rs1 as one of the inputs
                Alu_Src_2_sel__id_ex <= 2'b10;                      //select immediate as the second input
            end
            `op32_fp_storeop: begin
                Alu_Src_1_sel__id_ex <= 2'b00;                      //select rs1 as one of the inputs
                Alu_Src_2_sel__id_ex <= 2'b10;                      //select immediate as the second input
            end
            default: begin
                Alu_Src_1_sel__id_ex <= 2'b00;
                Alu_Src_2_sel__id_ex <= 2'b00;
            end
        endcase
            
        
        //decoding for alu-operation 
        Opcode__id_ex <= inst[6:0];
        Funct7__id_ex <= inst[31:25];                      //for SLLI,SRLI,SRAI instructions, the ALU should ignore the LSB of Funct7__id_ex and only use upper 6 bits. 
        Funct3__id_ex <= inst[14:12];                       //hence, modify ALU for that
            
            
        
            
         
        RS1_Data__id_ex <= RS1_Data__rf;          //replace operand by loaded value from cache
        RS2_Data__id_ex <= RS2_Data__rf;
            
            
        Shamt__id_ex <= {1'b0,inst[24:20]};
        
        
        //immediate generation logic
        case(inst[6:0]) 
            `jal:              Immediate__id_ex <= {{11{inst[31]}},{inst[31]},{inst[19:12]},inst[20],inst[30:21],1'b0};
            `jalr:             Immediate__id_ex <= {{20{inst[31]}},inst[31:20]}; 
            `op32_imm_alu:     Immediate__id_ex <= {{20{inst[31]}},inst[31:20]};
            `op_lui:           Immediate__id_ex <= {{inst[31:12]},12'b0};    
            `op_auipc:         Immediate__id_ex <= {{inst[31:12]},12'b0};
            `op32_branch:      Immediate__id_ex <= {{19{inst[31]}},{inst[31]},{inst[7]},{inst[30:25]},{inst[11:8]},1'b0};
            `op32_loadop:      Immediate__id_ex <= {{20{inst[31]}},inst[31:20]};  
            `op32_storeop:     Immediate__id_ex <= {{20{inst[31]}},{inst[31:25]},{inst[11:7]}};  
            `sys:              Immediate__id_ex <= { {27'b0} , {inst[19:15]}};
            `op32_fp_loadop:   Immediate__id_ex <= {{20{inst[31]}},inst[31:20]};  
            `op32_fp_storeop:  Immediate__id_ex <= {{20{inst[31]}},{inst[31:25]},{inst[11:7]}};   
            default:           Immediate__id_ex <= 32'b0;
        endcase
            
            
        
        
        AMO_Inst__id_ex <= amo;
            
            
        //multiplier and divider module commands
        casez({inst[31:25],inst[14:12],inst[6:0]}) 
            {7'b0000001,`func_mul,`op32_muldiv}: begin
                Mult_En__id_ex <= 1'b1;
                Div_En__id_ex <= 1'b0;
                Mult_Op__id_ex <= 2'b00;                                                //00 for signed multiplication
                Div_Op__id_ex <= 2'b00;                                                 //dummy value
            end
            {7'b0000001,`func_mulh,`op32_muldiv}: begin
                Mult_En__id_ex <= 1'b1;
                Div_En__id_ex <= 1'b0;
                Mult_Op__id_ex <= 2'b10;                                                //00 for signed multiplication - higher 32 bits
                Div_Op__id_ex <= 2'b00;                                                 //dummy value
            end
            {7'b0000001,`func_mulhsu,`op32_muldiv}: begin
                Mult_En__id_ex <= 1'b1;
                Div_En__id_ex <= 1'b0;
                Mult_Op__id_ex <= 2'b01;                                                //for signed*unsigned multiplication
                Div_Op__id_ex <= 2'b0;                                                 //dummy value
            end
            {7'b0000001,`func_mulhu,`op32_muldiv}: begin
                Mult_En__id_ex <= 1'b1;
                Div_En__id_ex <= 1'b0;
                Mult_Op__id_ex <= 2'b11;                                                //for unsigned*unsigned multiplication
                Div_Op__id_ex <= 2'b0;                                                 //dummy value
            end
            {7'b0000001,`func_div,`op32_muldiv}: begin
                Mult_En__id_ex <= 1'b0;
                Div_En__id_ex <= 1'b1;
                Mult_Op__id_ex <= 2'b11;                                                //dummy value
                Div_Op__id_ex <= 2'b11;                                                 //signed quotient
            end
            {7'b0000001,`func_divu,`op32_muldiv}: begin
                Mult_En__id_ex <= 1'b0;
                Div_En__id_ex <= 1'b1;
                Mult_Op__id_ex <= 2'b11;                                                //dummy value
                Div_Op__id_ex <= 2'b10;                                                 //unsigned quotient
            end
            {7'b0000001,`func_rem,`op32_muldiv}: begin
                Mult_En__id_ex <= 1'b0;
                Div_En__id_ex <= 1'b1;
                Mult_Op__id_ex <= 2'b11;                                                //dummy value
                Div_Op__id_ex <= 2'b01;                                                 //signed remainder
            end
            {7'b0000001,`func_remu,`op32_muldiv}: begin
                Mult_En__id_ex <= 1'b0;
                Div_En__id_ex <= 1'b1;
                Mult_Op__id_ex <= 2'b11;                                                //dummy value
                Div_Op__id_ex <= 2'b00;                                                 //unsigned remainder
            end
            default: begin
                Mult_En__id_ex <= 1'b0;
                Div_En__id_ex <= 1'b0;        
                Mult_Op__id_ex <= 2'b00;
                Div_Op__id_ex <= 2'b00; 
            end
        endcase
            
            
        lsu_op_port2 <= (amo & ~(inst[31:27] == 5'b00011)) ? 5'b01001 : 5'b0;   //No loading operation for SC instruction
        LR_Inst <= (inst[6:0] == `amo) & (inst[31:27] == 5'b00010);
        
        mret <= (inst[6:0] == `sys) & (inst[31:20] == 12'b001100000010);
        
        irq_ctrl_o <= irq_ctrl_wb;   
        uret <= (inst[6:0] == `sys) & (inst[31:20] == 12'b000000000010); 


        case(inst[31:20])
            `mcycle    : count_sel <= (inst[6:0] == `sys) ? 4'b0000 : 4'b1111;   
            `mcycleh   : count_sel <= (inst[6:0] == `sys) ? 4'b0001 : 4'b1111;   
            `minstret  : count_sel <= (inst[6:0] == `sys) ? 4'b0100 : 4'b1111;   
            `minstreth : count_sel <= (inst[6:0] == `sys) ? 4'b0101 : 4'b1111;   
            `mtime     : count_sel <= (inst[6:0] == `sys) ? 4'b1000 : 4'b1111;   
            `mtimeh    : count_sel <= (inst[6:0] == `sys) ? 4'b1001 : 4'b1111;   
            `mtimecmp  : count_sel <= (inst[6:0] == `sys) ? 4'b1010 : 4'b1111;   
            `mtimecmph : count_sel <= (inst[6:0] == `sys) ? 4'b1011 : 4'b1111;   
            `counttick : count_sel <= (inst[6:0] == `sys) ? 4'b1100 : 4'b1111;   
            `Num_tick  : count_sel <= (inst[6:0] == `sys) ? 4'b1101 : 4'b1111;
            default : count_sel <= 4'b1111;   //Nothing selected; Garbage value   
        endcase
        
        
        //Branch_Inst__id_ex is enabled if instruction detected is a conditional branch instruction
        Branch_Inst__id_ex <= (inst[6:0] == `op32_branch) ? 1'b1 : 1'b0;  
        
        //jal and jalr instructions
        JAL_Inst__id_ex <= (inst[6:0] == `jal) ? 1'b1 : 1'b0; 
        JALR_Inst__id_ex <= (inst[6:0] == `jalr) ? 1'b1 : 1'b0;           
        

        if (JAL_Inst__id_ex == 1'b1) begin
            if ((RD_Addr__id_ex == 5'b00001) || (RD_Addr__id_ex == 5'b00101)) begin
                Branch_Type__id_ex <= 3'b010;                                        // Call
            end
            else begin
                Branch_Type__id_ex <= 3'b001;                                        // Unconditional branch
            end
        end
        else if (JALR_Inst__id_ex == 1'b1) begin
            if (((RS1_Addr__rf == 5'b00001) || (RS1_Addr__rf == 5'b00101)) && ((RD_Addr__id_ex == 5'b00001) || (RD_Addr__id_ex == 5'b00101))) begin
                if (RS1_Addr__rf == RD_Addr__id_ex) begin
                    Branch_Type__id_ex <= 3'b010;                                    // Call
                end
                else begin
                    Branch_Type__id_ex <= 3'b100;                                    // Call and Return ?
                end
            end
            else if ((RS1_Addr__rf == 5'b00001) || (RS1_Addr__rf == 5'b00101)) begin
                Branch_Type__id_ex <= 3'b011;                                        // Return                                            
            end
            else if ((RD_Addr__id_ex == 5'b00001) || (RD_Addr__id_ex == 5'b00101)) begin
                Branch_Type__id_ex <= 3'b010;                                        // Call
            end
            else begin
                Branch_Type__id_ex <= 3'b000;  
            end
        end           
        else begin
            Branch_Type__id_ex <= 3'b000;  
        end
        
        
        BPU__Branch_Taken__id_ex <= BPU__Branch_Taken__IF_ID;              
        BPU__Branch_Target_Addr__id_ex <= BPU__Branch_Target_Addr__IF_ID; 
        BPU__PHT_Read_Index__id_ex <= BPU__PHT_Read_Index__IF_ID;     
        BPU__PHT_Read_Data__id_ex <= BPU__PHT_Read_Data__IF_ID; 
        BPU__BTB_Hit__id_ex <= BPU__BTB_Hit__IF_ID;
                
    end
end
endmodule
