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
// Create Date: 14.03.2018 03:14:33
// Design Name: 
// Module Name: seq
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


module seq(clk, rst, start, done, seq_no, state

    );
    
    input clk;
    input rst;
    input start;
    output reg done;
    output reg [3:0] seq_no;
    output reg [2:0] state;
    
    parameter s0 = 3'b000;
    parameter s1 = 3'b001;
    parameter s2 = 3'b010;
    parameter s3 = 3'b011;
    parameter s4 = 3'b100;
    parameter s5 = 3'b101;
    parameter s6 = 3'b110;
    
    reg [2:0] next_state;
    
    
    always @(posedge clk)
    begin
        #0.1 if(rst) begin
            seq_no = 0;
            end
        else if(state == s0) begin
            seq_no = 0;
            end
        else if(state == s5) begin
            seq_no = 4'd0;
            end
        else if(state == s1) begin
            if(seq_no == 12) begin
                seq_no = 4'd9;
                end
            else begin
                seq_no = seq_no + 1;
                end
            end
        else if(state == s2) begin
            if(seq_no == 0) begin
                seq_no = 4'd3;
                end
            else begin
                seq_no = seq_no - 1;
                end
            end
        else if(state == s3) begin
            if(seq_no == 9) begin
                seq_no = 4'd6;
                end
            else begin
                seq_no = seq_no + 1;
                end
            end
        else if(state == s4) begin
            if(seq_no == 3) begin
                seq_no = 4'd6;
                end
            else begin
                seq_no = seq_no - 1;
                end
            end
            
        end
        
    always @(posedge clk)
    begin
        #0.1 if(state == s5) begin
            done = 1'b1;
            end
        else begin
            done = 1'b0;
            end
        end
    
    always @(posedge clk)
    begin
        #0.1 if(rst) begin 
            state <= s0;
            end
        else begin  
            state <= next_state;
            end
        end
    
    
    always @(*)
    begin
        case (state)
            s0:   begin
                if(start) begin
                    if(!done) begin
                        next_state = s1;
                        end
                    end
                else begin
                    next_state = s0;
                    end
                end            
            s1:   begin
                if(seq_no == 12) begin
                    next_state = s2;
                    end
                else begin
                    next_state = s1;
                    end
                end
            s2:    begin   
                if(seq_no == 0) begin
                    next_state = s3;
                    end
                else begin
                    next_state = s2;
                    end
                end
            s3:    begin   
                if(seq_no == 9) begin
                    next_state = s4;
                    end
                else begin
                    next_state = s3;
                    end
                end
            s4:    begin   
                if(seq_no == 3) begin
                    next_state = s5;
                    end
                else begin
                    next_state = s4;
                    end
                end
            s5:    begin
                next_state = s0;
                end
            default:    begin
                next_state = s0;
                end
            endcase
        end

endmodule
