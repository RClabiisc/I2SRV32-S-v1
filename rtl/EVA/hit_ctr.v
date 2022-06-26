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
// Create Date: 07.03.2018 02:05:30
// Design Name: 
// Module Name: hit_ctr
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


module hit_ctr(clk, rst, update_EVA, hit, access_addr, classificationBit, age_1D, hitCtr_R_1D, hitCtr_NR_1D

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
    input hit;
    input [4:0] access_addr;
    inout [32*k - 1 : 0] age_1D;
    input [31:0] classificationBit;
    output reg [ctrLen*N-1 : 0] hitCtr_R_1D;
    output reg [ctrLen*N-1 : 0] hitCtr_NR_1D;
 
    reg [(ctrLen - 1):0] hitCtr_R[0:N-1];
    reg [(ctrLen - 1):0] hitCtr_NR[0:N-1];

    reg [(k - 1):0] age[0:31];    ////k-bit age for each line/////
    reg classification_bit[0:31];

//////////////converting 1-D array to 2-D vector///////////

    integer a;
    always @(*)
    begin
        for (a=0;a<32;a=a+1) begin
            age[a] = age_1D[a*k +: k];
            classification_bit[a] = classificationBit[a*1 +: 1];
            end
        end

//////////////// ****************** /////////////////////////    

/////////////////********** 2D_array to 1D_array conversion **********/////////////////        
       
    integer w;
    always @(*)
    begin
        if(rst) begin
            hitCtr_R_1D = { (ctrLen*N) {1'b0} };
            hitCtr_NR_1D = { (ctrLen*N) {1'b0} };
            end
        else begin
            for (w=0;w<N;w=w+1) begin
                hitCtr_R_1D[w*M +: M] = hitCtr_R[w];
                hitCtr_NR_1D[w*M +: M] = hitCtr_NR[w];
                end
            end
        end

//////////////// ****************** /////////////////////////
    
////////////////********  hitCtr logic ********////////////////
    
    integer i;
    integer l;
    
    always @ (posedge clk) begin
         #0.1 if(rst | update_EVA) begin
            for(i=0; i<N; i=i+1) begin
                hitCtr_R[i] <= { (ctrLen) {1'b0} };
                hitCtr_NR[i] <= { (ctrLen) {1'b0} };
                end
            end
        else if(hit) begin
            l = age[access_addr];
            if(classification_bit[access_addr]) begin
                if(hitCtr_R[l] == { (ctrLen) {1'b1} }) begin
                    hitCtr_R[l] = hitCtr_R[l];
                    end
                else begin
                    hitCtr_R[l] = hitCtr_R[l] + 1;
                    end
                end
            else begin
                if(hitCtr_NR[l] == { (ctrLen) {1'b1} }) begin
                    hitCtr_NR[l] = hitCtr_NR[l];
                    end
                else begin
                    hitCtr_NR[l] = hitCtr_NR[l] + 1;
                    end
                end
            end
        end
    
////////////////////  ******************  /////////////////////////////

endmodule
