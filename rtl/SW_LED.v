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
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2016 10:06:51
// Design Name: 
// Module Name: SW_LED
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SW_LED(
input sw1_i,
input sw2_i,
input sw3_i,
output reg led1_o,
output reg led2_o,
output reg led3_o,
input [31:0] wb_dat_i,
input [31:0] wb_adr_i,
input [3:0] wb_sel_i,
input [2:0] wb_cti_i,
input [1:0] wb_bte_i,
output reg [31:0] wb_dat_o,
output reg wb_ack_o,
output reg wb_err_o,
output reg wb_rty_o,
input wb_stb_i,
input wb_cyc_i,
input wb_we_i,
input wb_rst_i,
input wb_clk_i,
output reg irq_o,
input irq_ack);

//Level to pulse converter///
wire sw1_int;
wire sw2_int;
wire sw3_int;
reg sw1_reg;
reg sw2_reg;
reg sw3_reg;

always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if(wb_rst_i) begin
        sw1_reg <=  0;
        sw2_reg <=  0;
        sw3_reg <=  0;        
    end
    else begin
        sw1_reg <=  sw1_i;
        sw2_reg <=  sw2_i;
        sw3_reg <=  sw3_i;            
    end
end

assign sw1_int = sw1_i & ~sw1_reg;
assign sw2_int = sw2_i & ~sw2_reg;
assign sw3_int = sw3_i & ~sw3_reg; 
////////////////////////////////
///Scheduler FSM for the 3 switches///
reg state,nextstate;
parameter idle = 1'b0;
parameter signal_irq = 1'b1;
always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if(wb_rst_i) begin
        state <= idle;    
    end
    else begin
        state <= nextstate;
    end
end

reg [7:0] switch_status;
reg [7:0] led_control;

always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if(wb_rst_i) begin
        switch_status <= 8'b0;
    end
    else begin
        if(sw1_i) begin
            switch_status <= 8'b001;                
        end
        else if(sw2_i) begin
            switch_status <= 8'b010;                
        end
        else if(sw3_i) begin
            switch_status <= 8'b100;                
        end
        else begin
            switch_status <= 8'b0;
        end
    end
end

always @(*) begin
    case(state)
        idle: begin
            irq_o <= 1'b0;
            if(sw1_int | sw2_int | sw3_int) begin
                nextstate <= signal_irq;
            end
            else begin
                nextstate <= idle;            
            end
        end
        signal_irq: begin
            irq_o <= 1'b1;
            if(irq_ack) begin
                nextstate <= idle;                
            end
            else begin
                nextstate <= signal_irq;
            end
        end
        default: begin
            irq_o <= 1'b0;
            nextstate <= idle;
        end
    endcase;
end
//////////////////////////////////////
//Wishbone Interface//////////////////
always @(posedge wb_clk_i or posedge wb_rst_i) begin
    if(wb_rst_i) begin
        led_control <= 8'b0;
        wb_dat_o <= 32'b0;
        wb_ack_o <= 1'b0;      
        wb_err_o <= 1'b0;
        wb_rty_o <= 1'b0;           
    end
    else begin
        if(wb_stb_i & wb_cyc_i) begin
            wb_ack_o <= 1'b1;
            wb_err_o <= 1'b0;
            wb_rty_o <= 1'b0;           
            if(wb_we_i) begin                      //Wishbone red cycle
                case(wb_sel_i)
                    4'b0001: led_control <= wb_dat_i[7:0];
                    4'b0010: led_control <= wb_dat_i[15:8];
                    4'b0100: led_control <= wb_dat_i[23:16];
                    4'b1000: led_control <= wb_dat_i[31:24];
                    default: led_control <= 8'b0;      
                endcase;
            end
            else begin
                case(wb_sel_i)
                    4'b0001: wb_dat_o <= {{24'b0},{switch_status}};
                    4'b0010: wb_dat_o <= {{16'b0},{switch_status},{8'b0}};
                    4'b0100: wb_dat_o <= {{8'b0},{switch_status},{16'b0}};
                    4'b1000: wb_dat_o <= {{switch_status},{24'b0}};
                    4'b0011: wb_dat_o <= {{16'b0},{switch_status},{switch_status}};
                    4'b1100: wb_dat_o <= {{switch_status},{switch_status},{16'b0}};
                    4'b1111: wb_dat_o <= {{24'b0},{switch_status}};                                        
//                    4'b1111: wb_dat_o <= {{switch_status},{switch_status},{switch_status},{switch_status}};                    
                    default: wb_dat_o <= 32'b0;
                endcase;            
            end
        end
        else begin
            wb_ack_o <= 1'b0;
            wb_err_o <= 1'b0;
            wb_rty_o <= 1'b0;           
            wb_dat_o <= 32'b0;            
        end
    end
end
/////////////////////////////////////
////LED Control for Output///////////
always @(*) begin
    if(wb_rst_i) begin
        led1_o = 1'b0;
        led2_o = 1'b0;
        led3_o = 1'b0;
    end
    else begin
        led1_o = led_control[0];
        led2_o = led_control[1];
        led3_o = led_control[2];    
    end
end
/////////////////////////////////////
/////////////////////////////////////
endmodule