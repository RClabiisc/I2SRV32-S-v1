//******************************************************************************
// Copyright (c) 2014 - 2018, Indian Institute of Science, Bangalore.
// All Rights Reserved. See LICENSE for license details.
//------------------------------------------------------------------------------

// Contributors
// Akshay Birari (akshay@alum.iisc.ac.in), Piyush Birla (piyush@alum.iisc.ac.in)
// Suseela Budi (suseela@alum.iisc.ac.in), Pradeep Gupta (gupta@alum.iisc.ac.in)
// Kavya Sharat (kavyasharat@alum.iisc.ac.in), Sumeet Bandishte (sumeet.bandishte30@gmail.com)
// Kuruvilla Varghese (kuru@iisc.ac.in)
/*
Pulse Width Generators/timers with 16-bit main counter.
Period or timers target number is controlled by register [15:0]period.
Duty cycle is controlled by register [15:0]DC.
Clock used for PWM signal generation can be switched between Wishbone Bus clock and external clock. It is down clocked first.
o_pwm outputs PWM signal or timers interrupt.

control register [7:0]ctrl:
bit 0:	When set, external clock is chosen for PWM/timer. When cleared, wb clock is used for PWM/timer.
bit 1:	When set,  PWM is enabled. When cleared,  timer is enabled.
bit 2:	When set,  PWM/timer starts. When cleared, PWM/timer stops.
bit 3:	When set, timer runs continuously. When cleared, timer runs one time.
bit 4:	When set, o_pwm enabled.
bit 5:	timer interrupt bit	When it is written with 0, interrupt request is cleared. 
bit 6:	When set, a 16-bit external signal i_DC is used as duty cycle. When cleared, register DC is used.
bit 7:	When set, counter reset for PWM/timer, it's output and bit 5 will also be cleared. When changing from PWM mode to timer mode reset is needed before timer starts.
*/

`timescale 1ns / 1ps
`include "defines.v"


module	PWM(
//wishbone slave interface
input	i_wb_clk,
input	i_wb_rst,
input	i_wb_cyc,
input	i_wb_stb,
input	i_wb_we,
input	[31:0]i_wb_adr,
input	[31:0]i_wb_data,
input	[15:0]adc_reg,
input   [7:0] temp_set_reg,
output	[31:0]o_wb_data,
output	o_wb_ack,
output	reg [7:0] lcd_reg,
output	reg [7:0] led,
output	reg o_pwm,
output	reg o_buzzer

);
    reg	  [15:0]    DC;
    reg	  [15:0]    counter;
    wire	        write;
    wire	        clk;
    
    assign	write        =  i_wb_cyc & i_wb_stb & i_wb_we;
    assign	o_wb_ack     =  i_wb_stb;
    assign  o_wb_data    =  (i_wb_adr== `PWM_DC_REG) ? {16'b0,DC}:
                            (i_wb_adr== `led_addr)   ? {24'b0,led}:
                            (i_wb_adr== `ADC_REG)    ? {16'b0,adc_reg} : 
                            (i_wb_adr== `TEMP_REG)   ? {24'b0,temp_set_reg} : 
                            (i_wb_adr== `LCD_REG)    ? {24'b0,lcd_reg} :
                            32'b0;

always@(posedge i_wb_clk) begin
	if(i_wb_rst)
		led <= 0;
	else if((write) && (i_wb_adr == `led_addr))
        led <= i_wb_data[15:0];
end

always@(posedge i_wb_clk) begin
	if(i_wb_rst)
		DC <= 0;
	else if((write) && (i_wb_adr == `PWM_DC_REG))
        DC <= i_wb_data[15:0];
end

always@(posedge i_wb_clk) begin
	if(i_wb_rst)
		lcd_reg <= 0;
	else if((write) && (i_wb_adr == `LCD_REG))
        lcd_reg <= i_wb_data[7:0];
end
	
always@(posedge i_wb_clk) begin
    if(i_wb_rst)
        counter <= 16'b0;
    else if(counter == 16'hc350)
            counter <= 16'b0;
    else    
        counter <= counter + 1'b1;
end
        
 always@(posedge i_wb_clk) begin
    if(i_wb_rst)
        o_pwm <= 1'b0;
    else if(counter >= DC)
        o_pwm <= 16'b0;
    else    
        o_pwm <= 16'b1;
end

always@(posedge i_wb_clk) begin
	if(i_wb_rst)
		o_buzzer <= 0;
	else if((write) && (i_wb_adr == `BUZZER_REG))
        o_buzzer <= i_wb_data[0];
end
     


endmodule

