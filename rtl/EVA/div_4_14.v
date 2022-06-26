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
// Create Date: 12.03.2018 18:00:29
// Design Name: 
// Module Name: div_4_14
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



module div_4_14 #(
	//Parameterized values
	parameter Q = 14,
	parameter N = 18
	)
	(
	input 	[N-1:0] i_dividend,
	input 	[N-1:0] i_divisor,
	input 	i_start,
	input 	i_clk,
//	output 	reg [N-1:0] o_quotient_out,
	output 	[N-1:0] o_quotient_out,
	output 	o_complete,
	output	o_overflow
	);
 
	reg [2*N+Q-3:0]	reg_working_quotient;	//	Our working copy of the quotient
	reg [N-1:0] 		reg_quotient;				//	Final quotient
	reg [N-2+Q:0] 		reg_working_dividend;	//	Working copy of the dividend
	reg [2*N+Q-3:0]	reg_working_divisor;		// Working copy of the divisor
 
	reg [N-1:0] 			reg_count; 		//	This is obviously a lot bigger than it needs to be, as we only need 
													//		count to N-1+Q but, computing that number of bits requires a 
													//		logarithm (base 2), and I don't know how to do that in a 
													//		way that will work for everyone
										 
	reg					reg_done;			//	Computation completed flag
	reg					reg_sign;			//	The quotient's sign bit
	reg					reg_overflow;		//	Overflow flag

	reg                 done;               // ** defined by me **
 
	initial reg_done = 1'b1;				//	Initial state is to not be doing anything
	initial reg_overflow = 1'b0;			//		And there should be no woverflow present
	initial reg_sign = 1'b0;				//		And the sign should be positive

    initial done = 1'b0;
	initial reg_working_quotient = 0;	
	initial reg_quotient = 0;				
	initial reg_working_dividend = 0;	
	initial reg_working_divisor = 0;		
 	initial reg_count = 0; 		

 
	assign o_quotient_out[N-2:0] = reg_quotient[N-2:0];	//	The division results
	assign o_quotient_out[N-1] = reg_sign;						//	The sign of the quotient

//    always @(*)
//    begin
//        if(!done) begin
//            o_quotient_out[N-2:0] = reg_quotient[N-2:0];
//            o_quotient_out[N-1] = reg_sign;
//            end
//        end


//	assign o_complete = reg_done;                    // ** changed by me ** //
    assign o_complete = done;                        // ** changed by me ** //
	assign o_overflow = reg_overflow;
 
	always @( posedge i_clk ) begin
//	always @( posedge i_clk or negedge i_clk ) begin
		if( reg_done && i_start ) begin										//	This is our startup condition
			//  Need to check for a divide by zero right here, I think....
			reg_done <= 1'b0;												//	We're not done			
			reg_count <= N+Q-1;											//	Set the count
			reg_working_quotient <= 0;									//	Clear out the quotient register
			reg_working_dividend <= 0;									//	Clear out the dividend register 
			reg_working_divisor <= 0;									//	Clear out the divisor register 
			reg_overflow <= 1'b0;										//	Clear the overflow register

			reg_working_dividend[N+Q-2:Q] <= i_dividend[N-2:0];				//	Left-align the dividend in its working register
			reg_working_divisor[2*N+Q-3:N+Q-1] <= i_divisor[N-2:0];		//	Left-align the divisor into its working register

			reg_sign <= i_dividend[N-1] ^ i_divisor[N-1];		//	Set the sign bit
			end 
		else if(!reg_done) begin
			reg_working_divisor <= reg_working_divisor >> 1;	//	Right shift the divisor (that is, divide it by two - aka reduce the divisor)
			reg_count <= reg_count - 1;								//	Decrement the count

			//	If the dividend is greater than the divisor
			if(reg_working_dividend >= reg_working_divisor) begin
				reg_working_quotient[reg_count] <= 1'b1;										//	Set the quotient bit
				reg_working_dividend <= reg_working_dividend - reg_working_divisor;	//		and subtract the divisor from the dividend
				end
 
			//stop condition
			if(reg_count == 0) begin
				reg_done <= 1'b1;										//	If we're done, it's time to tell the calling process
				reg_quotient <= reg_working_quotient;			//	Move in our working copy to the outside world
				if (reg_working_quotient[2*N+Q-3:N]>0)
					reg_overflow <= 1'b1;
					end
			else
				reg_count <= reg_count - 1;	
			end
		end
		
/////////////**** fixing the output ****/////////////

//    always @(*)
//    begin
//        if( reg_done && i_start ) begin	
//            o_quotient_out = o_quotient_out;
//            end
//        else if(!reg_done) begin
//            if(reg_count == 0) begin
//                o_quotient_out[N-2:0] = reg_quotient[N-2:0];
//                o_quotient_out[N-1] = reg_sign;
//                end
//            end
//        end
		
/////////////**** done with three i_clk cycle high ****/////////////
    reg [1:0] count;
    always @(posedge i_clk)
    begin
        if(!reg_done) begin
            if(reg_count == 0) begin
//                o_quotient_out[N-2:0] = reg_quotient[N-2:0];
//                o_quotient_out[N-1] = reg_sign;
                done = 1'b1;
                count = 2'd2;
                end
            end
        else if (count != 0) begin
            done = 1'b1;
            count = count - 1;
            end
        else begin
            done = 1'b0;
            count = 0;
            end
        end

endmodule
