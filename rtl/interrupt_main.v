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
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:17:23 01/25/2016 
// Design Name: 
// Module Name:    interrupt_main 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
/*
interrupt_main : INTERRUPT CONTROLLER main module

Submodules:

// Interrupt controller  generates read/write signals for interrupt control and status registers
// Sfr file contains interrupt control and status registers

*/
////////////////////////////////////////////////////////////////////

module interrupt_main(
input [31:0] interrupt,  // interrupt input
input clk,               // clock 
input reset,             // reset      
input done,              //eret instruction from decode stage  
// eret to irq_interfac should be in same clock cycle as done needed to change  
input icache_stall_out,     //icache stall
input freeze,
input ic_irq_ack,
input eret_ack,          // interrupt acknowlegde from riscv cpu
output reg ic_proc_req,             // IRQ request to RISCV core
input [31:0] csr_wrdata,
input csr_wr_en,
input [11:0] csr_adr_rd,
input [11:0] csr_adr_wr,
output reg [31:0] csr_rddata,
output reg [5:0] device_id      //  Device_id made output to send fetch stage

 /////////////////////////////////////////////////
    );
    
localparam state1 = 4'b0001;       
localparam state4 = 4'b0100;
localparam state6 = 4'b0110;
localparam state7a = 4'b0000;
localparam state1a = 4'b1101;
localparam state6a = 4'b1110;
localparam state4b = 4'b1111;
localparam state1b = 4'b0111;
localparam state1c = 4'b0010;
localparam state9 = 4'b1001;

reg irq_ack_latch;
reg irq_stall;

reg[3:0] state;
reg[3:0] nextstate;
reg[1:0] cmd;

wire ic_irq_ack_int;
reg ic_proc_req_int;
reg[1:0] current_priority_reg;
reg[1:0] highest_premptive_intr;

reg[31:0] enable_reg;
reg[31:0] active_reg;
reg[31:0] pending_reg;
reg[6:0] stack_save_reg;
reg[7:0] STACK_SAVE_REG_S;
reg[31:0] irq_priority_reg0;    //highest priority is 0 priority
reg[31:0] irq_priority_reg1;   // priority 1 register
reg[31:0] irq_priority_reg2;   // priority 2 register
reg[31:0] irq_priority_reg3;   // priority 3 register

reg[31:0] lirq,dirq;
wire[31:0] interrupt_int;

assign proc_req = (ic_proc_req & ~ic_proc_req_int);
assign ic_irq_ack_int = (irq_ack_latch & ~ic_irq_ack);
assign interrupt_int = (lirq & ~dirq);// all are positive-edge triggered interrupts

always @(posedge clk)
begin
    if(reset) 
        state <= state1;
    else begin
        state <= nextstate;
        ic_proc_req_int <= ic_proc_req;
        irq_ack_latch <= ic_irq_ack;
        lirq <=  (interrupt & enable_reg);
        dirq <=  lirq;
    end
end

always@(*)
begin
    if(reset)
    begin
        cmd<=2'b0;                   //no command sent
        nextstate<= state1;
        ic_proc_req<=0;
    end
    else
    begin
        case(state)
            state1: begin
                if (|interrupt_int) begin
                    cmd<=2'b0;               
                    ic_proc_req<=1'b0;
                    nextstate<=state1b;
                end
                else
                begin
                    ic_proc_req<=1'b0;
                    cmd<=2'b0;
                    nextstate<=state1;
                end
            end            
            state1b: begin
                ic_proc_req<=1'b1;
                cmd<=2'b0;                              
                nextstate<=state1c;
            end   
            state1c: begin
                ic_proc_req<=1'b1;
                cmd<=2'b01;                              
                nextstate<=state1a;
            end         
            state1a: begin
                if (ic_irq_ack_int) begin
                    ic_proc_req<=1'b0;
                    cmd<=2'b0;        
                    nextstate<=state4;
                end
                else begin             
                    cmd<=2'b0; 
                    nextstate<=state1a;            
                    ic_proc_req<=1'b1;
                end
            end                     
            state4: begin
                ic_proc_req<=1'b0;
                if (done) begin      
                    cmd<=2'b10;
                    nextstate<=state6;
                end
                else if (current_priority_reg > highest_premptive_intr ) begin
                    cmd<=2'b0;     
                    nextstate<=state4b;
                end
                else begin
                    cmd<=2'b0;
                    nextstate<=state4;   
                end
            end
            state4b: begin
                if (done)  begin    
                    cmd<=2'b10;
                    nextstate<=state6;
                    ic_proc_req<=1'b0;
                end
                else begin
                    cmd<=2'b0;
                    nextstate<=state1b;
                    ic_proc_req<=1'b1;
                end                
            end
            state6: begin
                ic_proc_req<=1'b0;
                if(eret_ack) begin
                    if (|active_reg) begin
                        nextstate<=state7a;
                    end
                    else if (|pending_reg) begin
                        nextstate<=state6a;
                    end
                    else begin
                        cmd<=2'b0;
                        nextstate<=state1;
                    end
                end
                else begin
                    nextstate<=state6;
                    cmd<=2'b0;
                end
            end
            state6a: begin
                if(icache_stall_out) begin
                    ic_proc_req<=1'b0;
                    cmd<=2'b0;
                    nextstate<=state6a;
                end
                else begin
                    ic_proc_req<=1'b0;
                    cmd<=2'b0;
                    nextstate<=state1b;     //state9 & req = 0
                end
            end
//            state9: begin
//                ic_proc_req<=1;
//                cmd<=3'b0;            
//                nextstate<=state1b;
//            end
            state7a: begin
                if (current_priority_reg > highest_premptive_intr ) begin
                    ic_proc_req<=1'b0;
                    cmd<=2'b0;
                    nextstate<=state1b;
                end
                else begin
                    ic_proc_req<=0;
                    cmd<=2'b0;
                    nextstate<=state4;
                end
            end
            default: begin
                cmd<=2'b0;
                ic_proc_req<=1'b0;
                nextstate<=state1;
            end
        endcase
    end
end


always@(*)
begin
    if(reset)    
        highest_premptive_intr <= 2'b0;
    else if(|(irq_priority_reg0 & pending_reg))
        highest_premptive_intr <= 2'b0;
    else if(|(irq_priority_reg1 & pending_reg))
        highest_premptive_intr <= 2'b1;
    else if(|(irq_priority_reg2 & pending_reg))
        highest_premptive_intr <= 2'b10;
    else if(|(irq_priority_reg3 & pending_reg))
        highest_premptive_intr <= 2'b11;
end

always@(posedge clk)
begin
    if(reset)
        current_priority_reg<= 2'b0;
    else if(proc_req) 
        current_priority_reg <= highest_premptive_intr;
    else if (eret_ack)
   	    current_priority_reg <= stack_save_reg[1:0];
end

always@(posedge clk)
begin
    if(reset) begin
        device_id <= 5'b0;
    end
    else if (proc_req)
    begin
        if(highest_premptive_intr == 2'b0) begin
            if(irq_priority_reg0[0] & pending_reg[0])
                device_id <= 5'd0;
            else
            if(irq_priority_reg0[1] & pending_reg[1])
                device_id <= 5'd1;
            else
            if(irq_priority_reg0[2] & pending_reg[2])
                device_id <= 5'd2;
            else
            if(irq_priority_reg0[3] & pending_reg[3])
                device_id <= 5'd3;
            else
            if(irq_priority_reg0[4] & pending_reg[4])
                device_id <= 5'd4;
            else
            if(irq_priority_reg0[5] & pending_reg[5])
                device_id <= 5'd5;
            else
            if(irq_priority_reg0[6] & pending_reg[6])
                device_id <= 5'd6;
            else
            if(irq_priority_reg0[7] & pending_reg[7])
                device_id <= 5'd7;
            else
            if(irq_priority_reg0[8] & pending_reg[8])
                device_id <= 5'd8;
            else
            if(irq_priority_reg0[9] & pending_reg[9])
                device_id <= 5'd9;
            else
            if(irq_priority_reg0[10]& pending_reg[10])
                device_id <= 5'd10;
            else
            if(irq_priority_reg0[11]& pending_reg[11])
                device_id <= 5'd11;
            else
            if(irq_priority_reg0[12]& pending_reg[12])
                device_id <= 5'd12;
            else
            if(irq_priority_reg0[13]& pending_reg[13])
                device_id <= 5'd13;
            else
            if(irq_priority_reg0[14]& pending_reg[14])
                device_id <= 5'd14;
            else
            if(irq_priority_reg0[15]& pending_reg[15])
                device_id <= 5'd15;
            else
            if(irq_priority_reg0[16]& pending_reg[16])
                device_id <= 5'd16;
            else
            if(irq_priority_reg0[17]& pending_reg[17])
                device_id <= 5'd17;
            else
            if(irq_priority_reg0[18]& pending_reg[18])
                device_id <= 5'd18;
            else
            if(irq_priority_reg0[19]& pending_reg[19])
                device_id <= 5'd19;
            else
            if(irq_priority_reg0[20]& pending_reg[20])
                device_id <= 5'd20;
            else
            if(irq_priority_reg0[21]& pending_reg[21])
                device_id <= 5'd21;
            else
            if(irq_priority_reg0[22]& pending_reg[22])
                device_id <= 5'd22;
            else
            if(irq_priority_reg0[23]& pending_reg[23])
                device_id <= 5'd23;
            else
            if(irq_priority_reg0[24]& pending_reg[24])
                device_id <= 5'd24;
            else
            if(irq_priority_reg0[25]& pending_reg[25])
                device_id <= 5'd25;
            else
            if(irq_priority_reg0[26]& pending_reg[26])
                device_id <= 5'd26;
            else
            if(irq_priority_reg0[27]& pending_reg[27])
                device_id <= 5'd27;
            else
            if(irq_priority_reg0[28]& pending_reg[28])
                device_id <= 5'd28;
            else
            if(irq_priority_reg0[29]& pending_reg[29])
                device_id <= 5'd29;
            else
            if(irq_priority_reg0[30]& pending_reg[30])
                device_id <= 5'd30;
            else
            if(irq_priority_reg0[31]& pending_reg[31])
                device_id <= 5'd31;
            else
                device_id <= 5'd0;
        end
        else if(highest_premptive_intr == 2'b1) begin
            if(irq_priority_reg1[0] & pending_reg[0])
                device_id <= 5'd0;
            else
            if(irq_priority_reg1[1] & pending_reg[1])
                device_id <= 5'd1;
            else
            if(irq_priority_reg1[2] & pending_reg[2])
                device_id <= 5'd2;
            else
            if(irq_priority_reg1[3] & pending_reg[3])
                device_id <= 5'd3;
            else
            if(irq_priority_reg1[4] & pending_reg[4])
                device_id <= 5'd4;
            else
            if(irq_priority_reg1[5] & pending_reg[5])
                device_id <= 5'd5;
            else
            if(irq_priority_reg1[6] & pending_reg[6])
                device_id <= 5'd6;
            else
            if(irq_priority_reg1[7] & pending_reg[7])
                device_id <= 5'd7;
            else
            if(irq_priority_reg1[8] & pending_reg[8])
                device_id <= 5'd8;
            else
            if(irq_priority_reg1[9] & pending_reg[9])
                device_id <= 5'd9;
            else
            if(irq_priority_reg1[10]& pending_reg[10])
                device_id <= 5'd10;
            else
            if(irq_priority_reg1[11]& pending_reg[11])
                device_id <= 5'd11;
            else
            if(irq_priority_reg1[12]& pending_reg[12])
                device_id <= 5'd12;
            else
            if(irq_priority_reg1[13]& pending_reg[13])
                device_id <= 5'd13;
            else
            if(irq_priority_reg1[14]& pending_reg[14])
                device_id <= 5'd14;
            else
            if(irq_priority_reg1[15]& pending_reg[15])
                device_id <= 5'd15;
            else
            if(irq_priority_reg1[16]& pending_reg[16])
                device_id <= 5'd16;
            else
            if(irq_priority_reg1[17]& pending_reg[17])
                device_id <= 5'd17;
            else
            if(irq_priority_reg1[18]& pending_reg[18])
                device_id <= 5'd18;
            else
            if(irq_priority_reg1[19]& pending_reg[19])
                device_id <= 5'd19;
            else
            if(irq_priority_reg1[20]& pending_reg[20])
                device_id <= 5'd20;
            else
            if(irq_priority_reg1[21]& pending_reg[21])
                device_id <= 5'd21;
            else
            if(irq_priority_reg1[22]& pending_reg[22])
                device_id <= 5'd22;
            else
            if(irq_priority_reg1[23]& pending_reg[23])
                device_id <= 5'd23;
            else
            if(irq_priority_reg1[24]& pending_reg[24])
                device_id <= 5'd24;
            else
            if(irq_priority_reg1[25]& pending_reg[25])
                device_id <= 5'd25;
            else
            if(irq_priority_reg1[26]& pending_reg[26])
                device_id <= 5'd26;
            else
            if(irq_priority_reg1[27]& pending_reg[27])
                device_id <= 5'd27;
            else
            if(irq_priority_reg1[28]& pending_reg[28])
                device_id <= 5'd28;
            else
            if(irq_priority_reg1[29]& pending_reg[29])
                device_id <= 5'd29;
            else
            if(irq_priority_reg1[30]& pending_reg[30])
                device_id <= 5'd30;
            else
            if(irq_priority_reg1[31]& pending_reg[31])
                device_id <= 5'd31;
            else
                device_id <= 5'd0;
        end
        else if(highest_premptive_intr == 2'b10) begin
            if(irq_priority_reg2[0] & pending_reg[0])
                device_id <= 5'd0;
            else
            if(irq_priority_reg2[1] & pending_reg[1])
                device_id <= 5'd1;
            else
            if(irq_priority_reg2[2] & pending_reg[2])
                device_id <= 5'd2;
            else
            if(irq_priority_reg2[3] & pending_reg[3])
                device_id <= 5'd3;
            else
            if(irq_priority_reg2[4] & pending_reg[4])
                device_id <= 5'd4;
            else
            if(irq_priority_reg2[5] & pending_reg[5])
                device_id <= 5'd5;
            else
            if(irq_priority_reg2[6] & pending_reg[6])
                device_id <= 5'd6;
            else
            if(irq_priority_reg2[7] & pending_reg[7])
                device_id <= 5'd7;
            else
            if(irq_priority_reg2[8] & pending_reg[8])
                device_id <= 5'd8;
            else
            if(irq_priority_reg2[9] & pending_reg[9])
                device_id <= 5'd9;
            else
            if(irq_priority_reg2[10]& pending_reg[10])
                device_id <= 5'd10;
            else
            if(irq_priority_reg2[11]& pending_reg[11])
                device_id <= 5'd11;
            else
            if(irq_priority_reg2[12]& pending_reg[12])
                device_id <= 5'd12;
            else
            if(irq_priority_reg2[13]& pending_reg[13])
                device_id <= 5'd13;
            else
            if(irq_priority_reg2[14]& pending_reg[14])
                device_id <= 5'd14;
            else
            if(irq_priority_reg2[15]& pending_reg[15])
                device_id <= 5'd15;
            else
            if(irq_priority_reg2[16]& pending_reg[16])
                device_id <= 5'd16;
            else
            if(irq_priority_reg2[17]& pending_reg[17])
                device_id <= 5'd17;
            else
            if(irq_priority_reg2[18]& pending_reg[18])
                device_id <= 5'd18;
            else
            if(irq_priority_reg2[19]& pending_reg[19])
                device_id <= 5'd19;
            else
            if(irq_priority_reg2[20]& pending_reg[20])
                device_id <= 5'd20;
            else
            if(irq_priority_reg2[21]& pending_reg[21])
                device_id <= 5'd21;
            else
            if(irq_priority_reg2[22]& pending_reg[22])
                device_id <= 5'd22;
            else
            if(irq_priority_reg2[23]& pending_reg[23])
                device_id <= 5'd23;
            else
            if(irq_priority_reg2[24]& pending_reg[24])
                device_id <= 5'd24;
            else
            if(irq_priority_reg2[25]& pending_reg[25])
                device_id <= 5'd25;
            else
            if(irq_priority_reg2[26]& pending_reg[26])
                device_id <= 5'd26;
            else
            if(irq_priority_reg2[27]& pending_reg[27])
                device_id <= 5'd27;
            else
            if(irq_priority_reg2[28]& pending_reg[28])
                device_id <= 5'd28;
            else
            if(irq_priority_reg2[29]& pending_reg[29])
                device_id <= 5'd29;
            else
            if(irq_priority_reg2[30]& pending_reg[30])
                device_id <= 5'd30;
            else
            if(irq_priority_reg2[31]& pending_reg[31])
                device_id <= 5'd31;
            else
                device_id <= 5'd0;
        end
        else if(highest_premptive_intr == 2'b11) begin
            if(irq_priority_reg3[0] & pending_reg[0])
                device_id <= 5'd0;
            else
            if(irq_priority_reg3[1] & pending_reg[1])
                device_id <= 5'd1;
            else
            if(irq_priority_reg3[2] & pending_reg[2])
                device_id <= 5'd2;
            else
            if(irq_priority_reg3[3] & pending_reg[3])
                device_id <= 5'd3;
            else
            if(irq_priority_reg3[4] & pending_reg[4])
                device_id <= 5'd4;
            else
            if(irq_priority_reg3[5] & pending_reg[5])
                device_id <= 5'd5;
            else
            if(irq_priority_reg3[6] & pending_reg[6])
                device_id <= 5'd6;
            else
            if(irq_priority_reg3[7] & pending_reg[7])
                device_id <= 5'd7;
            else
            if(irq_priority_reg3[8] & pending_reg[8])
                device_id <= 5'd8;
            else
            if(irq_priority_reg3[9] & pending_reg[9])
                device_id <= 5'd9;
            else
            if(irq_priority_reg3[10]& pending_reg[10])
                device_id <= 5'd10;
            else
            if(irq_priority_reg3[11]& pending_reg[11])
                device_id <= 5'd11;
            else
            if(irq_priority_reg3[12]& pending_reg[12])
                device_id <= 5'd12;
            else
            if(irq_priority_reg3[13]& pending_reg[13])
                device_id <= 5'd13;
            else
            if(irq_priority_reg3[14]& pending_reg[14])
                device_id <= 5'd14;
            else
            if(irq_priority_reg3[15]& pending_reg[15])
                device_id <= 5'd15;
            else
            if(irq_priority_reg3[16]& pending_reg[16])
                device_id <= 5'd16;
            else
            if(irq_priority_reg3[17]& pending_reg[17])
                device_id <= 5'd17;
            else
            if(irq_priority_reg3[18]& pending_reg[18])
                device_id <= 5'd18;
            else
            if(irq_priority_reg3[19]& pending_reg[19])
                device_id <= 5'd19;
            else
            if(irq_priority_reg3[20]& pending_reg[20])
                device_id <= 5'd20;
            else
            if(irq_priority_reg3[21]& pending_reg[21])
                device_id <= 5'd21;
            else
            if(irq_priority_reg3[22]& pending_reg[22])
                device_id <= 5'd22;
            else
            if(irq_priority_reg3[23]& pending_reg[23])
                device_id <= 5'd23;
            else
            if(irq_priority_reg3[24]& pending_reg[24])
                device_id <= 5'd24;
            else
            if(irq_priority_reg3[25]& pending_reg[25])
                device_id <= 5'd25;
            else
            if(irq_priority_reg3[26]& pending_reg[26])
                device_id <= 5'd26;
            else
            if(irq_priority_reg3[27]& pending_reg[27])
                device_id <= 5'd27;
            else
            if(irq_priority_reg3[28]& pending_reg[28])
                device_id <= 5'd28;
            else
            if(irq_priority_reg3[29]& pending_reg[29])
                device_id <= 5'd29;
            else
            if(irq_priority_reg3[30]& pending_reg[30])
                device_id <= 5'd30;
            else
            if(irq_priority_reg3[31]& pending_reg[31])
                device_id <= 5'd31;
        end
    end
    else if(eret_ack)
        device_id <= stack_save_reg[6:2];
    end   
    
   //Priority level 0 register 
always@(posedge  clk ) begin
    if(reset)
        irq_priority_reg0 <= 32'b111100;
    else if( (csr_adr_wr==`PRIORITY_REG0) && csr_wr_en)
        irq_priority_reg0 <= csr_wrdata;
end

  //Priority level 1 register 
always@(posedge  clk) begin
    if(reset)
        irq_priority_reg1 <= 32'b0010;
    else if( (csr_adr_wr==`PRIORITY_REG1) && csr_wr_en)
        irq_priority_reg1 <= csr_wrdata;
end  

//Priority level 2 register 
always@(posedge  clk ) begin
    if(reset)
        irq_priority_reg2 <= 32'b0001;
    else if( (csr_adr_wr==`PRIORITY_REG2)   && csr_wr_en)
        irq_priority_reg2 <= csr_wrdata;
end

  //Priority level 3 register 
 always@(posedge  clk ) begin
    if(reset)
        irq_priority_reg3 <= 32'b0;
    else if( (csr_adr_wr==`PRIORITY_REG3)   && csr_wr_en)
        irq_priority_reg3 <= csr_wrdata;
end  

  //interrupt enable register . All interrupts enabled on reset 
 always@(posedge  clk) begin
    if(reset)
        enable_reg <= 32'hffffffff;
    else if( (csr_adr_wr==`ENABLE_REG) && csr_wr_en)
        enable_reg <= csr_wrdata;
end  

/////////active register set/clear////////////////
always@(posedge clk ) begin
    if(reset)
        active_reg<=0;
    else if(cmd==`clear_pend_act_stackrestore)
        active_reg[device_id]<=0;
    else if(cmd==`set_pend_act_stacksave)
        active_reg[device_id]<=1;
end

/////////pending register////////////////
always@(posedge clk) begin
    if(reset)
        pending_reg<=0;
    else if(|interrupt_int)
        pending_reg <= (pending_reg | interrupt_int);
    else if(cmd==`clear_pend_act_stackrestore)
        pending_reg[device_id]<=0;
end

/////////stack save register////////////////
always@(posedge clk ) begin
//stack_save_reg is combination of status_reg, and current_priority_reg which is pushed and popped out of stack
    if(reset)
        stack_save_reg <= 0;
    else if( cmd== `set_pend_act_stacksave)//`set_pend_act_stacksave)
        stack_save_reg <= {device_id,highest_premptive_intr };
    else if ((csr_adr_wr==`STACK_SAVE_REG)  && csr_wr_en) 
        stack_save_reg<= csr_wrdata[6:0];//wb_data_o_int;
end

always@(posedge clk ) begin
    if(reset)
        STACK_SAVE_REG_S <= 0;
    else if(cmd== `set_pend_act_stacksave)
        STACK_SAVE_REG_S <= stack_save_reg;
end


always @(clk) begin
    if (reset)
        csr_rddata<=32'h0;
    else if(~freeze) begin
        case (csr_adr_rd) 
           `ENABLE_REG:       csr_rddata <= #1 enable_reg;
           `PRIORITY_REG0:    csr_rddata <= #1 irq_priority_reg0;
           `PRIORITY_REG1:    csr_rddata <= #1 irq_priority_reg1;
           `PRIORITY_REG2:    csr_rddata <= #1 irq_priority_reg2;
           `PRIORITY_REG3:    csr_rddata <= #1 irq_priority_reg3;
           `PENDING_REG:      csr_rddata <= #1 pending_reg; 
           `ACTIVE_REG:       csr_rddata <= #1 active_reg;
           `STACK_SAVE_REG:   csr_rddata <= #1 {{25'b0},{stack_save_reg}};
           `STACK_SAVE_REG_S: csr_rddata <= #1 {{25'b0},{STACK_SAVE_REG_S}};
            default:          csr_rddata <=32'h0;
        endcase;
    end
end

endmodule