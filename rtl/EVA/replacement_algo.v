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
// Create Date: 23.03.2018 02:52:13
// Design Name: 
// Module Name: replacement_algo
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


module replacement_algo(clk, clk_x2, rst, re, we, hit, miss, access_addr, EVA_en, EVA_addr

    );

    parameter k = 3;
    parameter ctrLen = 10;
    parameter N = 2**k;   /////number of rows
    parameter bitLen = 15;
    
    input clk;
    input clk_x2;
    input rst;
    input re;
    input we;
    input hit;
    input miss;
    input [4:0] access_addr;
    input EVA_en;
    output [4:0] EVA_addr;

    
    wire update_EVA;
    wire [ctrLen*N-1 : 0] hitCtr_R_1D;
    wire [ctrLen*N-1 : 0] evictionCtr_R_1D;
    wire [ctrLen*N-1 : 0] hitCtr_NR_1D;
    wire [ctrLen*N-1 : 0] evictionCtr_NR_1D;
    wire [32*k - 1 : 0] age_1D;
    wire [31:0] classificationBit;
    wire [4*16-1 : 0] sorted_index_1D;
    wire clk_5;


    ctr_update counter(.clk(clk), .rst(rst), .re(re), .we(we), .hit(hit), .miss(miss), .evict_data(we), .write_addr(EVA_addr), 
                        .access_addr(access_addr), .evict_addr(EVA_addr), .update_EVA(update_EVA), .hitCtr_R_1D(hitCtr_R_1D),  
                        .evictionCtr_R_1D(evictionCtr_R_1D), .hitCtr_NR_1D(hitCtr_NR_1D), .evictionCtr_NR_1D(evictionCtr_NR_1D),
                        .age_1D(age_1D), .classificationBit(classificationBit)
                        );

    EVA_update EVA(.clk(clk), .clk_5(clk_x2), .rst(rst), .update_EVA(update_EVA), .hitCtr_R_1D(hitCtr_R_1D), .evictionCtr_R_1D(evictionCtr_R_1D), 
                    .hitCtr_NR_1D(hitCtr_NR_1D), .evictionCtr_NR_1D(evictionCtr_NR_1D)
                  , .sorted_index_1D(sorted_index_1D)
                  );

    addr_cal replaced_addr(.clk(clk), .rst(rst), .age_1D(age_1D), .classificationBit(classificationBit), .EVA_en(EVA_en), .sorted_index_1D(sorted_index_1D),
                           .EVA_addr(EVA_addr)
                            );

endmodule
