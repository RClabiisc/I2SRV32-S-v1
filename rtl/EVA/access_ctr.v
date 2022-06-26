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
// Create Date: 07.03.2018 02:07:52
// Design Name: 
// Module Name: access_ctr
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


module access_ctr(clk, rst, re, update_EVA

    );

    parameter accessCtrWidth = 13;

    input clk;
    input rst;
    input re;
    output reg update_EVA;

    reg [(accessCtrWidth-1):0] number_of_access_counter;

////// ******  access counter logic & genrating update_EVA signal ******  ////////////
    
    always @ (posedge clk) begin
        #0.1 if(rst) begin
            number_of_access_counter <= { (accessCtrWidth) {1'b0} };                        //////change with ctrLen//////
            update_EVA <= 1'b0;
            end
        else if(re) begin
            if(number_of_access_counter[accessCtrWidth-1] == 1'b1) begin           //////change with ctrLen//////
                number_of_access_counter <= 12'b0;                   //////change with ctrLen//////
                update_EVA <= 1'b1;   //////////////////generating after every 2048 access///////////
                end
            else begin
                number_of_access_counter <= number_of_access_counter + 1;
                update_EVA <= 1'b0;
                end
            end    
        end
    
//////////////////////////// ************************* ////////////////////////////

endmodule
