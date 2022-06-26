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

`include "defines.v"

module Sys_counter
(
    input rst,
    input proc_clk,
    
    input freeze,      //include when 1Hz timer implemented
    
    input [3:0] count_sel,
    output reg [31:0] count,
    
    input [31:0] csr_wrdata,
    input [3:0] wr_sel,
    input csr_wr_en,
    
    output tick_en
);

wire [63:0] proc_count_int;
wire [63:0] instr_count_int;  //include when 1Hz timer implemented    
wire [63:0] real_count_int;
wire [63:0] timecmp_int;
wire [16:0] count_tick_int;
wire rd_instret;
wire rd_time;
wire rd_cycle;
wire real_tick_en;
wire [15:0] Num_tick_reg;         //maximum for 43sec

//assign real_count = {Num_tick_reg[14:0],count_tick_int};

assign rd_instret = ~count_sel[3] && count_sel[2] && (~count_sel[1]);
assign rd_time = count_sel[3] && ~count_sel[2];
assign rd_cycle = ~count_sel[3] && ~count_sel[2] && (~count_sel[1]);
assign rd_counter_tick = count_sel[3] && count_sel[2] && (~count_sel[1]);


always @(posedge proc_clk) begin
    if(rst) begin
        count <= 32'b0;
    end
    else if (~freeze) begin
        case(count_sel)
            4'b0000: count <= proc_count_int[31:0]; 
            4'b0100: count <= instr_count_int[31:0];  //include when 1Hz timer implemented
            4'b1000: count <= real_count_int[31:0];
            4'b0001: count <= proc_count_int[63:32];
            4'b0101: count <= instr_count_int[63:32];  //include when 1Hz timer implemented
            4'b1001: count <= real_count_int[63:32];
            4'b1010: count <= timecmp_int[31:0];
            4'b1011: count <= timecmp_int[63:32];
            4'b1100: count <= {15'b0,count_tick_int};
            4'b1101: count <= {16'b0,Num_tick_reg};           //Number of tick Register
            default:     count <= 0;    
        endcase
    end
end

counter_tick ct( .out(count_tick_int),                                                  // Output of the counter
                 .clk(proc_clk),                                                        // clock Input
                 .wr_en(wr_sel[3] && (wr_sel[2]) && (~wr_sel[1]) && csr_wr_en),
                 .wr_en_timer(~wr_sel[0]),
                 .tick_en(tick_en),
                 .wr_data(csr_wrdata),
                 .rd_time(rd_counter_tick),
                 .Num_tick_reg(Num_tick_reg),
                 .reset(rst));                                                           // reset Input

counter_proc_clk cp1( .out(proc_count_int),                                                 // Output of the counter
                      .clk(proc_clk),                                                       // clock Input
                      .wr_en(~wr_sel[3] && ~wr_sel[2] && (~wr_sel[1]) && csr_wr_en)  ,
                      .wr_en_h(wr_sel[0]),
                      .rd_cycle(rd_cycle),
                      .wr_data(csr_wrdata),
                      .reset(rst));
                      
                      

//include when 1Hz timer implemented
counter_real_clk cr1   (
.out(real_count_int)     ,  // Output of the counter
//`ifdef EXT_WALL_CLOCK
//.clk(real_clk)     ,  // clock Input
//`else
.clk(proc_clk)     ,  // clock Input
//`endif
.wr_en(wr_sel[3] && (~wr_sel[2]) && csr_wr_en) ,.real_tick_en(real_tick_en),
.wr_en_h(wr_sel[0]) ,.wr_tcmp_en(wr_sel[1]),.timecmp(timecmp_int),
.wr_data(csr_wrdata),.rd_time(rd_time),
.reset(rst)      // reset Input
);

//Pipeline flushing case to be included//
counter_instr_clk ci1   (
.out(instr_count_int)     ,  // Output of the counter
.clk(proc_clk)     ,  // clock Input
.wr_en(~wr_sel[3] && wr_sel[2] && (~wr_sel[1]) && csr_wr_en)  ,
.wr_en_h(wr_sel[0])  ,.rd_instret(rd_instret),
.wr_data(csr_wrdata),
.freeze(freeze),    //if freeze is activated, the counter is stopped
.reset(rst)      // reset Input
);



endmodule


module counter_tick(
out     ,  // Output of the counter
clk     ,  // clock Input
wr_en  ,
wr_en_timer, tick_en, rd_time,
wr_data,Num_tick_reg,
reset      // reset Input
);
//----------Output Ports--------------
    output reg [16:0] out;
//------------Input Ports--------------
     input  clk, reset,wr_en ,wr_en_timer,rd_time;
     output tick_en;
     input [31:0] wr_data;
     output [15:0] Num_tick_reg;         //maximum for 43sec
//------------Internal Variables--------
//`ifdef EXT_WALL_CLOCK
//    reg [63:0] out;
// `else
    reg tick_en;
    reg [15:0] tick_count;
    reg [15:0] Num_tick_reg;         //maximum for 43sec

always @(posedge clk) begin
    if (reset) begin
      tick_en <= 1'b0;
    end
    else if(tick_count == Num_tick_reg)
      tick_en <= 1'b1;
    else
      tick_en <= 1'b0;    
end

always @(posedge clk) begin
    if(reset) begin
            Num_tick_reg <= 16'hFFFF; 
    end
    else if(wr_en && ~wr_en_timer) 
            begin
                Num_tick_reg <= wr_data[15:0];
            end
end

always @(posedge clk) begin
    if (reset) begin
      tick_count <= 16'b0;
    end
    else if(wr_en && ~wr_en_timer) 
      begin
      tick_count <= 16'b0;     
      end
    else if(out==17'h186A0)
      begin
      tick_count <= tick_count + 1;
      end
    else if(tick_en)
      begin
      tick_count <= 16'b0; 
      end
end    

always @(posedge clk) begin
    if(reset) begin
        out <= 17'b0;
    end
    else begin
        if(wr_en && wr_en_timer) begin
            out <= wr_data;
        end
        else if (~rd_time)
            begin
            if(out == 17'h186A0)
                out <= 17'b0;
            else
                out <= out + 1;
            end
    end
end
//ila_3 count_1( .clk(clk),
//                .probe0(out),
//                .probe1(wr_en_timer),
//                .probe2(tick_count),
//                .probe3(wr_en),
//                .probe4(Num_tick_reg),
//                .probe5(tick_en));
//`endif
endmodule 



module counter_proc_clk    (
out     ,  // Output of the counter
clk     ,  // clock Input
wr_en  ,
wr_en_h  ,
wr_data,rd_cycle,
reset      // reset Input
);
//----------Output Ports--------------
    output [63:0] out;
//------------Input Ports--------------
     input  clk, reset,wr_en ,wr_en_h,rd_cycle;
  input [31:0] wr_data;
  //------------Internal Variables--------
    reg [63:0] out;
//-------------Code Starts Here-------
always @(posedge clk or posedge reset)
    if (reset) begin
      out <= 64'b0 ;
    end 
    else begin
        if(wr_en)
            if(wr_en_h)
                out <= {{wr_data},{out[31:0]}};
            else 
                out <= {{out[63:32]},{wr_data}};
        else if(~rd_cycle)
            out <= out + 1; 
    end

endmodule 

//The real counter will depend on a 1 Hz clock which depends on implementation

module counter_real_clk    (
out     ,  // Output of the counter
clk     ,  // clock Input
wr_en  ,
wr_en_h  ,real_tick_en,rd_time,
wr_data,wr_tcmp_en,timecmp,
reset      // reset Input
);
//----------Output Ports--------------
    output [63:0] out;
    output [63:0] timecmp;
//------------Input Ports--------------
     input  clk, reset,wr_en ,wr_en_h,wr_tcmp_en,rd_time;
     output real_tick_en;
       input [31:0] wr_data;
//------------Internal Variables--------
//`ifdef EXT_WALL_CLOCK
//    reg [63:0] out;
// `else
    reg [63:0] out;
    reg [63:0] timecmp;
    reg real_tick_en;
    reg [26:0] tick_count;
//`endif
//-------------Code Starts Here-------
//`ifndef EXT_WALL_CLOCK
always @(posedge clk or posedge reset) begin
    if (reset) begin
      real_tick_en <= 1'b0;
    end
    else begin
      if(out >= timecmp)
        real_tick_en <= 1'b1;
      else 
        real_tick_en <= 1'b0;
    end
end
//`endif

//`ifdef EXT_WALL_CLOCK
//always @(posedge clk or posedge reset) begin
//    if(reset) begin
//        out <= 64'b0;
//    end
//    else begin
//        out <= out + 1;
//    end
//end
//`else
always @(posedge clk or posedge reset) begin
    if(reset) begin
        out <= 64'b1;
    end
    else begin
        if(wr_en && ~wr_tcmp_en) begin
            if(wr_en_h)
                out <= {{wr_data},{out[31:0]}};
            else
                out <= {{out[63:32]},{wr_data}};
        end
        else if (~rd_time)
            out <= out + 1;
    end
end

//ila_0 your_instance_name (
//	.clk(clk), // input wire clk
//	.probe0(out), // input wire [63:0]  probe0  
//	.probe1(timecmp), // input wire [63:0]  probe1 
//	.probe2(tick_en) // input wire [0:0]  probe2
//);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        timecmp <= 64'hffffffffFFFFFFFF;
    end
    else begin
            if(wr_en && wr_tcmp_en) 
            begin
                if(wr_en_h)
                    timecmp <= {{wr_data},{timecmp[31:0]}};
                else
                    timecmp <= {{timecmp[63:32]},{wr_data}};
            end
    end
end

//`endif
endmodule 

////////////////////////////////////////////////////////////////////////////////

module counter_instr_clk    (
out     ,  // Output of the counter
clk     ,  // clock Input
wr_en  ,
wr_en_h  ,rd_instret,
wr_data,  
freeze  ,  // if freeze then counter is paused
reset      // reset Input
);
//----------Output Ports--------------
    output [63:0] out;
//------------Input Ports--------------
     input  clk, reset,freeze,wr_en,wr_en_h,rd_instret;
     input [31:0] wr_data;
//------------Internal Variables--------
    reg [63:0] out;
//-------------Code Starts Here-------
always @(posedge clk or posedge reset)
    if (reset) begin
      out <= 64'b0 ;
    end 
    else if (~freeze) begin
        if(wr_en)
            if(wr_en_h)
                out <= {{wr_data},{out[31:0]}};
            else
                out <= {{out[63:32]},{wr_data}};
        else if (~rd_instret)
            out <= out + 1;
    end

endmodule 