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
// Create Date: 07.03.2018 02:04:56
// Design Name: 
// Module Name: ctr_update
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


module ctr_update(clk, rst, re, we, hit, miss, evict_data, write_addr, access_addr, evict_addr
                    , update_EVA, hitCtr_R_1D, evictionCtr_R_1D, hitCtr_NR_1D, evictionCtr_NR_1D, age_1D, classificationBit

    );
    
    parameter k = 3;       /////////////age counter width//////////
    parameter j = 2;       /////////////set counter width- will be used for Age Granularity//////////
    parameter A = 2;        //////////////Age Granularity/////////////
    parameter ctrLen = 10;
    parameter accessCtrWidth = 13;

    parameter N = 2**k;   /////number of rows
    parameter M = ctrLen;   /////number of column
    
    input clk;
    input rst;
    input re;
    input we;
    input hit;
    input miss;
    input evict_data;
    input [4:0] write_addr;
    input [4:0] access_addr;
    input [4:0] evict_addr;
    output update_EVA;
    output [ctrLen*N-1 : 0] hitCtr_R_1D;
    output [ctrLen*N-1 : 0] evictionCtr_R_1D;
    output [ctrLen*N-1 : 0] hitCtr_NR_1D;
    output [ctrLen*N-1 : 0] evictionCtr_NR_1D;
    output [32*k - 1 : 0] age_1D;
    output [31:0] classificationBit;

//    wire [31:0] classification_bit;

//    wire [32*k - 1 : 0] age_1D;
//    wire [31:0] classificationBit;

//    reg classification_bit[0:31]; 
//    reg [(k - 1):0] age[0:31];    ////k-bit age for each line/////
//    reg [(j - 1):0] setCtr[0:31];    /////j-bit set counter/////////////
//    reg [(ctrLen - 1):0] hitCtr_R[0:N-1];
//    reg [(ctrLen - 1):0] evictionCtr_R[0:N-1];
//    reg [(ctrLen - 1):0] hitCtr_NR[0:N-1];
//    reg [(ctrLen - 1):0] evictionCtr_NR[0:N-1];
//    reg [(accessCtrWidth-1):0] number_of_access_counter;
    
//    wire [4:0] wr_addr;
//    wire [4:0] read_addr;
    
//    assign wr_addr = write_addr;
//    assign read_addr = access_addr;
    
                    //////////////******** k = 3 ********//////////////
                    //////////////******** j = 2 ********//////////////
            //////////////******** counter length = 10 ********//////////////
        //////////////******** one bit for classification ********//////////////
    //////////////******** updating EVA after every 2048 access ********//////////////
    //////////********  hit = valid_data and (not(read_cam_delayed)) *******/////////////
    ///////*  re = re_delayed and (not(read_cam_delayed)) and (not(read_cam_delayed2)) *///////
    
    
    hit_ctr hitCtr(.clk(clk), .rst(rst), .update_EVA(update_EVA), .hit(hit), .access_addr(access_addr), .classificationBit(classificationBit),
                    .age_1D(age_1D), .hitCtr_R_1D(hitCtr_R_1D), .hitCtr_NR_1D(hitCtr_NR_1D)
        );

    eviction_ctr evictionCtr(.clk(clk), .rst(rst), .update_EVA(update_EVA), .evict_data(evict_data), .evict_addr(evict_addr), .age_1D(age_1D), 
                            .classificationBit(classificationBit),. evictionCtr_R_1D(evictionCtr_R_1D), .evictionCtr_NR_1D(evictionCtr_NR_1D)
        );

    class_bit classBit(.clk(clk), .rst(rst), .we(we), .re(re), .hit(hit), .write_addr(write_addr), .access_addr(access_addr), 
                                .classificationBit(classificationBit)
        );

    age_set_ctr a_s_ctr(.clk(clk), .rst(rst), .we(we), .re(re), .hit(hit), .miss(miss), .access_addr(access_addr), .write_addr(write_addr), 
                        .age_1D(age_1D)
        );

    access_ctr accessCtr(.clk(clk), .rst(rst), .re(re), .update_EVA(update_EVA)
        );    

endmodule
