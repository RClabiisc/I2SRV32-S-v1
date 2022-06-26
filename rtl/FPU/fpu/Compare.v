`timescale 1ns / 1ps

module Compare
(
    input [63:0] INPUT_1,
    input [63:0] INPUT_2,
    input SP_DP,
    output reg EQ,
    output reg LT,                
    output reg LE
);

wire INPUT_1_zero_SP = INPUT_1[30:0]==0;
wire INPUT_1_zero_DP = INPUT_1[62:0]==0;
wire INPUT_2_zero_SP = INPUT_2[30:0]==0;
wire INPUT_2_zero_DP = INPUT_2[62:0]==0;

wire GT_mag_SP = INPUT_1[30:0] > INPUT_2[30:0];
wire LT_mag_SP = INPUT_1[30:0] < INPUT_2[30:0];
wire GT_mag_DP = INPUT_1[62:0] > INPUT_2[62:0];
wire LT_mag_DP = INPUT_1[62:0] < INPUT_2[62:0];

always @(*) begin
    if(SP_DP==1) begin
        EQ <= (INPUT_1_zero_DP & INPUT_2_zero_DP) || (INPUT_1 == INPUT_2);
        LT <= INPUT_1[63] ^ INPUT_2[63] ? INPUT_1[63] & !(INPUT_1_zero_DP & INPUT_2_zero_DP) : INPUT_1[63] ? GT_mag_DP : LT_mag_DP;
        LE <= EQ | LT;
    end
    else begin
        EQ <= (INPUT_1_zero_SP & INPUT_2_zero_SP) || (INPUT_1 == INPUT_2);
        LT <= INPUT_1[31] ^ INPUT_2[31] ? INPUT_1[31] & !(INPUT_1_zero_SP & INPUT_2_zero_SP) : INPUT_1[31] ? GT_mag_SP : LT_mag_SP;
        LE <= EQ | LT;
    end    
end


endmodule
