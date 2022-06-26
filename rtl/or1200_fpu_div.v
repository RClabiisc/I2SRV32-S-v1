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
module divider(dividend,divisor,clk,result,sign,rst,op,start,done);

   input         clk;
   input         sign;
   input [31:0]  dividend, divisor;
   input         rst;
   input         op;
   input         start;
   output reg [31:0] result;
   reg [31:0] quotient, remainder;
   output        done;
    
   reg [31:0]    quotient_temp;
   reg [63:0]    dividend_copy, divisor_copy, diff;
   reg           negative_rem;
   reg           negative_quo;

   reg [5:0]     bit; 
   wire          done = !bit;
   wire [31:0] wir_rem;
    
   
   
   assign  wir_rem =  (!negative_rem) ? 
                         dividend_copy[31:0] : 
                         ~dividend_copy[31:0] + 1'b1;


   always @( posedge clk or posedge rst ) begin 
     if(rst) begin
        quotient <= 32'b0;
        bit <= 6'b0;
        negative_rem <= 1'b0;
        negative_quo <= 1'b0;
        quotient_temp <= 0;
        dividend_copy <= 0;
        divisor_copy    <= 0;
        
     end
     else if(start) begin

        bit <= 6'd32;
        quotient <= 0;
        quotient_temp = 0;
        dividend_copy = (!sign || !dividend[31]) ? 
                        {32'd0,dividend} : 
                        {32'd0,~dividend + 1'b1};
        divisor_copy = (!sign || !divisor[31]) ? 
                       {1'b0,divisor,31'd0} : 
                       {1'b0,~divisor + 1'b1,31'd0};

        negative_rem <= sign & (dividend[31]);

        negative_quo <= sign & (divisor[31] ^ dividend[31]); 
                        
    
     end 
     else if( done ) begin

        bit <= 6'd0;
        quotient <= 0;
        quotient_temp = 0;
        dividend_copy = (!sign || !dividend[31]) ? 
                        {32'd0,dividend} : 
                        {32'd0,~dividend + 1'b1};
        divisor_copy = (!sign || !divisor[31]) ? 
                       {1'b0,divisor,31'd0} : 
                       {1'b0,~divisor + 1'b1,31'd0};

        negative_rem <= sign & (dividend[31]);

        negative_quo <= sign & (divisor[31] ^ dividend[31]); 
                        
    
     end 
     else if ( bit > 0 ) begin

        diff = dividend_copy - divisor_copy;

        quotient_temp = quotient_temp << 1;

        if( !diff[63] ) begin

           dividend_copy = diff;
           quotient_temp[0] = 1'd1;

        end

        quotient <= (!negative_quo) ? 
                   quotient_temp : 
                   ~quotient_temp + 1'b1;

        divisor_copy = divisor_copy >> 1;
        bit <= bit - 1'b1;

     end
end


always @(*) begin
    if(rst) begin
        remainder <= 32'b0;
    end 
// Commented on 06-09-2016    
    else begin
        remainder <= wir_rem;
    end
//Replaced with following code
//    else begin
//    remainder <= wir_rem;
//    end
    //
end

always @(*) begin
    if(rst) begin
        result <= 32'b0;
    end 
    else begin
        result <= op ? quotient : remainder;
    end
end
endmodule