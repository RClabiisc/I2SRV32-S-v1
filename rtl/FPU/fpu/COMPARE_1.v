`timescale 1ns / 1ps

`define EQUAL           3'b000
`define LESS_THAN       3'b001
`define LESS_OR_EQUAL   3'b010
`define MIN             3'b100
`define MAX             3'b101

`define QNaN_DP 64'h7FF8000000000000
`define QNaN_SP 32'h7FC00000


module COMPARE
(
    input [63:0] INPUT_1,
    input [63:0] INPUT_2,
    input SP_DP,
    input [2:0] OPERATION,
    output reg [63:0] OUTPUT,
    output reg INVALID
);

wire [7:0] INPUT_1_exp_SP = INPUT_1[30:23];
wire [7:0] INPUT_2_exp_SP = INPUT_2[30:23];	
wire [10:0] INPUT_1_exp_DP = INPUT_1[62:52];
wire [10:0] INPUT_2_exp_DP = INPUT_2[62:52];	

wire [22:0] INPUT_1_man_SP = INPUT_1[22:0];
wire [22:0] INPUT_2_man_SP = INPUT_2[22:0];
wire [51:0] INPUT_1_man_DP = INPUT_1[51:0];
wire [51:0] INPUT_2_man_DP = INPUT_2[51:0];

wire INPUT_1_QNAN_SP = &INPUT_1_exp_SP & INPUT_1_man_SP[22];
wire INPUT_2_QNAN_SP = &INPUT_2_exp_SP & INPUT_2_man_SP[22];
wire INPUT_1_QNAN_DP = &INPUT_1_exp_DP & INPUT_1_man_DP[51];                      
wire INPUT_2_QNAN_DP = &INPUT_2_exp_DP & INPUT_2_man_DP[51];

wire INPUT_1_SNAN_SP = &INPUT_1_exp_SP & !INPUT_1_man_SP[22] & (|INPUT_1_man_SP);
wire INPUT_2_SNAN_SP = &INPUT_2_exp_SP & !INPUT_2_man_SP[22] & (|INPUT_2_man_SP);
wire INPUT_1_SNAN_DP = &INPUT_1_exp_DP & !INPUT_1_man_DP[51] & (|INPUT_1_man_DP);                      
wire INPUT_2_SNAN_DP = &INPUT_2_exp_DP & !INPUT_2_man_DP[51] & (|INPUT_2_man_DP);

wire EQ;
wire LT;
wire LE;

Compare COMP( .INPUT_1(INPUT_1), .INPUT_2(INPUT_2), .SP_DP(SP_DP), .EQ(EQ), .LT(LT), .LE(LE));

always @(*) begin
    if(SP_DP == 1) begin
        case(OPERATION)
            `EQUAL : begin
                if(INPUT_1_SNAN_DP | INPUT_2_SNAN_DP) begin
                    INVALID <= 1'b1;
                    OUTPUT <= {64{1'b0}};
                end
                else if(INPUT_1_QNAN_DP | INPUT_2_QNAN_DP) begin
                    INVALID <= 1'b0;
                    OUTPUT <= {64{1'b0}};               
                end
                else begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{63{1'b0}},EQ};
                end
            end
            `LESS_THAN : begin
                if(INPUT_1_SNAN_DP | INPUT_2_SNAN_DP | INPUT_1_QNAN_DP | INPUT_2_QNAN_DP) begin
                    INVALID <= 1'b1;
                    OUTPUT <= {64{1'b0}};
                end
                else begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{63{1'b0}},LT};
                end
            end
            `LESS_OR_EQUAL : begin
                if(INPUT_1_SNAN_DP | INPUT_2_SNAN_DP | INPUT_1_QNAN_DP | INPUT_2_QNAN_DP) begin
                    INVALID <= 1'b1;
                    OUTPUT <= {64{1'b0}};
                end
                else begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{63{1'b0}},LE};
                end         
            end        
            `MIN : begin
                if(INPUT_1_SNAN_DP | INPUT_2_SNAN_DP | (INPUT_1_QNAN_DP & INPUT_2_QNAN_DP)) begin
                    INVALID <= 1'b0;
                    OUTPUT <= `QNaN_DP;
                end
                else if (INPUT_1_QNAN_DP) begin
                    INVALID <= 1'b0;
                    OUTPUT <= INPUT_2;
                end
                else if (INPUT_2_QNAN_DP) begin
                    INVALID <= 1'b0;
                    OUTPUT <= INPUT_1;
                end
                else begin
                    if (EQ == 1'b1) begin
                        OUTPUT <= INPUT_1; 
                    end
                    else if (LT == 1'b1) begin
                        OUTPUT <= INPUT_1;               
                    end
                    else begin
                        OUTPUT <= INPUT_2;
                    end
                    INVALID <= 1'b0;
                 end
            end
            `MAX : begin
                if(INPUT_1_SNAN_DP | INPUT_2_SNAN_DP | (INPUT_1_QNAN_DP & INPUT_2_QNAN_DP)) begin
                    INVALID <= 1'b0;
                    OUTPUT <= `QNaN_DP;
                end
                else if (INPUT_1_QNAN_DP) begin
                    INVALID <= 1'b0;
                    OUTPUT <= INPUT_2;
                end
                else if (INPUT_2_QNAN_DP) begin
                    INVALID <= 1'b0;
                    OUTPUT <= INPUT_1;
                end
                else begin
                    if (EQ == 1'b1) begin
                        OUTPUT <= INPUT_1; 
                    end
                    else if (LT == 1'b1) begin
                        OUTPUT <= INPUT_2;               
                    end
                    else begin
                        OUTPUT <= INPUT_1;
                    end
                    INVALID <= 1'b0;
                 end        
            end
            default: begin
            
            end
        endcase;
    end
    else begin
        case(OPERATION)
            `EQUAL : begin
                if(INPUT_1_SNAN_SP | INPUT_2_SNAN_SP) begin
                    INVALID <= 1'b1;
                    OUTPUT <= {64{1'b0}};
                end
                else if(INPUT_1_QNAN_SP | INPUT_2_QNAN_SP) begin
                    INVALID <= 1'b0;
                    OUTPUT <= {64{1'b0}};               
                end
                else begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{63{1'b0}},EQ};
                end
            end
            `LESS_THAN : begin
                if(INPUT_1_SNAN_SP | INPUT_2_SNAN_SP | INPUT_1_QNAN_SP | INPUT_2_QNAN_SP) begin
                    INVALID <= 1'b1;
                    OUTPUT <= {64{1'b0}};
                end
                else begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{63{1'b0}},LT};
                end
            end
            `LESS_OR_EQUAL : begin
                if(INPUT_1_SNAN_SP | INPUT_2_SNAN_SP | INPUT_1_QNAN_SP | INPUT_2_QNAN_SP) begin
                    INVALID <= 1'b1;
                    OUTPUT <= {64{1'b0}};
                end
                else begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{63{1'b0}},LE};
                end         
            end        
            `MIN : begin
                if(INPUT_1_SNAN_SP | INPUT_2_SNAN_SP | (INPUT_1_QNAN_SP & INPUT_2_QNAN_SP)) begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{32{1'b0}},`QNaN_SP};
                end
                else if (INPUT_1_QNAN_SP) begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{32{1'b0}},INPUT_2};
                end
                else if (INPUT_2_QNAN_SP) begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{32{1'b0}},INPUT_1};
                end
                else begin
                    if (EQ == 1'b1) begin
                        OUTPUT <= {{32{1'b0}},INPUT_1}; 
                    end
                    else if (LT == 1'b1) begin
                        OUTPUT <= {{32{1'b0}},INPUT_1};               
                    end
                    else begin
                        OUTPUT <= {{32{1'b0}},INPUT_2};
                    end
                    INVALID <= 1'b0;
                 end
            end
            `MAX : begin
                if(INPUT_1_SNAN_SP | INPUT_2_SNAN_SP | (INPUT_1_QNAN_SP & INPUT_2_QNAN_SP)) begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{32{1'b0}},`QNaN_SP};
                end
                else if (INPUT_1_QNAN_SP) begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{32{1'b0}},INPUT_2};
                end
                else if (INPUT_2_QNAN_SP) begin
                    INVALID <= 1'b0;
                    OUTPUT <= {{32{1'b0}},INPUT_1};
                end
                else begin
                    if (EQ == 1'b1) begin
                        OUTPUT <= {{32{1'b0}},INPUT_1}; 
                    end
                    else if (LT == 1'b1) begin
                        OUTPUT <= {{32{1'b0}},INPUT_2};               
                    end
                    else begin
                        OUTPUT <= {{32{1'b0}},INPUT_1};
                    end
                    INVALID <= 1'b0;
                 end        
            end
            default: begin
            
            end
        endcase;
    end
end

endmodule
