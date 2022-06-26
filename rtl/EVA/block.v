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
// Create Date: 18.03.2018 00:08:24
// Design Name: 
// Module Name: block
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


module block(clk, rst, start, seq_no, state, in, done_sorting, sorted_index_1D

    );

    parameter bit_len = 18;
    parameter Number = 16;
    
    input clk;
    input rst;
    input start;
    input [3:0] seq_no;
    input [2:0] state;
    input [bit_len*Number-1 : 0] in;
    output reg done_sorting;
    output reg [4*Number-1 : 0] sorted_index_1D;
    
    reg done;
    reg signed [bit_len-1 : 0] in_final [Number-1 : 0];
    (*keep = "true" *) reg [3 : 0] index [Number-1 : 0];

    reg signed [bit_len-1 : 0] sorted_no [Number-1 : 0];
    reg [3 : 0] sorted_index [Number-1 : 0];

    reg signed [bit_len-1:0] in0;
    reg signed [bit_len-1:0] in1;
    reg signed [bit_len-1:0] in2;
    reg signed [bit_len-1:0] in3;
    reg [3:0] in4;
    reg [3:0] in5;
    reg [3:0] in6;
    reg [3:0] in7;

    reg signed [bit_len-1:0] op0;
    reg signed [bit_len-1:0] op1;
    reg signed [bit_len-1:0] op2;
    reg signed [bit_len-1:0] op3;
    reg [3:0] op4;
    reg [3:0] op5;
    reg [3:0] op6;
    reg [3:0] op7;

    reg signed [bit_len-1:0] value0 [3:0];
    reg signed [bit_len-1:0] value1 [3:0];
    reg signed [bit_len-1:0] value2 [3:0];
    
    reg [3:0] index0 [3:0];
    reg [3:0] index1 [3:0];
    reg [3:0] index2 [3:0];

    reg [3:0] seq_no_delayed;
    reg [2:0] state_delayed;
    
    
/////////////////********** 2D_array to 1D_array conversion **********/////////////////        
           
    integer w;
    always @(*)
    begin
        for (w=0;w<Number;w=w+1) begin
            sorted_index_1D[w*4 +: 4] = sorted_index[w];
            end
        end
    
//////////////// ****************** /////////////////////////

//////////////**** updating number array and index array after each step sorting ****///////////

    integer i;
    always @(posedge clk)
    begin
        #0.1 if(rst) begin
            for(i=0; i<Number; i=i+1) begin
                in_final[i] = 0;
                index[i] = 0;
                end
            end
        else if(start) begin
            for (i=0;i<Number;i=i+1) begin
                in_final[i] = in[i*bit_len +: bit_len];
                index[i] = i;
                end
            end
        else if(state_delayed != 3'b000) begin
            in_final[seq_no_delayed] = op0;
            in_final[seq_no_delayed+1] = op1;
            in_final[seq_no_delayed+2] = op2;
            in_final[seq_no_delayed+3] = op3;
            index[seq_no_delayed] = op4;
            index[seq_no_delayed+1] = op5;
            index[seq_no_delayed+2] = op6;
            index[seq_no_delayed+3] = op7;
            end
        end

//////////////// ****************** /////////////////////////

//////////////**** combinational block ****///////////

    always @(*)
    begin
        if(rst) begin
            in0 = 0;
            in1 = 0;
            in2 = 0;
            in3 = 0;
            in4 = 0;
            in5 = 0;
            in6 = 0;
            in7 = 0;
            end
        else if(state_delayed != 3'b000) begin
            in0 = in_final[seq_no_delayed];
            in1 = in_final[seq_no_delayed+1];
            in2 = in_final[seq_no_delayed+2];
            in3 = in_final[seq_no_delayed+3];
            in4 = index[seq_no_delayed];
            in5 = index[seq_no_delayed+1];
            in6 = index[seq_no_delayed+2];
            in7 = index[seq_no_delayed+3];
            end


        if(in0 > in1) begin
            value0[0] = in1;
            value0[1] = in0;
            index0[0] = in5;
            index0[1] = in4;
            end
        else begin
            value0[1] = in1;
            value0[0] = in0;
            index0[0] = in4;
            index0[1] = in5;
            end
        
        if(in2 > in3) begin
            value0[2] = in3;
            value0[3] = in2;
            index0[2] = in7;
            index0[3] = in6;
            end
        else begin
            value0[3] = in3;
            value0[2] = in2;
            index0[2] = in6;
            index0[3] = in7;
            end
                
                
        if(value0[1] > value0[2]) begin
            value1[1] = value0[2];
            value1[2] = value0[1];
            index1[1] = index0[2];
            index1[2] = index0[1];
            end
        else begin
            value1[1] = value0[1];
            value1[2] = value0[2];
            index1[1] = index0[1];
            index1[2] = index0[2];
            end
                
        value1[0] = value0[0];
        value1[3] = value0[3];
        index1[0] = index0[0];
        index1[3] = index0[3];            
            
        if(value1[0] > value1[1]) begin
            value2[0] = value1[1];
            value2[1] = value1[0];
            index2[0] = index1[1];
            index2[1] = index1[0];
            end
        else begin
            value2[0] = value1[0];
            value2[1] = value1[1];
            index2[0] = index1[0];
            index2[1] = index1[1];
            end
                
        if(value1[2] > value1[3]) begin
            value2[2] = value1[3];
            value2[3] = value1[2];
            index2[2] = index1[3];
            index2[3] = index1[2];
            end
        else begin
            value2[2] = value1[2];
            value2[3] = value1[3];
            index2[2] = index1[2];
            index2[3] = index1[3];
            end
                    
        if(value2[1] > value2[2]) begin
            op1 = value2[2];
            op2 = value2[1];
            op5 = index2[2];
            op6 = index2[1];
            end
        else begin
            op1 = value2[1];
            op2 = value2[2];
            op5 = index2[1];
            op6 = index2[2];
            end
            
        op0 = value2[0];
        op3 = value2[3];
        op4 = index2[0];
        op7 = index2[3];

        end

//////////////// ****************** /////////////////////////

//////////////**** generating signals ****///////////

    always @(posedge clk)
    begin
        #0.1 done_sorting = done;
        if(state == 3'b101) begin
            done = 1'b1;
            end
        else begin
            done = 1'b0;
            end
        end

    always @(posedge clk)
    begin
        #0.1 seq_no_delayed <= seq_no;
        state_delayed <= state;
        end

//////////////// ****************** /////////////////////////

//////////////**** updating output number and index array after sorting ****///////////

    integer k;

    always @(posedge clk)
    begin
        #0.1 if(rst) begin
            for(k=0;k<Number;k=k+1) begin
                sorted_no[k] = 0;
                sorted_index[k] = k;
                end
            end
        else if(done_sorting) begin
//        else if(done_delayed2) begin
            for(k=0;k<Number;k=k+1) begin
                sorted_no[k] = in_final[k][bit_len-1:0];
                sorted_index[k] = index[k];
                end
            end
        
        end

//////////////// ****************** /////////////////////////


endmodule