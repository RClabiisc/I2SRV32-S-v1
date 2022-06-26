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



module Branch_Target_Buff
(
    input CLK,
    input RST,
    
    input BPU__Stall,
    
    input [31:0] BTB_Read_Addr,
    output reg [31:0] BTB_Read_Data,
    output reg BTB_Hit,
    
    input [31:0] BTB_Write_Addr,
    input [31:0] BTB_Write_Data,
    input BTB_Write_En
    
);

reg [31:0] BTB_Read_Addr__reg;
reg [31:0] BTB_Write_Addr__reg;
reg [31:0] BTB_Write_Data__reg;
reg BTB_Write_En__reg;

wire [55:0] BTB_Read_Data_Set0;
wire [55:0] BTB_Read_Data_Set1;
wire [55:0] BTB_Read_Data_Set2;
wire [55:0] BTB_Read_Data_Set3;

wire BTB_Hit_Set0;
wire BTB_Hit_Set1;
wire BTB_Hit_Set2;
wire BTB_Hit_Set3;

wire [55:0] BTB_Write_Data_temp;
reg BTB_Write_En_Set0;
reg BTB_Write_En_Set1;
reg BTB_Write_En_Set2;
reg BTB_Write_En_Set3;

wire [1:0] LRU_Set; 

assign BTB_Hit_Set0 = ((BTB_Read_Data_Set0[55] == 1'b1) && (BTB_Read_Data_Set0[54:32] == BTB_Read_Addr__reg[31:9])) ? 1'b1 : 1'b0;
assign BTB_Hit_Set1 = ((BTB_Read_Data_Set1[55] == 1'b1) && (BTB_Read_Data_Set1[54:32] == BTB_Read_Addr__reg[31:9])) ? 1'b1 : 1'b0;
assign BTB_Hit_Set2 = ((BTB_Read_Data_Set2[55] == 1'b1) && (BTB_Read_Data_Set2[54:32] == BTB_Read_Addr__reg[31:9])) ? 1'b1 : 1'b0;
assign BTB_Hit_Set3 = ((BTB_Read_Data_Set3[55] == 1'b1) && (BTB_Read_Data_Set3[54:32] == BTB_Read_Addr__reg[31:9])) ? 1'b1 : 1'b0;

assign BTB_Write_Data_temp = {1'b1,BTB_Write_Addr__reg[31:9],BTB_Write_Data__reg};

always @(posedge CLK) begin
    if (RST) begin 
        BTB_Read_Addr__reg <= 32'h00000000;
        
        BTB_Write_Addr__reg <= 32'h00000000;
        BTB_Write_Data__reg <= 32'h00000000;
        BTB_Write_En__reg <= 1'b0;
    end
    else if(~BPU__Stall) begin
        BTB_Read_Addr__reg <= BTB_Read_Addr;
        
        BTB_Write_Addr__reg <= BTB_Write_Addr;
        BTB_Write_Data__reg <= BTB_Write_Data;
        BTB_Write_En__reg <= BTB_Write_En;
    end 
end

always @(*) begin
    if (RST) begin 
        BTB_Hit <= 1'b0;
        BTB_Read_Data <= 32'h00000000;
    end
    else if (BTB_Hit_Set0 | BTB_Hit_Set1 | BTB_Hit_Set2 | BTB_Hit_Set3) begin
        BTB_Hit <= 1'b1;
        case({BTB_Hit_Set3,BTB_Hit_Set2,BTB_Hit_Set1,BTB_Hit_Set0})
            4'b0001 : BTB_Read_Data <= BTB_Read_Data_Set0[31:0];
            4'b0010 : BTB_Read_Data <= BTB_Read_Data_Set1[31:0];
            4'b0100 : BTB_Read_Data <= BTB_Read_Data_Set2[31:0];
            4'b1000 : BTB_Read_Data <= BTB_Read_Data_Set3[31:0];
            default : BTB_Read_Data <= 32'h00000000;        
        endcase
    end 
    else begin
        BTB_Hit <= 1'b0;
        BTB_Read_Data <= 32'h00000000;
    end
end

always @(*) begin
    if (RST | BPU__Stall) begin 
        BTB_Write_En_Set0 <= 1'b0; BTB_Write_En_Set1 <= 1'b0; BTB_Write_En_Set2 <= 1'b0; BTB_Write_En_Set3 <= 1'b0;
    end
    else if (BTB_Write_En__reg) begin
        casex(LRU_Set)
            2'b00 : begin
                BTB_Write_En_Set0 <= 1'b1; BTB_Write_En_Set1 <= 1'b0; BTB_Write_En_Set2 <= 1'b0; BTB_Write_En_Set3 <= 1'b0;
            end
            2'b01 : begin
                BTB_Write_En_Set0 <= 1'b0; BTB_Write_En_Set1 <= 1'b1; BTB_Write_En_Set2 <= 1'b0; BTB_Write_En_Set3 <= 1'b0;
            end
            2'b10 : begin
                BTB_Write_En_Set0 <= 1'b0; BTB_Write_En_Set1 <= 1'b0; BTB_Write_En_Set2 <= 1'b1; BTB_Write_En_Set3 <= 1'b0;
            end
            2'b11 : begin
                BTB_Write_En_Set0 <= 1'b0; BTB_Write_En_Set1 <= 1'b0; BTB_Write_En_Set2 <= 1'b0; BTB_Write_En_Set3 <= 1'b1;
            end
            default : begin
                BTB_Write_En_Set0 <= 1'b0; BTB_Write_En_Set1 <= 1'b0; BTB_Write_En_Set2 <= 1'b0; BTB_Write_En_Set3 <= 1'b0;
            end       
        endcase
    end 
    else begin
        BTB_Write_En_Set0 <= 1'b0; BTB_Write_En_Set1 <= 1'b0; BTB_Write_En_Set2 <= 1'b0; BTB_Write_En_Set3 <= 1'b0;
    end
end


BTB_mem BTB_Set0( .clka(CLK),.rsta(RST),.wea(7'h00),.addra(BTB_Read_Addr[8:2]),.dina(56'h0),.douta(BTB_Read_Data_Set0),.ena(~BPU__Stall),
                  .clkb(CLK),.rstb(RST),.web({7{BTB_Write_En_Set0}}),.addrb(BTB_Write_Addr__reg[8:2]),.dinb(BTB_Write_Data_temp),.doutb());

BTB_mem BTB_Set1( .clka(CLK),.rsta(RST),.wea(7'h00),.addra(BTB_Read_Addr[8:2]),.dina(56'h0),.douta(BTB_Read_Data_Set1),.ena(~BPU__Stall),
                  .clkb(CLK),.rstb(RST),.web({7{BTB_Write_En_Set1}}),.addrb(BTB_Write_Addr__reg[8:2]),.dinb(BTB_Write_Data_temp),.doutb());
                        
BTB_mem BTB_Set2( .clka(CLK),.rsta(RST),.wea(7'h00),.addra(BTB_Read_Addr[8:2]),.dina(56'h0),.douta(BTB_Read_Data_Set2),.ena(~BPU__Stall),
                  .clkb(CLK),.rstb(RST),.web({7{BTB_Write_En_Set2}}),.addrb(BTB_Write_Addr__reg[8:2]),.dinb(BTB_Write_Data_temp),.doutb());                        

BTB_mem BTB_Set3( .clka(CLK),.rsta(RST),.wea(7'h00),.addra(BTB_Read_Addr[8:2]),.dina(56'h0),.douta(BTB_Read_Data_Set3),.ena(~BPU__Stall),
                  .clkb(CLK),.rstb(RST),.web({7{BTB_Write_En_Set3}}),.addrb(BTB_Write_Addr__reg[8:2]),.dinb(BTB_Write_Data_temp),.doutb());
                        

BTB_PLRU PLRU( .CLK(CLK),
               .RST(RST),
               .BPU__Stall(BPU__Stall),         
               .BTB_Read_Addr__reg(BTB_Read_Addr__reg[8:2]),
               .BTB_Hit_Set0(BTB_Hit_Set0),
               .BTB_Hit_Set1(BTB_Hit_Set1),
               .BTB_Hit_Set2(BTB_Hit_Set2),
               .BTB_Hit_Set3(BTB_Hit_Set3),
               .Read_Access(BTB_Hit),
               .BTB_Write_Addr__reg(BTB_Write_Addr__reg[8:2]),
               .Write_Access(BTB_Write_En__reg),
               .LRU_Set(LRU_Set));                   
endmodule



