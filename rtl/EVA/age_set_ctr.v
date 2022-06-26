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
// Create Date: 07.03.2018 02:07:15
// Design Name: 
// Module Name: age_set_ctr
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


module age_set_ctr(clk, rst, re, we, hit, miss, access_addr, write_addr, age_1D

    );

    parameter k = 3;       /////////////age counter width//////////
    parameter j = 2;       /////////////set counter width- will be used for Age Granularity//////////
    parameter A = 2;        //////////////Age Granularity/////////////
    parameter accessCtrWidth = 13;
    parameter N = 2**k;   /////number of rows


    input clk;
    input rst;
    input re;
    input we;
    input hit;
    input miss;
    input [4:0] write_addr;
    input [4:0] access_addr;
    output reg [32*k - 1 : 0] age_1D;
    
    reg [(k - 1):0] age[0:31];    ////k-bit age for each line/////
    reg [(j - 1):0] setCtr[0:31];    /////j-bit set counter/////////////

/////////////////********** 2D_array to 1D_array conversion **********/////////////////        
       
    integer w;
    always @(*)
    begin
        if(rst) begin
            age_1D = 0;
            end
        else begin
            for (w=0;w<32;w=w+1) begin
                    age_1D[w*k +: k] = age[w];
                    end
                end
            end

//////////////// ****************** /////////////////////////

/////////////////********** age and setCtr logic **********/////////////////

    integer x;
    integer y;
    integer z;

    always @(posedge clk) begin    
        #0.1 if(rst) begin
            for(x=0; x<32; x=x+1) begin
                age[x] <= { (k) {1'b0} };
                setCtr[x] <= { (j) {1'b0} };
                end
            end
        else if(we) begin
            age[write_addr] = { (k) {1'b0} };
            setCtr[write_addr] <= { (j) {1'b0} };
            end
        else if(re) begin
            if(hit) begin
                for(y=0; y<32; y=y+1) begin
                    if(access_addr == y) begin
                        setCtr[y] = { (j) {1'b0} };
                        age[y] = { (k) {1'b0} };
                        for(z=0; z<32; z=z+1) begin
                            if(z!=y) begin
                                if(setCtr[z] == A) begin
                                    setCtr[z] = { (j) {1'b0} };
                                    if(age[z] == N-1) begin
                                        age[z] <= age[z];
                                        end
                                    else begin
                                        age[z] = age[z] + 1;
                                        end
                                    end
                                else begin
                                    setCtr[z] = setCtr[z] + 1;
                                    end
                                end
                            end
                        end
                    end
                end
            else begin
                for(y=0; y<32; y=y+1) begin
                    if(setCtr[y] == A) begin
                        setCtr[y] = { (j) {1'b0} };
                        if(age[y] == N-1) begin
                            age[y] <= age[y];
                            end
                        else begin
                            age[y] = age[y] + 1;
                            end
                        end
                    else begin
                        setCtr[y] = setCtr[y] + 1;
                        end
                    end
                end
            end
        end
        
//////////////////  ******************  /////////////////////////////

endmodule
