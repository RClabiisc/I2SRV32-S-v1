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



module Return_Addr_Stack
(
    input CLK,
    input RST,
    input BPU__Stall,
    
    input RET_Inst,
    output reg [31:0] RET_Target_Addr,
    output reg RET_Addr_Valid,
    
    input RET_Inst_EX,
    input CALL_Inst,
    input [31:0] CALL_Inst_nextPC,
    
    input Branch_Taken__EX_MEM
);

reg RET_Inst__reg;

reg [31:0] RAS[0:31];

reg [4:0] TOS;
reg [4:0] BOS;
reg RAS_Empty;

reg [4:0] Write_Pointer;

wire BOS_Incr;

integer j;

assign BOS_Incr = (BOS == Write_Pointer) ? 1'b1 : 1'b0;

wire Condition_CHK__1 = ((RAS_Empty == 1'b1) && ((RET_Inst == 1'b1) || (RET_Inst_EX == 1'b1))) ? 1'b1 : 1'b0;
wire Condition_CHK__2 = ((TOS == 5'b11111)) ? 1'b1 : 1'b0;
wire Condition_CHK__3 = ((Branch_Taken__EX_MEM == 1'b1) && ((RET_Inst == 1'b1) || (RET_Inst__reg == 1'b1))) ? 1'b1 : 1'b0;


always @(posedge CLK) begin
    if (RST) begin
        RET_Inst__reg <= 1'b0;
    end
    else if (~BPU__Stall) begin
        RET_Inst__reg <= RET_Inst;
    end
end



always @(posedge CLK) begin
    if (RST) begin
        TOS <= 5'b00000;
    end
    else if (~BPU__Stall) begin
        if ((Branch_Taken__EX_MEM == 1'b1)) begin
            if ((RET_Inst == 1'b1) && (RET_Inst__reg == 1'b1)) begin
                TOS <= TOS + 2;
            end
            else if ((RET_Inst == 1'b1) || (RET_Inst__reg == 1'b1)) begin
                TOS <= TOS + 1;
            end
        end
        else if(CALL_Inst) begin
            TOS <= TOS + 1;
        end
        else if (((RET_Inst == 1'b1) && (RET_Inst_EX == 1'b1)) & ((RAS_Empty == 1'b0) && !(TOS == (BOS + 1)))) begin
            TOS <= TOS - 2;
        end
        else if(((RET_Inst == 1'b1) || (RET_Inst_EX == 1'b1)) & (RAS_Empty == 1'b0)) begin
            TOS <= TOS - 1;
        end
    end
end

always @(posedge CLK) begin
    if (RST) begin
        BOS <= 5'b00000;
    end
    else if (~BPU__Stall) begin
        if(CALL_Inst & BOS_Incr) begin
            BOS <= BOS + 1;
        end
    end
end

always @(posedge CLK) begin
    if (RST) begin
        RAS_Empty <= 1'b1;
    end
    else begin
        RAS_Empty <= (TOS == BOS) ? 1'b1 : 1'b0;
    end
end



always @(posedge CLK) begin
    if (RST) begin
        RET_Target_Addr <= 32'h00000000;  
        RET_Addr_Valid <= 1'b0;
    end
    else begin
        RET_Target_Addr <= RAS[TOS];
        RET_Addr_Valid <= ~RAS_Empty;
    end
end


always @(*) begin
    if (RST) begin
        Write_Pointer <= 5'b00000;  
    end
    else begin
        Write_Pointer <= TOS + 1;
    end
end

always @(posedge CLK) begin
    if (RST) begin
        for(j=0; j<256; j=j+1)
            RAS[j] <= 32'h00000000;
    end
    else if((CALL_Inst) & (~BPU__Stall)) begin
        RAS[Write_Pointer] <= CALL_Inst_nextPC;
    end
end


endmodule
