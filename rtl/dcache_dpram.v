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





module dcache_dpram
(
    input rst,
    input clk,
    input clk_x2,
    input [255:0] dcache_in_a_w0,
    input [255:0] dcache_in_b_w0,
    input [255:0] dcache_in_a_w1,
    input [255:0] dcache_in_b_w1,
    
    input [31:0] addr_in_a,
    input [31:0] addr_in_b,
    input [6:0] dcache_addr_w0_a,
    input [6:0] dcache_addr_w1_a,
    input [6:0] dcache_addr_w0_b,
    input [6:0] dcache_addr_w1_b,
    
    input [31:0] we_a_w0,
    input [31:0] we_b_w0,
    input [31:0] we_a_w1,
    input [31:0] we_b_w1,
    
    input [3:0] we_tag_a_w0,
    input [3:0] we_tag_b_w0,
    input [3:0] we_tag_a_w1,
    input [3:0] we_tag_b_w1,
    
    input [6:0] tag_addr_a_w0,
    input [6:0] tag_addr_a_w1,
    input [6:0] tag_addr_b_w0,
    input [6:0] tag_addr_b_w1,
    input [31:0] tag_data_a_w0,
    input [31:0] tag_data_a_w1,
    input [31:0] tag_data_b_w0,
    input [31:0] tag_data_b_w1,
    
    output reg [31:0] tag_a_w0_o,
    output reg [31:0] tag_a_w1_o,
    output reg [31:0] tag_b_w0_o,
    output reg [31:0] tag_b_w1_o,
    
    input [6:0] Dirty_bit_Addr_a_w0, 
    input [6:0] Dirty_bit_Addr_a_w1, 
    output reg Dirty_bit_Read_Data_a_w0,       
    output reg Dirty_bit_Read_Data_a_w1,       
    input Dirty_bit_Write_Data_a_w0, 
    input Dirty_bit_Write_Data_a_w1, 
    input Dirty_bit_Write_En_a_w0,   
    input Dirty_bit_Write_En_a_w1,  
    
    input [6:0] Dirty_bit_Addr_b_w0, 
    input [6:0] Dirty_bit_Addr_b_w1, 
    output reg Dirty_bit_Read_Data_b_w0,       
    output reg Dirty_bit_Read_Data_b_w1,       
    input Dirty_bit_Write_Data_b_w0, 
    input Dirty_bit_Write_Data_b_w1, 
    input Dirty_bit_Write_En_b_w0,   
    input Dirty_bit_Write_En_b_w1,   
    
    
    input [4:0] lsu_op_port1,
    input [4:0] lsu_op_port2,
    
    input freeze,
    input byp_a,                        //Bypass the input register and feed the address directly. 
    input byp_b,  
    
    input vpn_to_ppn_req_port1,
    input vpn_to_ppn_req_port2,
    input freeze_tlb,
    output tlb_freeze_dcache,
    output [25:0] tag_out_tlb_port1,
    output [25:0] tag_out_tlb_port2,
    output tag_hit_tlb_port1,
    output tag_hit_tlb_port2,
    //------------ Wishbone Signals -------------- 
    
    //input				wb_clk_i;	// clock input
    //input				wb_rst_i;	// reset input
    input				wb_ack_i,	// normal termination
    input				wb_err_i,	// termination w/ error
    input				wb_rty_i,	// termination w/ retry
    input  [31:0]       wb_dat_i,
    output				wb_cyc_o,
    output              wb_stb_o,	// strobe output
    output              wb_we_o,	// indicates write transfer
    output [31:0] 		wb_adr_o,	
    output [1:0]        wb_bte_o,
    output [2:0] 		wb_cti_o,
    output [3:0]        wb_sel_o,	// byte select outputs for the signals-byte select and extend
    output [31:0]       wb_dat_o,	// output data bus
    
    
                          //
    output reg [255:0] w0_data_a,
    output reg [255:0] w1_data_a,
    output reg [255:0] w0_data_b,
    output reg [255:0] w1_data_b,
    
    output reg [31:0] dout_a,
    output reg [31:0] dout_b,
    output reg hit_a,
    output reg hit_b,
    output reg mis_a,
    output reg mis_b,
    output reg a_w0_hit,          //signals the fsm which way was hit. that way will be written  in case of write
    output reg a_w1_hit,          //  "       "   "   "   "   "   "       "   "   "   "   "       "   "   "   "
    output reg b_w0_hit,          //signals the fsm which way was hit. that way will be written  in case of write
    output reg b_w1_hit,          //  "       "   "   "   "   "   "       "   "   "   "   "       "   "   "   "wire [4:0] index_a;
    
    output addr_exception_port1,
    output addr_exception_port2
);

parameter offset_start_bit = 0;
parameter offset_last_bit = 4;
parameter index_start_bit = 5;
parameter index_last_bit = 11;
parameter tag_start_bit = 12;
parameter tag_last_bit = 31;
parameter vpn_width = 20;
parameter tag_width=22;

//-------TLB tag out----------------------------------
//Currently TLB tag out consists of 22 bit physical tag and 4 bit i.e. U, X, W, R. 
//But Current design uses 20 bit physical tag. So by assuming MSB 2 bits as zero in 22 bit physical tag
//it will become 20 bit value and i.e. taken for comparison. Because of this reason 23:4 is considered for tag
parameter tag_tlb_start_bit = 4;
parameter tag_tlb_last_bit = 23;
//----------------------------------------------------




wire [21:0] tag_a;
wire [6:0] index_a;
wire [2:0] blk_offst_a;
wire [6:0] index_b;
wire [2:0] blk_offst_b;
wire [21:0] tag_b;

wire [127:0] w0_a_1;
wire [127:0] w1_a_1;
wire [127:0] w0_b_1;
wire [127:0] w1_b_1;
wire [127:0] w0_a_2;
wire [127:0] w1_a_2;
wire [127:0] w0_b_2;
wire [127:0] w1_b_2;
wire [31:0] tag_a_w0_int;
wire [31:0] tag_a_w1_int;
wire [31:0] tag_b_w0_int;
wire [31:0] tag_b_w1_int;

wire tag_comp_w0_a;
wire tag_comp_w1_a;
wire tag_comp_w0_b;
wire tag_comp_w1_b;

wire proc_rq_port1;
wire proc_rq_port2;




reg [31:0] addr_in_a_int;
reg [31:0] addr_in_b_int;
reg [4:0] lsu_op_port1_int;
reg [4:0] lsu_op_port2_int;

localparam PULSE_START = 2'b00;
localparam PULSE_DEL = 2'b01;
localparam PULSE_HI = 2'b10;
localparam PULSE_LOW = 2'b11;

wire read_exception_port1;
wire read_exception_port2;
wire write_exception_port1;
wire write_exception_port2;

assign read_exception_port1 = ((lsu_op_port1_int == 2'b01) && (~tag_out_tlb_port1[1]) && tag_hit_tlb_port1);
assign read_exception_port2 = ((lsu_op_port2_int == 2'b01) && (~tag_out_tlb_port2[1]) && tag_hit_tlb_port2);
assign write_exception_port1 = ((lsu_op_port1_int == 2'b10) && (~(tag_out_tlb_port1[2:1] == 2'b11)) && tag_hit_tlb_port1);
assign write_exception_port2 = ((lsu_op_port2_int == 2'b10) && (~(tag_out_tlb_port2[2:1] == 2'b11)) && tag_hit_tlb_port2);
assign addr_exception_port1 =  read_exception_port1 || write_exception_port1;
assign addr_exception_port2 =  read_exception_port2 || write_exception_port2;

assign proc_rq_port1 = lsu_op_port1[1] ^ lsu_op_port1[0];
assign proc_rq_port2 = lsu_op_port2[1] ^ lsu_op_port2[0];



//input register to take in the operand values;disabled by 'byp' pin
always @(posedge clk ) begin
    if(rst) begin
        addr_in_a_int <= 32'b0;
        addr_in_b_int <= 32'b0;        
        lsu_op_port1_int <= 5'b0;
        lsu_op_port2_int <= 5'b0;
    end
    else begin
        if(~freeze) begin
            addr_in_a_int <= addr_in_a;
            addr_in_b_int <= addr_in_b;
            lsu_op_port1_int <= lsu_op_port1;
            lsu_op_port2_int <= lsu_op_port2;        
        end
    end
end


assign blk_offst_a = byp_a ? addr_in_a[4:2] : addr_in_a_int[4:2];
assign blk_offst_b = byp_b ? addr_in_b[4:2] : addr_in_b_int[4:2];
assign index_a = addr_in_a[index_last_bit:index_start_bit];
assign index_b = addr_in_b[index_last_bit:index_start_bit];
assign tag_a = byp_a ? addr_in_a[tag_last_bit:tag_start_bit] : addr_in_a_int[tag_last_bit:tag_start_bit];
assign tag_b = byp_b ? addr_in_b[tag_last_bit:tag_start_bit] : addr_in_b_int[tag_last_bit:tag_start_bit];
assign tag_comp_w0_a = ((tag_out_tlb_port1[tag_tlb_last_bit:tag_tlb_start_bit] == tag_a_w0_int[(tag_last_bit-tag_start_bit):0]) & tag_a_w0_int[22] & tag_hit_tlb_port1) ? 1'b1 : 1'b0;
assign tag_comp_w1_a = ((tag_out_tlb_port1[tag_tlb_last_bit:tag_tlb_start_bit] == tag_a_w1_int[(tag_last_bit-tag_start_bit):0]) & tag_a_w1_int[22] & tag_hit_tlb_port1) ? 1'b1 : 1'b0; 
assign tag_comp_w0_b = ((tag_out_tlb_port2[tag_tlb_last_bit:tag_tlb_start_bit] == tag_b_w0_int[(tag_last_bit-tag_start_bit):0]) & tag_b_w0_int[22] & tag_hit_tlb_port2) ? 1'b1 : 1'b0;
assign tag_comp_w1_b = ((tag_out_tlb_port2[tag_tlb_last_bit:tag_tlb_start_bit] == tag_b_w1_int[(tag_last_bit-tag_start_bit):0]) & tag_b_w1_int[22] & tag_hit_tlb_port2) ? 1'b1 : 1'b0; 


always @(*) begin
    if(rst) begin
        a_w0_hit <= 1'b0;
        a_w1_hit <= 1'b0;
        b_w0_hit <= 1'b0;
        b_w1_hit <= 1'b0;        
    end
    else begin
        a_w0_hit <= tag_comp_w0_a;
        a_w1_hit <= tag_comp_w1_a;
        b_w0_hit <= tag_comp_w0_b;
        b_w1_hit <= tag_comp_w1_b;            
    end
end

always @(*) begin
    hit_a <= (tag_comp_w0_a) | (tag_comp_w1_a);
    hit_b <= (tag_comp_w0_b) | (tag_comp_w1_b);       
    mis_a <= ~hit_a;
    mis_b <= ~hit_b;
end

always @(*) begin
    case(blk_offst_a)
        3'b000: dout_a <= tag_comp_w0_a ? w0_a_1[31:0] : w1_a_1[31:0];
        3'b001: dout_a <= tag_comp_w0_a ? w0_a_1[63:32] : w1_a_1[63:32];
        3'b010: dout_a <= tag_comp_w0_a ? w0_a_1[95:64] : w1_a_1[95:64];
        3'b011: dout_a <= tag_comp_w0_a ? w0_a_1[127:96] : w1_a_1[127:96];
        3'b100: dout_a <= tag_comp_w0_a ? w0_a_2[31:0] : w1_a_2[31:0];
        3'b101: dout_a <= tag_comp_w0_a ? w0_a_2[63:32] : w1_a_2[63:32];
        3'b110: dout_a <= tag_comp_w0_a ? w0_a_2[95:64] : w1_a_2[95:64];
        3'b111: dout_a <= tag_comp_w0_a ? w0_a_2[127:96] : w1_a_2[127:96];
        default: dout_a <= 32'b0;
    endcase;
end
 
always @(*) begin
    case(blk_offst_b)
        3'b000: dout_b <= tag_comp_w0_b ? w0_b_1[31:0] : w1_b_1[31:0];
        3'b001: dout_b <= tag_comp_w0_b ? w0_b_1[63:32] : w1_b_1[63:32];
        3'b010: dout_b <= tag_comp_w0_b ? w0_b_1[95:64] : w1_b_1[95:64];
        3'b011: dout_b <= tag_comp_w0_b ? w0_b_1[127:96] : w1_b_1[127:96];
        3'b100: dout_b <= tag_comp_w0_b ? w0_b_2[31:0] : w1_b_2[31:0];
        3'b101: dout_b <= tag_comp_w0_b ? w0_b_2[63:32] : w1_b_2[63:32];
        3'b110: dout_b <= tag_comp_w0_b ? w0_b_2[95:64] : w1_b_2[95:64];
        3'b111: dout_b <= tag_comp_w0_b ? w0_b_2[127:96] : w1_b_2[127:96];
        default: dout_b <= 32'b0;
    endcase;
end

always @(*) begin
    w0_data_a <= {{w0_a_2},{w0_a_1}};
    w1_data_a <= {{w1_a_2},{w1_a_1}};
    w0_data_b <= {{w0_b_2},{w0_b_1}};
    w1_data_b <= {{w1_b_2},{w1_b_1}};
    tag_a_w0_o <= tag_a_w0_int;
    tag_a_w1_o <= tag_a_w1_int;
    tag_b_w0_o <= tag_b_w0_int;
    tag_b_w1_o <= tag_b_w1_int;
end
 
reg [127:0] Dirty_Bit_w0;
reg [127:0] Dirty_Bit_w1;

always @(posedge clk) begin
    if(rst) begin
		 Dirty_Bit_w0 <= 0;
    end
    else begin
        if(Dirty_bit_Write_En_a_w0) begin
            Dirty_Bit_w0[Dirty_bit_Addr_a_w0] <= Dirty_bit_Write_Data_a_w0;
        end
        if(Dirty_bit_Write_En_b_w0) begin
            Dirty_Bit_w0[Dirty_bit_Addr_b_w0] <= Dirty_bit_Write_Data_b_w0;
        end
    end
end

always @(posedge clk) begin
    if(rst) begin
		 Dirty_Bit_w1 <= 0;
    end
    else begin
        if(Dirty_bit_Write_En_a_w1) begin
            Dirty_Bit_w1[Dirty_bit_Addr_a_w1] <= Dirty_bit_Write_Data_a_w1;
        end
        if(Dirty_bit_Write_En_b_w1) begin
            Dirty_Bit_w1[Dirty_bit_Addr_b_w1] <= Dirty_bit_Write_Data_b_w1;
        end
    end
end

always @(*) begin
    if(rst) begin
        Dirty_bit_Read_Data_a_w0 <= 0;
        Dirty_bit_Read_Data_a_w1 <= 0;
        Dirty_bit_Read_Data_b_w0 <= 0;
        Dirty_bit_Read_Data_b_w1 <= 0;
    end
    else begin
        Dirty_bit_Read_Data_a_w0 <= Dirty_Bit_w0[Dirty_bit_Addr_a_w0];
        Dirty_bit_Read_Data_a_w1 <= Dirty_Bit_w1[Dirty_bit_Addr_a_w1];
        Dirty_bit_Read_Data_b_w0 <= Dirty_Bit_w0[Dirty_bit_Addr_b_w0];
        Dirty_bit_Read_Data_b_w1 <= Dirty_Bit_w1[Dirty_bit_Addr_b_w1];
    end
end

dcache ram_w0_1 (                                             //w0 data ram bank
  .clka(clk),.rsta(rst),.wea(we_a_w0[15:0]),.addra(dcache_addr_w0_a),.dina(dcache_in_a_w0[127:0]),.douta(w0_a_1),
  .clkb(clk),.rstb(rst),.web(we_b_w0[15:0]),.addrb(dcache_addr_w0_b),.dinb(dcache_in_b_w0[127:0]),.doutb(w0_b_1)
);

dcache ram_w0_2 (                                             //w0 data ram bank
  .clka(clk),.rsta(rst),.wea(we_a_w0[31:16]),.addra(dcache_addr_w0_a),.dina(dcache_in_a_w0[255:128]),.douta(w0_a_2),
  .clkb(clk),.rstb(rst),.web(we_b_w0[31:16]),.addrb(dcache_addr_w0_b),.dinb(dcache_in_b_w0[255:128]),.doutb(w0_b_2)
);



dcache ram_w1_1 (                                             //w1 data ram bank
  .clka(clk),.rsta(rst),.wea(we_a_w1[15:0]),.addra(dcache_addr_w1_a),.dina(dcache_in_a_w1[127:0]),.douta(w1_a_1),
  .clkb(clk),.rstb(rst),.web(we_b_w1[15:0]),.addrb(dcache_addr_w1_b),.dinb(dcache_in_b_w1[127:0]),.doutb(w1_b_1)
);

dcache ram_w1_2 (                                             //w1 data ram bank
  .clka(clk),.rsta(rst),.wea(we_a_w1[31:16]),.addra(dcache_addr_w1_a),.dina(dcache_in_a_w1[255:128]),.douta(w1_a_2),
  .clkb(clk),.rstb(rst),.web(we_b_w1[31:16]),.addrb(dcache_addr_w1_b),.dinb(dcache_in_b_w1[255:128]),.doutb(w1_b_2)
);


tag_ram tag_w0 (
  .clka(clk), // input clka
  .rsta(rst),
  .wea(we_tag_a_w0), // input [3 : 0] wea
  .addra(tag_addr_a_w0), // input [7 : 0] addra --[6:0] now
  .dina(tag_data_a_w0), // input [31 : 0] dina
  .douta(tag_a_w0_int), // output [31 : 0] douta
  .clkb(clk), // input clkb
  .rstb(rst),
  .web(we_tag_b_w0), // input [3 : 0] web
  .addrb(tag_addr_b_w0), // input [7 : 0] addrb --[6:0] now
  .dinb(tag_data_b_w0), // input [31 : 0] dinb
  .doutb(tag_b_w0_int) // output [31 : 0] doutb
);

tag_ram tag_w1 (
  .clka(clk), // input clka
  .rsta(rst),
  .wea(we_tag_a_w1), // input [3 : 0] wea
  .addra(tag_addr_a_w1), // input [7 : 0] addra --[6:0] now
  .dina(tag_data_a_w1), // input [31 : 0] dina
  .douta(tag_a_w1_int), // output [31 : 0] douta
  .clkb(clk), // input clkb
  .rstb(rst),
  .web(we_tag_b_w1), // input [3 : 0] web
  .addrb(tag_addr_b_w1), // input [7 : 0] addrb --[6:0] now
  .dinb(tag_data_b_w1), // input [31 : 0] dinb
  .doutb(tag_b_w1_int) // output [31 : 0] doutb
);

tlb dtlb
(
.clk(clk),
.clk_x2(clk_x2),
.rst(rst),
.vpn_to_ppn_req_port1(vpn_to_ppn_req_port1),
.vpn_to_ppn_req_port2(vpn_to_ppn_req_port2),
.vpn_in_port1(addr_in_a[tag_last_bit:tag_start_bit]),
.vpn_in_port2(addr_in_b[tag_last_bit:tag_start_bit]),
.tag_out_port1(tag_out_tlb_port1),
.tag_out_port2(tag_out_tlb_port2),
.tag_hit_port1(tag_hit_tlb_port1),
.tag_hit_port2(tag_hit_tlb_port2),
.freeze_tlb(freeze_tlb),
.freeze(tlb_freeze_dcache),
.wb_ack_i(wb_ack_i),
.wb_err_i(wb_err_i),
.wb_rty_i(wb_rty_i),
.wb_dat_i(wb_dat_i),
.wb_cyc_o(wb_cyc_o),
.wb_stb_o(wb_stb_o),
.wb_we_o (wb_we_o ),
.wb_adr_o(wb_adr_o),
.wb_bte_o(wb_bte_o),
.wb_cti_o(wb_cti_o),
.wb_sel_o(wb_sel_o),
.wb_dat_o(wb_dat_o)
);


endmodule
