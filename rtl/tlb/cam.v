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
// Create Date: 03.01.2017 12:45:51
// Design Name: 
// Module Name: Registers
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




/////////////////////////////////////


module Registers( clk, rst, we, re,  write_addr, write_data, vpn, miss, valid_data, output_data,access_addr

    );
        //parameters definition:
    // Define the parameters as your requirement
    
    parameter valid = 0;
    parameter R = 1; 
    parameter W = 2; 
    parameter X = 3; 
    parameter U = 4; 
    parameter global = 5; 
    parameter Access = 6; 
    parameter dirty = 7;
    parameter reserved_low = 8;
    parameter reserved_high = 9;
    
    parameter PPN_low = 10;
    parameter PPN_high = 31;
    parameter VPN_low = 32;
    parameter VPN_high = 51;    

    parameter TLB_width = 52; 
    parameter TLB_height = 32; 
    
    input clk;
    input rst;
    input we;
    input re;
    input[4:0] write_addr;
    input[(TLB_width - 1) :0] write_data;
    input[(VPN_high - VPN_low ):0] vpn;
    
    output reg miss;
    output reg valid_data;
    output reg [((PPN_high - PPN_low) + 4 ): 0 ] output_data;
    output reg [4:0] access_addr;
    
    wire [(TLB_height-1):0] data_found;
    wire [4:0] data_addr_int;
    
    reg [((PPN_high - PPN_low) + 1 + 4 ): 0 ] output_data_int;
    reg [(TLB_width - 1):0] mem[0:31];
    

////// ******  Compariosn of Virtual Addrees ******  ////////////
 
assign   data_found[0] = re?(( mem[0][valid] && (mem[0][VPN_high : VPN_low] == vpn))):0;
assign   data_found[1] = re?(( mem[1][valid] && (mem[1][VPN_high : VPN_low] == vpn))):0;
assign   data_found[2] = re?(( mem[2][valid] && (mem[2][VPN_high : VPN_low] == vpn))):0;
assign   data_found[3] = re?(( mem[3][valid] && (mem[3][VPN_high : VPN_low] == vpn))):0;
assign   data_found[4] = re?(( mem[4][valid] && (mem[4][VPN_high : VPN_low] == vpn))):0;
assign   data_found[5] = re?(( mem[5][valid] && (mem[5][VPN_high : VPN_low] == vpn))):0;
assign   data_found[6] = re?(( mem[6][valid] && (mem[6][VPN_high : VPN_low] == vpn))):0;
assign   data_found[7] = re?(( mem[7][valid] && (mem[7][VPN_high : VPN_low] == vpn))):0;
assign   data_found[8] = re?(( mem[8][valid] && (mem[8][VPN_high : VPN_low] == vpn))):0;
assign   data_found[9] = re?(( mem[9][valid] && (mem[9][VPN_high : VPN_low] == vpn))):0;
assign   data_found[10] = re?(( mem[10][valid] && (mem[10][VPN_high : VPN_low] == vpn))):0;
assign   data_found[11] = re?(( mem[11][valid] && (mem[11][VPN_high : VPN_low] == vpn))):0;
assign   data_found[12] = re?(( mem[12][valid] && (mem[12][VPN_high : VPN_low] == vpn))):0;
assign   data_found[13] = re?(( mem[13][valid] && (mem[13][VPN_high : VPN_low] == vpn))):0;
assign   data_found[14] = re?(( mem[14][valid] && (mem[14][VPN_high : VPN_low] == vpn))):0;
assign   data_found[15] = re?(( mem[15][valid] && (mem[15][VPN_high : VPN_low] == vpn))):0;
assign   data_found[16] = re?(( mem[16][valid] && (mem[16][VPN_high : VPN_low] == vpn))):0;
assign   data_found[17] = re?(( mem[17][valid] && (mem[17][VPN_high : VPN_low] == vpn))):0;
assign   data_found[18] = re?(( mem[18][valid] && (mem[18][VPN_high : VPN_low] == vpn))):0;
assign   data_found[19] = re?(( mem[19][valid] && (mem[19][VPN_high : VPN_low] == vpn))):0;
assign   data_found[20] = re?(( mem[20][valid] && (mem[20][VPN_high : VPN_low] == vpn))):0;
assign   data_found[21] = re?(( mem[21][valid] && (mem[21][VPN_high : VPN_low] == vpn))):0;
assign   data_found[22] = re?(( mem[22][valid] && (mem[22][VPN_high : VPN_low] == vpn))):0;
assign   data_found[23] = re?(( mem[23][valid] && (mem[23][VPN_high : VPN_low] == vpn))):0;
assign   data_found[24] = re?(( mem[24][valid] && (mem[24][VPN_high : VPN_low] == vpn))):0;
assign   data_found[25] = re?(( mem[25][valid] && (mem[25][VPN_high : VPN_low] == vpn))):0;
assign   data_found[26] = re?(( mem[26][valid] && (mem[26][VPN_high : VPN_low] == vpn))):0;
assign   data_found[27] = re?(( mem[27][valid] && (mem[27][VPN_high : VPN_low] == vpn))):0;
assign   data_found[28] = re?(( mem[28][valid] && (mem[28][VPN_high : VPN_low] == vpn))):0;
assign   data_found[29] = re?(( mem[29][valid] && (mem[29][VPN_high : VPN_low] == vpn))):0;
assign   data_found[30] = re?(( mem[30][valid] && (mem[30][VPN_high : VPN_low] == vpn))):0;
assign   data_found[31] = re?(( mem[31][valid] && (mem[31][VPN_high : VPN_low] == vpn))):0;

////////////////  ******************  /////////////////////////////

//////  ********   Priority Encoder (to calculate address where virtaul address is found )****** /////////////

assign  data_addr_int  =
    (data_found == 32'b0000_0000_0000_0000_0000_0000_0000_0010) ? 1 : 
    (data_found == 32'b0000_0000_0000_0000_0000_0000_0000_0100) ? 2 : 
    (data_found == 32'b0000_0000_0000_0000_0000_0000_0000_1000) ? 3 : 
    (data_found == 32'b0000_0000_0000_0000_0000_0000_0001_0000) ? 4 : 
    (data_found == 32'b0000_0000_0000_0000_0000_0000_0010_0000) ? 5 : 
    (data_found == 32'b0000_0000_0000_0000_0000_0000_0100_0000) ? 6 : 
    (data_found == 32'b0000_0000_0000_0000_0000_0000_1000_0000) ? 7 : 
    (data_found == 32'b0000_0000_0000_0000_0000_0001_0000_0000) ? 8 : 
    (data_found == 32'b0000_0000_0000_0000_0000_0010_0000_0000) ? 9 : 
    (data_found == 32'b0000_0000_0000_0000_0000_0100_0000_0000) ? 10: 
    (data_found == 32'b0000_0000_0000_0000_0000_1000_0000_0000) ? 11: 
    (data_found == 32'b0000_0000_0000_0000_0001_0000_0000_0000) ? 12: 
    (data_found == 32'b0000_0000_0000_0000_0010_0000_0000_0000) ? 13: 
    (data_found == 32'b0000_0000_0000_0000_0100_0000_0000_0000) ? 14: 
    (data_found == 32'b0000_0000_0000_0000_1000_0000_0000_0000) ? 15: 
    (data_found == 32'b0000_0000_0000_0001_0000_0000_0000_0000) ? 16: 
    (data_found == 32'b0000_0000_0000_0010_0000_0000_0000_0000) ? 17: 
    (data_found == 32'b0000_0000_0000_0100_0000_0000_0000_0000) ? 18: 
    (data_found == 32'b0000_0000_0000_1000_0000_0000_0000_0000) ? 19: 
    (data_found == 32'b0000_0000_0001_0000_0000_0000_0000_0000) ? 20: 
    (data_found == 32'b0000_0000_0010_0000_0000_0000_0000_0000) ? 21: 
    (data_found == 32'b0000_0000_0100_0000_0000_0000_0000_0000) ? 22: 
    (data_found == 32'b0000_0000_1000_0000_0000_0000_0000_0000) ? 23: 
    (data_found == 32'b0000_0001_0000_0000_0000_0000_0000_0000) ? 24: 
    (data_found == 32'b0000_0010_0000_0000_0000_0000_0000_0000) ? 25: 
    (data_found == 32'b0000_0100_0000_0000_0000_0000_0000_0000) ? 26: 
    (data_found == 32'b0000_1000_0000_0000_0000_0000_0000_0000) ? 27: 
    (data_found == 32'b0001_0000_0000_0000_0000_0000_0000_0000) ? 28: 
    (data_found == 32'b0010_0000_0000_0000_0000_0000_0000_0000) ? 29: 
    (data_found == 32'b0100_0000_0000_0000_0000_0000_0000_0000) ? 30: 
    (data_found == 32'b1000_0000_0000_0000_0000_0000_0000_0000) ? 31: 0; 
                          
////////////////  ******************  /////////////////////////////

////////  ********* output data prepapration **********  //////////////
always@(*) begin
        case(data_found)
            32'h00000001: output_data_int = {  mem[0][PPN_high : PPN_low], mem[0][U] , mem[0][X] , mem[0][W] , mem[0][R]} ;
            32'h00000002: output_data_int = {  mem[1][PPN_high : PPN_low], mem[1][U] , mem[1][X] , mem[1][W] , mem[1][R]} ;
            32'h00000004: output_data_int = {  mem[2][PPN_high : PPN_low], mem[2][U] , mem[2][X] , mem[2][W] , mem[2][R]} ;
            32'h00000008: output_data_int = {  mem[3][PPN_high : PPN_low], mem[3][U] , mem[3][X] , mem[3][W] , mem[3][R]} ;
            32'h00000010: output_data_int = {  mem[4][PPN_high : PPN_low], mem[4][U] , mem[4][X] , mem[4][W] , mem[4][R]} ;
            32'h00000020: output_data_int = {  mem[5][PPN_high : PPN_low], mem[5][U] , mem[5][X] , mem[5][W] , mem[5][R]} ;
            32'h00000040: output_data_int = {  mem[6][PPN_high : PPN_low], mem[6][U] , mem[6][X] , mem[6][W] , mem[6][R]} ;
            32'h00000080: output_data_int = {  mem[7][PPN_high : PPN_low], mem[7][U] , mem[7][X] , mem[7][W] , mem[7][R]} ;
            32'h00000100: output_data_int = {  mem[8][PPN_high : PPN_low], mem[8][U] , mem[8][X] , mem[8][W] , mem[8][R]} ;
            32'h00000200: output_data_int = {  mem[9][PPN_high : PPN_low], mem[9][U] , mem[9][X] , mem[9][W] , mem[9][R]} ;
            32'h00000400: output_data_int = { mem[10][PPN_high : PPN_low], mem[10][U], mem[10][X], mem[10][W], mem[10][R]};
            32'h00000800: output_data_int = { mem[11][PPN_high : PPN_low], mem[11][U], mem[11][X], mem[11][W], mem[11][R]};
            32'h00001000: output_data_int = { mem[12][PPN_high : PPN_low], mem[12][U], mem[12][X], mem[12][W], mem[12][R]};
            32'h00002000: output_data_int = { mem[13][PPN_high : PPN_low], mem[13][U], mem[13][X], mem[13][W], mem[13][R]};
            32'h00004000: output_data_int = { mem[14][PPN_high : PPN_low], mem[14][U], mem[14][X], mem[14][W], mem[14][R]};
            32'h00008000: output_data_int = { mem[15][PPN_high : PPN_low], mem[15][U], mem[15][X], mem[15][W], mem[15][R]};
            32'h00010000: output_data_int = { mem[16][PPN_high : PPN_low], mem[16][U], mem[16][X], mem[16][W], mem[16][R]};
            32'h00020000: output_data_int = { mem[17][PPN_high : PPN_low], mem[17][U], mem[17][X], mem[17][W], mem[17][R]};
            32'h00040000: output_data_int = { mem[18][PPN_high : PPN_low], mem[18][U], mem[18][X], mem[18][W], mem[18][R]};
            32'h00080000: output_data_int = { mem[19][PPN_high : PPN_low], mem[19][U], mem[19][X], mem[19][W], mem[19][R]};
            32'h00100000: output_data_int = { mem[20][PPN_high : PPN_low], mem[20][U], mem[20][X], mem[20][W], mem[20][R]};
            32'h00200000: output_data_int = { mem[21][PPN_high : PPN_low], mem[21][U], mem[21][X], mem[21][W], mem[21][R]};
            32'h00400000: output_data_int = { mem[22][PPN_high : PPN_low], mem[22][U], mem[22][X], mem[22][W], mem[22][R]};
            32'h00800000: output_data_int = { mem[23][PPN_high : PPN_low], mem[23][U], mem[23][X], mem[23][W], mem[23][R]};
            32'h01000000: output_data_int = { mem[24][PPN_high : PPN_low], mem[24][U], mem[24][X], mem[24][W], mem[24][R]};
            32'h02000000: output_data_int = { mem[25][PPN_high : PPN_low], mem[25][U], mem[25][X], mem[25][W], mem[25][R]};
            32'h04000000: output_data_int = { mem[26][PPN_high : PPN_low], mem[26][U], mem[26][X], mem[26][W], mem[26][R]};
            32'h08000000: output_data_int = { mem[27][PPN_high : PPN_low], mem[27][U], mem[27][X], mem[27][W], mem[27][R]};
            32'h10000000: output_data_int = { mem[28][PPN_high : PPN_low], mem[28][U], mem[28][X], mem[28][W], mem[28][R]};
            32'h20000000: output_data_int = { mem[29][PPN_high : PPN_low], mem[29][U], mem[29][X], mem[29][W], mem[29][R]};
            32'h40000000: output_data_int = { mem[30][PPN_high : PPN_low], mem[30][U], mem[30][X], mem[30][W], mem[30][R]};
            32'h80000000: output_data_int = { mem[31][PPN_high : PPN_low], mem[31][U], mem[31][X], mem[31][W], mem[31][R]};
            default: output_data_int = 22'b0;
        
            endcase        
end

//////////////// ********************** ////////////////////

/////////  ***** Memory Write ***** ///////////////
                          
always @ (posedge clk) begin
        if(rst) begin
            mem[0] <= 50'b0;
            mem[1] <= 50'b0;           
            mem[2] <= 50'b0;      
            mem[3] <= 50'b0;
            mem[4] <= 50'b0;
            mem[5] <= 50'b0;
            mem[6] <= 50'b0;                  
            mem[7] <= 50'b0;                 
            mem[8] <= 50'b0;
            mem[9] <= 50'b0;
            mem[10] <= 50'b0;
            mem[11] <= 50'b0;
            mem[12] <= 50'b0;
            mem[13] <= 50'b0;
            mem[14] <= 50'b0;
            mem[15] <= 50'b0;
            mem[16] <= 50'b0;
            mem[17] <= 50'b0;
            mem[18] <= 50'b0;                 
            mem[19] <= 50'b0;                 
            mem[20] <= 50'b0;
            mem[21] <= 50'b0;
            mem[22] <= 50'b0;
            mem[23] <= 50'b0;
            mem[24] <= 50'b0;
            mem[25] <= 50'b0;
            mem[26] <= 50'b0;
            mem[27] <= 50'b0;
            mem[28] <= 50'b0;
            mem[29] <= 50'b0;
            mem[30] <= 50'b0;           
            mem[31] <= 50'b0;
 
            end
        else if(we) 
            mem[write_addr] <= write_data;
                    
        end    
////////////////  ******************  /////////////////////////////

////////  ****** Output Assignment *******  ///////////////////
    
always @ (posedge clk) begin
        if(rst) begin
            output_data <= 22'b0;
            miss <= 1'b0;
            access_addr <= 5'b0;
            valid_data <= 1'b0;
        end
        else if (re)
            begin
                if( data_found == 0) 
                begin
                    miss <= 1'b1;
                    valid_data <= 1'b0;  
                    access_addr <= data_addr_int;
                    output_data <= output_data_int;        
                end
                else 
                begin 
                    miss <= 1'b0;
                    valid_data <= 1'b1;
                    access_addr <= data_addr_int;
                    output_data <= output_data_int;        
                end        
            end
        else 
            begin
                miss <= 1'b0;
                valid_data <= 1'b0;
                access_addr <= data_addr_int;
                output_data <= output_data_int;        
            end    
        
    end
    

////**** ILA ****////

    reg [31:0] miss_counter;
    reg [31:0] hit_counter;
    
    reg [15:0] clk_counter;
    
    always @(posedge clk)
    begin
        clk_counter = clk_counter + 1;
        end
    
    always @(posedge clk)
    begin
        if(rst) begin
            miss_counter = 0;
            end
        else if(miss) begin
            miss_counter = miss_counter + 1;
            end        
        end
        
    always @(posedge clk)
    begin
        if(rst) begin
            hit_counter = 0;
            end
        else if(valid_data) begin
            hit_counter = hit_counter + 1;
            end        
        end

//    ila_0 debugger( .clk(clk),
//                    .probe0(miss_counter),
//                    .probe1(hit_counter)
//                    );





endmodule

