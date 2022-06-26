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

module EXECUTE
(
    input CLK,
    input RST,
    
    input [31:0] pc_id_ex,                              //                                                                  *********
    
    input Forward_RS1_MEM__ID_EX,                       //MEM stage forwarding for RS1 control signal from ID_EX stage
    input Forward_RS2_MEM__ID_EX,                       //MEM stage forwarding for RS2 control signal from ID_EX stage
    input Forward_RS1_WB__ID_EX,                        //WB stage forwarding for rs1 control signal from ID_EX stage 
    input Forward_RS2_WB__ID_EX,                        //WB stage forwarding for rs2 control signal from ID_EX stage
    input [31:0] RD_Data__EX_MEM,                       //MEM stage RD data for forwarding from EX_MEM stage
    input [31:0] RD_Data__MEM_WB,                       //WB stage RD data for forwarding from MEM_WB stage
    
    input Forward_RS1_MEM_FP__ID_EX,                    //MEM stage forwarding for RS1 control signal from ID_EX stage
    input Forward_RS2_MEM_FP__ID_EX,                    //MEM stage forwarding for RS2 control signal from ID_EX stage
    input Forward_RS1_WB_FP__ID_EX,                     //WB stage forwarding for rs1 control signal from ID_EX stage 
    input Forward_RS2_WB_FP__ID_EX,                     //WB stage forwarding for rs2 control signal from ID_EX stage
    input [31:0] FP__RD_Data_Int__EX_MEM,               //MEM stage RD data for forwarding from EX_MEM stage
    input [31:0] FP__RD_Data_Int__MEM_WB,               //WB stage RD data for forwarding from MEM_WB stage
        
    input [4:0] Load_Store_Op__ID_EX,                   //Load Store Unit Operation from ID_EX stage
    output reg [4:0] Load_Store_Op__ex_mem,             //Load Store Unit Operation to EX_MEM stage
    
    input [1:0] Alu_Src_1_sel__ID_EX,                   //ALU source 1 select mux signals from ID_EX stage
    input [1:0] Alu_Src_2_sel__ID_EX,                   //ALU source 2 select mux signals from ID_EX stage
    input [6:0] Opcode__ID_EX,                          //Instruction[6:0] from ID_EX stage
    input [6:0] Funct7__ID_EX,                          //Instruction[31:25] from ID_EX stage
    input [2:0] Funct3__ID_EX,                          //Instruction[14:12] from ID_EX stage
    input JAL_Inst__ID_EX,                              //Indicates JAL instruction from ID_EX stage
    input JALR_Inst__ID_EX,                             //Indicates JALR instruction from ID_EX stage
    input [31:0] RS1_Data__ID_EX,                       //Source Regester - 1  Data from ID_EX stage
    input [31:0] RS2_Data__ID_EX,                       //Source Regester - 2  Data from ID_EX stage
    input [5:0] Shamt__ID_EX,                           //Shamt for alu from ID_EX stage
    input [31:0] Immediate__ID_EX,                      //immediate for alu from ID_EX stage
    input Branch_Inst__ID_EX,                           //Indicates conditional branch instruction from ID_EX stage
    input AMO_Inst__ID_EX,                              //Indicates Atomic Instruction from ID_EX stage
    input Load__Stall_ID_EX,                            //For dependancy between load and ALU instruction stall from ID_EX register                                                                  
    
    input [31:0] amo_load_val_i,                        //                                                                  *********
    
    output reg Branch_Taken__ex_mem,                    //Branch decision calculated in EX stage to EX_MEM stage
    output reg [31:0] Branch_Target_Addr__ex_mem,       //Branch Addr calculated in EX stage to EX_MEM stage
    input Branch_Taken__EX_MEM,
    
    
    output reg [31:0] ALU_Result__ex_mem,               //ALU output Result to EX_MEM stage
    output reg [31:0] RD_Data__ex_mem,                  //RD data for write back to register file to EX_MEM stage
    
    input [1:0] Mult_Op__ID_EX,
    input [1:0] Div_Op__ID_EX,
    input Mult_En__ID_EX,
    input Div_En__ID_EX,
    output reg Mult_Div_unit__Stall,
    input Mult_Div_unit_Freeze,
    input Mult_Div_unit__Stall_disable,
    input Inst_Cache__Stall__reg,
    input Inst_Cache__Stall,
    
    input Reg_Write_Enable__ID_EX,
    output reg Reg_Write_Enable__ex_mem,
    input [4:0] RD_Addr__ID_EX,
    output reg [4:0] RD_Addr__ex_mem,
    
    input [31:0] Store_Data__ID_EX,
    output reg [31:0] Store_Data__ex_mem,
    
    input BPU__Branch_Taken__ID_EX,
    input [31:0] BPU__Branch_Target_Addr__ID_EX,
    input [10:0] BPU__PHT_Read_Index__ID_EX,
    input [1:0] BPU__PHT_Read_Data__ID_EX, 
    input BPU__BTB_Hit__ID_EX,       
    input [2:0] Branch_Type__ID_EX, 
    
    output reg [10:0] PHT_Write_Index__ex_mem,
    output reg [1:0] PHT_Write_Data__ex_mem,
    output reg PHT_Write_En__ex_mem,
    output reg GHR_Write_Data__ex_mem,
    output reg GHR_Write_En__ex_mem,
    output reg [31:0] BTB_Write_Addr__ex_mem,
    output reg [31:0] BTB_Write_Data__ex_mem,
    output reg BTB_Write_En__ex_mem,
    output reg RAS_RET_Inst_EX__ex_mem,
    output reg RAS_CALL_Inst__ex_mem,
    output reg [31:0] RAS_CALL_Inst_nextPC__ex_mem,
    
    
    input lsustall_i,
    output reg lsustall_o,
    
    
    
    //Irq_ctrl from decode stage. This signal disengages the branch signal so that the state saving instructions are not nop'ed by a jump instruction already in the pipeline
    input irq_ctrl,
    input eret,
    output reg eret_o,
    //Signal the Dcache to check reservation and process
    output reg SC_Inst__ex_mem,
    output trap_en,
    input [31:0] csr_indata,
    output [31:0] csr_wrdata,
    
    input PC_Control__IRQ
);


// fsm for multiplier activation
parameter idle = 2'b00;
parameter act  = 2'b01;
parameter stay = 2'b10;
parameter div_stay = 2'b11;
 
reg [31:0] in1_mux;
reg [31:0] in2_mux;
wire Branch_Taken;
wire [4:0] lsu_op_int;
wire wb_op_int;

wire[31:0] src1int;
wire[31:0] resultslti ;
wire[31:0] resultsltiu;
wire[31:0] resultsltu;
wire[31:0] resultslt;
wire[31:0] adderout;
wire [31:0] addout;
wire [31:0] addoutw;
wire [31:0] sll;
wire [31:0] srl;
wire [31:0] sra;
wire [31:0] sllw;
wire [31:0] srlw;
wire [31:0] sraw;
wire [31:0] sllwout;
wire [31:0] srlwout;
wire [31:0] srawout;
wire[31:0] xorout;
wire[31:0] orout;
wire[31:0] andout;
wire[31:0] sllout;
wire[31:0] srlout;
wire[31:0] sraout;
wire beq,bne,blt,bge,bltu,bgeu;
wire [31:0] indata1;
wire [31:0] indata2;
wire [31:0] insrc0;
wire [31:0] insrc1;
wire is32;
reg [31:0] result_int;
wire [31:0] swap_o1;        //signals after performing swapping operations
wire [31:0] swap_o2;        //signals after performing swapping operations
wire [31:0] max;            //signed max of the two numbers
wire [31:0] maxu;           //unsigned max of the two numbers 
wire [31:0] min;            //signed min of the two numbers
wire [31:0] minu;           //unsigned min of the two numbers
wire [31:0] src0_int;
wire [31:0] src1_int;
wire [31:0] csr_wrdata_int;


reg [1:0] state;
reg [1:0] next_state;
wire [31:0] muldiv_rs1;
wire [31:0] muldiv_rs2;
reg signal_div_kill;
wire div_start;
wire done_div;
reg mul_rst;
wire [63:0] P_int;
wire [31:0] div_res;
wire [31:0] mul_res;
wire [31:0] div_res__temp;
wire [31:0] mul_res__temp;
reg [31:0] div_res__reg;
reg [31:0] mul_res__reg;
reg mul_res_sel;




assign src0_int = RS1_Data__ID_EX;
assign src1_int = RS2_Data__ID_EX;

integer shamt_int;

assign indata1 = ((Opcode__ID_EX == `op32_branch) | AMO_Inst__ID_EX) ? in1_mux :       //if atomic instruction, dont use forwarding because the data from dcache is to be used, not from the pipeline 
                 (Forward_RS1_MEM_FP__ID_EX) ? FP__RD_Data_Int__EX_MEM :
                 (Forward_RS1_WB_FP__ID_EX) ? FP__RD_Data_Int__MEM_WB : 
                 (Forward_RS1_MEM__ID_EX) ? RD_Data__EX_MEM : 
                 (Forward_RS1_WB__ID_EX) ? RD_Data__MEM_WB : in1_mux;       //select usual data or forwarded data(data from ex/mem reg is given priority)

assign indata2 = ((Opcode__ID_EX == `op32_branch) | (Opcode__ID_EX == `op32_storeop)) ? in2_mux : 
                 (Forward_RS2_MEM_FP__ID_EX) ? FP__RD_Data_Int__EX_MEM :
                 (Forward_RS2_WB_FP__ID_EX) ? FP__RD_Data_Int__MEM_WB :
                 (Forward_RS2_MEM__ID_EX) ? RD_Data__EX_MEM : 
                 (Forward_RS2_WB__ID_EX) ? RD_Data__MEM_WB : in2_mux;       //select usual data or forwarded data(data from ex/mem reg is given priority)

assign insrc0 = (Forward_RS1_MEM_FP__ID_EX) ? FP__RD_Data_Int__EX_MEM :
                (Forward_RS1_WB_FP__ID_EX) ? FP__RD_Data_Int__MEM_WB :
                (Forward_RS1_MEM__ID_EX) ? RD_Data__EX_MEM : 
                (Forward_RS1_WB__ID_EX) ? RD_Data__MEM_WB : src0_int;       //select usual data or forwarded data(data from ex/mem reg is given priority)

assign insrc1 = (Forward_RS2_MEM_FP__ID_EX) ? FP__RD_Data_Int__EX_MEM :
                (Forward_RS2_WB_FP__ID_EX) ? FP__RD_Data_Int__MEM_WB :
                (Forward_RS2_MEM__ID_EX) ? RD_Data__EX_MEM : 
                (Forward_RS2_WB__ID_EX) ? RD_Data__MEM_WB : src1_int;       //select usual data or forwarded data(data from ex/mem reg is given priority)              


assign beq = (insrc0 == insrc1) ? 1'b1 : 1'b0;
assign bne = ~beq;
assign blt = ($signed(insrc0) < $signed(insrc1)) ? 1'b1 : 1'b0;
assign bltu = (insrc0< insrc1) ? 1'b1 : 1'b0;
assign bge = ($signed(insrc0) >= $signed(insrc1)) ? 1'b1 : 1'b0;
assign bgeu = (insrc0 >= insrc1) ? 1'b1 : 1'b0;


assign max = ($signed(indata1) > $signed(indata2)) ? indata1 : indata2;
assign maxu = (indata1> indata2) ? indata1: indata2;
assign min = ($signed(indata1) <= $signed(indata2)) ? indata1 : indata2;
assign minu = (indata1 <= indata2) ? indata1 : indata2;

assign Branch_Taken = ((((Funct3__ID_EX==`func_beq) & beq) | ((Funct3__ID_EX==`func_bne) & bne) | ((Funct3__ID_EX==`func_blt) & blt) | ((Funct3__ID_EX==`func_bltu) & bltu) | 
                      ((Funct3__ID_EX==`func_bge) & bge) | ((Funct3__ID_EX==`func_bgeu) & bgeu)) & Branch_Inst__ID_EX) | JALR_Inst__ID_EX | JAL_Inst__ID_EX;


always @(*) begin
    case(Alu_Src_1_sel__ID_EX)
        2'b00:in1_mux <= src0_int;
        2'b01:in1_mux <= pc_id_ex;
        2'b10:in1_mux <= Immediate__ID_EX;
        2'b11:in1_mux <= amo_load_val_i;
        default:in1_mux <= 32'b0;
    endcase
    case(Alu_Src_2_sel__ID_EX)
        2'b00:in2_mux <= src1_int;
        2'b01:in2_mux <= pc_id_ex;
        2'b10:in2_mux <= Immediate__ID_EX;
        2'b11:in2_mux <= csr_indata;
        default:in2_mux <= 32'b0;
    endcase
end

assign resultsltu = (indata1 < indata2) ? {{31'b0},{1'b1}} : 32'h0;
assign resultslt = ($signed(indata1) < $signed(indata2))? {{31'b0},{1'b1}}: 32'h0;
assign addout = ((indata1) + (( (Opcode__ID_EX == `op32_alu) & (Funct7__ID_EX == `func_sub)) ? (~(indata2)+1) : indata2)); //select subtraction operation if it is an adder operation and the func7 is 0700000
assign xorout = indata1^indata2;
assign orout = indata1 | indata2;
assign andout = indata1 & indata2;
assign sll = indata1 << ((Opcode__ID_EX == `op32_imm_alu) ? shamt_int : indata2[5:0]);
assign srl = indata1 >> ((Opcode__ID_EX == `op32_imm_alu) ? shamt_int : indata2[5:0]);
assign sra = $signed(indata1) >>> ((Opcode__ID_EX == `op32_imm_alu) ? shamt_int : indata2[5:0]);
assign adderout = addout;

assign trap_en = 1'b0;
assign csr_wrdata = trap_en ? pc_id_ex : csr_wrdata_int;
assign csr_wrdata_int = ((Funct3__ID_EX == 3'b001) || (Funct3__ID_EX == 3'b101)) ? indata1 :
                        (((Funct3__ID_EX == 3'b010) || (Funct3__ID_EX == 3'b110)) ?  in2_mux | indata1 :
                        (((Funct3__ID_EX == 3'b011) || (Funct3__ID_EX == 3'b111)) ? (in2_mux & (~indata1)) : 32'b0)) ;

assign swap_o1 = indata2;           //swap indata1 and indata2
assign swap_o2 = indata1;           //swap indata1 and indata2

assign sllout = sll;              //whether sllw or normal sll operation has to be performed
assign srlout = srl;              //whether srlw or normal srl operation has to be performed
assign sraout = sra;              //whether sraw or normal sra operation has to be performed

always @(*) begin
    if(( Load__Stall_ID_EX | RST | Branch_Taken__EX_MEM)) begin
        ALU_Result__ex_mem <= 32'b0;
        eret_o <= 1'b0;
    end
    else begin
        ALU_Result__ex_mem <= AMO_Inst__ID_EX ? RS1_Data__ID_EX : result_int;    
        eret_o <= eret;          //condition for store address in case of atomic instruction
    end
end

always @(*) begin
    casex({{Funct7__ID_EX},{Funct3__ID_EX},{Opcode__ID_EX}})
        {{7'b???????},{3'b???},{`op_lui}}:                      result_int <= Immediate__ID_EX;
        {{7'b???????},{3'b???},{`op_auipc}}:                    result_int <= adderout; 
        {{7'b???????},{3'b???},{`jal}}:                         result_int <= adderout;
        {{7'b???????},{3'b???},{`jalr}}:                        result_int <= {{adderout[30:1]},1'b0};
        {{7'b???????},{3'b???},{`op32_branch}}:                 result_int <= adderout;
        {{7'b???????},{3'b???},{`op32_loadop}}:                 result_int <= adderout;
        {{7'b???????},{3'b???},{`op32_storeop}}:                result_int <= adderout;
        {{7'b???????},{`alu_addsub},{`op32_imm_alu}}:           result_int <= adderout;
        {{7'b0000000},{`alu_addsub},{`op32_alu}}:               result_int <= adderout;
        {{7'b0100000},{`alu_addsub},{`op32_alu}}:               result_int <= adderout;
        {{7'b???????},{`alu_slt},{`op32_imm_alu}}:              result_int <= resultslt;
        {{7'b0000000},{`alu_slt},{`op32_alu}}:                  result_int <= resultslt;
        {{7'b???????},{`alu_sltu},{`op32_imm_alu}}:             result_int <= resultsltu;
        {{7'b0000000},{`alu_sltu},{`op32_alu}}:                 result_int <= resultsltu;
        {{7'b0000000},{`alu_sll},{`op32_imm_alu}}:              result_int <= sllout;
        {{7'b0000000},{`alu_sll},{`op32_alu}}:                  result_int <= sllout;
        {{7'b0000000},{`alu_srlsra},{`op32_imm_alu}}:           result_int <= srlout;
        {{7'b0000000},{`alu_srlsra},{`op32_alu}}:               result_int <= srlout;
        {{7'b0100000},{`alu_srlsra},{`op32_imm_alu}}:           result_int <= sraout;
        {{7'b0100000},{`alu_srlsra},{`op32_alu}}:               result_int <= sraout;
        {{7'b???????},{`alu_or},{`op32_imm_alu}}:               result_int <= orout;
        {{7'b0000000},{`alu_or},{`op32_alu}}:                   result_int <= orout;
        {{7'b???????},{`alu_xor},{`op32_imm_alu}}:              result_int <= xorout;
        {{7'b0000000},{`alu_xor},{`op32_alu}}:                  result_int <= xorout;
        {{7'b???????},{`alu_and},{`op32_imm_alu}}:              result_int <= andout;
        {{7'b0000000},{`alu_and},{`op32_alu}}:                  result_int <= andout;  
        {{7'b0000001},{3'b000},{`op32_muldiv}}:                 result_int <= mul_res;
        {{7'b0000001},{3'b001},{`op32_muldiv}}:                 result_int <= mul_res;
        {{7'b0000001},{3'b010},{`op32_muldiv}}:                 result_int <= mul_res;
        {{7'b0000001},{3'b011},{`op32_muldiv}}:                 result_int <= mul_res;
        {{7'b0000001},{3'b100},{`op32_muldiv}}:                 result_int <= div_res;                              
        {{7'b0000001},{3'b101},{`op32_muldiv}}:                 result_int <= div_res;                              
        {{7'b0000001},{3'b110},{`op32_muldiv}}:                 result_int <= div_res;                              
        {{7'b0000001},{3'b111},{`op32_muldiv}}:                 result_int <= div_res;                              
        {{7'b00001??},{3'b010},{`amo}}:                         result_int <= swap_o1;         //amoswap instructions
        {{7'b00000??},{3'b010},{`amo}}:                         result_int <= adderout;        //amoadd instructions
        {{7'b00100??},{3'b010},{`amo}}:                         result_int <= xorout;          //amoxor instructions
        {{7'b01100??},{3'b010},{`amo}}:                         result_int <= andout;          //amoand instructions
        {{7'b01000??},{3'b010},{`amo}}:                         result_int <= orout;           //amoor instructions
        {{7'b10000??},{3'b010},{`amo}}:                         result_int <= min;             //amomin instructions
        {{7'b10100??},{3'b010},{`amo}}:                         result_int <= max;             //amomax instructions
        {{7'b11000??},{3'b010},{`amo}}:                         result_int <= minu;            //amominu instructions
        {{7'b11100??},{3'b010},{`amo}}:                         result_int <= maxu;            //amomaxu instructions        
        {{7'b???????},{3'b???},{`op32_fp_loadop}}:              result_int <= adderout;
        {{7'b???????},{3'b???},{`op32_fp_storeop}}:             result_int <= adderout;
        default:
            result_int <= 32'b0;
    endcase
end 

always @(*) begin
    if((Load__Stall_ID_EX | RST | Branch_Taken__EX_MEM)) begin                                 // Stall implementation
        shamt_int <= 5'b0;
        Load_Store_Op__ex_mem <= 5'b0;
        Store_Data__ex_mem <= 32'b0;
        Reg_Write_Enable__ex_mem <= 1'b0;
        lsustall_o <= lsustall_i;                          //stall signal for mem and wb stages should not be interfered with
        RD_Addr__ex_mem <= 5'b0;
        SC_Inst__ex_mem <= 1'b0;                   
    end
    else begin
        shamt_int <= Shamt__ID_EX;
        Load_Store_Op__ex_mem <= Load_Store_Op__ID_EX;
        Store_Data__ex_mem <= AMO_Inst__ID_EX ? result_int : ((Forward_RS2_MEM__ID_EX) ? RD_Data__EX_MEM : ((Forward_RS2_WB__ID_EX) ? RD_Data__MEM_WB : Store_Data__ID_EX));
        Reg_Write_Enable__ex_mem <= Reg_Write_Enable__ID_EX;
        lsustall_o <= lsustall_i;
        RD_Addr__ex_mem <= RD_Addr__ID_EX;
        SC_Inst__ex_mem <= (Opcode__ID_EX == `amo) & (Funct7__ID_EX[6:2] == 5'b00011);  //High for SC instruction  
    end
end




always @(*) begin
    if((Load__Stall_ID_EX | RST | Branch_Taken__EX_MEM)) begin
        RD_Data__ex_mem <= 32'b0;    
    end
    else begin
        case(Opcode__ID_EX)
            (`jal) : RD_Data__ex_mem <= Store_Data__ID_EX ;
            (`jalr): RD_Data__ex_mem <= Store_Data__ID_EX ;
            (`op32_branch) : RD_Data__ex_mem <= 32'b0;
            (`op32_storeop): RD_Data__ex_mem <= 32'b0;
            (`amo) : RD_Data__ex_mem <= indata1;
            (`sys) : RD_Data__ex_mem <= indata2;        // csr_indata can be used directly 
            default: RD_Data__ex_mem <= ALU_Result__ex_mem;
        endcase 
    end
end

always @(*) begin
    if(RST | Branch_Taken__EX_MEM) begin
        PHT_Write_Index__ex_mem <= 11'b0;
        PHT_Write_Data__ex_mem <= 2'b0;
        PHT_Write_En__ex_mem <= 1'b0;
        GHR_Write_Data__ex_mem <= 1'b0;
        GHR_Write_En__ex_mem <= 1'b0;
        BTB_Write_Addr__ex_mem <= 32'b0;
        BTB_Write_Data__ex_mem <= 32'b0;
        BTB_Write_En__ex_mem <= 1'b0;
        
        Branch_Taken__ex_mem <= 1'b0;                               
        Branch_Target_Addr__ex_mem <= 32'b0;
        RAS_RET_Inst_EX__ex_mem <= 1'b0;
        RAS_CALL_Inst__ex_mem <= 1'b0;
        RAS_CALL_Inst_nextPC__ex_mem <= 32'b0;
    end
    else begin
        PHT_Write_Index__ex_mem <= BPU__PHT_Read_Index__ID_EX;
        
        case(BPU__PHT_Read_Data__ID_EX)
            2'b00 : PHT_Write_Data__ex_mem <= (Branch_Taken) ? 2'b01 : 2'b00;
            2'b01 : PHT_Write_Data__ex_mem <= (Branch_Taken) ? 2'b10 : 2'b00;
            2'b10 : PHT_Write_Data__ex_mem <= (Branch_Taken) ? 2'b11 : 2'b01;
            2'b11 : PHT_Write_Data__ex_mem <= (Branch_Taken) ? 2'b11 : 2'b10;
            default: PHT_Write_Data__ex_mem <= 2'b00;
        endcase 
        
        PHT_Write_En__ex_mem <= (Branch_Inst__ID_EX) ? 1'b1 : 1'b0;
        
        GHR_Write_Data__ex_mem <= (Branch_Taken) ? 1'b1 : 1'b0;
        
        GHR_Write_En__ex_mem <= (Branch_Inst__ID_EX) ? 1'b1 : 1'b0;
        
        BTB_Write_Addr__ex_mem <= pc_id_ex;
        
        BTB_Write_Data__ex_mem <= {result_int[31:2],Branch_Type__ID_EX[1:0]};
        
        BTB_Write_En__ex_mem <= ((BPU__BTB_Hit__ID_EX == 1'b0) && ((Branch_Inst__ID_EX == 1'b1) || (JAL_Inst__ID_EX == 1'b1) || (JALR_Inst__ID_EX == 1'b1))) ? 1'b1 : 1'b0;
        
//        if (PC_Control__IRQ == 1'b1) begin
//            Branch_Taken__ex_mem <= 1'b0;                               
//            Branch_Target_Addr__ex_mem <= 32'b0;
//        end
//        else begin
            case({BPU__Branch_Taken__ID_EX,Branch_Taken})
                2'b00 : begin
                    Branch_Taken__ex_mem <= 1'b0;                               
                    Branch_Target_Addr__ex_mem <= pc_id_ex + 4;
                end
                2'b01 : begin
                    Branch_Taken__ex_mem <= Branch_Taken;                               
                    Branch_Target_Addr__ex_mem <= adderout;
                end
                2'b10 : begin
                    Branch_Taken__ex_mem <= ~Branch_Taken;                               
                    Branch_Target_Addr__ex_mem <= pc_id_ex + 4;                      
                end
                2'b11 : begin
                    if ((JALR_Inst__ID_EX == 1'b1) && (BPU__Branch_Target_Addr__ID_EX != adderout)) begin // && (Branch_Type__ID_EX == 3'b011) 
                        Branch_Taken__ex_mem <= Branch_Taken;                               
                        Branch_Target_Addr__ex_mem <= adderout;   
                    end
                    else begin
                        Branch_Taken__ex_mem <= 1'b0;                               
                        Branch_Target_Addr__ex_mem <= pc_id_ex + 4;   
                   end
                end
                default: begin
                    Branch_Taken__ex_mem <= 1'b0;                               
                    Branch_Target_Addr__ex_mem <= pc_id_ex + 4;
                end
            endcase
        //end
        
        RAS_RET_Inst_EX__ex_mem <= ((JALR_Inst__ID_EX == 1'b1) && (Branch_Type__ID_EX == 3'b011) && (BPU__Branch_Taken__ID_EX == 1'b0)) ? 1'b1 : 1'b0;
        
        RAS_CALL_Inst__ex_mem <= (((JAL_Inst__ID_EX == 1'b1) || (JALR_Inst__ID_EX == 1'b1)) && (Branch_Type__ID_EX == 3'b010)) ? 1'b1 : 1'b0;
        
        RAS_CALL_Inst_nextPC__ex_mem <= pc_id_ex + 4;
         
    end
end













assign muldiv_rs1 = (Forward_RS1_MEM_FP__ID_EX) ? FP__RD_Data_Int__EX_MEM :
                    (Forward_RS1_WB_FP__ID_EX) ? FP__RD_Data_Int__MEM_WB :
                    (Forward_RS1_MEM__ID_EX) ? RD_Data__EX_MEM : 
                    (Forward_RS1_WB__ID_EX) ? RD_Data__MEM_WB : RS1_Data__ID_EX;       //select usual data or forwarded data(data from ex/mem reg is given priority)

assign muldiv_rs2 = (Forward_RS2_MEM_FP__ID_EX) ? FP__RD_Data_Int__EX_MEM :
                    (Forward_RS2_WB_FP__ID_EX) ? FP__RD_Data_Int__MEM_WB :
                    (Forward_RS2_MEM__ID_EX) ? RD_Data__EX_MEM : 
                    (Forward_RS2_WB__ID_EX) ? RD_Data__MEM_WB : RS2_Data__ID_EX;       //select usual data or forwarded data(data from ex/mem reg is given priority)              

always @( posedge CLK) begin
    if(RST) begin
        state <= idle;
    end
    else if(~Mult_Div_unit_Freeze) begin
        state <= next_state;
    end
end

//edge detector logic for Div_En__ID_EX signal. We want to use only the 0-to-1 transition of Div_En__ID_EX for starting the fsm.
always @(posedge CLK ) begin
    if(RST | Mult_Div_unit_Freeze) begin
        signal_div_kill <= 1'b0;
    end
    else begin
        signal_div_kill <= Mult_Div_unit__Stall;
    end
end

reg Mult_Div_unit_State_Freeze__reg;

always @(posedge CLK ) begin
    if(RST) begin
        Mult_Div_unit_State_Freeze__reg <= 1'b0;
    end
    else begin
        Mult_Div_unit_State_Freeze__reg <= Mult_Div_unit_Freeze;
    end
end


assign div_start = (~signal_div_kill) & (Div_En__ID_EX); 


always @(*) begin
    case(state) 
        idle :  begin
            mul_rst <= ~Mult_En__ID_EX;                //Mult_En__ID_EX given by decode unit
            mul_res_sel <= 1'b0;
            if(Mult_En__ID_EX) begin
                Mult_Div_unit__Stall <= Mult_Div_unit__Stall_disable ? 1'b0 : 1'b1;
                next_state <= stay;
            end
            else if(div_start) begin
                next_state <= div_stay;
                Mult_Div_unit__Stall <= Mult_Div_unit__Stall_disable ? 1'b0 : 1'b1;
            end
            else begin
                Mult_Div_unit__Stall <= 1'b0;
                next_state <= idle;
            end
        end
        
        stay :  begin
            mul_rst <= 1'b0;
            Mult_Div_unit__Stall <= Mult_Div_unit__Stall_disable ? 1'b0 : 1'b1;
            next_state <= act;
            mul_res_sel <= 1'b0;
        end
        
        div_stay :  begin
            mul_rst <= 1'b0;
            mul_res_sel <= 1'b0;
            
            if (Mult_Div_unit_State_Freeze__reg) begin
                next_state <= idle;
                Mult_Div_unit__Stall <= 1'b0; 
            end
            else begin
                next_state <= done_div ? idle : div_stay;
                Mult_Div_unit__Stall <= Mult_Div_unit__Stall_disable ? 1'b0 : ~done_div; 
            end         
        end
        
        act :  begin
            mul_rst <= 1'b0;
            Mult_Div_unit__Stall <= 1'b0;
            next_state <= idle;
            mul_res_sel <= 1'b0;
        end
        
        default : begin
            next_state <= idle;
            mul_res_sel <= 1'b0;
            mul_rst <= 1'b0;
            Mult_Div_unit__Stall <= 1'b0;            
        end
    endcase
end

assign div_res = (Inst_Cache__Stall__reg == 1'b1) ? div_res__reg : div_res__temp;
assign mul_res = (Inst_Cache__Stall__reg == 1'b1) ? mul_res__reg : mul_res__temp;

always @(posedge CLK) begin
    if(RST) begin
        div_res__reg <= 32'b0;
        mul_res__reg <= 32'b0;
    end
    else if ((Inst_Cache__Stall__reg == 1'b0) && (Inst_Cache__Stall == 1'b1)) begin
        div_res__reg <= div_res__temp;
        mul_res__reg <= mul_res__temp;
    end 
end



or1200_amultp2_32x32 or1( .X(muldiv_rs1), 
                          .Y(muldiv_rs2), 
                          .RST(mul_rst), 
                          .CLK(CLK),
                          .mul_op(Mult_Op__ID_EX),
                          .result_mul(mul_res__temp),
                          .FREEZE(Mult_Div_unit_Freeze));

divider div1(.dividend(muldiv_rs1),
             .divisor(muldiv_rs2),
             .clk(CLK),
             .result(div_res__temp),
             .sign(Div_Op__ID_EX[0]),
             .rst(RST),
             .op(Div_Op__ID_EX[1]),
             .start(div_start),
             .done(done_div)); 

endmodule
