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
// Create Date: 23.03.2018 02:24:25
// Design Name: 
// Module Name: addr_cal
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


module addr_cal(clk, rst, age_1D, classificationBit, EVA_en, sorted_index_1D, EVA_addr

    );
    
    parameter k = 3;       /////////////age counter width//////////

    input clk;
    input rst;
    input [32*k-1 : 0] age_1D;
    input [31:0] classificationBit;
    input EVA_en;
    input [4*16-1 : 0] sorted_index_1D;
    output reg [4:0] EVA_addr;


    reg [(k - 1):0] age[0:31];    ////k-bit age for each line/////
    reg classification_bit[0:31];
    reg [3 : 0] sorted_index [15 : 0];

    reg [k:0] age_C[0:31];    //// k+1 -bit classified age for each line/////
    
    reg [5:0] replacement_ctr;

//////////////converting 1-D array to 2-D vector///////////

    integer a;
    always @(*)
    begin
        for (a=0;a<32;a=a+1) begin
            age[a] = age_1D[a*k +: k];
            classification_bit[a] = classificationBit[a*1 +: 1];
            end
        end

    integer b;
    always @(*)
    begin
        for(b=0;b<32;b=b+1) begin
            age_C[b] = {classification_bit[b], age[b]};
            end
        end

    integer c;
    always @(*)
    begin
        for (c=0;c<16;c=c+1) begin
            sorted_index[c] = sorted_index_1D[c*4 +: 4];
            end
        end

//////////////// ****************** /////////////////////////

////////////// replacement ctr logic //////////////

    always @(posedge clk)
    begin
        if(rst) begin
            replacement_ctr = 0;
            end
        else if(EVA_en) begin
            if(replacement_ctr == 33) begin
                replacement_ctr = replacement_ctr;
                end
            else begin
                replacement_ctr = replacement_ctr + 1;
                end
            end
        end

//////////////// ****************** /////////////////////////

////////////// replacement address calculation //////////////

    always @(posedge clk)
    begin
        if(rst) begin
            EVA_addr = 0;
            end
        else if(EVA_en) begin
            if(replacement_ctr != 33) begin
                EVA_addr = replacement_ctr-1;
                end
            else begin
                if(age_C[0] == sorted_index[0]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[0]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[0]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[0]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[0]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[0]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[0]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[0]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[0]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[0]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[0]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[0]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[0]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[0]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[0]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[0]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[0]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[0]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[0]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[0]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[0]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[0]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[0]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[0]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[0]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[0]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[0]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[0]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[0]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[0]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[0]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[0]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[1]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[1]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[1]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[1]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[1]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[1]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[1]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[1]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[1]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[1]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[1]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[1]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[1]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[1]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[1]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[1]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[1]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[1]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[1]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[1]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[1]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[1]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[1]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[1]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[1]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[1]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[1]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[1]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[1]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[1]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[1]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[1]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[2]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[2]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[2]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[2]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[2]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[2]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[2]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[2]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[2]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[2]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[2]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[2]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[2]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[2]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[2]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[2]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[2]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[2]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[2]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[2]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[2]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[2]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[2]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[2]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[2]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[2]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[2]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[2]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[2]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[2]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[2]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[2]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[3]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[3]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[3]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[3]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[3]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[3]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[3]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[3]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[3]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[3]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[3]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[3]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[3]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[3]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[3]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[3]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[3]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[3]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[3]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[3]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[3]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[3]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[3]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[3]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[3]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[3]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[3]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[3]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[3]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[3]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[3]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[3]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[4]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[4]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[4]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[4]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[4]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[4]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[4]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[4]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[4]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[4]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[4]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[4]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[4]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[4]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[4]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[4]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[4]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[4]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[4]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[4]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[4]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[4]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[4]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[4]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[4]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[4]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[4]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[4]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[4]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[4]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[4]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[4]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[5]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[5]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[5]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[5]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[5]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[5]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[5]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[5]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[5]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[5]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[5]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[5]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[5]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[5]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[5]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[5]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[5]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[5]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[5]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[5]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[5]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[5]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[5]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[5]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[5]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[5]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[5]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[5]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[5]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[5]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[5]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[5]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[6]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[6]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[6]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[6]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[6]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[6]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[6]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[6]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[6]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[6]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[6]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[6]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[6]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[6]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[6]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[6]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[6]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[6]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[6]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[6]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[6]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[6]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[6]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[6]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[6]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[6]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[6]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[6]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[6]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[6]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[6]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[6]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[7]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[7]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[7]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[7]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[7]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[7]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[7]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[7]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[7]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[7]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[7]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[7]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[7]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[7]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[7]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[7]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[7]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[7]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[7]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[7]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[7]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[7]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[7]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[7]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[7]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[7]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[7]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[7]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[7]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[7]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[7]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[7]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[8]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[8]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[8]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[8]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[8]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[8]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[8]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[8]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[8]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[8]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[8]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[8]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[8]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[8]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[8]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[8]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[8]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[8]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[8]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[8]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[8]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[8]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[8]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[8]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[8]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[8]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[8]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[8]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[8]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[8]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[8]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[8]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[9]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[9]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[9]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[9]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[9]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[9]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[9]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[9]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[9]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[9]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[9]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[9]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[9]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[9]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[9]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[9]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[9]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[9]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[9]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[9]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[9]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[9]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[9]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[9]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[9]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[9]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[9]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[9]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[9]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[9]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[9]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[9]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[10]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[10]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[10]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[10]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[10]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[10]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[10]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[10]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[10]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[10]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[10]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[10]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[10]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[10]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[10]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[10]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[10]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[10]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[10]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[10]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[10]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[10]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[10]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[10]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[10]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[10]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[10]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[10]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[10]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[10]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[10]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[10]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[11]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[11]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[11]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[11]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[11]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[11]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[11]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[11]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[11]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[11]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[11]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[11]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[11]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[11]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[11]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[11]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[11]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[11]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[11]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[11]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[11]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[11]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[11]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[11]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[11]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[11]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[11]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[11]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[11]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[11]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[11]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[11]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[12]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[12]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[12]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[12]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[12]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[12]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[12]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[12]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[12]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[12]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[12]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[12]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[12]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[12]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[12]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[12]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[12]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[12]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[12]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[12]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[12]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[12]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[12]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[12]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[12]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[12]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[12]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[12]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[12]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[12]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[12]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[12]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[13]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[13]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[13]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[13]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[13]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[13]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[13]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[13]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[13]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[13]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[13]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[13]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[13]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[13]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[13]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[13]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[13]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[13]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[13]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[13]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[13]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[13]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[13]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[13]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[13]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[13]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[13]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[13]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[13]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[13]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[13]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[13]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[14]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[14]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[14]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[14]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[14]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[14]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[14]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[14]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[14]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[14]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[14]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[14]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[14]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[14]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[14]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[14]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[14]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[14]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[14]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[14]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[14]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[14]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[14]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[14]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[14]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[14]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[14]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[14]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[14]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[14]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[14]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[14]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[15]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[15]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[15]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[15]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[15]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[15]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[15]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[15]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[15]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[15]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[15]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[15]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[15]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[15]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[15]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[15]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[15]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[15]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[15]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[15]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[15]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[15]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[15]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[15]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[15]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[15]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[15]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[15]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[15]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[15]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[15]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[15]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[16]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[16]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[16]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[16]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[16]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[16]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[16]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[16]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[16]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[16]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[16]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[16]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[16]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[16]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[16]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[16]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[16]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[16]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[16]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[16]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[16]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[16]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[16]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[16]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[16]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[16]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[16]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[16]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[16]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[16]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[16]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[16]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[17]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[17]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[17]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[17]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[17]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[17]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[17]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[17]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[17]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[17]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[17]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[17]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[17]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[17]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[17]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[17]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[17]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[17]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[17]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[17]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[17]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[17]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[17]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[17]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[17]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[17]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[17]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[17]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[17]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[17]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[17]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[17]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[18]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[18]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[18]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[18]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[18]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[18]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[18]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[18]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[18]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[18]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[18]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[18]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[18]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[18]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[18]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[18]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[18]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[18]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[18]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[18]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[18]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[18]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[18]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[18]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[18]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[18]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[18]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[18]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[18]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[18]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[18]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[18]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[19]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[19]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[19]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[19]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[19]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[19]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[19]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[19]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[19]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[19]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[19]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[19]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[19]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[19]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[19]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[19]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[19]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[19]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[19]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[19]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[19]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[19]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[19]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[19]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[19]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[19]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[19]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[19]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[19]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[19]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[19]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[19]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[20]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[20]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[20]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[20]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[20]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[20]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[20]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[20]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[20]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[20]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[20]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[20]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[20]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[20]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[20]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[20]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[20]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[20]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[20]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[20]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[20]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[20]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[20]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[20]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[20]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[20]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[20]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[20]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[20]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[20]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[20]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[20]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[21]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[21]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[21]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[21]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[21]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[21]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[21]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[21]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[21]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[21]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[21]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[21]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[21]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[21]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[21]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[21]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[21]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[21]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[21]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[21]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[21]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[21]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[21]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[21]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[21]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[21]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[21]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[21]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[21]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[21]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[21]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[21]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[22]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[22]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[22]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[22]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[22]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[22]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[22]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[22]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[22]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[22]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[22]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[22]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[22]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[22]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[22]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[22]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[22]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[22]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[22]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[22]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[22]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[22]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[22]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[22]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[22]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[22]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[22]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[22]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[22]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[22]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[22]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[22]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[23]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[23]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[23]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[23]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[23]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[23]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[23]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[23]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[23]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[23]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[23]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[23]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[23]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[23]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[23]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[23]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[23]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[23]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[23]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[23]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[23]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[23]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[23]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[23]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[23]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[23]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[23]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[23]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[23]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[23]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[23]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[23]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[24]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[24]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[24]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[24]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[24]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[24]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[24]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[24]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[24]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[24]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[24]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[24]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[24]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[24]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[24]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[24]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[24]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[24]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[24]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[24]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[24]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[24]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[24]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[24]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[24]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[24]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[24]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[24]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[24]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[24]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[24]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[24]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[25]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[25]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[25]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[25]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[25]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[25]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[25]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[25]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[25]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[25]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[25]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[25]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[25]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[25]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[25]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[25]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[25]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[25]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[25]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[25]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[25]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[25]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[25]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[25]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[25]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[25]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[25]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[25]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[25]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[25]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[25]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[25]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[26]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[26]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[26]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[26]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[26]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[26]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[26]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[26]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[26]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[26]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[26]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[26]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[26]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[26]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[26]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[26]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[26]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[26]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[26]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[26]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[26]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[26]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[26]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[26]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[26]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[26]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[26]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[26]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[26]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[26]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[26]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[26]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[27]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[27]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[27]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[27]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[27]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[27]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[27]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[27]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[27]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[27]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[27]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[27]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[27]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[27]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[27]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[27]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[27]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[27]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[27]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[27]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[27]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[27]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[27]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[27]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[27]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[27]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[27]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[27]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[27]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[27]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[27]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[27]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[28]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[28]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[28]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[28]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[28]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[28]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[28]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[28]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[28]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[28]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[28]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[28]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[28]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[28]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[28]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[28]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[28]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[28]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[28]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[28]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[28]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[28]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[28]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[28]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[28]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[28]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[28]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[28]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[28]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[28]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[28]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[28]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[29]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[29]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[29]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[29]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[29]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[29]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[29]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[29]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[29]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[29]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[29]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[29]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[29]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[29]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[29]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[29]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[29]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[29]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[29]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[29]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[29]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[29]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[29]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[29]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[29]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[29]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[29]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[29]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[29]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[29]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[29]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[29]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[30]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[30]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[30]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[30]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[30]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[30]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[30]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[30]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[30]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[30]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[30]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[30]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[30]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[30]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[30]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[30]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[30]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[30]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[30]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[30]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[30]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[30]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[30]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[30]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[30]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[30]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[30]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[30]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[30]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[30]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[30]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[30]) begin
                    EVA_addr = 31;
                    end
                else if(age_C[0] == sorted_index[31]) begin
                    EVA_addr = 0;
                    end
                else if(age_C[1] == sorted_index[31]) begin
                    EVA_addr = 1;
                    end
                else if(age_C[2] == sorted_index[31]) begin
                    EVA_addr = 2;
                    end
                else if(age_C[3] == sorted_index[31]) begin
                    EVA_addr = 3;
                    end
                else if(age_C[4] == sorted_index[31]) begin
                    EVA_addr = 4;
                    end
                else if(age_C[5] == sorted_index[31]) begin
                    EVA_addr = 5;
                    end
                else if(age_C[6] == sorted_index[31]) begin
                    EVA_addr = 6;
                    end
                else if(age_C[7] == sorted_index[31]) begin
                    EVA_addr = 7;
                    end
                else if(age_C[8] == sorted_index[31]) begin
                    EVA_addr = 8;
                    end
                else if(age_C[9] == sorted_index[31]) begin
                    EVA_addr = 9;
                    end
                else if(age_C[10] == sorted_index[31]) begin
                    EVA_addr = 10;
                    end
                else if(age_C[11] == sorted_index[31]) begin
                    EVA_addr = 11;
                    end
                else if(age_C[12] == sorted_index[31]) begin
                    EVA_addr = 12;
                    end
                else if(age_C[13] == sorted_index[31]) begin
                    EVA_addr = 13;
                    end
                else if(age_C[14] == sorted_index[31]) begin
                    EVA_addr = 14;
                    end
                else if(age_C[15] == sorted_index[31]) begin
                    EVA_addr = 15;
                    end
                else if(age_C[16] == sorted_index[31]) begin
                    EVA_addr = 16;
                    end
                else if(age_C[17] == sorted_index[31]) begin
                    EVA_addr = 17;
                    end
                else if(age_C[18] == sorted_index[31]) begin
                    EVA_addr = 18;
                    end
                else if(age_C[19] == sorted_index[31]) begin
                    EVA_addr = 19;
                    end
                else if(age_C[20] == sorted_index[31]) begin
                    EVA_addr = 20;
                    end
                else if(age_C[21] == sorted_index[31]) begin
                    EVA_addr = 21;
                    end
                else if(age_C[22] == sorted_index[31]) begin
                    EVA_addr = 22;
                    end
                else if(age_C[23] == sorted_index[31]) begin
                    EVA_addr = 23;
                    end
                else if(age_C[24] == sorted_index[31]) begin
                    EVA_addr = 24;
                    end
                else if(age_C[25] == sorted_index[31]) begin
                    EVA_addr = 25;
                    end
                else if(age_C[26] == sorted_index[31]) begin
                    EVA_addr = 26;
                    end
                else if(age_C[27] == sorted_index[31]) begin
                    EVA_addr = 27;
                    end
                else if(age_C[28] == sorted_index[31]) begin
                    EVA_addr = 28;
                    end
                else if(age_C[29] == sorted_index[31]) begin
                    EVA_addr = 29;
                    end
                else if(age_C[30] == sorted_index[31]) begin
                    EVA_addr = 30;
                    end
                else if(age_C[31] == sorted_index[31]) begin
                    EVA_addr = 31;
                    end
                else begin
                    EVA_addr = EVA_addr;
                    end
                end
            end
        end

//////////////// ****************** /////////////////////////

endmodule
