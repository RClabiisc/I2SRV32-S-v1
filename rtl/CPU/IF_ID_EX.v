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

module IF_ID_EX
(
    input CLK,
    input RST,
    
    
    
    
    output [4:0] Load_Store_Op__Port1,                          //memory stage operation signals to lsu
    output reg [31:0] proc_addr_port1,                  //to memory stage
    output [31:0] Store_Data,                       //data to be stored(only used for memory stage)
    output lsustall_o,                                  //mem stage Load__Stall
    output reg Load__Stall,
    input  Data_Cache__Stall,
    input  [31:0] proc_data_port1_int,
    
    output [4:0] lsu_op_port2,
    output reg [31:0] proc_addr_port2,                  //contents of rs1 sent to dcache to read dcache
    input [31:0] amo_load_val_i,
        
    
    
    output Inst_Cache_Freeze,
    output [31:0] pc_cache,                             //send pc to data-cache
    input Inst_Cache__Stall,
    input [31:0] Instruction__IF_ID,
    
    
    
    output LR_Inst,                                        //to register file
    output SC_Inst,
    
    
    output Mult_Div_unit__Stall,
    output FPU__Stall,
    
    
    output eret_ack,
    
    
    
    output tick_en,
    input addr_exception,
    input [31:0] interrupt,
    
    
    
    output [63:0] led,
    
    
    `ifdef itlb_def
    output vpn_to_ppn_req
    `endif
);



// IF_ID Register
wire [31:0] PC__IF_ID;
wire [31:0] PC_4__IF_ID;
wire [10:0] BPU__PHT_Read_Index__if_id;
wire [1:0] BPU__PHT_Read_Data__IF_ID;

wire BPU__Branch_Taken__IF_ID;
wire [31:0] BPU__Branch_Target_Addr__IF_ID;
reg [10:0] BPU__PHT_Read_Index__IF_ID;
wire BPU__BTB_Hit__IF_ID;


// ID_EX Register
wire [31:0] RS1_Data__id_ex;
reg  [31:0] RS1_Data__ID_EX;
wire [31:0] RS2_Data__id_ex;
reg  [31:0] RS2_Data__ID_EX;
wire [5:0] Shamt__id_ex;
reg  [5:0] Shamt__ID_EX;
wire [31:0] Immediate__id_ex;
reg  [31:0] Immediate__ID_EX; 
wire [31:0] Store_Data__id_ex;
reg  [31:0] Store_Data__ID_EX;
wire [6:0] Opcode__id_ex;
reg  [6:0] Opcode__ID_EX;
wire [6:0] Funct7__id_ex;
reg  [6:0] Funct7__ID_EX;
wire [2:0] Funct3__id_ex;
reg  [2:0] Funct3__ID_EX;
wire [4:0] RD_Addr__id_ex;
reg  [4:0] RD_Addr__ID_EX;
wire [4:0] Load_Store_Op__id_ex;
reg  [4:0] Load_Store_Op__ID_EX;
wire [1:0] Alu_Src_1_sel__id_ex;
reg  [1:0] Alu_Src_1_sel__ID_EX;
wire [1:0] Alu_Src_2_sel__id_ex;
reg  [1:0] Alu_Src_2_sel__ID_EX;
wire Branch_Inst__id_ex;
reg  Branch_Inst__ID_EX;
wire Forward_RS1_MEM__id_ex; 
reg  Forward_RS1_MEM__ID_EX;
wire Forward_RS2_MEM__id_ex;
reg  Forward_RS2_MEM__ID_EX;
wire Forward_RS1_WB__id_ex;
reg  Forward_RS1_WB__ID_EX;
wire Forward_RS2_WB__id_ex;
reg  Forward_RS2_WB__ID_EX;
wire Forward_RS1_MEM_FP__id_ex; 
reg  Forward_RS1_MEM_FP__ID_EX;
wire Forward_RS2_MEM_FP__id_ex;
reg  Forward_RS2_MEM_FP__ID_EX;
wire Forward_RS1_WB_FP__id_ex;
reg  Forward_RS1_WB_FP__ID_EX;
wire Forward_RS2_WB_FP__id_ex;
reg  Forward_RS2_WB_FP__ID_EX;
wire JAL_Inst__id_ex;
reg  JAL_Inst__ID_EX;
wire JALR_Inst__id_ex;
reg  JALR_Inst__ID_EX; 
wire Reg_Write_Enable__id_ex;
reg  Reg_Write_Enable__ID_EX;
wire AMO_Inst__id_ex;
reg  AMO_Inst__ID_EX;    
wire [1:0] Mult_Op__id_ex;
reg  [1:0] Mult_Op__ID_EX;                            
wire Mult_En__id_ex; 
reg  Mult_En__ID_EX;
wire [1:0] Div_Op__id_ex; 
reg  [1:0] Div_Op__ID_EX;                     
wire Div_En__id_ex;
reg  Div_En__ID_EX;
wire Load__Stall_id_ex;                       
reg  Load__Stall_ID_EX;
wire BPU__Branch_Taken__id_ex;
wire [31:0] BPU__Branch_Target_Addr__id_ex;
wire [10:0] BPU__PHT_Read_Index__id_ex;
wire [1:0] BPU__PHT_Read_Data__id_ex;
wire [2:0] Branch_Type__id_ex; 
wire BPU__BTB_Hit__id_ex; 
reg BPU__Branch_Taken__ID_EX;
reg [31:0] BPU__Branch_Target_Addr__ID_EX;
reg [10:0] BPU__PHT_Read_Index__ID_EX;
reg [1:0] BPU__PHT_Read_Data__ID_EX;
reg [2:0] Branch_Type__ID_EX;  
reg BPU__BTB_Hit__ID_EX;  
    

wire [4:0] FP__RD_Addr__id_ex;
wire FP__Reg_Write_En__id_ex;
wire [4:0] FP__RD_Addr_Int__id_ex;
wire FP__Reg_Write_En_Int__id_ex;
wire FP__Forward_RS1_MEM__id_ex;
wire FP__Forward_RS2_MEM__id_ex;
wire FP__Forward_RS3_MEM__id_ex;
wire FP__Forward_RS1_WB__id_ex;
wire FP__Forward_RS2_WB__id_ex;
wire FP__Forward_RS3_WB__id_ex;
wire FP__Forward_RS1_MEM_Int__id_ex;              
wire FP__Forward_RS1_WB_Int__id_ex;  
wire FP__Forward_RS1_MEM_Int_FP__id_ex;             
wire FP__Forward_RS1_WB_Int_FP__id_ex;                           
wire [2:0] FP__Fpu_Operation__id_ex;
wire [2:0] FP__Fpu_Sub_Op__id_ex;
wire [2:0] FP__Rounding_Mode__id_ex; 
wire FP__SP_DP__id_ex;
wire FP__Fpu_Inst__id_ex;
wire [63:0] FP__RS1_Data__id_ex;
wire [63:0] FP__RS2_Data__id_ex;
wire [63:0] FP__RS3_Data__id_ex;
wire [63:0] FP__Store_Data__id_ex;
wire FP__Load_Inst__id_ex;
wire FP__Store_Inst__id_ex;

reg  [4:0] FP__RD_Addr__ID_EX;
reg  FP__Reg_Write_En__ID_EX;
reg  [4:0] FP__RD_Addr_Int__ID_EX;
reg  FP__Reg_Write_En_Int__ID_EX;
reg  FP__Forward_RS1_MEM__ID_EX;
reg  FP__Forward_RS2_MEM__ID_EX;
reg  FP__Forward_RS3_MEM__ID_EX;
reg  FP__Forward_RS1_WB__ID_EX;
reg  FP__Forward_RS2_WB__ID_EX;
reg  FP__Forward_RS3_WB__ID_EX;
reg  FP__Forward_RS1_MEM_Int__ID_EX;              
reg  FP__Forward_RS1_WB_Int__ID_EX;
reg  FP__Forward_RS1_MEM_Int_FP__ID_EX;             
reg  FP__Forward_RS1_WB_Int_FP__ID_EX;                
reg  [2:0] FP__Fpu_Operation__ID_EX;
reg  [2:0] FP__Fpu_Sub_Op__ID_EX;
reg  [2:0] FP__Rounding_Mode__ID_EX; 
reg  FP__SP_DP__ID_EX;
reg  FP__Fpu_Inst__ID_EX;
reg  [63:0] FP__RS1_Data__ID_EX;
reg  [63:0] FP__RS2_Data__ID_EX;
reg  [63:0] FP__RS3_Data__ID_EX;
reg  [63:0] FP__Store_Data__ID_EX;
reg  FP__Load_Inst__ID_EX;
reg  FP__Store_Inst__ID_EX;
    
// EX_MEM Register
wire Branch_Taken__ex_mem;
reg  Branch_Taken__EX_MEM;
wire [31:0] Branch_Target_Addr__ex_mem;
reg  [31:0] Branch_Target_Addr__EX_MEM;
wire [31:0] RD_Data__ex_mem;
reg  [31:0] RD_Data__EX_MEM;          
wire [31:0] ALU_Result__ex_mem;
reg  [31:0] ALU_Result__EX_MEM;
wire [4:0] RD_Addr__ex_mem;
reg  [4:0] RD_Addr__EX_MEM;
wire Reg_Write_Enable__ex_mem;
reg  Reg_Write_Enable__EX_MEM;
wire [4:0] Load_Store_Op__ex_mem;
reg  [4:0] Load_Store_Op__EX_MEM;       //to keep track of lsuop in the current instr in mem. decides whether wb_data to be used or loaded value.
wire SC_Inst__ex_mem;
reg  SC_Inst__EX_MEM;
wire [31:0] Store_Data__ex_mem;
wire [10:0] PHT_Write_Index__ex_mem;
wire [1:0] PHT_Write_Data__ex_mem;
wire PHT_Write_En__ex_mem;
wire GHR_Write_Data__ex_mem;
wire GHR_Write_En__ex_mem;
wire [31:0] BTB_Write_Addr__ex_mem;
wire [31:0] BTB_Write_Data__ex_mem;
wire BTB_Write_En__ex_mem;
wire RAS_RET_Inst_EX__ex_mem;
wire RAS_CALL_Inst__ex_mem;
wire [31:0] RAS_CALL_Inst_nextPC__ex_mem;

wire [63:0] FP__RD_Data__ex_mem;
wire [31:0] FP__RD_Data_Int__ex_mem;
wire [4:0] FP__RD_Addr__ex_mem;
wire FP__Reg_Write_En__ex_mem;
wire [4:0] FP__RD_Addr_Int__ex_mem;
wire FP__Reg_Write_En_Int__ex_mem;
wire FP__SP_DP__ex_mem;
wire [63:0] FP__Store_Data__ex_mem;
wire FP__Load_Inst__ex_mem; 
wire FP__Store_Inst__ex_mem;

reg  [63:0] FP__RD_Data__EX_MEM;
reg  [31:0] FP__RD_Data_Int__EX_MEM;
reg  [4:0] FP__RD_Addr__EX_MEM;
reg  FP__Reg_Write_En__EX_MEM;
reg  [4:0] FP__RD_Addr_Int__EX_MEM;
reg  FP__Reg_Write_En_Int__EX_MEM;
reg  FP__SP_DP__EX_MEM;
reg  [63:0] FP__Store_Data__EX_MEM;
wire [4:0] FPU_flags;
wire [2:0] frm;


// MEM_WB Register
wire [31:0] RD_Data__mem_wb;
reg  [31:0] RD_Data__MEM_WB;
wire Branch_Taken__mem_wb;
reg  Branch_Taken__MEM_WB;

wire [63:0] FP__RD_Data__mem_wb;
reg  [63:0] FP__RD_Data__MEM_WB;
wire [31:0] FP__RD_Data_Int__mem_wb;
reg  [31:0] FP__RD_Data_Int__MEM_WB;
reg FP__Reg_Write_En_Int__MEM_WB;
wire FP__Reg_Write_En_Int__mem_wb;
 


// Register File
wire [4:0] RS1_Addr__rf;
wire [4:0] RS2_Addr__rf;
wire [31:0] RS1_Data__rf;
wire [31:0] RS2_Data__rf;

wire [4:0] FP__RS1_Addr__rf;
wire [4:0] FP__RS2_Addr__rf;
wire [4:0] FP__RS3_Addr__rf;
wire [4:0] FP__RS1_Addr_Int__rf;
wire FP__RS1_read_Int__rf;
wire [63:0] FP__RS1_Data__rf;         
wire [63:0] FP__RS2_Data__rf;
wire [63:0] FP__RS3_Data__rf;
wire [31:0] FP__RS1_Data_Int__rf;





wire NOP__IF_ID;
wire [31:0] pc_forw;
reg  [31:0] pc_id_ex;
reg  lsustall_i;
wire irq_ctrl_int;
reg irq_ctrl_int2;
wire  csr_wr_en_int;
wire  mepc_res_int;
wire  mret_int;
wire Mult_Div_unit_Freeze;
wire FPU_Freeze;
wire eret_int;
reg irq_ctrl_o;

wire [31:0] csr_mtvec;
wire [31:0] csr_wrdata;
reg [11:0] csr_adr;
wire [11:0] csr_adr_int;
wire [31:0] csr_indata;
reg  csr_wr_en;
reg  mepc_res;
wire  trap_en;
wire badaddr;
wire mtie;

wire [31:0] count;                 //System timers/counter value. RDCYC[H], RDTIM[H], RDINST[H] instructions
reg [3:0] wr_sel;
wire [3:0] count_sel_int;
wire tick_en_int;

wire [31:0] csr_indata_intr;
reg eret;
wire [5:0] device_id;
wire [31:0] inst_inj;              //Injected Instruction__IF_ID stream
wire irq_icache_freeze;
wire eret_o;
wire irq;
wire irq_ack;
wire irq_ctrl;
wire irq_ctrl_wb_i;
wire PC_Control__IRQ;
wire irq_ctrl_dec_src1;
wire irq_ctrl_dec_src2;
wire IF_ID_Freeze__irq;

reg Inst_Cache__Stall__reg;
reg [31:0] proc_data_port1_int__reg;
reg FPU__Stall__reg;
reg [63:0] Double_Load_Data;
reg Mult_Div_unit__Stall__reg;

reg Double_Load_Store__Stall;
reg Double_Load_Store__Stall_reg;
reg Double_Load_Store__Stall_pre;
reg [31:0] Double_Load_Buffer;
reg [31:0] Double_Store_Buffer;
reg [31:0] ALU_Result__ex_mem__reg;

wire Mult_Div_unit__Stall_disable;
wire FPU__Stall_disable;

wire [31:0] inst_out;


assign Inst_Cache_Freeze = (Mult_Div_unit__Stall | FPU__Stall | Data_Cache__Stall | irq_icache_freeze | Double_Load_Store__Stall) ;

assign Mult_Div_unit_Freeze = (Mult_Div_unit__Stall) ? (Data_Cache__Stall | Double_Load_Store__Stall) : (Inst_Cache__Stall | Data_Cache__Stall | Double_Load_Store__Stall);

assign FPU_Freeze = (FPU__Stall) ? (Data_Cache__Stall | Double_Load_Store__Stall) : (Inst_Cache__Stall | Data_Cache__Stall | Double_Load_Store__Stall);

assign Mult_Div_unit__Stall_disable = (Data_Cache__Stall | Double_Load_Store__Stall);

assign FPU__Stall_disable = (Data_Cache__Stall | Double_Load_Store__Stall);





assign Store_Data = Double_Load_Store__Stall_reg ? Double_Store_Buffer : (FP__Store_Inst__ex_mem ? FP__Store_Data__ex_mem[31:0] : Store_Data__ex_mem);

assign SC_Inst = SC_Inst__ex_mem;

assign Load_Store_Op__Port1 = Load_Store_Op__ex_mem;



assign tick_en  = tick_en_int && mtie;

assign badaddr = ((~proc_addr_port1[0] && ~proc_addr_port1[1]) || (~pc_id_ex[0] && ~pc_id_ex[1])) ;

assign RD_Data__mem_wb = (((~Load_Store_Op__EX_MEM[1]) & (Load_Store_Op__EX_MEM[0])) | SC_Inst__EX_MEM) ? (((Inst_Cache__Stall__reg == 1'b1) || (FPU__Stall__reg == 1'b1) || (Mult_Div_unit__Stall__reg == 1'b1)) ? proc_data_port1_int__reg : proc_data_port1_int) : RD_Data__EX_MEM;         //For conventional loads

assign FP__RD_Data__mem_wb = ((~Load_Store_Op__EX_MEM[1]) & (Load_Store_Op__EX_MEM[0])) ? (((Inst_Cache__Stall__reg == 1'b1) || (FPU__Stall__reg == 1'b1) || (Mult_Div_unit__Stall__reg == 1'b1)) ? ((FP__SP_DP__EX_MEM) ? Double_Load_Data : proc_data_port1_int__reg) : ((FP__SP_DP__EX_MEM) ? {proc_data_port1_int,Double_Load_Buffer} : proc_data_port1_int)) : FP__RD_Data__EX_MEM;    

assign FP__RD_Data_Int__mem_wb = FP__RD_Data_Int__EX_MEM;

assign FP__Reg_Write_En_Int__mem_wb = FP__Reg_Write_En_Int__EX_MEM;

assign FP__RS1_Data_Int__rf = RS1_Data__rf;

assign Branch_Taken__mem_wb = Branch_Taken__EX_MEM;



always @(*) begin

    proc_addr_port1 <= AMO_Inst__ID_EX ? (Forward_RS1_MEM__ID_EX ? (ALU_Result__EX_MEM) : (Forward_RS1_WB__ID_EX ? RD_Data__MEM_WB : RS1_Data__ID_EX)) : (Double_Load_Store__Stall_reg ? (ALU_Result__ex_mem__reg + 4) : ALU_Result__ex_mem);
    
    proc_addr_port2 <= Forward_RS1_MEM__id_ex ? RD_Data__ex_mem : (Forward_RS1_WB__id_ex ? RD_Data__mem_wb : RS1_Data__rf);    //forwarding for rs1 of amo
    
    Load__Stall <= (Mult_Div_unit__Stall || FPU__Stall || Data_Cache__Stall || Inst_Cache__Stall || Double_Load_Store__Stall) ? 1'b0 : Load__Stall_id_ex;
    
end




always @(posedge CLK ) begin
    if(RST) begin
        Double_Load_Store__Stall_reg <= 1'b0;
    end
    else if(~(Mult_Div_unit__Stall || FPU__Stall || Data_Cache__Stall || Inst_Cache__Stall)) begin
        Double_Load_Store__Stall_reg <= Double_Load_Store__Stall;
    end 
end

always @(*) begin
    if (RST) begin
        Double_Load_Store__Stall <= 1'b0;
    end
    else if (Double_Load_Store__Stall_reg == 1'b1) begin
        Double_Load_Store__Stall <= 1'b0;
    end
    else if (Load_Store_Op__ex_mem[4:2] == 3'b011) begin
        Double_Load_Store__Stall <= 1'b1;
    end
    else begin
        Double_Load_Store__Stall <= 1'b0;
    end
end

always @(posedge CLK ) begin
    if(RST) begin
        Double_Load_Buffer <= 32'h00000000;
        Double_Store_Buffer <= 32'h00000000;
    end
    else if (Double_Load_Store__Stall_pre) begin
        Double_Load_Buffer <= proc_data_port1_int;
    end 
    else if (Double_Load_Store__Stall) begin
        Double_Store_Buffer <= FP__Store_Data__ex_mem[63:32];
    end 
end

always @(posedge CLK ) begin
    if(RST) begin
        ALU_Result__ex_mem__reg <= 32'h00000000;
    end
    else if(~(Mult_Div_unit__Stall || FPU__Stall || Data_Cache__Stall || Inst_Cache__Stall)) begin
        ALU_Result__ex_mem__reg <= ALU_Result__ex_mem;
    end 
end


always @(posedge CLK ) begin
    if(RST) begin
        Inst_Cache__Stall__reg <= 1'b0;
        FPU__Stall__reg <= 1'b0;
        Mult_Div_unit__Stall__reg <= 1'b0;
    end
    else begin
        Inst_Cache__Stall__reg <= Inst_Cache__Stall;
        FPU__Stall__reg <= FPU__Stall;
        Mult_Div_unit__Stall__reg <= Mult_Div_unit__Stall;
    end 
end

always @(posedge CLK ) begin
    if(RST) begin
        Double_Load_Store__Stall_pre <= 1'b0;
    end
    else if (~Data_Cache__Stall) begin
        Double_Load_Store__Stall_pre <= Double_Load_Store__Stall;
    end 
end





// Register IF_ID stage
always @(posedge RST or posedge CLK) begin
    if(RST) begin   
        BPU__PHT_Read_Index__IF_ID <= 11'b0;            
    end
    else if(~(Mult_Div_unit__Stall || FPU__Stall || Data_Cache__Stall || Inst_Cache__Stall || Double_Load_Store__Stall)) begin
        BPU__PHT_Read_Index__IF_ID <= BPU__PHT_Read_Index__if_id;                      
    end
end


// Register ID_EX stage
always @(posedge CLK ) begin
    if(RST) begin
        RS1_Data__ID_EX <= 32'b0;
        RS2_Data__ID_EX <= 32'b0;
        Shamt__ID_EX <= 6'b0;
        Immediate__ID_EX <= 32'b0;
        Store_Data__ID_EX <= 0;
        Opcode__ID_EX <= 7'b0;
        Funct7__ID_EX <= 7'b0;
        Funct3__ID_EX <= 3'b0;
        RD_Addr__ID_EX <= 5'b0;
        Load_Store_Op__ID_EX <= 5'b0;
        Alu_Src_1_sel__ID_EX <= 2'b0;
        Alu_Src_2_sel__ID_EX <= 2'b0; 
        Branch_Inst__ID_EX <= 1'b0;      
        Forward_RS1_WB__ID_EX <= 1'b0;
        Forward_RS2_WB__ID_EX <= 1'b0;
        Forward_RS1_MEM__ID_EX <= 1'b0;
        Forward_RS2_MEM__ID_EX <= 1'b0;
        Forward_RS1_WB_FP__ID_EX <= 1'b0;
        Forward_RS2_WB_FP__ID_EX <= 1'b0;
        Forward_RS1_MEM_FP__ID_EX <= 1'b0;
        Forward_RS2_MEM_FP__ID_EX <= 1'b0;
        JAL_Inst__ID_EX <= 1'b0;
        JALR_Inst__ID_EX <= 1'b0;
        Reg_Write_Enable__ID_EX <= 1'b0;
        AMO_Inst__ID_EX <= 1'b0; 
        Mult_Op__ID_EX <= 2'b00;
        Mult_En__ID_EX <= 1'b0;
        Div_Op__ID_EX <= 2'b00;
        Div_En__ID_EX <= 1'b0;
        Load__Stall_ID_EX <= 1'b0; 
        BPU__Branch_Taken__ID_EX <= 1'b0; 
        BPU__Branch_Target_Addr__ID_EX <= 32'b0; 
        BPU__PHT_Read_Index__ID_EX <= 11'b0; 
        BPU__PHT_Read_Data__ID_EX <= 2'b0; 
        BPU__BTB_Hit__ID_EX <= 1'b0;
        Branch_Type__ID_EX <= 3'b0;    
        
        FP__RD_Addr__ID_EX <= 5'b0;
        FP__Reg_Write_En__ID_EX <= 1'b0;
        FP__RD_Addr_Int__ID_EX <= 5'b0;   
        FP__Reg_Write_En_Int__ID_EX <= 1'b0;    
        FP__Forward_RS1_MEM__ID_EX <= 1'b0;     
        FP__Forward_RS2_MEM__ID_EX <= 1'b0;     
        FP__Forward_RS3_MEM__ID_EX <= 1'b0;     
        FP__Forward_RS1_WB__ID_EX <= 1'b0;      
        FP__Forward_RS2_WB__ID_EX <= 1'b0;      
        FP__Forward_RS3_WB__ID_EX <= 1'b0;      
        FP__Forward_RS1_MEM_Int__ID_EX <= 1'b0; 
        FP__Forward_RS1_WB_Int__ID_EX <= 1'b0;  
        FP__Forward_RS1_MEM_Int_FP__ID_EX <= 1'b0;
        FP__Forward_RS1_WB_Int_FP__ID_EX <= 1'b0; 
        FP__Fpu_Operation__ID_EX <= 3'b0; 
        FP__Fpu_Sub_Op__ID_EX <= 3'b0;    
        FP__Rounding_Mode__ID_EX <= 3'b0; 
        FP__SP_DP__ID_EX <= 1'b0;               
        FP__Fpu_Inst__ID_EX <= 1'b0;            
        FP__RS1_Data__ID_EX <= 64'b0;     
        FP__RS2_Data__ID_EX <= 64'b0;     
        FP__RS3_Data__ID_EX <= 64'b0; 
        FP__Store_Data__ID_EX <= 64'b0; 
        FP__Load_Inst__ID_EX <= 1'b0; 
        FP__Store_Inst__ID_EX <= 1'b0;   
    end
    else if(~(Mult_Div_unit__Stall || FPU__Stall || Data_Cache__Stall || Inst_Cache__Stall || Double_Load_Store__Stall)) begin
        RS1_Data__ID_EX <= RS1_Data__id_ex;
        RS2_Data__ID_EX <= RS2_Data__id_ex;
        Shamt__ID_EX <= Shamt__id_ex;
        Immediate__ID_EX <= Immediate__id_ex;
        Store_Data__ID_EX <= Store_Data__id_ex;
        Opcode__ID_EX <= Opcode__id_ex;
        Funct7__ID_EX <= Funct7__id_ex;
        Funct3__ID_EX <= Funct3__id_ex;
        RD_Addr__ID_EX <= RD_Addr__id_ex;
        Load_Store_Op__ID_EX <= Load_Store_Op__id_ex;
        Alu_Src_1_sel__ID_EX <= Alu_Src_1_sel__id_ex;
        Alu_Src_2_sel__ID_EX <= Alu_Src_2_sel__id_ex;
        Branch_Inst__ID_EX <= Branch_Inst__id_ex;
        Forward_RS1_WB__ID_EX <= Forward_RS1_WB__id_ex;
        Forward_RS2_WB__ID_EX <= Forward_RS2_WB__id_ex;
        Forward_RS1_MEM__ID_EX <= Forward_RS1_MEM__id_ex;
        Forward_RS2_MEM__ID_EX <= Forward_RS2_MEM__id_ex;
        Forward_RS1_WB_FP__ID_EX <= Forward_RS1_WB_FP__id_ex;
        Forward_RS2_WB_FP__ID_EX <= Forward_RS2_WB_FP__id_ex;
        Forward_RS1_MEM_FP__ID_EX <= Forward_RS1_MEM_FP__id_ex;
        Forward_RS2_MEM_FP__ID_EX <= Forward_RS2_MEM_FP__id_ex;
        FP__Forward_RS1_MEM_Int_FP__ID_EX <= FP__Forward_RS1_MEM_Int_FP__id_ex;
        FP__Forward_RS1_WB_Int_FP__ID_EX <= FP__Forward_RS1_WB_Int_FP__id_ex; 
        JAL_Inst__ID_EX <= JAL_Inst__id_ex;
        JALR_Inst__ID_EX <= JALR_Inst__id_ex;
        Reg_Write_Enable__ID_EX <= Reg_Write_Enable__id_ex; 
        AMO_Inst__ID_EX <= AMO_Inst__id_ex; 
        Mult_Op__ID_EX <= Mult_Op__id_ex;
        Mult_En__ID_EX <= Mult_En__id_ex;
        Div_Op__ID_EX <= Div_Op__id_ex;
        Div_En__ID_EX <= Div_En__id_ex; 
        Load__Stall_ID_EX <= Load__Stall_id_ex;
        BPU__Branch_Taken__ID_EX <= BPU__Branch_Taken__id_ex; 
        BPU__Branch_Target_Addr__ID_EX <= BPU__Branch_Target_Addr__id_ex; 
        BPU__PHT_Read_Index__ID_EX <= BPU__PHT_Read_Index__id_ex; 
        BPU__PHT_Read_Data__ID_EX <= BPU__PHT_Read_Data__id_ex; 
        BPU__BTB_Hit__ID_EX <= BPU__BTB_Hit__id_ex;
        Branch_Type__ID_EX <= Branch_Type__id_ex; 
        
        
        FP__RD_Addr__ID_EX <= FP__RD_Addr__id_ex;
        FP__Reg_Write_En__ID_EX <= FP__Reg_Write_En__id_ex;
        FP__RD_Addr_Int__ID_EX <= FP__RD_Addr_Int__id_ex;
        FP__Reg_Write_En_Int__ID_EX <= FP__Reg_Write_En_Int__id_ex;
        FP__Forward_RS1_MEM__ID_EX <= FP__Forward_RS1_MEM__id_ex;
        FP__Forward_RS2_MEM__ID_EX <= FP__Forward_RS2_MEM__id_ex;
        FP__Forward_RS3_MEM__ID_EX <= FP__Forward_RS3_MEM__id_ex;
        FP__Forward_RS1_WB__ID_EX <= FP__Forward_RS1_WB__id_ex;
        FP__Forward_RS2_WB__ID_EX <= FP__Forward_RS2_WB__id_ex;
        FP__Forward_RS3_WB__ID_EX <= FP__Forward_RS3_WB__id_ex;
        FP__Forward_RS1_MEM_Int__ID_EX <= FP__Forward_RS1_MEM_Int__id_ex;              
        FP__Forward_RS1_WB_Int__ID_EX <= FP__Forward_RS1_WB_Int__id_ex;               
        FP__Fpu_Operation__ID_EX <= FP__Fpu_Operation__id_ex;
        FP__Fpu_Sub_Op__ID_EX <= FP__Fpu_Sub_Op__id_ex;
        FP__Rounding_Mode__ID_EX <= FP__Rounding_Mode__id_ex; 
        FP__SP_DP__ID_EX <= FP__SP_DP__id_ex;
        FP__Fpu_Inst__ID_EX <= FP__Fpu_Inst__id_ex;
        FP__RS1_Data__ID_EX <= FP__RS1_Data__id_ex;
        FP__RS2_Data__ID_EX <= FP__RS2_Data__id_ex;
        FP__RS3_Data__ID_EX <= FP__RS3_Data__id_ex; 
        FP__Store_Data__ID_EX <= FP__Store_Data__id_ex;
        FP__Load_Inst__ID_EX <= FP__Load_Inst__id_ex; 
        FP__Store_Inst__ID_EX <= FP__Store_Inst__id_ex;
    end 
end


// Register EX_MEM stage
always @(posedge CLK ) begin
    if(RST) begin             
        Branch_Taken__EX_MEM  <= 1'b0;
        Branch_Target_Addr__EX_MEM  <= 32'b0;
        RD_Data__EX_MEM <= 32'b0;
        ALU_Result__EX_MEM <= 32'b0;
        RD_Addr__EX_MEM  <= 5'b0;
        Reg_Write_Enable__EX_MEM  <= 1'b0;
        Load_Store_Op__EX_MEM <= 5'b0; 
        SC_Inst__EX_MEM <= 1'b0; 
        proc_data_port1_int__reg <= 32'b0;
        
        
        FP__RD_Data__EX_MEM <= 64'b0;       
        FP__RD_Data_Int__EX_MEM <= 32'b0;   
        FP__RD_Addr__EX_MEM <= 5'b0;        
        FP__Reg_Write_En__EX_MEM <= 1'b0; 
        FP__RD_Addr_Int__EX_MEM <= 5'b0;
        FP__Reg_Write_En_Int__EX_MEM <= 1'b0;
        FP__SP_DP__EX_MEM <= 1'b0;
        FP__Store_Data__EX_MEM <= 64'b0;   
        Double_Load_Data <= 64'b0;         
    end
    else if(~(Mult_Div_unit__Stall || FPU__Stall || Data_Cache__Stall || Inst_Cache__Stall || Double_Load_Store__Stall)) begin            
        Branch_Taken__EX_MEM  <= Branch_Taken__ex_mem;
        Branch_Target_Addr__EX_MEM  <= Branch_Target_Addr__ex_mem;
        RD_Data__EX_MEM <= RD_Data__ex_mem;
        ALU_Result__EX_MEM <= ALU_Result__ex_mem;
        RD_Addr__EX_MEM  <= RD_Addr__ex_mem;
        Reg_Write_Enable__EX_MEM  <= Reg_Write_Enable__ex_mem; 
        Load_Store_Op__EX_MEM <= Load_Store_Op__ex_mem; 
        SC_Inst__EX_MEM <= SC_Inst__ex_mem; 
        
        
        FP__RD_Data__EX_MEM <= FP__RD_Data__ex_mem;      
        FP__RD_Data_Int__EX_MEM <= FP__RD_Data_Int__ex_mem;  
        FP__RD_Addr__EX_MEM <= FP__RD_Addr__ex_mem;       
        FP__Reg_Write_En__EX_MEM <= FP__Reg_Write_En__ex_mem;
        FP__RD_Addr_Int__EX_MEM <= FP__RD_Addr_Int__ex_mem;
        FP__Reg_Write_En_Int__EX_MEM <= FP__Reg_Write_En_Int__ex_mem;
        FP__SP_DP__EX_MEM <= FP__SP_DP__ex_mem;
        FP__Store_Data__EX_MEM <= FP__Store_Data__ex_mem;           
    end 
    else if(((Inst_Cache__Stall__reg == 1'b0) && (Inst_Cache__Stall == 1'b1)) || ((FPU__Stall__reg == 1'b0) && (FPU__Stall == 1'b1)) || ((Mult_Div_unit__Stall__reg == 1'b0) && (Mult_Div_unit__Stall == 1'b1))) begin
        Reg_Write_Enable__EX_MEM  <= 1'b0;
        proc_data_port1_int__reg <= proc_data_port1_int;
        FP__Reg_Write_En__EX_MEM <= 1'b0;
        FP__Reg_Write_En_Int__EX_MEM <= 1'b0;
        Double_Load_Data <= {proc_data_port1_int,Double_Load_Buffer};
    end
end


// Register MEM_WB stage
always @(posedge RST or posedge CLK) begin
    if(RST) begin
        RD_Data__MEM_WB <= 32'b0;
        Branch_Taken__MEM_WB <= 1'b0;
        
        FP__RD_Data__MEM_WB <= 64'b0;
        FP__RD_Data_Int__MEM_WB <= 32'b0;
        FP__Reg_Write_En_Int__MEM_WB <= 1'b0;
    end
    else if(~(Mult_Div_unit__Stall || FPU__Stall || Data_Cache__Stall || Inst_Cache__Stall || Double_Load_Store__Stall_reg)) begin
        RD_Data__MEM_WB <= RD_Data__mem_wb;
        Branch_Taken__MEM_WB <= Branch_Taken__mem_wb;
        
        FP__RD_Data__MEM_WB <= FP__RD_Data__mem_wb;
        FP__RD_Data_Int__MEM_WB <= FP__RD_Data_Int__mem_wb; 
        FP__Reg_Write_En_Int__MEM_WB <= FP__Reg_Write_En_Int__mem_wb;   
    end
end



always @(posedge CLK ) begin
    if(RST) begin
        pc_id_ex <= 32'b0;
        irq_ctrl_int2 <= 1'b0;
        irq_ctrl_o <= 1'b0;
        wr_sel <= 3'b0;
        csr_wr_en <= 1'b0;
        mepc_res <= 1'b0;
        csr_adr <= 12'b0;
        eret <= 1'b0;
    end
    else if(~(Mult_Div_unit__Stall || FPU__Stall || Data_Cache__Stall || Inst_Cache__Stall || Double_Load_Store__Stall)) begin
        pc_id_ex <= pc_forw;
        irq_ctrl_int2 <= irq_ctrl_int;
        irq_ctrl_o <= irq_ctrl_int2;                                //Output of decode_execute stage
        wr_sel <= count_sel_int;
        
        mepc_res <= mepc_res_int;
        csr_adr <= csr_adr_int;
        eret <= eret_int;
        
        if(Branch_Taken__ex_mem == 1'b1)
            csr_wr_en <= 1'b0;
        else
            csr_wr_en <= csr_wr_en_int;
    end   
end


always @(posedge CLK ) begin
    if(RST) 
        lsustall_i <= 1'b0;
    else
        lsustall_i <= Load__Stall_id_ex;
end



reg IF_ID_Freeze__irq__reg;

always @(posedge CLK ) begin
    if(RST) begin
        IF_ID_Freeze__irq__reg <= 1'b0;
    end
    else  begin
        IF_ID_Freeze__irq__reg <= IF_ID_Freeze__irq;
    end 
end



Branch_Prediction_Unit BPU( .CLK(CLK),
                            .RST(RST),
                            .PC(pc_cache),
                            .BPU__Stall(Data_Cache__Stall || Inst_Cache__Stall || Mult_Div_unit__Stall || FPU__Stall || Double_Load_Store__Stall),
                            .Branch_Taken(BPU__Branch_Taken__IF_ID),
                            .Branch_Target_Addr(BPU__Branch_Target_Addr__IF_ID),
                            .BTB_Hit(BPU__BTB_Hit__IF_ID),
                            .PHT_Read_Index(BPU__PHT_Read_Index__if_id),
                            .PHT_Read_Data(BPU__PHT_Read_Data__IF_ID),
                            .PHT_Write_Index(PHT_Write_Index__ex_mem),
                            .PHT_Write_Data(PHT_Write_Data__ex_mem),
                            .PHT_Write_En(PHT_Write_En__ex_mem),
                            .GHR_Write_Data(GHR_Write_Data__ex_mem),
                            .GHR_Write_En(GHR_Write_En__ex_mem),
                            .BTB_Write_Addr(BTB_Write_Addr__ex_mem),
                            .BTB_Write_Data(BTB_Write_Data__ex_mem),
                            .BTB_Write_En(BTB_Write_En__ex_mem),
                            .RAS_RET_Inst_EX(RAS_RET_Inst_EX__ex_mem),
                            .RAS_CALL_Inst(RAS_CALL_Inst__ex_mem),
                            .RAS_CALL_Inst_nextPC(RAS_CALL_Inst_nextPC__ex_mem),
                            .Branch_Taken__EX_MEM(Branch_Taken__EX_MEM),
                            .PC_Control__IRQ(PC_Control__IRQ));

INST_FETCH IF( .CLK(CLK),
               .RST(RST), 
               .Branch_Taken__EX_MEM(Branch_Taken__EX_MEM),
               .Branch_Taken__MEM_WB(Branch_Taken__MEM_WB),
               .Branch_Target_Addr__EX_MEM(Branch_Target_Addr__EX_MEM),
               .BPU__Branch_Taken__IF_ID(BPU__Branch_Taken__IF_ID),
               .BPU__Branch_Target_Addr__IF_ID(BPU__Branch_Target_Addr__IF_ID),
               .CSR_mtvec(csr_mtvec),
               .Load__Stall(Load__Stall),
               .IF_ID_Freeze(IF_ID_Freeze__irq || Data_Cache__Stall || Inst_Cache__Stall || Mult_Div_unit__Stall || FPU__Stall || Double_Load_Store__Stall),
               .PC_Control__IRQ(PC_Control__IRQ),
               .Device_id(device_id),
               .PC__IF_ID(PC__IF_ID), 
               .PC_4__IF_ID(PC_4__IF_ID), 
               .NOP__IF_ID(NOP__IF_ID),
               .pc(pc_cache),
               `ifdef itlb_def
               .vpn_to_ppn_req1(vpn_to_ppn_req)
               `endif 
               );

DECODE ID( .CLK(CLK),                                                              
           .RST(RST),
           .Instruction__IF_ID(Instruction__IF_ID),                                               
           .PC__IF_ID(PC__IF_ID),
           .PC_4__IF_ID(PC_4__IF_ID),                                                      
           .pc_forw(pc_forw),
           .RS1_Addr__rf(RS1_Addr__rf),                                                     
           .RS2_Addr__rf(RS2_Addr__rf),
           .RS1_Data__rf(RS1_Data__rf),                                                      
           .RS2_Data__rf(RS2_Data__rf), 
           .Reg_Write_Enable__id_ex(Reg_Write_Enable__id_ex),                                          
           .RD_Addr__id_ex(RD_Addr__id_ex),
           .Reg_Write_Enable__ID_EX(Reg_Write_Enable__ID_EX),                                          
           .Reg_Write_Enable__EX_MEM(Reg_Write_Enable__EX_MEM),
           .RD_Addr__ID_EX(RD_Addr__ID_EX),                                                   
           .RD_Addr__EX_MEM(RD_Addr__EX_MEM),
           .Forward_RS1_MEM__id_ex(Forward_RS1_MEM__id_ex),                                           
           .Forward_RS2_MEM__id_ex(Forward_RS2_MEM__id_ex),
           .Forward_RS1_WB__id_ex(Forward_RS1_WB__id_ex),                                            
           .Forward_RS2_WB__id_ex(Forward_RS2_WB__id_ex),
           .FP__Reg_Write_En_Int__ID_EX(FP__Reg_Write_En_Int__ID_EX),
           .FP__Reg_Write_En_Int__EX_MEM(FP__Reg_Write_En_Int__EX_MEM),
           .FP__RD_Addr_Int__ID_EX(FP__RD_Addr_Int__ID_EX),
           .FP__RD_Addr_Int__EX_MEM(FP__RD_Addr_Int__EX_MEM),
           .Forward_RS1_MEM_FP__id_ex(Forward_RS1_MEM_FP__id_ex),
           .Forward_RS2_MEM_FP__id_ex(Forward_RS2_MEM_FP__id_ex),
           .Forward_RS1_WB_FP__id_ex(Forward_RS1_WB_FP__id_ex),
           .Forward_RS2_WB_FP__id_ex(Forward_RS2_WB_FP__id_ex),
           .Branch_Taken__EX_MEM(Branch_Taken__EX_MEM),                                              
           .NOP__IF_ID(NOP__IF_ID),                                                           
           .Load_Store_Op__id_ex(Load_Store_Op__id_ex),
           .Store_Data__id_ex(Store_Data__id_ex),                                                
           .Load_Store_Op__ID_EX(Load_Store_Op__ID_EX),
           .Alu_Src_1_sel__id_ex(Alu_Src_1_sel__id_ex),                                             
           .Alu_Src_2_sel__id_ex(Alu_Src_2_sel__id_ex),
           .Opcode__id_ex(Opcode__id_ex),                                                    
           .Funct7__id_ex(Funct7__id_ex),
           .Funct3__id_ex(Funct3__id_ex),                                                    
           .JAL_Inst__id_ex(JAL_Inst__id_ex),
           .JALR_Inst__id_ex(JALR_Inst__id_ex),                                                 
           .RS1_Data__id_ex(RS1_Data__id_ex),                                                                 
           .RS2_Data__id_ex(RS2_Data__id_ex),                                                  
           .Shamt__id_ex(Shamt__id_ex),                                                                 
           .Immediate__id_ex(Immediate__id_ex),                                                 
           .Branch_Inst__id_ex(Branch_Inst__id_ex),                                                                 
           .AMO_Inst__id_ex(AMO_Inst__id_ex),                                                  
           .Mult_Op__id_ex(Mult_Op__id_ex),                                                                 
           .Mult_En__id_ex(Mult_En__id_ex),                                                   
           .Div_Op__id_ex(Div_Op__id_ex),
           .Div_En__id_ex(Div_En__id_ex),                                                    
           .Load__Stall_id_ex(Load__Stall_id_ex),
           .Mult_Div_unit__Stall(Mult_Div_unit__Stall || FPU__Stall),  
           .BPU__Branch_Taken__IF_ID(BPU__Branch_Taken__IF_ID),
           .BPU__Branch_Target_Addr__IF_ID(BPU__Branch_Target_Addr__IF_ID),
           .BPU__PHT_Read_Index__IF_ID(BPU__PHT_Read_Index__IF_ID),
           .BPU__PHT_Read_Data__IF_ID(BPU__PHT_Read_Data__IF_ID), 
           .BPU__BTB_Hit__IF_ID(BPU__BTB_Hit__IF_ID),   
           .BPU__Branch_Taken__id_ex(BPU__Branch_Taken__id_ex),
           .BPU__Branch_Target_Addr__id_ex(BPU__Branch_Target_Addr__id_ex),
           .BPU__PHT_Read_Index__id_ex(BPU__PHT_Read_Index__id_ex),
           .BPU__PHT_Read_Data__id_ex(BPU__PHT_Read_Data__id_ex), 
           .BPU__BTB_Hit__id_ex(BPU__BTB_Hit__id_ex),       
           .Branch_Type__id_ex(Branch_Type__id_ex),                                         
           .lsu_op_port2(lsu_op_port2),
           .LR_Inst(LR_Inst),                                                             
           .mret(mret_int),
           .csr_adr(csr_adr_int),                                                          
           .csr_wr_en(csr_wr_en_int),
           .mepc_res(mepc_res_int),                                                         
           .inst_inj(inst_inj),
           .irq_ctrl(irq_ctrl),                                                         
           .irq_ctrl_wb(irq_ctrl_wb_i),
           .irq_ctrl_o(irq_ctrl_int),                                                       
           .count_sel(count_sel_int),
           .eret(eret_int),
           .inst_out(inst_out));

 
FP_DECODE FP__ID( .CLK(CLK),
                  .RST(RST),
                  .Instruction__IF_ID(inst_out),
                  .Branch_Taken__EX_MEM(Branch_Taken__EX_MEM),
                  .NOP__IF_ID(NOP__IF_ID),
                  .FP__RS1_Addr__rf(FP__RS1_Addr__rf),
                  .FP__RS2_Addr__rf(FP__RS2_Addr__rf),
                  .FP__RS3_Addr__rf(FP__RS3_Addr__rf),
                  .FP__RS1_Addr_Int__rf(FP__RS1_Addr_Int__rf),
                  .FP__RS1_read_Int__rf(FP__RS1_read_Int__rf),
                  .FP__RS1_Data__rf(FP__RS1_Data__rf),
                  .FP__RS2_Data__rf(FP__RS2_Data__rf),
                  .FP__RS3_Data__rf(FP__RS3_Data__rf),
                  .FP__RS1_Data_Int__rf(FP__RS1_Data_Int__rf),
                  .FP__RD_Addr__id_ex(FP__RD_Addr__id_ex),
                  .FP__Reg_Write_En__id_ex(FP__Reg_Write_En__id_ex),
                  .FP__RD_Addr_Int__id_ex(FP__RD_Addr_Int__id_ex),
                  .FP__Reg_Write_En_Int__id_ex(FP__Reg_Write_En_Int__id_ex),
                  .FP__Reg_Write_En__ID_EX(FP__Reg_Write_En__ID_EX),
                  .FP__Reg_Write_En__EX_MEM(FP__Reg_Write_En__EX_MEM),
                  .FP__RD_Addr__ID_EX(FP__RD_Addr__ID_EX),
                  .FP__RD_Addr__EX_MEM(FP__RD_Addr__EX_MEM),
                  .Reg_Write_Enable__ID_EX(Reg_Write_Enable__ID_EX),
                  .Reg_Write_Enable__EX_MEM(Reg_Write_Enable__EX_MEM),
                  .RD_Addr__ID_EX(RD_Addr__ID_EX),
                  .RD_Addr__EX_MEM(RD_Addr__EX_MEM),
                  .FP__Reg_Write_En_Int__ID_EX(FP__Reg_Write_En_Int__ID_EX),
                  .FP__Reg_Write_En_Int__EX_MEM(FP__Reg_Write_En_Int__EX_MEM),
                  .FP__RD_Addr_Int__ID_EX(FP__RD_Addr_Int__ID_EX),
                  .FP__RD_Addr_Int__EX_MEM(FP__RD_Addr_Int__EX_MEM),
                  .FP__Forward_RS1_MEM__id_ex(FP__Forward_RS1_MEM__id_ex),
                  .FP__Forward_RS2_MEM__id_ex(FP__Forward_RS2_MEM__id_ex),
                  .FP__Forward_RS3_MEM__id_ex(FP__Forward_RS3_MEM__id_ex),
                  .FP__Forward_RS1_WB__id_ex(FP__Forward_RS1_WB__id_ex),
                  .FP__Forward_RS2_WB__id_ex(FP__Forward_RS2_WB__id_ex),
                  .FP__Forward_RS3_WB__id_ex(FP__Forward_RS3_WB__id_ex),
                  .FP__Forward_RS1_MEM_Int__id_ex(FP__Forward_RS1_MEM_Int__id_ex),
                  .FP__Forward_RS1_WB_Int__id_ex(FP__Forward_RS1_WB_Int__id_ex),
                  .FP__Forward_RS1_MEM_Int_FP__id_ex(FP__Forward_RS1_MEM_Int_FP__id_ex),
                  .FP__Forward_RS1_WB_Int_FP__id_ex(FP__Forward_RS1_WB_Int_FP__id_ex),
                  .FP__Fpu_Operation__id_ex(FP__Fpu_Operation__id_ex),
                  .FP__Fpu_Sub_Op__id_ex(FP__Fpu_Sub_Op__id_ex),
                  .FP__Rounding_Mode__id_ex(FP__Rounding_Mode__id_ex),
                  .FP__SP_DP__id_ex(FP__SP_DP__id_ex),
                  .FP__Fpu_Inst__id_ex(FP__Fpu_Inst__id_ex),
                  .FP__RS1_Data__id_ex(FP__RS1_Data__id_ex),
                  .FP__RS2_Data__id_ex(FP__RS2_Data__id_ex),
                  .FP__RS3_Data__id_ex(FP__RS3_Data__id_ex),
                  .FP__Store_Data__id_ex(FP__Store_Data__id_ex),
                  .FP__Load_Inst__id_ex(FP__Load_Inst__id_ex),
                  .FP__Store_Inst__id_ex(FP__Store_Inst__id_ex),
                  .inst_inj(inst_inj),
                  .irq_ctrl(irq_ctrl));

           
EXECUTE EX( .CLK(CLK),                                                              
            .RST(RST),
            .pc_id_ex(pc_id_ex),
            .Forward_RS1_MEM__ID_EX(Forward_RS1_MEM__ID_EX),
            .Forward_RS2_MEM__ID_EX(Forward_RS2_MEM__ID_EX),
            .Forward_RS1_WB__ID_EX(Forward_RS1_WB__ID_EX),
            .Forward_RS2_WB__ID_EX(Forward_RS2_WB__ID_EX),
            .RD_Data__EX_MEM(RD_Data__mem_wb),
            .RD_Data__MEM_WB(RD_Data__MEM_WB),
            .Forward_RS1_MEM_FP__ID_EX(Forward_RS1_MEM_FP__ID_EX),
            .Forward_RS2_MEM_FP__ID_EX(Forward_RS2_MEM_FP__ID_EX),
            .Forward_RS1_WB_FP__ID_EX(Forward_RS1_WB_FP__ID_EX),
            .Forward_RS2_WB_FP__ID_EX(Forward_RS2_WB_FP__ID_EX),
            .FP__RD_Data_Int__EX_MEM(FP__RD_Data_Int__EX_MEM),
            .FP__RD_Data_Int__MEM_WB(FP__RD_Data_Int__MEM_WB),
            .Load_Store_Op__ID_EX(Load_Store_Op__ID_EX),
            .Load_Store_Op__ex_mem(Load_Store_Op__ex_mem),
            .Alu_Src_1_sel__ID_EX(Alu_Src_1_sel__ID_EX),
            .Alu_Src_2_sel__ID_EX(Alu_Src_2_sel__ID_EX),
            .Opcode__ID_EX(Opcode__ID_EX),
            .Funct7__ID_EX(Funct7__ID_EX),
            .Funct3__ID_EX(Funct3__ID_EX),
            .JAL_Inst__ID_EX(JAL_Inst__ID_EX),
            .JALR_Inst__ID_EX(JALR_Inst__ID_EX),
            .RS1_Data__ID_EX(RS1_Data__ID_EX),
            .RS2_Data__ID_EX(RS2_Data__ID_EX),
            .Shamt__ID_EX(Shamt__ID_EX),
            .Immediate__ID_EX(Immediate__ID_EX),
            .Branch_Inst__ID_EX(Branch_Inst__ID_EX),
            .AMO_Inst__ID_EX(AMO_Inst__ID_EX),
            .Load__Stall_ID_EX(Load__Stall_ID_EX),
            .amo_load_val_i(amo_load_val_i),
            .Branch_Taken__ex_mem(Branch_Taken__ex_mem),
            .Branch_Target_Addr__ex_mem(Branch_Target_Addr__ex_mem),
            .Branch_Taken__EX_MEM(Branch_Taken__EX_MEM),
            .ALU_Result__ex_mem(ALU_Result__ex_mem),
            .RD_Data__ex_mem(RD_Data__ex_mem),
            .Mult_Op__ID_EX(Mult_Op__ID_EX),
            .Div_Op__ID_EX(Div_Op__ID_EX),
            .Mult_En__ID_EX(Mult_En__ID_EX),
            .Div_En__ID_EX(Div_En__ID_EX),
            .Mult_Div_unit__Stall(Mult_Div_unit__Stall),
            .Mult_Div_unit_Freeze(Mult_Div_unit_Freeze),
            .Mult_Div_unit__Stall_disable(Mult_Div_unit__Stall_disable),
            .Inst_Cache__Stall__reg(Inst_Cache__Stall__reg),
            .Inst_Cache__Stall(Inst_Cache__Stall),
            .Reg_Write_Enable__ID_EX(Reg_Write_Enable__ID_EX),
            .Reg_Write_Enable__ex_mem(Reg_Write_Enable__ex_mem),
            .RD_Addr__ID_EX(RD_Addr__ID_EX),
            .RD_Addr__ex_mem(RD_Addr__ex_mem),
            .Store_Data__ID_EX(Store_Data__ID_EX),
            .Store_Data__ex_mem(Store_Data__ex_mem),
            .BPU__Branch_Taken__ID_EX(BPU__Branch_Taken__ID_EX),
            .BPU__Branch_Target_Addr__ID_EX(BPU__Branch_Target_Addr__ID_EX),
            .BPU__PHT_Read_Index__ID_EX(BPU__PHT_Read_Index__ID_EX),
            .BPU__PHT_Read_Data__ID_EX(BPU__PHT_Read_Data__ID_EX), 
            .BPU__BTB_Hit__ID_EX(BPU__BTB_Hit__ID_EX),
            .PHT_Write_Index__ex_mem(PHT_Write_Index__ex_mem),
            .PHT_Write_Data__ex_mem(PHT_Write_Data__ex_mem),
            .PHT_Write_En__ex_mem(PHT_Write_En__ex_mem),
            .GHR_Write_Data__ex_mem(GHR_Write_Data__ex_mem),
            .GHR_Write_En__ex_mem(GHR_Write_En__ex_mem),
            .BTB_Write_Addr__ex_mem(BTB_Write_Addr__ex_mem),
            .BTB_Write_Data__ex_mem(BTB_Write_Data__ex_mem),
            .BTB_Write_En__ex_mem(BTB_Write_En__ex_mem),       
            .Branch_Type__ID_EX(Branch_Type__ID_EX), 
            .RAS_RET_Inst_EX__ex_mem(RAS_RET_Inst_EX__ex_mem),
            .RAS_CALL_Inst__ex_mem(RAS_CALL_Inst__ex_mem),
            .RAS_CALL_Inst_nextPC__ex_mem(RAS_CALL_Inst_nextPC__ex_mem),
            .lsustall_i(lsustall_i),
            .lsustall_o(lsustall_o),
            .irq_ctrl(irq_ctrl_int2),
            .eret(eret),
            .eret_o(eret_o),
            .SC_Inst__ex_mem(SC_Inst__ex_mem),
            .trap_en(trap_en),
            .csr_indata(csr_indata | csr_indata_intr | count),
            .csr_wrdata(csr_wrdata),
            .PC_Control__IRQ(PC_Control__IRQ));


FP_EXECUTE FP_EX( .RST(RST),
                  .CLK(CLK),
                  .FP__Forward_RS1_MEM__ID_EX(FP__Forward_RS1_MEM__ID_EX),
                  .FP__Forward_RS2_MEM__ID_EX(FP__Forward_RS2_MEM__ID_EX),
                  .FP__Forward_RS3_MEM__ID_EX(FP__Forward_RS3_MEM__ID_EX),
                  .FP__Forward_RS1_WB__ID_EX(FP__Forward_RS1_WB__ID_EX),
                  .FP__Forward_RS2_WB__ID_EX(FP__Forward_RS2_WB__ID_EX),
                  .FP__Forward_RS3_WB__ID_EX(FP__Forward_RS3_WB__ID_EX),
                  .FP__Forward_RS1_MEM_Int__ID_EX(FP__Forward_RS1_MEM_Int__ID_EX),
                  .FP__Forward_RS1_WB_Int__ID_EX(FP__Forward_RS1_WB_Int__ID_EX),
                  .FP__Forward_RS1_MEM_Int_FP__ID_EX(FP__Forward_RS1_MEM_Int_FP__ID_EX),
                  .FP__Forward_RS1_WB_Int_FP__ID_EX(FP__Forward_RS1_WB_Int_FP__ID_EX),
                  .FP__RD_Data__EX_MEM(FP__RD_Data__mem_wb),
                  .FP__RD_Data__MEM_WB(FP__RD_Data__MEM_WB),
                  .RD_Data__EX_MEM(FP__Reg_Write_En_Int__EX_MEM ? FP__RD_Data_Int__EX_MEM : RD_Data__mem_wb),
                  .RD_Data__MEM_WB(FP__Reg_Write_En_Int__MEM_WB ? FP__RD_Data_Int__MEM_WB : RD_Data__MEM_WB),
                  .FP__RD_Data_Int__EX_MEM(FP__RD_Data_Int__EX_MEM),
                  .FP__RD_Data_Int__MEM_WB(FP__RD_Data_Int__MEM_WB),
                  .FP__Fpu_Operation__ID_EX(FP__Fpu_Operation__ID_EX),
                  .FP__Fpu_Sub_Op__ID_EX(FP__Fpu_Sub_Op__ID_EX),
                  .FP__Rounding_Mode__ID_EX(FP__Rounding_Mode__ID_EX),
                  .FP__SP_DP__ID_EX(FP__SP_DP__ID_EX),
                  .FP__Fpu_Inst__ID_EX(FP__Fpu_Inst__ID_EX),
                  .FP__RS1_Data__ID_EX(FP__RS1_Data__ID_EX),
                  .FP__RS2_Data__ID_EX(FP__RS2_Data__ID_EX),
                  .FP__RS3_Data__ID_EX(FP__RS3_Data__ID_EX),
                  .FP__Store_Data__ID_EX(FP__Store_Data__ID_EX),
                  .FP__Store_Data__ex_mem(FP__Store_Data__ex_mem),
                  .FP__Load_Inst__ID_EX(FP__Load_Inst__ID_EX),
                  .FP__Store_Inst__ID_EX(FP__Store_Inst__ID_EX),
                  .FP__Load_Inst__ex_mem(FP__Load_Inst__ex_mem),
                  .FP__Store_Inst__ex_mem(FP__Store_Inst__ex_mem),
                  .FP__RD_Data__ex_mem(FP__RD_Data__ex_mem),
                  .FP__RD_Data_Int__ex_mem(FP__RD_Data_Int__ex_mem),
                  .Branch_Taken__EX_MEM(Branch_Taken__EX_MEM),
                  .FP__RD_Addr__ID_EX(FP__RD_Addr__ID_EX),
                  .FP__Reg_Write_En__ID_EX(FP__Reg_Write_En__ID_EX),
                  .FP__RD_Addr_Int__ID_EX(FP__RD_Addr_Int__ID_EX),
                  .FP__Reg_Write_En_Int__ID_EX(FP__Reg_Write_En_Int__ID_EX),
                  .FP__RD_Addr__ex_mem(FP__RD_Addr__ex_mem),
                  .FP__Reg_Write_En__ex_mem(FP__Reg_Write_En__ex_mem),
                  .FP__RD_Addr_Int__ex_mem(FP__RD_Addr_Int__ex_mem),
                  .FP__Reg_Write_En_Int__ex_mem(FP__Reg_Write_En_Int__ex_mem),
                  .FP__SP_DP__ex_mem(FP__SP_DP__ex_mem),
                  .FPU__Stall(FPU__Stall),
                  .FPU_Freeze(FPU_Freeze),
                  .FPU__Stall_disable(FPU__Stall_disable),
                  .Inst_Cache__Stall__reg(Inst_Cache__Stall__reg),
                  .Inst_Cache__Stall(Inst_Cache__Stall),
                  .frm(frm),
                  .FPU_flags(FPU_flags));


REG_FILE RF( .CLK(CLK),
             .RST(RST),
             .RS1_Read_Addr(FP__RS1_read_Int__rf ? FP__RS1_Addr_Int__rf : RS1_Addr__rf), 
             .RS2_Read_Addr(RS2_Addr__rf),
             .RD_Write_Addr(FP__Reg_Write_En_Int__EX_MEM ? FP__RD_Addr_Int__EX_MEM : RD_Addr__EX_MEM),
             .RD_Write_Data(FP__Reg_Write_En_Int__EX_MEM ? FP__RD_Data_Int__EX_MEM : RD_Data__mem_wb),
             .Reg_Write_Enable__EX_MEM(FP__Reg_Write_En_Int__EX_MEM ? FP__Reg_Write_En_Int__EX_MEM : Reg_Write_Enable__EX_MEM),
             .MEM_WB_Freeze(Data_Cache__Stall | Double_Load_Store__Stall_reg),
             .RS1_Dec_Ctrl__IRQ(irq_ctrl_dec_src1),
             .RS2_Dec_Ctrl__IRQ(irq_ctrl_dec_src2),
             .WB_Ctrl__IRQ(irq_ctrl_o),
             .RS1_Read_Data(RS1_Data__rf),
             .RS2_Read_Data(RS2_Data__rf),
             .led());
             
             
FP_REG_FILE FP_RF( .RST(RST),
                   .CLK(CLK),
                   .FP__RS1_Read_Addr(FP__RS1_Addr__rf),
                   .FP__RS2_Read_Addr(FP__RS2_Addr__rf),
                   .FP__RS3_Read_Addr(FP__RS3_Addr__rf),
                   .FP__RD_Write_Addr(FP__RD_Addr__EX_MEM),
                   .FP__RD_Write_Data(FP__RD_Data__mem_wb),
                   .FP__Reg_Write_En__EX_MEM(FP__Reg_Write_En__EX_MEM),
                   .FP__SP_DP__EX_MEM(FP__SP_DP__EX_MEM),
                   .FP__MEM_WB_Freeze(Data_Cache__Stall | Double_Load_Store__Stall_reg),
                   .FP__RS1_Read_Data(FP__RS1_Data__rf),
                   .FP__RS2_Read_Data(FP__RS2_Data__rf),
                   .FP__RS3_Read_Data(FP__RS3_Data__rf),
                   .led(led));


            
Sys_counter sc1( .rst(RST),
                 .proc_clk(CLK),
                 .freeze(Mult_Div_unit__Stall || FPU__Stall || Data_Cache__Stall || Inst_Cache__Stall || Double_Load_Store__Stall),
                 .count_sel(count_sel_int),
                 .count(count),
                 .wr_sel(wr_sel),
                 .csr_wrdata(csr_wrdata),
                 .csr_wr_en(csr_wr_en),
                 .tick_en(tick_en_int));
 
 csr c1( .clk(CLK),
         .rst(RST),
         .csr_adr_wr(csr_adr),
         .csr_wrdata(csr_wrdata),
         .csr_wr_en(csr_wr_en),
         .csr_adr_rd(csr_adr_int),
         .csr_rddata(csr_indata),
         .csr_mtvec(csr_mtvec),
         .mtie(mtie),
         .mret(eret_o),
         .badaddr(badaddr),
         .trap_en(trap_en),
         .mepc_res(mepc_res),
         .addr_exception(addr_exception),
         .freeze(Mult_Div_unit__Stall || FPU__Stall || Data_Cache__Stall || Inst_Cache__Stall || Double_Load_Store__Stall),
         .FPU_Inst(FP__Fpu_Inst__ID_EX & ~FPU__Stall),
         .FPU_flags(FPU_flags),
         .frm(frm),
         .pc_id_ex(pc_id_ex));
         

 irq_interface ii(.clk(CLK),.rst(RST),.stall_mul(Mult_Div_unit__Stall || FPU__Stall),.freeze(Data_Cache__Stall),.icache_freeze(Inst_Cache__Stall),        
                  .irq(irq),.eret(eret_o),.irq_ack(irq_ack),.eret_ack(eret_ack),.inst_inj(inst_inj),.irq_ctrl(irq_ctrl),
                  .irq_ctrl_wb(irq_ctrl_wb_i),.irq_if_ctrl(PC_Control__IRQ),.irq_ctrl_dec_src1(irq_ctrl_dec_src1),
                  .irq_ctrl_dec_src2(irq_ctrl_dec_src2),.if_id_freeze(IF_ID_Freeze__irq),
                  .irq_icache_freeze(irq_icache_freeze)
 );
 
 interrupt_main i1(.interrupt(interrupt),.clk(CLK),.reset(RST),.done(eret),.ic_irq_ack(irq_ack ),.eret_ack(eret_ack),   
                   .icache_stall_out(Inst_Cache__Stall),.ic_proc_req(irq),.device_id(device_id),
                   .csr_wrdata(csr_wrdata),.csr_wr_en(csr_wr_en),.csr_adr_wr(csr_adr),.csr_adr_rd(csr_adr_int)
                   ,.csr_rddata(csr_indata_intr),.freeze(Mult_Div_unit__Stall || FPU__Stall || Data_Cache__Stall || Inst_Cache__Stall || Double_Load_Store__Stall)
                   );

//ila_2 debugger( .clk(CLK),
//                .probe0(pc_cache),
//                .probe1(Instruction__IF_ID),
//                .probe2(RD_Addr__EX_MEM),
//                .probe3(RD_Data__mem_wb),
//                .probe4(Reg_Write_Enable__EX_MEM),
//                .probe5(Inst_Cache__Stall),
//                .probe6(Data_Cache__Stall),
//                .probe7(Mult_Div_unit__Stall),
//                .probe8(FPU__Stall),
//                .probe9(Load_Store_Op__Port1),
//                .probe10(proc_addr_port1),
//                .probe11(Store_Data),
//                .probe12(proc_data_port1_int),
//                .probe13(Double_Load_Store__Stall));
                
//ila_0 debugger( .clk(CLK),
//                .probe0(pc_cache),
//                .probe1(Instruction__IF_ID),
//                .probe2(FP__RD_Addr__EX_MEM),
//                .probe3(FP__RD_Data__mem_wb),
//                .probe4(FP__Reg_Write_En__EX_MEM),
//                .probe5(FP__Reg_Write_En_Int__EX_MEM),
//                .probe6(FP__RD_Addr_Int__EX_MEM),
//                .probe7(FP__RD_Data_Int__EX_MEM),
//                .probe8(FP__Reg_Write_En_Int__EX_MEM));


//reg [31:0] Counter__1,Counter__2,Counter__3,Counter__4,Counter__5,Counter__6;  

//ila_0 debugger( .clk(CLK),
//                .probe0(pc_cache),
//                .probe1(Instruction__IF_ID),
//                .probe2(Counter__1),
//                .probe3(Counter__2),
//                .probe4(Counter__3),
//                .probe5(Counter__4),
//                .probe6(Counter__5),
//                .probe7(Counter__6));

//ila_0 debugger( .clk(CLK),
//                .probe0(pc_cache),
//                .probe1(Instruction__IF_ID));



//always @(posedge CLK) begin
//    if (RST) begin
//        Counter__1 <= 32'b0;
//        Counter__2 <= 32'b0;
//    end
//    else if (~(Mult_Div_unit__Stall | FPU__Stall | Data_Cache__Stall | Inst_Cache__Stall | Double_Load_Store__Stall | Branch_Taken__EX_MEM)) begin
//        if (Branch_Inst__ID_EX == 1'b1) begin
//            Counter__1 <= Counter__1 + 1;
//            if (Branch_Taken__ex_mem == 1'b1) begin
//                Counter__2 <= Counter__2 + 1;
//            end
//        end
//    end 
//end     

//always @(posedge CLK) begin
//    if (RST) begin
//        Counter__3 <= 32'b0;
//        Counter__4 <= 32'b0;
//    end
//    else if (~(Mult_Div_unit__Stall | FPU__Stall | Data_Cache__Stall | Inst_Cache__Stall | Double_Load_Store__Stall | Branch_Taken__EX_MEM)) begin
//        if (((JAL_Inst__ID_EX == 1'b1) || (JALR_Inst__ID_EX == 1'b1)) && ((Branch_Type__ID_EX == 3'b001) || (Branch_Type__ID_EX == 3'b010))) begin
//            Counter__3 <= Counter__3 + 1;
//            if (Branch_Taken__ex_mem == 1'b1) begin
//                Counter__4 <= Counter__4 + 1;
//            end
//        end
//    end 
//end     

//always @(posedge CLK) begin
//    if (RST) begin
//        Counter__5 <= 32'b0;
//        Counter__6 <= 32'b0;
//    end
//    else if (~(Mult_Div_unit__Stall | FPU__Stall | Data_Cache__Stall | Inst_Cache__Stall | Double_Load_Store__Stall | Branch_Taken__EX_MEM)) begin
//        if ((JALR_Inst__ID_EX == 1'b1) && (Branch_Type__ID_EX == 3'b011)) begin
//            Counter__5 <= Counter__5 + 1;
//            if (Branch_Taken__ex_mem == 1'b1) begin
//                Counter__6 <= Counter__6 + 1;
//            end
//        end
//    end 
//end     

                               
endmodule

