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

// Input

// Opcode values in Instruction__IF_ID

`define OP_LOAD_FP      7'b0000111
`define OP_STORE_FP     7'b0100111
`define OP_MADD         7'b1000011
`define OP_MSUB         7'b1000111
`define OP_NMSUB        7'b1001011
`define OP_NMADD        7'b1001111
`define OP_FP           7'b1010011


`define FUNC_SP 2'b00
`define FUNC_DP 2'b01

// Function values in Instruction__IF_ID

`define FADD        5'b00000
`define FSUB        5'b00001
`define FMUL        5'b00010
`define FDIV        5'b00011
`define FSQRT       5'b01011
`define FSGNJ       5'b00100
`define FMIN_MAX    5'b00101
`define FCVT_W_FP   5'b11000
`define FCVT_FP_W   5'b11010
`define FCVT_FP_FP  5'b01000
`define FMV_X_W     5'b11100
`define FMV_W_X     5'b11110                      
`define FEQ_LT_LE   5'b10100

// Sub_Function values in Instruction__IF_ID

`define FUNC_SGNJ   3'b000
`define FUNC_SGNJN  3'b001
`define FUNC_SGNJX  3'b010


`define FUNC_MIN    3'b000
`define FUNC_MAX    3'b001


`define FUNC_SIGNED     1'b0
`define FUNC_UNSIGNED   1'b1


`define FUNC_MV_X_W 3'b000
`define FUNC_CLASS 3'b001


`define FUNC_EQ 3'b010
`define FUNC_LT 3'b001
`define FUNC_LE 3'b000






//Output
 
//values for FP__Fpu_Operation__id_ex

`define ADD             3'b000
`define MULT            3'b001
`define DIV             3'b010
`define SQRT            3'b011
`define COMPARE         3'b100
`define CONVERT         3'b101
`define FUSED_MULT_ADD  3'b110
`define TRANSFER        3'b111

//values for FP__Fpu_Sub_Op__id_ex

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

`define FMADD   3'b000
`define FMSUB   3'b001
`define FNMADD  3'b010
`define FNMSUB  3'b011

`define MOV_INT_FP  3'b000
`define MOV_FP_INT  3'b001
`define FCLASS      3'b100






module FP_DECODE
(
    input CLK,
    input RST,
    
    // Input - Output
    input [31:0] Instruction__IF_ID,
    input Branch_Taken__EX_MEM,                                     //Branch decision calculated in EX stage from EX_MEM stage
    input NOP__IF_ID,                                               //Branch decision calculated in EX stage from EX_MEM stage register in IF_ID stage
    
    // Output to Reg File
    output reg [4:0] FP__RS1_Addr__rf,
    output reg [4:0] FP__RS2_Addr__rf,
    output reg [4:0] FP__RS3_Addr__rf,
    output reg [4:0] FP__RS1_Addr_Int__rf,
    output reg FP__RS1_read_Int__rf,
    
    // Input data read from reg file
    input [63:0] FP__RS1_Data__rf,         
    input [63:0] FP__RS2_Data__rf,
    input [63:0] FP__RS3_Data__rf,
    input [31:0] FP__RS1_Data_Int__rf,
    
    output reg [4:0] FP__RD_Addr__id_ex,
    output reg FP__Reg_Write_En__id_ex,
    output reg [4:0] FP__RD_Addr_Int__id_ex,
    output reg FP__Reg_Write_En_Int__id_ex,
    
    // Input for forwarding unit
    input FP__Reg_Write_En__ID_EX,
    input FP__Reg_Write_En__EX_MEM,
    input [4:0] FP__RD_Addr__ID_EX,
    input [4:0] FP__RD_Addr__EX_MEM,
    
    input Reg_Write_Enable__ID_EX,                  //Reg write-back control signal from ID_EX stage
    input Reg_Write_Enable__EX_MEM,                 //Reg write-back control signal from EX_MEM stage
    input [4:0] RD_Addr__ID_EX,                     //Destination Register Addr from ID_EX stage
    input [4:0] RD_Addr__EX_MEM,                    //Destination Register Addr from EX_MEM stage  
    
    input FP__Reg_Write_En_Int__ID_EX,
    input FP__Reg_Write_En_Int__EX_MEM,
    input [4:0] FP__RD_Addr_Int__ID_EX,
    input [4:0] FP__RD_Addr_Int__EX_MEM,
    
    // Output for forwarding unit
    output reg FP__Forward_RS1_MEM__id_ex,
    output reg FP__Forward_RS2_MEM__id_ex,
    output reg FP__Forward_RS3_MEM__id_ex,
    output reg FP__Forward_RS1_WB__id_ex,
    output reg FP__Forward_RS2_WB__id_ex,
    output reg FP__Forward_RS3_WB__id_ex,
    output reg FP__Forward_RS1_MEM_Int__id_ex,              //MEM stage forwarding for RS1 control signal to ID_EX stage
    output reg FP__Forward_RS1_WB_Int__id_ex,               //WB stage forwarding for rs1 control signal to ID_EX stage  
    output reg FP__Forward_RS1_MEM_Int_FP__id_ex,              
    output reg FP__Forward_RS1_WB_Int_FP__id_ex,               

    // Output Control signals to EX stage
    output reg [2:0] FP__Fpu_Operation__id_ex,
    output reg [2:0] FP__Fpu_Sub_Op__id_ex,
    output reg [2:0] FP__Rounding_Mode__id_ex, 
    output reg FP__SP_DP__id_ex,
    output reg FP__Fpu_Inst__id_ex,
    output reg [63:0] FP__RS1_Data__id_ex,
    output reg [63:0] FP__RS2_Data__id_ex,
    output reg [63:0] FP__RS3_Data__id_ex,
    
    output reg [63:0] FP__Store_Data__id_ex,
    output reg FP__Load_Inst__id_ex,
    output reg FP__Store_Inst__id_ex,
    
    input [31:0] inst_inj,
    input irq_ctrl    
);
    







// Signals
wire FPU_load_store_op;
wire FPU_fused_muladd_op;
wire FPU_op;
wire FPU_load_op;
wire FPU_store_op;


wire [4:0] FP_RF_write_addr_int;
wire [4:0] FP_RF_read_addr_1_int;
wire [4:0] FP_RF_read_addr_2_int;
wire [4:0] FP_RF_read_addr_3_int;

wire FP_RF_write_op_int;
wire FP_RF_read_op_1;
wire FP_RF_read_op_2;
wire FP_RF_read_op_3;


wire [4:0] FP_INT_RF_read_addr_1_int;
wire FP_INT_RF_read_op_1;

wire [4:0] FP_INT_RF_write_addr_int;
wire FP_INT_RF_write_op_int;

reg [4:0] write_addr_EX;
reg [4:0] write_addr_MEM;
reg [4:0] write_addr_WB;
reg [4:0] Int_write_addr_WB;      
reg [4:0] Int_write_addr_MEM; 
reg [4:0] Int_write_addr_FP_WB;      
reg [4:0] Int_write_addr_FP_MEM; 


//wire [31:0] Instruction__IF_ID;
//assign Instruction__IF_ID = irq_ctrl ? 32'b0 : Instruction;



// Instruction__IF_ID type decode
assign FPU_load_op = (Instruction__IF_ID[6:0] == `OP_LOAD_FP) ? 1'b1 : 1'b0;

assign FPU_store_op = (Instruction__IF_ID[6:0] == `OP_STORE_FP) ? 1'b1 : 1'b0;

assign FPU_load_store_op = ((Instruction__IF_ID[6:0] == `OP_LOAD_FP) | (Instruction__IF_ID[6:0] == `OP_STORE_FP)) ? 1'b1 : 1'b0;

assign FPU_fused_muladd_op = ((Instruction__IF_ID[6:0] == `OP_MADD) | (Instruction__IF_ID[6:0] == `OP_MSUB) | (Instruction__IF_ID[6:0] == `OP_NMSUB) | (Instruction__IF_ID[6:0] == `OP_NMADD)) ? 1'b1 : 1'b0;

assign FPU_op = (Instruction__IF_ID[6:0] == `OP_FP) ? 1'b1 : 1'b0;



// read - write addr decode
assign FP_RF_write_addr_int = Instruction__IF_ID[11:7];
assign FP_RF_read_addr_1_int = Instruction__IF_ID[19:15];
assign FP_RF_read_addr_2_int = Instruction__IF_ID[24:20];
assign FP_RF_read_addr_3_int = Instruction__IF_ID[31:27];

assign FP_INT_RF_read_addr_1_int = FP_INT_RF_read_op_1 ? Instruction__IF_ID[19:15] : 5'b00000;     // FP operation - integer file read
assign FP_INT_RF_write_addr_int = FP_INT_RF_write_op_int ? Instruction__IF_ID[11:7] : 5'b00000;        // FP operation - integer file write


// read - write operation control signals
assign FP_RF_write_op_int = ((Instruction__IF_ID[6:0] == `OP_LOAD_FP) | FPU_fused_muladd_op | (FPU_op & ((Instruction__IF_ID[31:27] == `FADD) | (Instruction__IF_ID[31:27] == `FSUB) | (Instruction__IF_ID[31:27] == `FMUL)
                                                                                | (Instruction__IF_ID[31:27] == `FDIV) | (Instruction__IF_ID[31:27] == `FSQRT) | (Instruction__IF_ID[31:27] == `FSGNJ) 
                                                                                | (Instruction__IF_ID[31:27] == `FMIN_MAX) | (Instruction__IF_ID[31:27] == `FCVT_FP_FP) | (Instruction__IF_ID[31:27] == `FCVT_FP_W) 
                                                                                | (Instruction__IF_ID[31:27] == `FMV_W_X)))) ? 1'b1 : 1'b0;

assign FP_RF_read_op_1 = (FPU_fused_muladd_op | (FPU_op & ((Instruction__IF_ID[31:27] == `FADD) | (Instruction__IF_ID[31:27] == `FSUB) | (Instruction__IF_ID[31:27] == `FMUL)
                                                                                | (Instruction__IF_ID[31:27] == `FDIV) | (Instruction__IF_ID[31:27] == `FSQRT) | (Instruction__IF_ID[31:27] == `FSGNJ) 
                                                                                | (Instruction__IF_ID[31:27] == `FMIN_MAX) | (Instruction__IF_ID[31:27] == `FCVT_W_FP) | (Instruction__IF_ID[31:27] == `FCVT_FP_FP) 
                                                                                | (Instruction__IF_ID[31:27] == `FMV_X_W) | (Instruction__IF_ID[31:27] == `FEQ_LT_LE)))) ? 1'b1 : 1'b0;

assign FP_RF_read_op_2 = ((Instruction__IF_ID[6:0] == `OP_STORE_FP) | FPU_fused_muladd_op | (FPU_op & ((Instruction__IF_ID[31:27] == `FADD) | (Instruction__IF_ID[31:27] == `FSUB) | (Instruction__IF_ID[31:27] == `FMUL)
                                                            | (Instruction__IF_ID[31:27] == `FDIV) | (Instruction__IF_ID[31:27] == `FSGNJ) | (Instruction__IF_ID[31:27] == `FMIN_MAX) 
                                                            | (Instruction__IF_ID[31:27] == `FEQ_LT_LE)))) ? 1'b1 : 1'b0;

assign FP_RF_read_op_3 = (FPU_fused_muladd_op) ? 1'b1 : 1'b0;

assign FP_INT_RF_read_op_1 = (FPU_op & ((Instruction__IF_ID[31:27] == `FCVT_FP_W) | (Instruction__IF_ID[31:27] == `FMV_W_X))) ? 1'b1 : 1'b0;

assign FP_INT_RF_write_op_int = (FPU_op & ((Instruction__IF_ID[31:27] == `FCVT_W_FP) | (Instruction__IF_ID[31:27] == `FMV_X_W) | (Instruction__IF_ID[31:27] == `FEQ_LT_LE))) ? 1'b1 : 1'b0;






// write addr of prev Instruction__IF_ID -- Forwarding
always @(*) begin
    if(RST) begin
        write_addr_WB <= 5'b0;      
        write_addr_MEM <= 5'b0;      
        write_addr_EX <= 5'b0; 
        Int_write_addr_WB <= 5'b0;      
        Int_write_addr_MEM <= 5'b0;    
        Int_write_addr_FP_WB <= 5'b0;      
        Int_write_addr_FP_MEM <= 5'b0;         
    end
    else begin
        write_addr_WB <= FP__RD_Addr__EX_MEM;
        write_addr_MEM <= FP__RD_Addr__ID_EX;
        write_addr_EX <= FP_RF_write_addr_int; 
        Int_write_addr_WB <= RD_Addr__EX_MEM;      
        Int_write_addr_MEM <= RD_Addr__ID_EX;         
        Int_write_addr_FP_WB <= FP__RD_Addr_Int__EX_MEM;      
        Int_write_addr_FP_MEM <= FP__RD_Addr_Int__ID_EX;            
    end
end
        
// Forwarding control signals
always @(*) begin
    if(RST | Branch_Taken__EX_MEM | NOP__IF_ID) begin
        FP__Forward_RS1_MEM__id_ex <= 1'b0;      
        FP__Forward_RS2_MEM__id_ex <= 1'b0;      
        FP__Forward_RS3_MEM__id_ex <= 1'b0;  
        FP__Forward_RS1_WB__id_ex <= 1'b0;      
        FP__Forward_RS2_WB__id_ex <= 1'b0;      
        FP__Forward_RS3_WB__id_ex <= 1'b0; 
        FP__Forward_RS1_MEM_Int__id_ex <= 1'b0;   
        FP__Forward_RS1_WB_Int__id_ex <= 1'b0; 
        FP__Forward_RS1_MEM_Int_FP__id_ex <= 1'b0;   
        FP__Forward_RS1_WB_Int_FP__id_ex <= 1'b0; 
    end
    else begin
        FP__Forward_RS1_MEM__id_ex <= FP_RF_read_op_1 ? ((write_addr_MEM == FP_RF_read_addr_1_int) & FP__Reg_Write_En__ID_EX) : 1'b0;      
        FP__Forward_RS2_MEM__id_ex <= FP_RF_read_op_2 ? ((write_addr_MEM == FP_RF_read_addr_2_int) & FP__Reg_Write_En__ID_EX) : 1'b0;      
        FP__Forward_RS3_MEM__id_ex <= FP_RF_read_op_3 ? ((write_addr_MEM == FP_RF_read_addr_3_int) & FP__Reg_Write_En__ID_EX) : 1'b0;  
        FP__Forward_RS1_WB__id_ex <= FP_RF_read_op_1 ? ((write_addr_WB == FP_RF_read_addr_1_int) & FP__Reg_Write_En__EX_MEM) : 1'b0;      
        FP__Forward_RS2_WB__id_ex <= FP_RF_read_op_2 ? ((write_addr_WB == FP_RF_read_addr_2_int) & FP__Reg_Write_En__EX_MEM) : 1'b0;      
        FP__Forward_RS3_WB__id_ex <= FP_RF_read_op_3 ? ((write_addr_WB == FP_RF_read_addr_3_int) & FP__Reg_Write_En__EX_MEM) : 1'b0; 
        FP__Forward_RS1_MEM_Int__id_ex <= FP_INT_RF_read_op_1 ? ((Int_write_addr_MEM == FP_INT_RF_read_addr_1_int) & Reg_Write_Enable__ID_EX) : 1'b0;   
        FP__Forward_RS1_WB_Int__id_ex <= FP_INT_RF_read_op_1 ? ((Int_write_addr_WB == FP_INT_RF_read_addr_1_int) & Reg_Write_Enable__EX_MEM) : 1'b0;            
        FP__Forward_RS1_MEM_Int_FP__id_ex <= FP_INT_RF_read_op_1 ? ((Int_write_addr_FP_MEM == FP_INT_RF_read_addr_1_int) & FP__Reg_Write_En_Int__ID_EX) : 1'b0;    
        FP__Forward_RS1_WB_Int_FP__id_ex <= FP_INT_RF_read_op_1 ? ((Int_write_addr_FP_WB == FP_INT_RF_read_addr_1_int) & FP__Reg_Write_En_Int__EX_MEM) : 1'b0;          
    end
end


// Reg File read addr assign
always @(*) begin
    if(RST | Branch_Taken__EX_MEM | NOP__IF_ID) begin
        FP__RD_Addr__id_ex <= {5{1'b0}};
        FP__RS1_Addr__rf <= {5{1'b0}};
        FP__RS2_Addr__rf <= {5{1'b0}};
        FP__RS3_Addr__rf <= {5{1'b0}};
        FP__RS1_Addr_Int__rf <= {5{1'b0}};
        FP__RS1_read_Int__rf <= 1'b0;
        FP__Reg_Write_En__id_ex <= 1'b0; 
    end
    else begin
        FP__RD_Addr__id_ex <= FP_RF_write_addr_int;
        FP__RS1_Addr__rf <= FP_RF_read_addr_1_int;
        FP__RS2_Addr__rf <= FP_RF_read_addr_2_int;
        FP__RS3_Addr__rf <= FP_RF_read_addr_3_int;
        FP__RS1_Addr_Int__rf <= FP_INT_RF_read_addr_1_int;
        FP__RS1_read_Int__rf <= FP_INT_RF_read_op_1;
        FP__Reg_Write_En__id_ex <= FP_RF_write_op_int;
    end
end


// read data assign
always @(*) begin
    if(RST | Branch_Taken__EX_MEM | NOP__IF_ID) begin
        FP__RS1_Data__id_ex <= {64{1'b0}};
        FP__RS2_Data__id_ex <= {64{1'b0}};
        FP__RS3_Data__id_ex <= {64{1'b0}};
        
        FP__Store_Data__id_ex <= {64{1'b0}};
    end
    else begin
        FP__RS1_Data__id_ex <= FP_INT_RF_read_op_1 ? {{32{1'b0}}, FP__RS1_Data_Int__rf} : FP__RS1_Data__rf;
        FP__RS2_Data__id_ex <= FP__RS2_Data__rf;
        FP__RS3_Data__id_ex <= FP__RS3_Data__rf;
        
        FP__Store_Data__id_ex <= FP__RS2_Data__rf;
    end
end


// Decoding Instruction__IF_ID
always @(*) begin
    if (RST | Branch_Taken__EX_MEM | NOP__IF_ID) begin
        FP__Fpu_Operation__id_ex <= 3'b000;
        FP__Fpu_Sub_Op__id_ex <= 3'b000;
        FP__Rounding_Mode__id_ex <= 3'b000;
        FP__SP_DP__id_ex <= 1'b0;
        FP__Reg_Write_En_Int__id_ex <= 1'b0;
        FP__RD_Addr_Int__id_ex <= {5{1'b0}};
        FP__Fpu_Inst__id_ex <= 1'b0;
        FP__Load_Inst__id_ex <= 1'b0;
        FP__Store_Inst__id_ex <= 1'b0;  
    end
    else begin
        FP__SP_DP__id_ex <= FPU_load_store_op ? Instruction__IF_ID[12] : Instruction__IF_ID[25];
        FP__Rounding_Mode__id_ex <= Instruction__IF_ID[14:12];
        FP__Fpu_Inst__id_ex <= (FPU_op | FPU_fused_muladd_op);
        FP__Reg_Write_En_Int__id_ex <= FP_INT_RF_write_op_int;
        FP__RD_Addr_Int__id_ex <= FP_INT_RF_write_addr_int;
        FP__Load_Inst__id_ex <= FPU_load_op;
        FP__Store_Inst__id_ex <= FPU_store_op; 
        if (FPU_fused_muladd_op == 1'b1) begin
            FP__Fpu_Operation__id_ex <= `FUSED_MULT_ADD;
            case(Instruction__IF_ID[6:0]) 
                `OP_MADD:   FP__Fpu_Sub_Op__id_ex <= `FMADD; 
                `OP_MSUB:   FP__Fpu_Sub_Op__id_ex <= `FMSUB;
                `OP_NMSUB:  FP__Fpu_Sub_Op__id_ex <= `FNMSUB;  
                `OP_NMADD:  FP__Fpu_Sub_Op__id_ex <= `FNMADD; 
                default:    FP__Fpu_Sub_Op__id_ex <= 3'b000;
            endcase
        end
        else if (FPU_op == 1'b1) begin
            case(Instruction__IF_ID[31:27]) 
                `FADD: begin
                    FP__Fpu_Operation__id_ex <= `ADD;
                    FP__Fpu_Sub_Op__id_ex <= 3'b000;
                end
                
                `FSUB: begin
                    FP__Fpu_Operation__id_ex <= `ADD;
                    FP__Fpu_Sub_Op__id_ex <= 3'b001;                
                end
                
                `FMUL: begin
                    FP__Fpu_Operation__id_ex <= `MULT;
                    FP__Fpu_Sub_Op__id_ex <= 3'b000;             
                end
                
                `FDIV: begin
                    FP__Fpu_Operation__id_ex <= `DIV;
                    FP__Fpu_Sub_Op__id_ex <= 3'b000;            
                end
                
                `FSQRT: begin
                    FP__Fpu_Operation__id_ex <= `SQRT;
                    FP__Fpu_Sub_Op__id_ex <= 3'b000;  
                end
                
                `FSGNJ: begin
                    FP__Fpu_Operation__id_ex <= `CONVERT;
                    case(Instruction__IF_ID[14:12]) 
                        `FUNC_SGNJ:     FP__Fpu_Sub_Op__id_ex <= `SIGN_INJECTION;
                        `FUNC_SGNJN:    FP__Fpu_Sub_Op__id_ex <= `SIGN_INJECTION_NEG; 
                        `FUNC_SGNJX:    FP__Fpu_Sub_Op__id_ex <= `SIGN_INJECTION_XOR;
                        default:        FP__Fpu_Sub_Op__id_ex <= 3'b000;
                    endcase                
                end
                
                `FMIN_MAX: begin
                    FP__Fpu_Operation__id_ex <= `COMPARE;
                    case(Instruction__IF_ID[14:12]) 
                        `FUNC_MIN:      FP__Fpu_Sub_Op__id_ex <= `MIN;
                        `FUNC_MAX:      FP__Fpu_Sub_Op__id_ex <= `MAX; 
                        default:        FP__Fpu_Sub_Op__id_ex <= 3'b000;
                    endcase               
                end
                
                `FCVT_W_FP: begin
                    FP__Fpu_Operation__id_ex <= `CONVERT;
                    if (Instruction__IF_ID[20] == `FUNC_UNSIGNED)
                        FP__Fpu_Sub_Op__id_ex <= `FP_TO_INT_UNSIGNED;
                    else
                        FP__Fpu_Sub_Op__id_ex <= `FP_TO_INT_SIGNED;
                end
                
                `FCVT_FP_W: begin
                    FP__Fpu_Operation__id_ex <= `CONVERT;
                    if (Instruction__IF_ID[20] == `FUNC_UNSIGNED)
                        FP__Fpu_Sub_Op__id_ex <= `INT_TO_FP_UNSIGNED;
                    else
                        FP__Fpu_Sub_Op__id_ex <= `INT_TO_FP_SIGNED;                
                end
                
                `FCVT_FP_FP: begin
                    FP__Fpu_Operation__id_ex <= `CONVERT;
                    FP__Fpu_Sub_Op__id_ex <= `FP_TO_FP;             
                end
                
                `FMV_X_W: begin
                    FP__Fpu_Operation__id_ex <= `TRANSFER;
                    case(Instruction__IF_ID[14:12]) 
                        `FUNC_MV_X_W:   FP__Fpu_Sub_Op__id_ex <= `MOV_INT_FP;
                        `FUNC_CLASS:    FP__Fpu_Sub_Op__id_ex <= `FCLASS; 
                        default:        FP__Fpu_Sub_Op__id_ex <= 3'b000;
                    endcase         
                end
                
                `FMV_W_X: begin
                    FP__Fpu_Operation__id_ex <= `TRANSFER;
                    FP__Fpu_Sub_Op__id_ex <= `MOV_FP_INT;  
                end
                
                `FEQ_LT_LE: begin
                    FP__Fpu_Operation__id_ex <= `COMPARE;
                    case(Instruction__IF_ID[14:12]) 
                        `FUNC_EQ:   FP__Fpu_Sub_Op__id_ex <= `EQUAL;
                        `FUNC_LT:   FP__Fpu_Sub_Op__id_ex <= `LESS_THAN; 
                        `FUNC_LE:   FP__Fpu_Sub_Op__id_ex <= `LESS_OR_EQUAL;
                        default:    FP__Fpu_Sub_Op__id_ex <= 3'b000;
                    endcase              
                end
                
                default: begin
                    FP__Fpu_Operation__id_ex <= 3'b000;
                    FP__Fpu_Sub_Op__id_ex <= 3'b000;
                end
            endcase
        end
        else begin
            FP__Fpu_Operation__id_ex <= 3'b000;
            FP__Fpu_Sub_Op__id_ex <= 3'b000;
        end
    end     
end



endmodule
