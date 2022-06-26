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
// Create Date: 07.03.2018 02:06:43
// Design Name: 
// Module Name: class_bit
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


module class_bit(clk, rst,we, re, hit, write_addr, access_addr, classificationBit

    );
    
    input clk;
    input rst;
    input re;
    input we;
    input hit;
    input [4:0] write_addr;
    input [4:0] access_addr;
    output reg [31:0] classificationBit;
    
    reg classification_bit[0:31];

/////////////////********** 2D_array to 1D_array conversion **********/////////////////        
       
    integer w;
    always @(*)
    begin
        if(rst) begin
            classificationBit = 0;
            end
        else begin
            for (w=0;w<32;w=w+1) begin
                classificationBit[w*1 +: 1] = classification_bit[w];
                end
            end
        end
//////////////// ****************** /////////////////////////

/////////////////********** classification bit logic **********/////////////////

    integer g;
    always @(posedge clk)
    begin
        #0.1 if(rst) begin
            for(g=0; g<32; g=g+1) begin
                classification_bit[g] = 0;
                end
            end
        else if(we) begin
            classification_bit[write_addr] <= 1'b0;
            end
        else if(re) begin
            if(hit) begin
                classification_bit[access_addr] = 1'b1;
                end
            end
        end

//////////////////  ******************  /////////////////////////////
    
endmodule
