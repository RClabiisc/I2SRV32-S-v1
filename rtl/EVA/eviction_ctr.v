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
// Create Date: 07.03.2018 02:06:06
// Design Name: 
// Module Name: eviction_ctr
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


module eviction_ctr(clk, rst, update_EVA, evict_data, evict_addr, age_1D, classificationBit, evictionCtr_R_1D, evictionCtr_NR_1D

    );

    parameter k = 3;       /////////////age counter width//////////
    parameter j = 2;       /////////////set counter width- will be used for Age Granularity//////////
    parameter A = 2;        //////////////Age Granularity/////////////
    parameter accessCtrWidth = 13;
    parameter N = 2**k;   /////number of rows
    parameter ctrLen = 10;
    parameter M = ctrLen;   /////number of column
    
    input clk;
    input rst;
    input update_EVA;
    input evict_data;
    input [4:0] evict_addr;
    inout [32*k - 1 : 0] age_1D;
    input [31:0] classificationBit;
    output reg [ctrLen*N-1 : 0] evictionCtr_R_1D;
    output reg [ctrLen*N-1 : 0] evictionCtr_NR_1D;

    reg [(ctrLen - 1):0] evictionCtr_NR[0:N-1];
    reg [(ctrLen - 1):0] evictionCtr_R[0:N-1];
    
    reg [(k - 1):0] age[0:31];    ////k-bit age for each line/////
    reg classification_bit[0:31];
    
//////////////converting 1-D array to 2-D vector///////////

    integer i;
    always @(*)
    begin
        for (i=0;i<32;i=i+1) begin
            age[i] = age_1D[i*k +: k];
            classification_bit[i] = classificationBit[i*1 +: 1];
            end
        end

//////////////// ****************** /////////////////////////

/////////////////********** 2D_array to 1D_array conversion **********/////////////////        
       
    integer w;
    always @(*)
    begin
        if(rst) begin    
            evictionCtr_R_1D = { (ctrLen*N) {1'b0} };
            evictionCtr_NR_1D = { (ctrLen*N) {1'b0} };
            end
        else begin
            for (w=0;w<N;w=w+1) begin
                evictionCtr_R_1D[w*M +: M] = evictionCtr_R[w];
                evictionCtr_NR_1D[w*M +: M] = evictionCtr_NR[w];
                end
            end
        end
//////////////// ****************** /////////////////////////
    
////////////////********  evictionCtr logic ********////////////////

    integer a;
    integer b;
    
    always @ (posedge clk) begin
         #0.1 if(rst | update_EVA) begin
            for(a=0 ; a<N; a=a+1) begin
                evictionCtr_R[a] <= { (ctrLen) {1'b0} };
                evictionCtr_NR[a] <= { (ctrLen) {1'b0} };
                end
            end
        else if(evict_data) begin
            b = age[evict_addr];
            if(classification_bit[evict_addr]) begin
                if(evictionCtr_R[b] == { (ctrLen) {1'b1} }) begin
                    evictionCtr_R[b] = evictionCtr_R[b];
                    end
                else begin
                    evictionCtr_R[b] = evictionCtr_R[b] + 1;
                    end
                end
            else begin
                if(evictionCtr_NR[b] == { (ctrLen) {1'b1} }) begin
                    evictionCtr_NR[b] = evictionCtr_NR[b];
                    end
                else begin
                    evictionCtr_NR[b] = evictionCtr_NR[b] + 1;
                    end
                end
            end
        end

////////////////  ******************  /////////////////////////////

endmodule
