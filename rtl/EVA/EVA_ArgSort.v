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
// Create Date: 14.03.2018 03:13:47
// Design Name: 
// Module Name: EVA_ArgSort
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


module EVA_ArgSort(clk, rst, start, in, done_sorting, sorted_index_1D

    );
    
    parameter bit_len = 18;
    parameter Number = 16;

    input clk;
    input rst;
    input start;
    input [bit_len*Number-1 : 0] in;
    output done_sorting;
    output [4*Number-1 : 0] sorted_index_1D;

    wire done;
    wire [3:0] seq_no;
    wire [2:0] state;    

    seq seq_gen(.clk(clk), .rst(rst), .start(start), .done(done), .seq_no(seq_no), .state(state)
                );

    block sort(.clk(clk), .rst(rst), .start(start), .seq_no(seq_no), .state(state), .in(in), .done_sorting(done_sorting), .sorted_index_1D(sorted_index_1D)
                );

endmodule
