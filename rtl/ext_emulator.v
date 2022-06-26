
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
// Create Date: 30.12.2015 09:18:32
// Design Name: 
// Module Name: ext_emulator
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


module ext_emulator(clk,rst,wb_dat_i,wb_cyc_o,wb_adr_o,wb_stb_o,wb_we_o,wb_sel_o,wb_dat_o,wb_cti_o,wb_bte_o,clmode,
wb_ack_i,wb_err_i,wb_rty_i);

input rst;
input clk;
output reg [31:0] wb_dat_i;
input wb_cyc_o;
input [31:0] wb_adr_o;
input wb_stb_o;
input wb_we_o;
input [3:0] wb_sel_o;
input [31:0] wb_dat_o;
input [2:0] wb_cti_o;
input [1:0] wb_bte_o;
output reg [1:0] clmode;
output reg wb_ack_i;
output reg wb_err_i;
output reg wb_rty_i;

reg [2:0] state,nxstate;
reg [3:0] count;
integer k;
integer j;

localparam START = 3'b000;
localparam A = 3'b001;
localparam READ_B = 3'b010;
localparam READ_C = 3'b011;
localparam READ_D = 3'b100;
localparam WRITE_B = 3'b101;
localparam WRITE_C = 3'b110;
localparam WRITE_D = 3'b111;

reg [31:0] addra;
reg [31:0] dina;
reg [3:0] wea;
reg ena;
wire [31:0] douta;

always @(posedge clk) begin
    if(rst) begin
#1        k <= 0;
    end
    else begin
        if(wb_stb_o & wb_cyc_o & (count == 4'b1111)) begin                               //Latch the first address if the burst//Use this for subsequent increments
#1            k <= wb_adr_o[31] ? (~(wb_adr_o) + 32'd1) : wb_adr_o;
        end
    end
end


mainMem Main(
  .clka(clk), // input clka
  .rsta(rst),      // reset
  .ena(~ena), // input ena
  .wea(wea), // input [3 : 0] wea
  .addra(addra), // input [31 : 0] addra
  .dina(dina), // input [31 : 0] dina
  .douta(douta) // output [31 : 0] douta
);




always @(posedge clk ) begin
    if(rst) begin
#1        clmode <= 2'b00;
        wb_rty_i <= 1'b0;
        wb_err_i <= 1'b0;
    end
    else begin
#1        clmode <= 2'b00;
        wb_rty_i <= 1'b0;
        wb_err_i <= 1'b0;
    end
end

reg dat;
always @(posedge clk ) begin
    if(rst) begin
        dat <= 1'b0;
    end
    else if ((wb_adr_o == 32'h21004) )begin
        dat <= 1'b1;
    end
    else
        dat <= 1'b0;
end

always @(posedge clk ) begin
    if(rst) begin
#1        count <= 4'b1111;
    end
    else begin
        if(wb_stb_o & wb_cyc_o) begin
#1            case(wb_bte_o)
                2'b00:  count <= count + 1;
                2'b01:  count <= count + 1;                 //TODO: change the count sequence for different burst-type extensions
                2'b10:  count <= count + 1;
                2'b11:  count <= count + 1;
                default:  count <= count + 1;
            endcase;
        end
        else if (wb_stb_o & wb_cyc_o & (wb_cti_o == 3'b111) & (count == 4'b1111)) begin
#1            count <= 4'b1100;
        end
        else begin
            count <= 4'b1111;
        end
    end
end

always @(*) begin
    case(count)
        4'b0000: begin
            addra <= k;
            dina <= wb_dat_o;
            wea <= {4{wb_we_o}};
            ena <= 1'b0;
        end
        4'b0001: begin
            addra <= k+4;
            dina <= wb_dat_o;
            wea <= {4{wb_we_o}};
            ena <= 1'b0;
        end
        4'b0010: begin
            addra <= k+8;
            dina <= wb_dat_o;
            wea <= {4{wb_we_o}};
            ena <= 1'b0;
        end
        4'b0011: begin
            addra <= k+12;
            dina <= wb_dat_o;
            wea <= {4{wb_we_o}};
            ena <= 1'b0;
        end
        4'b0100: begin
            addra <= k+16;
            dina <= wb_dat_o;
            wea <= {4{wb_we_o}};
            ena <= 1'b0;
        end
        4'b0101: begin
            addra <= k+20;
            dina <= wb_dat_o;
            wea <= {4{wb_we_o}};
            ena <= 1'b0;
        end
        4'b0110: begin
            addra <= k+24;
            dina <= wb_dat_o;
            wea <= {4{wb_we_o}};
            ena <= 1'b0;
        end
        4'b0111: begin
            addra <= k+28;
            dina <= wb_dat_o;
            wea <= {4{wb_we_o}};
            ena <= 1'b0;
        end
       
//////  Classic Cycle Transfer /////
        4'b1100: begin
            addra <= wb_adr_o;
            dina <= wb_dat_o;
            wea <= {4{wb_we_o}};
            ena <= 1'b0;
        end        
        default: begin
            addra <= 0;
            dina <= 0;
            wea <= 0;
            ena <= 1'b1;
        end
    endcase;
end


always @(*) begin
    case(count) 
    // **       This case added to give wb_ack at count oooo only in write operation   -- P  ** // 
        4'b0000 : begin
            wb_ack_i <= wb_we_o;
            wb_dat_i <= 32'b0;
        end 
    // **
        4'b0001 : begin
            wb_ack_i <= 1'b1;
            wb_dat_i <= douta;
        end 
        4'b0010 : begin
            wb_ack_i <= 1'b1;
            wb_dat_i <= douta;
        end    
        4'b0011 : begin
            wb_ack_i <= 1'b1;
            wb_dat_i <= douta;
        end
        4'b0100 : begin
            wb_ack_i <= 1'b1;
            wb_dat_i <= douta;
        end   
        4'b0101 : begin
            wb_ack_i <= 1'b1;
            wb_dat_i <= douta;
        end
        4'b0110 : begin
            wb_ack_i <= 1'b1;
            wb_dat_i <= douta;
        end
        4'b0111 : begin
            wb_ack_i <= 1'b1;                
            wb_dat_i <= douta;
        end
        4'b1000 : begin
            wb_ack_i <= 1'b1;                
            wb_dat_i <= douta;
        end
        4'b1001 : begin
            wb_ack_i <= 1'b0;                                        
            wb_dat_i <= douta;
        end      
        default : begin
            wb_ack_i <= 1'b0;
            wb_dat_i <= 0;
        end                                                                                       
    endcase;
end

endmodule
