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
`include "../rtl/defines.v"

module FPGA_WRAPPER_TEST(  );

reg rst;
reg clk_in1_p;
reg clk_in1_n;
wire [7:0] led;
reg [2:0] int_in;

`ifdef UART_IMPL_PER
parameter bit_time = 160; 
reg rx_i;
wire tx_o;
`endif

//wire [31:0] out_t0;
//wire [31:0] out_t1;
//wire [31:0] out_t2;

initial begin
rst <= 1'b1; clk_in1_p <= 1'b0;clk_in1_n<=1'b1; int_in <= 3'b0;

`ifdef UART_IMPL_PER rx_i <= 1'b1; `endif

#200 rst <= 1'b0;
//#7900 int_in <= 3'b100;
//#20 int_in <= 3'b000;
////#1000 int_in <= 3'b001;
//#20 int_in <= 3'b000;
//#80 int_in <= 3'b000;
//#20 int_in <= 3'b000;
//#930 int_in <= 3'b000;
//#20 int_in <= 3'b000;

`ifdef UART_IMPL_PER
 #300
      rx_i = 0; //start bit
    #bit_time
      rx_i = 1; //bit 0
    #bit_time
      rx_i = 0; //bit 1
    #bit_time
      rx_i = 0; //bit 2
    #bit_time
      rx_i = 0; //bit 3
    #bit_time
      rx_i = 0; //bit 4
    #bit_time
      rx_i = 1; //bit 5
    #bit_time
      rx_i = 1; //bit 6
    #bit_time
      rx_i = 0; //bit 7
    #bit_time
      rx_i = 1; //Stop bit
 
  #500
          rx_i = 0; //start bit
        #bit_time
          rx_i = 1; //bit 0
        #bit_time
          rx_i = 1; //bit 1
        #bit_time
          rx_i = 1; //bit 2
        #bit_time
          rx_i = 0; //bit 3
        #bit_time
          rx_i = 0; //bit 4
        #bit_time
          rx_i = 1; //bit 5
        #bit_time
          rx_i = 1; //bit 6
        #bit_time
          rx_i = 0; //bit 7
        #bit_time
          rx_i = 1; //Stop bit
`endif
          
end

always #2.5 clk_in1_p <= ~clk_in1_p;
always #2.5 clk_in1_n <= ~clk_in1_n;

FPGA_WRAPPER FW1(.rst_in(rst),.clk_in1_p(clk_in1_p),
.clk_in1_n(clk_in1_n),.led(led),.int_in(int_in)
`ifdef UART_IMPL_PER
,.srx_pad_i(rx_i),.stx_pad_o(tx_o)
`endif
);


endmodule