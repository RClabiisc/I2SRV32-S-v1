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

module BTB_PLRU
(
    input CLK,
    input RST,
    
    input BPU__Stall,
    
    input [6:0] BTB_Read_Addr__reg,
    input BTB_Hit_Set0,
    input BTB_Hit_Set1,
    input BTB_Hit_Set2,
    input BTB_Hit_Set3,
    input Read_Access,
    
    input [6:0] BTB_Write_Addr__reg,
    input Write_Access,
    output reg [1:0] LRU_Set
);

reg [1:0] level_1[0:127];
reg [3:0] level_0[0:127];

wire [1:0] level_1_Write_Value = level_1[BTB_Write_Addr__reg];
wire [3:0] level_0_Read_Value = level_0[BTB_Read_Addr__reg];
wire [3:0] level_0_Write_Value = level_0[BTB_Write_Addr__reg];


integer j;

always @(posedge CLK) begin
    if(RST) begin
        for(j=0; j<128; j=j+1) begin
            level_1[j] <= 2'b00;
            level_0[j] <= 4'b0000;
        end
    end
    else if(~BPU__Stall) begin
        if(Read_Access) begin
            case({BTB_Hit_Set3,BTB_Hit_Set2,BTB_Hit_Set1,BTB_Hit_Set0})
                4'b0001 : begin
                    level_1[BTB_Read_Addr__reg] <= 2'b01;
                    level_0[BTB_Read_Addr__reg] <= {level_0_Read_Value[3:2],2'b01};
                end
                4'b0010 : begin
                    level_1[BTB_Read_Addr__reg] <= 2'b01;
                    level_0[BTB_Read_Addr__reg] <= {level_0_Read_Value[3:2],2'b10};        
                end
                4'b0100 : begin
                    level_1[BTB_Read_Addr__reg] <= 2'b10;
                    level_0[BTB_Read_Addr__reg] <= {2'b01,level_0_Read_Value[1:0]};                   
                end
                4'b1000 : begin
                    level_1[BTB_Read_Addr__reg] <= 2'b10;
                    level_0[BTB_Read_Addr__reg] <= {2'b10,level_0_Read_Value[1:0]};                             
                end 
            endcase
        end
        
        if((Write_Access == 1'b1) && ~((Read_Access == 1'b1) && (BTB_Read_Addr__reg == BTB_Write_Addr__reg))) begin
            case(LRU_Set)
                2'b00 : begin
                    level_1[BTB_Write_Addr__reg] <= 2'b01;
                    level_0[BTB_Write_Addr__reg] <= {level_0_Write_Value[3:2],2'b01};
                end
                2'b01 : begin
                    level_1[BTB_Write_Addr__reg] <= 2'b01;
                    level_0[BTB_Write_Addr__reg] <= {level_0_Write_Value[3:2],2'b10};        
                end
                2'b10 : begin
                    level_1[BTB_Write_Addr__reg] <= 2'b10;
                    level_0[BTB_Write_Addr__reg] <= {2'b01,level_0_Write_Value[1:0]};                   
                end
                2'b11 : begin
                    level_1[BTB_Write_Addr__reg] <= 2'b10;
                    level_0[BTB_Write_Addr__reg] <= {2'b10,level_0_Write_Value[1:0]};                             
                end 
            endcase
        end
    end
end

always@(*) begin
    if(RST) begin
        LRU_Set <= 2'b00;
    end
    else begin
        if(level_1_Write_Value[0]==1'b0) begin
            if(level_0_Write_Value[0]==1'b0) 
                LRU_Set <= 2'b00;
            else                 
                LRU_Set <= 2'b01;
        end
        else begin
            if(level_0_Write_Value[2]==1'b0) 
                LRU_Set <= 2'b10;
            else                 
                LRU_Set <= 2'b11;
        end
    end
end
endmodule
