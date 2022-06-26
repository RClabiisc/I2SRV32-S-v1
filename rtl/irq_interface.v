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
module irq_interface(
input clk,
input rst,
input stall_mul,
input freeze,
input icache_freeze,
input irq,
input eret,
output reg irq_ack,
output reg eret_ack,
output reg [31:0] inst_inj,
output reg irq_ctrl,
output reg irq_ctrl_wb,
output reg irq_if_ctrl,             //The pc should be changed to ISR value when IrQ is high.
output reg irq_ctrl_dec_src1,
output reg irq_ctrl_dec_src2,
output reg if_id_freeze,
output reg irq_icache_freeze
);

parameter idle= 2'b00;
parameter ent_inject = 2'b01;
parameter ret_inject = 2'b10;

reg [3:0] count1,count2;
reg count1_en,count2_en;
reg [1:0] state,nxstate;

wire [31:0] inst0;
wire [31:0] inst1;
wire [31:0] inst2;
wire [31:0] inst3;
wire [31:0] inst4;
wire [31:0] inst5;
wire [31:0] inst6;
wire [31:0] inst7;
wire [31:0] inst8;
wire [31:0] inst9;
wire [31:0] inst10;
wire [31:0] inst11;

/////////////Sequence of instructions for saving state
// ** THese instruction should get executed in starting and ending of stack pointer ** //
// ** Since mepc is being used at many places, we are making these storing of PC and current priority in software **//

//assign inst0 = 32'b01011111000100000000_00011_0110111;      // LUI r3(s), 5F100 ; load r31 with peripheral base address
//assign inst1 = 32'b011111111000_00011_010_00011_0000011;    //lw 3(s) zero,5F1007F8(#2040); Load the active register from 2040 location(its address)
//assign inst2 = 32'b111111111000_00010_000_00010_0010011;    //addi sp,sp,-8;    Modify stack pointer
//assign inst3 = 32'b0000000_00011_00010_010_00100_0100011;   //sw sp,3(s),4; Push active register to stack.
//assign inst4 = 32'b00000000000000000000_00001_0010111;      //auipc ra,0 
//assign inst5 = 32'b0000000_00001_00010_010_00000_0100011;   //sw sp,3(s),0; Store reg 1 in 2044 location. xepc location

///////////////Sequence of instructions for restoring state

//assign inst6 = 32'b01011111000100000000_00011_0110111;      // LUI r3(s), 5F100 ; load r31 with peripheral base address
//assign inst7 = 32'b000000000100_00010_010_00100_0000011;   //lw 4(s),sp,4;   Pop from stack-active register
//assign inst8 = 32'b0111111_00100_00011_010_11000_0100011;   //sw zero,4(s),5F1007F8(#2040);; Store the active register back to its address
//assign inst9 = 32'b000000000000_00010_010_00001_0000011;   //lw 4(s),sp,0; Load reg 1 with 2044(xepc) register
//assign inst10 = 32'b000000001000_00010_000_00010_0010011;    //addi sp,sp,8; Restore stack pointer to its previous value
//assign inst11 = 32'b000000000000_00001_000_00000_1100111;   //jalr zero,4(s),zero; Set pc to the location in register 1
// ***              *** //

assign inst0 = 32'b00000000000000000000_00011_0010111;      //auipc x3(s),0 
assign inst1 = 32'h34119073;      //CSRW mepc, x3(s)  

assign inst2 = 32'h341021F3;     // CSRR x3(s), mepc
assign inst3 = 32'h00018067;   //jalr zero,x3(s)  Set pc to the location in shadow register 3


always @(posedge clk or posedge rst) begin
	if(rst) begin
		state <=  #2 idle;
		count1 <= #2 4'd0;
		count2 <= #2 4'd1;
	end
	else begin
		if(~stall_mul & ~freeze & ~icache_freeze ) begin   // icache_freeze added in the condition reason in cpu.v
			state <= #2 nxstate;
			if((count1 == 4) & count1_en)
				count1 <= #2 3'd0;
			else if(count1_en)
			count1 <= #2	 count1 + 1;
            if((count2 == 4) & count2_en)
			count2 <= #2	3'd1;            
            else if(count2_en)
				count2 <= #2 count2 + 1;
		end
	end
end

always @(*) begin
	case(state)
		idle:	begin
			count1_en <= 1'b0;
			count2_en <= 1'b0;
			irq_if_ctrl <= 1'b0;
			irq_icache_freeze <= 1'b0;
            if_id_freeze <= 1'b0;
			if(irq) begin
				nxstate <= ent_inject;
				irq_ctrl <= 1'b0;
			end
            else if(eret) begin
                nxstate <= ret_inject;
				irq_ctrl <= 1'b1;       
            end
			else begin
				nxstate <= idle;
				irq_ctrl <= 1'b0;
			end
		end
		ent_inject: begin
			irq_ctrl <= 1'b1;
			count1_en <= 1'b1;
			count2_en <= 1'b0;
            irq_if_ctrl <= 1'b1;
			if(count1 == 4) begin
				if_id_freeze <= 1'b0;
    			irq_icache_freeze <= 1'b0;
				nxstate <= idle;
            end				
			else begin
				if_id_freeze <= 1'b1;
                irq_icache_freeze <= 1'b1;
				nxstate <= ent_inject;
            end
		end
        ret_inject: begin
            irq_ctrl <= 1'b1;
            count1_en <= 1'b0;
            count2_en <= 1'b1;
            irq_if_ctrl <= 1'b0;
            if(count2 == 4) begin
                if_id_freeze <= 1'b0;
                nxstate <= idle;
    			irq_icache_freeze <= 1'b0;
            end
            else begin
                if_id_freeze <= 1'b1;
                nxstate <= ret_inject;
    			irq_icache_freeze <= 1'b1;
            end                   
        end
        default: begin
            irq_ctrl <= 1'b0;
			irq_icache_freeze <= 1'b0;
            count1_en <= 1'b0;
            count2_en <= 1'b0;
            irq_if_ctrl <= 1'b0;
            if_id_freeze <= 1'b0;
            nxstate <= idle;    
        end
	endcase;
end

always @(*) begin
	if(count1_en) begin
        eret_ack <= 1'b0;
        case(count1)
            4'd0: begin 
                inst_inj <= 32'b0;
                irq_ack <= 1'b0;
                irq_ctrl_dec_src1 <= 1'b0;
                irq_ctrl_dec_src2 <= 1'b0;                
                irq_ctrl_wb <= 1'b0;
            end
            4'd1: begin 
                inst_inj <= 32'b0;
                irq_ack <= 1'b0;
                irq_ctrl_dec_src1 <= 1'b0;
                irq_ctrl_dec_src2 <= 1'b0;                
                irq_ctrl_wb <= 1'b0;
            end
            4'd2: begin 
                inst_inj <= 32'b0;
                irq_ack <= 1'b0;
                irq_ctrl_dec_src1 <= 1'b0;
                irq_ctrl_dec_src2 <= 1'b0;                
                irq_ctrl_wb <= 1'b0;
            end
            4'd3: begin 
                inst_inj <= inst0;
                irq_ack <= 1'b0;
                irq_ctrl_dec_src1 <= 1'b0;
                irq_ctrl_dec_src2 <= 1'b0;                
                irq_ctrl_wb <= 1'b1;
            end
            4'd4: begin 
                inst_inj <= inst1;
                irq_ack <= 1'b1;
                irq_ctrl_dec_src1 <= 1'b1;
                irq_ctrl_dec_src2 <= 1'b0;                
                irq_ctrl_wb <= 1'b0;
            end
//            4'd5: begin
//                inst_inj <= inst2;
//                irq_ack <= 1'b0;
//                irq_ctrl_dec_src1 <= 1'b0;
//                irq_ctrl_dec_src2 <= 1'b0;                
//                irq_ctrl_wb <= 1'b0;
//            end
//            4'd6: begin
//                inst_inj <= inst3;
//                irq_ack <= 1'b0;
//                irq_ctrl_dec_src1 <= 1'b0;
//                irq_ctrl_dec_src2 <= 1'b1;                
//                irq_ctrl_wb <= 1'b0;
//            end
//            4'd7: begin
//                inst_inj <= inst4;
//                irq_ack <= 1'b0;
//                irq_ctrl_dec_src1 <= 1'b0;
//                irq_ctrl_dec_src2 <= 1'b0;                
//                irq_ctrl_wb <= 1'b0;
//            end
//            4'd8: begin
//                inst_inj <= inst5;
//                irq_ack <=1'b1;
//                irq_ctrl_dec_src1 <= 1'b0;
//                irq_ctrl_dec_src2 <= 1'b0;                
//                irq_ctrl_wb <= 1'b0;
//            end
            default: begin
                inst_inj <= 32'b0;
                irq_ack <=1'b0;
                irq_ctrl_dec_src1 <= 1'b0;
                irq_ctrl_dec_src2 <= 1'b0;                
                irq_ctrl_wb <= 1'b0;            
            end
            endcase;
    end
    else if(count2_en) begin
        irq_ack <= 1'b0;
       case(count2)
            4'd1:	 begin 
                inst_inj <= inst2;
                eret_ack <= 1'b0;
                irq_ctrl_dec_src1 <= 1'b0;
                irq_ctrl_dec_src2 <= 1'b0;                
                irq_ctrl_wb <= 1'b1;
            end
            4'd2:	 begin 
                inst_inj <= inst3;
                eret_ack <= 1'b0;
                irq_ctrl_dec_src1 <= 1'b1;
                irq_ctrl_dec_src2 <= 1'b0;                
                irq_ctrl_wb <= 1'b0;
            end
//            4'd3: begin
//                inst_inj <= inst8;
//                eret_ack <= 1'b0;
//                irq_ctrl_dec_src1 <= 1'b1;
//                irq_ctrl_dec_src2 <= 1'b1;                
//                irq_ctrl_wb <= 1'b0;
//            end
//            4'd4: begin
//                inst_inj <= inst9;
//                eret_ack <= 1'b0;
//                irq_ctrl_dec_src1 <= 1'b0;
//                irq_ctrl_dec_src2 <= 1'b0;                
//                irq_ctrl_wb <= 1'b0;
//            end
//            4'd5: begin
//                inst_inj <= inst10;
//                eret_ack <= 1'b0;
//                irq_ctrl_dec_src1 <= 1'b0;
//                irq_ctrl_dec_src2 <= 1'b0;                
//                irq_ctrl_wb <= 1'b0;
//            end
//            4'd6: begin
//                inst_inj <= inst11;
//                eret_ack <= 1'b0;
//                irq_ctrl_dec_src1 <= 1'b0;
//                irq_ctrl_dec_src2 <= 1'b0;                
//                irq_ctrl_wb <= 1'b0;
//            end
            4'd3: begin
                inst_inj <= 32'b0;
                eret_ack <= 1'b0;
                irq_ctrl_dec_src1 <= 1'b0;
                irq_ctrl_dec_src2 <= 1'b0;                
                irq_ctrl_wb <= 1'b0;
            end
            4'd4: begin
                inst_inj <= 32'd0;
                eret_ack <= 1'b1;
                irq_ctrl_dec_src1 <= 1'b0;
                irq_ctrl_dec_src2 <= 1'b0;                
                irq_ctrl_wb <= 1'b0;
            end        
            default: begin
                inst_inj <= 32'b0;
                eret_ack <=1'b0;
                irq_ctrl_dec_src1 <= 1'b0;
                irq_ctrl_dec_src2 <= 1'b0;                
                irq_ctrl_wb <= 1'b0;            
            end
        endcase;
    end
    else begin
        inst_inj <= 32'b0;
        irq_ack <= 1'b0;
        eret_ack <= 1'b0;
        irq_ctrl_dec_src1 <= 1'b0;
        irq_ctrl_dec_src2 <= 1'b0;    
        irq_ctrl_wb <= 1'b0;    
    end
end

endmodule