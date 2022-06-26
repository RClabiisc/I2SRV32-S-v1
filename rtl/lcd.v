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
// Create Date: 14.05.2017 16:29:39
// Design Name: 
// Module Name: lcd
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.05.2017 14:30:03
// Design Name: 
// Module Name: lcd
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
 module LCD(clk,rst, en, rs, rw,data,data_in);

input clk; // pin C9 is the 50-MHz on-board clock
input rst;
input [63:0] data_in; 
output en; // enable (1)
output rs; // Register Select (1 data bits for R/W)
output rw; // Read/Write 1/0
output [3:0] data;

reg [24:0] count; // 27-bit count, 0-(128M-1), over 2 secs
reg [5:0] code; // 6-bits different signals to give out
reg state;

reg [3:0] word_1_0;
reg [3:0] word_1_1;
reg [3:0] word_1_2;
reg [3:0] word_1_3;
reg [3:0] word_1_4;
reg [3:0] word_1_5;
reg [3:0] word_1_6;
reg [3:0] word_1_7;

reg [3:0] word_2_0;
reg [3:0] word_2_1;
reg [3:0] word_2_2;
reg [3:0] word_2_3;
reg [3:0] word_2_4;
reg [3:0] word_2_5;
reg [3:0] word_2_6;
reg [3:0] word_2_7;

assign en = state ? count[11] : count[18]; // flip rate about 25 (50MHz/2*21=2M)
assign rs = code[5]; 
assign rw = code[4];
assign data = code[3:0];

always @ (posedge clk) begin
    if(rst)
        count <= 25'b0;
    else
        count <= count + 1;
end

always @ (posedge clk) begin
    if(rst)
        state <= 1'b0;
    else if (count[24:19] == 7'd50)
        state <= 1'b1;
end

always @ (posedge clk) begin
    if(rst) begin
        word_1_0 <= 4'b0;
        word_1_1 <= 4'b0;
        word_1_2 <= 4'b0;
        word_1_3 <= 4'b0;
        word_1_4 <= 4'b0;
        word_1_5 <= 4'b0;
        word_1_6 <= 4'b0;
        word_1_7 <= 4'b0;
        
        word_2_0 <= 4'b0;
        word_2_1 <= 4'b0;
        word_2_2 <= 4'b0;
        word_2_3 <= 4'b0;
        word_2_4 <= 4'b0;
        word_2_5 <= 4'b0;
        word_2_6 <= 4'b0;
        word_2_7 <= 4'b0;
    end
    else if(~count[18]) begin
        word_1_0 <= data_in[3:0];
        word_1_1 <= data_in[7:4];
        word_1_2 <= data_in[11:8];
        word_1_3 <= data_in[15:12]; 
        word_1_4 <= data_in[19:16]; 
        word_1_5 <= data_in[23:20];
        word_1_6 <= data_in[27:24];
        word_1_7 <= data_in[31:28];
                   
        word_2_0 <= data_in[35:32];
        word_2_1 <= data_in[39:36];
        word_2_2 <= data_in[43:40];
        word_2_3 <= data_in[47:44];
        word_2_4 <= data_in[51:48];
        word_2_5 <= data_in[55:52];
        word_2_6 <= data_in[59:56];
        word_2_7 <= data_in[63:60];
    end
end

always @ (posedge clk) begin
    if(rst) begin
        code <= 6'b0;
    end
    else if(state == 1'b0) begin
        case (count [24:19]) // as top 6 bits change
            // power-on init can be carried out befor this loop to avoid the flickers
            0: code <= 6'h03; // power-on init sequence
            1: code <= 6'h00; 
            
            2: code <= 6'h03; // this is needed at least once
            3: code <= 6'h00; 
            
            4: code <= 6'h03; // when LCD's powered on
            5: code <= 6'h00; 
            
            6: code <= 6'h00; // it flickers existing char dislay
            7: code <= 6'h02;

            // Send 00 and upper nibble 0010, then 00 and lower nibble 10xx
            10: code <= 6'h02; // Function Set, upper nibble 0010
            11: code <= 6'h08; // lower nibble 1000 (10xx)
            // Table 5-3, Entry Mode
            
	        12: code <= 6'h00; // it flickers existing char dislay
            13: code <= 6'h0C;

            // Table 5-3 Clear Display, 00 and upper nibble 0000, 00 and lower nibble 0001
	        14: code <= 6'h00;// Clear Display, 00 and upper nibble 0000
            15: code <= 6'h01;// then 00 and lower nibble 0001
            // Chararters are then given out, the cursor will advance to the right

            // send 00 and upper nibble: I/D bit (Incr 1, Decr 0), S bit (Shift 1, 0 no)
            16: code <= 6'h00; // see table, upper nibble 0000, then lower nibble:
            17: code <= 6'h06; // 0110: Incr, Shift disabled
            // Table 5-3, Display On/Off
            // send 00 and upper nibble 0000, then 00 and lower nibble 1 DCB
            // D: 1, show char represented by code in DDR, 0 don't, but code remains
            // C: 1, show cursor, 0 don't
            // B: 1, cursor blinks (if shown), 0 don't blink (if shown)

            // Table 5-3, Write Data to DD RAM (or CG RAM)
            // Fig 5-4, 'H' send 10 and upper nibble 0100, then 10 and lower nibble
            //18: code <= 6'h22; // 'space' high nibble
            //19: code <= 6'h20; //  low nibble
            //20: code <= 6'h22; // 'space' high nibble
            //21: code <= 6'h20; //  low nibble
            //22: code <= 6'h25; // 'T' high nibble
            //23: code <= 6'h24; //  low nibble
            //24: code <= 6'h24; // 'E' high nibble
            //25: code <= 6'h25; //  low nibble
            //26: code <= 6'h24; // 'M' high nibble
            //27: code <= 6'h2D; //  low nibble
            //28: code <= 6'h25; // 'P' high nibble
            //29: code <= 6'h20; //  low nibble
            //30: code <= 6'h24; // 'E' high nibble
            //31: code <= 6'h25; //  low nibble
            //32: code <= 6'h25; // 'R' high nibble
            //33: code <= 6'h22; //  low nibble
            //34: code <= 6'h24; // 'A' high nibble
            //35: code <= 6'h21; //  low nibble
            //36: code <= 6'h25; // 'T' high nibble
            //37: code <= 6'h24; //  low nibble
            //38: code <= 6'h25; // 'U' high nibble
            //39: code <= 6'h25; //  low nibble
            //40: code <= 6'h25; // 'R' high nibble
            //41: code <= 6'h22; //  low nibble
            //42: code <= 6'h24; // 'E' high nibble
            //43: code <= 6'h25; //  low nibble    
            //44: code <= 6'h23; // ':' high nibble
            //45: code <= 6'h2A; //  low nibble
            //
            //46: code <= 6'h0C; // pos cursor to 2nd line upper nibble
            //47: code <= 6'h08;  // lower nibble: h0
            // Characters are then given out, the cursor will advance to the right
            //48: code <= 6'h22; // 'space' high nibble
            //49: code <= 6'h20; //  low nibble
            //50: code <= 6'h22; // 'space' high nibble
            //51: code <= 6'h20; //  low nibble
            //52: code <= 6'h22; // 'space' high nibble
            //53: code <= 6'h20; //  low nibble
            //54: code <= 6'h22; // 'space' high nibble
            //55: code <= 6'h20; //  low nibble
            //56: code <= 6'h22; // 'space' high nibble
            //57: code <= 6'h20; //  low nibble
            //58: code <= 6'h22; // 'space' high nibble
            //59: code <= 6'h20; //  low nibble
            //60: code <= 6'h22; // 'space' high nibble
            //61: code <= 6'h20; //  low nibble
            //62: code <= 6'h22; // 'space' high nibble
            //63: code <= 6'h20; //  low nibble
            //48: code <= 6'h24; // 'C' high nibble
            //49: code <= 6'h23; //  low nibble
            default: code <= 6'h10; // the restun-used time
        endcase
    end
    else if (state == 1'b1 && count[18] == 1'b1 ) begin
        case (count [17:12])
        
            0 : code <= 6'h08;
            1 : code <= 6'h00;
                    
            2  : code <= 6'h23;
            3  : code <= {2'b10,word_2_7};
            4  : code <= 6'h23;
            5  : code <= {2'b10,word_2_6};
            6  : code <= 6'h22; 
            7  : code <= 6'h20;            
            8  : code <= 6'h23;             
            9  : code <= {2'b10,word_2_5};  
            10  : code <= 6'h23;             
            11  : code <= {2'b10,word_2_4};  
            12 : code <= 6'h22;             
            13 : code <= 6'h20;             
            14 : code <= 6'h23;             
            15 : code <= {2'b10,word_2_3};  
            16 : code <= 6'h23;             
            17 : code <= {2'b10,word_2_2};  
            18 : code <= 6'h22;             
            19 : code <= 6'h20;             
            20 : code <= 6'h23;             
            21 : code <= {2'b10,word_2_1};  
            22 : code <= 6'h23;             
            23 : code <= {2'b10,word_2_0};  
            24 : code <= 6'h22;             
            25 : code <= 6'h20;      
            
            26 : code <= 6'h0C;
            27 : code <= 6'h00;
            
            28 : code <= 6'h23;           
            29 : code <= {2'b10,word_1_7};
            30 : code <= 6'h23;           
            31 : code <= {2'b10,word_1_6};
            32 : code <= 6'h22;           
            33 : code <= 6'h20;           
            34 : code <= 6'h23;           
            35 : code <= {2'b10,word_1_5};
            36 : code <= 6'h23;           
            37 : code <= {2'b10,word_1_4};
            38 : code <= 6'h22;           
            39 : code <= 6'h20;           
            40 : code <= 6'h23;           
            41 : code <= {2'b10,word_1_3};
            42 : code <= 6'h23;           
            43 : code <= {2'b10,word_1_2};
            44 : code <= 6'h22;           
            45 : code <= 6'h20;           
            46 : code <= 6'h23;           
            47 : code <= {2'b10,word_1_1};
            48 : code <= 6'h23;           
            49 : code <= {2'b10,word_1_0};
            50 : code <= 6'h22;           
            51 : code <= 6'h20;           
                   
            default:  code <= 6'h10; // the restun-used time

        endcase
    end      
    
// (it flips when counted upto 2M, and flips again after another 2M)
end 

endmodule
