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

`define TESTING 1

module dcache_top(rst,clk,clk_x2,freeze,dtop_freeze,cache_flush,bus_rq,bus_data,bus_addr,bus_re,bus_we,lsustall,lsu_op_port1,
lsu_op_port2,prp_acs0,prp_acs1,biu_prp_acs,proc_data_in_port1,proc_data_in_port2,proc_addr_in_port1,proc_addr_in_port2,
proc_data_port1,proc_data_port2,bus_rdy,sc_chkdone,biu_sel_o,tlb_freeze_dcache, wb_ack_i,wb_err_i,wb_rty_i,wb_dat_i,wb_cyc_o,
wb_stb_o,wb_we_o,wb_adr_o,wb_bte_o,wb_cti_o,wb_sel_o,wb_dat_o,addr_exception
);

parameter vpn_width=20;


input rst;
input clk;
input clk_x2;
input lsustall;
input sc_chkdone;                       //For SC instruction
input [4:0] lsu_op_port1;
input [4:0] lsu_op_port2;
input [31:0] proc_addr_in_port1;
input [31:0] proc_addr_in_port2;
input dtop_freeze;
input cache_flush;
input [31:0] proc_data_in_port1;
input [31:0] proc_data_in_port2;

input prp_acs0;                         //Peripheral access signal. The fsm should not cache these valfues
input prp_acs1;                         //

input bus_rdy;
output reg freeze;

output reg bus_rq;
inout [255:0] bus_data;
//output [255:0] bus_data_o;
output reg [31:0] bus_addr;
output reg bus_re;
output reg bus_we;
output reg [31:0] proc_data_port1;
output reg [31:0] proc_data_port2;
output biu_prp_acs;                     //Signal for biu from FSM
output reg [3:0] biu_sel_o;
output tlb_freeze_dcache;

//------------ Wishbone Signals -------------- 

//input				wb_clk_i;	// clock input
//input				wb_rst_i;	// reset input
input				wb_ack_i;	// normal termination
input				wb_err_i;	// termination w/ error
input				wb_rty_i;	// termination w/ retry
input  [31:0]       wb_dat_i;
output				wb_cyc_o;
output              wb_stb_o;	// strobe output
output              wb_we_o;	// indicates write transfer
output [31:0] 		wb_adr_o;	
output [1:0]        wb_bte_o;
output [2:0] 		wb_cti_o;
output [3:0]        wb_sel_o;	// byte select outputs for the signals-byte select and extend
output [31:0]       wb_dat_o;	// output data bus
output addr_exception;

wire freeze_int1; 
wire bus_rq_int1;
wire bus_re_int1;
wire bus_cntrl_int1;
wire bus_cntrl_int2;
wire bus_we_int1;
wire [31:0] bus_addr_int1;
wire [31:0] bus_addr_int2;
//wire [31:0] bus_addr_int1;
wire freeze_int2; 
wire bus_rq_int2;
wire bus_re_int2;
wire bus_we_int2;

wire hit_a;
wire hit_b;
wire mis_a;
wire mis_b;
wire [31:0] proc_data_port1_int;
wire [31:0] proc_data_port2_int;
reg [31:0] proc_addr_in_port1_int;
reg [31:0] proc_addr_in_port2_int;
reg [31:0] proc_data_in_port1_int;
reg [31:0] proc_data_in_port2_int;

reg [4:0] lsu_op_port1_reg;
reg [4:0] lsu_op_port2_reg;
reg [31:0] proc_addr_in_port1_reg;
reg [31:0] proc_data_in_port1_reg;
reg [31:0] proc_addr_in_port2_reg;
reg [31:0] proc_data_in_port2_reg;


reg [4:0] lsu_op_port1_int;
reg [4:0] lsu_op_port2_int;

wire [31:0] dout_a;
wire [31:0] dout_b;
wire [255:0] dcache_in_a_w0;
wire [255:0] dcache_in_a_w1;
wire [255:0] dcache_in_b_w0;
wire [255:0] dcache_in_b_w1;
wire [255:0] dcache_out_a_w0;
wire [255:0] dcache_out_a_w1;
wire [255:0] dcache_out_b_w0;
wire [255:0] dcache_out_b_w1;
wire w0_a_hit;
wire w1_a_hit;
wire w0_b_hit;
wire w1_b_hit;
wire [6:0] dcache_addr_w0_a;
wire [6:0] dcache_addr_w1_a;
wire [6:0] dcache_addr_w0_b;
wire [6:0] dcache_addr_w1_b;
wire [31:0] we_data_a_w0;
wire [31:0] we_data_a_w1;
wire [31:0] we_data_b_w0;
wire [31:0] we_data_b_w1;
wire [3:0] we_tag_a_w0;
wire [3:0] we_tag_a_w1;
wire [3:0] we_tag_b_w0;
wire [3:0] we_tag_b_w1;
wire [6:0] tag_addr_a_w0;
wire [6:0] tag_addr_a_w1;
wire [6:0] tag_addr_b_w0;
wire [6:0] tag_addr_b_w1;
wire [31:0] tag_data_a_w0;
wire [31:0] tag_data_a_w1;
wire [31:0] tag_data_b_w0;
wire [31:0] tag_data_b_w1;
wire [31:0] tag_data_a_w0_o;
wire [31:0] tag_data_a_w1_o;
wire [31:0] tag_data_b_w0_o;
wire [31:0] tag_data_b_w1_o;

reg [2:0] state,nextState;
reg bus_rdy_int1;
reg bus_rdy_int2;
reg bus_rq_str;
reg p1;
wire wr_rd_clsh;
wire bus_clsh;
reg byp_a,byp_b;

reg [1:0] lru_data_in;
wire [6:0] lru_addr;
reg [1:0] mem[0:255];
wire [6:0] lru_addr_int1;
wire [6:0] lru_addr_int2;
wire proc_rq_o_int1;
wire proc_rq_o_int2;

wire fsm0_prp_acs;
wire fsm1_prp_acs;      //Signals from fsm to biu to signal non-burst transaction

wire [1:0] lru_data_out;
wire lru_we;
wire lru_we_int1;
wire lru_we_int2;
wire [1:0] lru_data_out_int1;
wire [1:0] lru_data_out_int2;

reg freeze_fsm0;        //the first controller will be frozen if second is busy
reg freeze_fsm1;        //the second controller will be frozen if first is busy

wire cache_flush_int1;  //
wire cache_flush_int2;
wire vpn_to_ppn_req1;
wire vpn_to_ppn_req2;
wire [(vpn_width-1+6):0] tag_out_tlb_port1;
wire [(vpn_width-1+6):0] tag_out_tlb_port2;


wire [6:0] Dirty_bit_Addr_a_w0; 
wire [6:0] Dirty_bit_Addr_a_w1; 
wire Dirty_bit_Read_Data_a_w0;       
wire Dirty_bit_Read_Data_a_w1;       
wire Dirty_bit_Write_Data_a_w0; 
wire Dirty_bit_Write_Data_a_w1; 
wire Dirty_bit_Write_En_a_w0;   
wire Dirty_bit_Write_En_a_w1;  

wire [6:0] Dirty_bit_Addr_b_w0; 
wire [6:0] Dirty_bit_Addr_b_w1; 
wire Dirty_bit_Read_Data_b_w0;      
wire Dirty_bit_Read_Data_b_w1;       
wire Dirty_bit_Write_Data_b_w0; 
wire Dirty_bit_Write_Data_b_w1; 
wire Dirty_bit_Write_En_b_w0;   
wire Dirty_bit_Write_En_b_w1;   

wire proc_rq_reg_1;
wire proc_rq_reg_2;


integer i;
integer j;

localparam CHECK = 3'b000;
localparam BUS_CLSH = 3'b001;
localparam HOLD = 3'b011;
localparam BUS_SER = 3'b010;                         //State to serialise bus transactions by port 1 and port 2 and hand them back the data
localparam HOLD_2 = 3'b100;

wire  addr_exception_port1;
wire  addr_exception_port2;

wire tag_hit_tlb_port1;
wire tag_hit_tlb_port2;

assign addr_exception = addr_exception_port1 || addr_exception_port2 ;


assign wr_rd_clsh = (proc_addr_in_port1[11:5] == proc_addr_in_port2[11:5]);
assign bus_clsh = bus_cntrl_int1 & bus_cntrl_int2;

assign biu_prp_acs = (cache_flush_int1 | cache_flush_int2) ? 1'b0 : fsm0_prp_acs | fsm1_prp_acs;


//always @(*) begin
assign lru_addr = (proc_rq_reg_1 | bus_cntrl_int1) ? lru_addr_int1 : ((proc_rq_reg_2 | bus_cntrl_int2) ? lru_addr_int2 : 8'b0);
//end

assign lru_we = (lru_we_int1 ~^ lru_we_int2);
assign lru_data_out = ~(lru_we_int1 ~^ lru_we_int2) ? ((~lru_we_int1) ? lru_data_out_int1 : lru_data_out_int2) : 2'b0;

always @(*) begin
    i <= lru_addr;
end

always @(posedge clk) begin
//////////////////////////////////
// RF is written on clock high //
////////////////////////////////
    if(rst) begin
		 for(j=0; j<256; j=j+1) mem[j] <= 2'b10;
    end
    else begin
        if(~lru_we & ~dtop_freeze) begin
            mem[i] <= lru_data_out;
        end
    end
end

//////////////////////////////
// RF is read on clock low //
////////////////////////////
always @(*) begin
    lru_data_in <= mem[i];
end
/////////////////////////////


always @(posedge clk ) begin
    if(rst) begin
        lsu_op_port1_reg <= 5'b0;
        lsu_op_port2_reg <= 5'b0;
        proc_addr_in_port1_reg <= 32'b0;
        proc_data_in_port1_reg <= 32'b0;
        proc_addr_in_port2_reg <= 32'b0;
        proc_data_in_port2_reg <= 32'b0;        
    end
    else begin
        if(~freeze & ~dtop_freeze) begin
            lsu_op_port1_reg <= lsu_op_port1;
            lsu_op_port2_reg <= lsu_op_port2;
            proc_addr_in_port1_reg <= proc_addr_in_port1;
            proc_data_in_port1_reg <= proc_data_in_port1;
            proc_addr_in_port2_reg <= proc_addr_in_port2;
            proc_data_in_port2_reg <= proc_data_in_port2;    
        end    
    end
end








always @(*) begin
    proc_data_port1 <= proc_data_port1_int;
    proc_data_port2 <= proc_data_port2_int;
    if(bus_cntrl_int1 & biu_prp_acs) begin
        casex({{lsu_op_port1_reg[4:2]},{bus_addr[1:0]}})
            5'b10000:   biu_sel_o <= 4'b0001;           //Load byte
            5'b10001:   biu_sel_o <= 4'b0010;
            5'b10010:   biu_sel_o <= 4'b0100;
            5'b10011:   biu_sel_o <= 4'b1000;            
            5'b10100:   biu_sel_o <= 4'b0011;           //Load half word
            5'b10110:   biu_sel_o <= 4'b1100;            
            5'b00100:   biu_sel_o <= 4'b0011;           //Load/Store half word      
            5'b00110:   biu_sel_o <= 4'b1100;           //Load/Store half word at 2-byte aligned boundary
            5'b010??:   biu_sel_o <= 4'b1111;           //Load/Store word
            5'b00000:   biu_sel_o <= 4'b0001;           //Store byte at 4-byte aligned address 
            5'b00001:   biu_sel_o <= 4'b0010;           //Load/Store byte non-4 byte aligned address
            5'b00010:   biu_sel_o <= 4'b0100;
            5'b00011:   biu_sel_o <= 4'b1000;
            default:    biu_sel_o <= 4'b0000;            
        endcase;
    end
    else if(bus_cntrl_int2 & biu_prp_acs) begin
        case({{lsu_op_port2_reg[4:2]},{bus_addr[3:2]}})
            5'b10000:   biu_sel_o <= 4'b0001;           //Load byte
            5'b10001:   biu_sel_o <= 4'b0010;
            5'b10010:   biu_sel_o <= 4'b0100;
            5'b10011:   biu_sel_o <= 4'b1000;            
            5'b10100:   biu_sel_o <= 4'b0011;           //Load half word
            5'b10110:   biu_sel_o <= 4'b1100;            
            5'b00100:   biu_sel_o <= 4'b0011;           //Load/Store half word      
            5'b00110:   biu_sel_o <= 4'b1100;           //Load/Store half word at 2-byte aligned boundary
            5'b01000:   biu_sel_o <= 4'b1111;           //Load/Store word
            5'b01001:   biu_sel_o <= 4'b1111;           //Load/Store word
            5'b01010:   biu_sel_o <= 4'b1111;           //Load/Store word
            5'b01011:   biu_sel_o <= 4'b1111;           //Load/Store word
            5'b00000:   biu_sel_o <= 4'b0001;           //Store byte at 4-byte aligned address 
            5'b00001:   biu_sel_o <= 4'b0010;           //Load/Store byte non-4 byte aligned address
            5'b00010:   biu_sel_o <= 4'b0100;
            5'b00011:   biu_sel_o <= 4'b1000;
            default:    biu_sel_o <= 4'b0000;            
        endcase;
    end
    else begin
        biu_sel_o <= 4'b1111;
    end
end

reg lru_addr_int[6:0];

always @( posedge clk) begin
    if(rst) begin
        state <= CHECK;  
    end
    else if (~dtop_freeze) begin
        state <= nextState;
    end
end

always @(*) begin
    case(state)
        CHECK : begin
            freeze <= freeze_int1 | freeze_int2;
            
            byp_a <= 1'b0;
            byp_b <= 1'b0; 
                           
            bus_re <= bus_re_int1 | bus_re_int2;
            bus_we <= bus_we_int1 | bus_we_int2;
            bus_addr <= bus_clsh ? bus_addr_int1 : (bus_rq_int1 ? bus_addr_int1 : bus_addr_int2);
            
            if((((lsu_op_port1[1] ^ lsu_op_port2[1]) & (lsu_op_port1[0] ^ lsu_op_port2[0])) & wr_rd_clsh) | (lsu_op_port1[0] & lsu_op_port2[0] & wr_rd_clsh)) begin  
               
                bus_rq <= bus_rq_int1 | bus_rq_int2;

                freeze_fsm0 <= 1'b0;
                lsu_op_port1_int <= lsu_op_port1;
                proc_data_in_port1_int <= proc_data_in_port1;
                proc_addr_in_port1_int <= proc_addr_in_port1;
                bus_rdy_int1 <= bus_rdy;
            
                freeze_fsm1 <= 1'b0;
                lsu_op_port2_int <= 5'b0;                    
                proc_addr_in_port2_int <= 32'b0;  
                proc_data_in_port2_int <= 32'b0;
                bus_rdy_int2 <= bus_rdy;
                
                nextState <= HOLD;
                
            end
            else if (bus_clsh) begin
               
                bus_rq <= bus_rq_int1;
            
                freeze_fsm0 <= 1'b0;
                lsu_op_port1_int <= lsu_op_port1;
                proc_addr_in_port1_int <= proc_addr_in_port1;
                proc_data_in_port1_int <= proc_data_in_port1;
                bus_rdy_int1 <= bus_rdy;                    
            
                freeze_fsm1 <= 1'b0;
                lsu_op_port2_int <= lsu_op_port2;                                        
                proc_addr_in_port2_int <= proc_addr_in_port2;
                proc_data_in_port2_int <= proc_data_in_port2;                                        
                bus_rdy_int2 <= 1'b0;
                
                nextState <= BUS_CLSH;
                 
            end
            else begin
                
                bus_rq <= bus_rq_int1 | bus_rq_int2;
               
                freeze_fsm0 <= freeze_int2;
                lsu_op_port1_int <= lsu_op_port1;
                proc_addr_in_port1_int <= proc_addr_in_port1;
                proc_data_in_port1_int <= proc_data_in_port1;
                bus_rdy_int1 <= bus_rdy;
            
                freeze_fsm1 <= freeze_int1;
                lsu_op_port2_int <= lsu_op_port2;
                proc_data_in_port2_int <= proc_data_in_port2;
                proc_addr_in_port2_int <= proc_addr_in_port2;                                                
                bus_rdy_int2 <= bus_rdy;
                
                nextState <= CHECK;
                
            end
        end
        
        BUS_CLSH: begin
            freeze <= freeze_int1 | freeze_int2;
            
            byp_a <= 1'b0;
            byp_b <= 1'b0;    
            
            bus_re <= bus_re_int1 | bus_re_int2;
            bus_we <= bus_we_int1 | bus_we_int2;
            bus_addr <= bus_clsh ? bus_addr_int1 : bus_addr_int2 ;
                        
            freeze_fsm0 <= 1'b0;
            bus_rdy_int1 <= bus_rdy;
            
            freeze_fsm1 <= 1'b0;
            bus_rdy_int2 <= 1'b0;
            
            
            if(~bus_cntrl_int1) begin
            
                bus_rq <= bus_rq_int2;
             
                lsu_op_port1_int <= 5'b0;
                proc_addr_in_port1_int <= 32'b0;
                proc_data_in_port1_int <= 32'b0;
            
                lsu_op_port2_int <= lsu_op_port2_reg;
                proc_addr_in_port2_int <= proc_addr_in_port2_reg;
                proc_data_in_port2_int <= proc_data_in_port2_reg;    
                
                nextState <= BUS_SER;  
                                                  
            end
            else begin
            
                bus_rq <= bus_rq_int1;
            
                lsu_op_port1_int <= lsu_op_port1_reg;
                proc_addr_in_port1_int <= proc_addr_in_port1_reg;
                proc_data_in_port1_int <= proc_data_in_port1_reg;
            
                lsu_op_port2_int <= lsu_op_port2_reg;
                proc_addr_in_port2_int <= proc_addr_in_port2_reg;
                proc_data_in_port2_int <= proc_data_in_port2_reg;  
                
                nextState <= BUS_CLSH; 
                                                     
            end
        end
        
        BUS_SER : begin
            freeze <= freeze_int1 | freeze_int2;
            
            byp_a <= 1'b0;
            byp_b <= 1'b0;   
                         
            bus_re <= bus_re_int1 | bus_re_int2;
            bus_we <= bus_we_int1 | bus_we_int2;
            bus_addr <= bus_addr_int2 ;
                        
            freeze_fsm0 <= 1'b0;
            bus_rdy_int1 <= 1'b0;
            
            freeze_fsm1 <= 1'b0;
            bus_rdy_int2 <= bus_rdy;
            
            if(~bus_cntrl_int2) begin
            
                bus_rq <= bus_rq_int2;
              
                lsu_op_port1_int <= 32'b0;
                proc_addr_in_port1_int <= 32'b0;
                proc_data_in_port1_int <= 32'b0;

                lsu_op_port2_int <= 5'b0;
                proc_addr_in_port2_int <= 32'b0;
                proc_data_in_port2_int <= 32'b0;  
                
                nextState <= CHECK;  
                                                    
            end
            else begin
            
                bus_rq <= bus_rq_int2;
               
                lsu_op_port1_int <= 32'b0;
                proc_addr_in_port1_int <= 32'b0;
                proc_data_in_port1_int <= 32'b0;

                lsu_op_port2_int <= lsu_op_port2_reg;
                proc_addr_in_port2_int <= proc_addr_in_port2_reg;
                proc_data_in_port2_int <= proc_data_in_port2_reg; 
                
                nextState <= BUS_SER;  
                                                      
            end
        end
        
        HOLD: begin
            freeze <= 1'b1;
            
            byp_a <= 1'b0;
            
            bus_re <= bus_re_int1 | bus_re_int2;
            bus_we <= bus_we_int1 | bus_we_int2;
            
            freeze_fsm0 <= 1'b0;
            freeze_fsm1 <= 1'b0;
            
            if(~freeze_int1) begin
            
                byp_b <= 1'b1; 
                
                bus_addr <= bus_addr_int2 ;
                bus_rq <= bus_rq_int1 | bus_rq_int2;
              
                lsu_op_port1_int <= 5'b0;
                proc_data_in_port1_int <= 32'b0;
                proc_addr_in_port1_int <= 32'b0;
                bus_rdy_int1 <= bus_rdy;

                lsu_op_port2_int <= lsu_op_port2_reg;
                proc_addr_in_port2_int <= proc_addr_in_port2_reg;  
                proc_data_in_port2_int <= proc_data_in_port2_reg;
                bus_rdy_int2 <= bus_rdy;   
                
                nextState <= HOLD_2;   
                              
            end
            else begin
            
                byp_b <= 1'b0;
                
                bus_addr <= bus_addr_int1;
                bus_rq <= bus_rq_int1 | bus_rq_int2;
                        
                lsu_op_port1_int <= lsu_op_port1_reg;
                proc_data_in_port1_int <= proc_data_in_port1_reg;
                proc_addr_in_port1_int <= proc_addr_in_port1_reg;
                bus_rdy_int1 <= bus_rdy;

                lsu_op_port2_int <= 5'b0;                    
                proc_addr_in_port2_int <= 32'b0;  
                proc_data_in_port2_int <= 32'b0;
                bus_rdy_int2 <= bus_rdy;
                
                nextState <= HOLD;
                
            end
        end      
          
        HOLD_2: begin
            freeze <= 1'b1;
            
            byp_a <= 1'b0;
            
            bus_re <= bus_re_int1 | bus_re_int2;
            bus_we <= bus_we_int1 | bus_we_int2;
            
            freeze_fsm0 <= 1'b0;
            freeze_fsm1 <= 1'b0;
            
            if(~freeze_int2) begin
            
                byp_b <= 1'b1; 
                
                bus_addr <= bus_addr_int2;
                bus_rq <= bus_rq_int1 | bus_rq_int2;
           
                lsu_op_port1_int <= 5'b0;
                proc_data_in_port1_int <= 32'b0;
                proc_addr_in_port1_int <= 32'b0;
                bus_rdy_int1 <= bus_rdy;

                lsu_op_port2_int <= 5'b0;
                proc_addr_in_port2_int <= 32'b0;  
                proc_data_in_port2_int <= 32'b0;
                bus_rdy_int2 <= bus_rdy;  
                
                nextState <= CHECK;  
                                
            end
            else begin
            
                byp_b <= 1'b0;
                
                bus_addr <= bus_addr_int2;
                bus_rq <= bus_rq_int1 | bus_rq_int2;
                            
                lsu_op_port1_int <= 5'b0;
                proc_data_in_port1_int <= 32'b0;
                proc_addr_in_port1_int <= 32'b0;
                bus_rdy_int1 <= bus_rdy;

                lsu_op_port2_int <= lsu_op_port2_reg;                    
                proc_addr_in_port2_int <= proc_addr_in_port2_reg;  
                proc_data_in_port2_int <= proc_data_in_port2_reg;
                bus_rdy_int2 <= bus_rdy;
                
                nextState <= HOLD_2;
                
            end
        end      
          
        default: begin
            freeze <= 1'b0;
            
            byp_a <= 1'b0;
            byp_b <= 1'b0; 
            
            bus_re <= 1'b0;
            bus_we <= 1'b0;
            bus_addr <= 32'b0;
            bus_rq <= 1'b0;
            
            freeze_fsm0 <= 1'b0;
            lsu_op_port1_int <= 5'b0;
            proc_data_in_port1_int <= 32'b0;
            proc_addr_in_port1_int <= 32'b0;
            bus_rdy_int1 <= bus_rdy;
            
            freeze_fsm1 <= 1'b0;
            lsu_op_port2_int <= 5'b0;
            proc_addr_in_port2_int <= 32'b0;  
            proc_data_in_port2_int <= 32'b0;
            bus_rdy_int2 <= bus_rdy;
            
            nextState <= CHECK;
        end
    endcase;
end



dcache_ram_fsm drf0( .clk(clk),
                     .rst(rst),
                     .Ext_Stall(dtop_freeze),
                     .freeze(freeze_int1),
                     .dcache_fsm_freeze(dtop_freeze | freeze_fsm0 | tlb_freeze_dcache),
                     .cache_flush(cache_flush),
                     .cache_flush_o(cache_flush_int1),
                     .bus_rq(bus_rq_int1),
                     .bus_rdy(bus_rdy_int1),
                     .bus_data(bus_data),
                     .bus_addr(bus_addr_int1),
                     .hit(hit_a),
                     .mis(mis_a),
                     .bus_re(bus_re_int1),
                     .bus_we(bus_we_int1),
                     .Load_Store_op(lsu_op_port1_int),
                     .Load_Data(proc_data_port1_int),
                     .MEM_Addr(proc_addr_in_port1_int),
                     .DCache_Read_Word(dout_a),
                     .DCache_Write_Data_w0(dcache_in_a_w0),
                     .DCache_Write_Data_w1(dcache_in_a_w1),
                     .DCache_Read_Data_w0(dcache_out_a_w0),
                     .DCache_Read_Data_w1(dcache_out_a_w1),
                     .w0_hit(w0_a_hit),
                     .w1_hit(w1_a_hit),
                     .DCache_Addr_w0(dcache_addr_w0_a),
                     .DCache_Addr_w1(dcache_addr_w1_a),
                     .Tag_Write_En_w0(we_tag_a_w0),
                     .Tag_Write_En_w1(we_tag_a_w1),
                     .Tag_Addr_w0(tag_addr_a_w0),
                     .Tag_Addr_w1(tag_addr_a_w1),
                     .Tag_Write_Data_w0(tag_data_a_w0),
                     .Tag_Write_Data_w1(tag_data_a_w1),
                     .Tag_Read_Data_w0(tag_data_a_w0_o),
                     .Tag_Read_Data_w1(tag_data_a_w1_o),
                     .DCache_Write_En_w0(we_data_a_w0),
                     .DCache_Write_En_w1(we_data_a_w1),
                     .tag_comp_w0(w0_a_hit),
                     .tag_comp_w1(w1_a_hit),
                     .Store_Data(proc_data_in_port1_int),
                     .LRU_Read_Data(lru_data_in),
                     .LRU_Addr(lru_addr_int1),
                     .LRU_Write_Data(lru_data_out_int1),
                     .LRU_Write_En(lru_we_int1),
                     .bus_cntrl(bus_cntrl_int1),
                     .proc_rq_o(proc_rq_o_int1),
                     .proc_rq_reg(proc_rq_reg_1),
                     .sc_chkdone(sc_chkdone),
                     .prp_acs(prp_acs0),
                     .fsm_prp_acs(fsm0_prp_acs),
                     .tag_out_tlb(tag_out_tlb_port1),
                     .tag_hit_tlb(tag_hit_tlb_port1),
                     .addr_exception(addr_exception_port1),
                     .Dirty_bit_Addr_w0(Dirty_bit_Addr_a_w0),
                     .Dirty_bit_Addr_w1(Dirty_bit_Addr_a_w1),
                     .Dirty_bit_Read_Data_w0(Dirty_bit_Read_Data_a_w0),
                     .Dirty_bit_Read_Data_w1(Dirty_bit_Read_Data_a_w1),
                     .Dirty_bit_Write_Data_w0(Dirty_bit_Write_Data_a_w0),
                     .Dirty_bit_Write_Data_w1(Dirty_bit_Write_Data_a_w1),
                     .Dirty_bit_Write_En_w0(Dirty_bit_Write_En_a_w0),
                     .Dirty_bit_Write_En_w1(Dirty_bit_Write_En_a_w1));


dcache_ram_fsm drf1( .clk(clk),
                     .rst(rst),
                     .Ext_Stall(dtop_freeze),
                     .freeze(freeze_int2),
                     .dcache_fsm_freeze(dtop_freeze | freeze_fsm1 | tlb_freeze_dcache),
                     .cache_flush(1'b0),
                     .cache_flush_o(cache_flush_int2),
                     .bus_rq(bus_rq_int2),
                     .bus_rdy(bus_rdy_int2),
                     .bus_data(bus_data),
                     .bus_addr(bus_addr_int2),
                     .hit(hit_b),
                     .mis(mis_b),
                     .bus_re(bus_re_int2),
                     .bus_we(bus_we_int2),
                     .Load_Store_op(lsu_op_port2_int),
                     .Load_Data(proc_data_port2_int),
                     .MEM_Addr(proc_addr_in_port2_int),
                     .DCache_Read_Word(dout_b),
                     .DCache_Write_Data_w0(dcache_in_b_w0),
                     .DCache_Write_Data_w1(dcache_in_b_w1),
                     .DCache_Read_Data_w0(dcache_out_b_w0),
                     .DCache_Read_Data_w1(dcache_out_b_w1),
                     .w0_hit(w0_b_hit),
                     .w1_hit(w1_b_hit),
                     .DCache_Addr_w0(dcache_addr_w0_b),
                     .DCache_Addr_w1(dcache_addr_w1_b),
                     .Tag_Write_En_w0(we_tag_b_w0),
                     .Tag_Write_En_w1(we_tag_b_w1),
                     .Tag_Addr_w0(tag_addr_b_w0),
                     .Tag_Addr_w1(tag_addr_b_w1),
                     .Tag_Write_Data_w0(tag_data_b_w0),
                     .Tag_Write_Data_w1(tag_data_b_w1),
                     .Tag_Read_Data_w0(tag_data_b_w0_o),
                     .Tag_Read_Data_w1(tag_data_b_w1_o),
                     .DCache_Write_En_w0(we_data_b_w0),
                     .DCache_Write_En_w1(we_data_b_w1),
                     .tag_comp_w0(w0_b_hit),
                     .tag_comp_w1(w1_b_hit),
                     .Store_Data(proc_data_in_port2_int),
                     .LRU_Read_Data(lru_data_in),
                     .LRU_Addr(lru_addr_int2),
                     .LRU_Write_Data(lru_data_out_int2),
                     .LRU_Write_En(lru_we_int2),
                     .bus_cntrl(bus_cntrl_int2),
                     .proc_rq_o(proc_rq_o_int2),
                     .proc_rq_reg(proc_rq_reg_2),
                     .sc_chkdone(1'b1),
                     .prp_acs(prp_acs1),
                     .fsm_prp_acs(fsm1_prp_acs),
                     .tag_out_tlb(tag_out_tlb_port2),
                     .tag_hit_tlb(tag_hit_tlb_port2),
                     .addr_exception(addr_exception_port2),
                     .Dirty_bit_Addr_w0(Dirty_bit_Addr_b_w0),             
                     .Dirty_bit_Addr_w1(Dirty_bit_Addr_b_w1),             
                     .Dirty_bit_Read_Data_w0(Dirty_bit_Read_Data_b_w0),   
                     .Dirty_bit_Read_Data_w1(Dirty_bit_Read_Data_b_w1),   
                     .Dirty_bit_Write_Data_w0(Dirty_bit_Write_Data_b_w0), 
                     .Dirty_bit_Write_Data_w1(Dirty_bit_Write_Data_b_w1), 
                     .Dirty_bit_Write_En_w0(Dirty_bit_Write_En_b_w0),     
                     .Dirty_bit_Write_En_w1(Dirty_bit_Write_En_b_w1));    
                     

dcache_dpram dd( .rst(rst),
                 .clk(clk),
                 .clk_x2(clk_x2),
                 .dcache_in_a_w0(dcache_in_a_w0),
                 .dcache_in_a_w1(dcache_in_a_w1),
                 .dcache_in_b_w0(dcache_in_b_w0),
                 .dcache_in_b_w1(dcache_in_b_w1),
                 .addr_in_a(proc_addr_in_port1_int),
                 .addr_in_b(proc_addr_in_port2_int),
                 .dcache_addr_w0_a(dcache_addr_w0_a),
                 .dcache_addr_w1_a(dcache_addr_w1_a),
                 .dcache_addr_w0_b(dcache_addr_w0_b),
                 .dcache_addr_w1_b(dcache_addr_w1_b),
                 .we_a_w0(we_data_a_w0),
                 .we_a_w1(we_data_a_w1),
                 .we_b_w0(we_data_b_w0),
                 .we_b_w1(we_data_b_w1),
                 .we_tag_a_w0(we_tag_a_w0),
                 .we_tag_b_w0(we_tag_b_w0),
                 .we_tag_a_w1(we_tag_a_w1),
                 .we_tag_b_w1(we_tag_b_w1),
                 .tag_addr_a_w0(tag_addr_a_w0),
                 .tag_addr_a_w1(tag_addr_a_w1),
                 .tag_addr_b_w0(tag_addr_b_w0),
                 .tag_addr_b_w1(tag_addr_b_w1),
                 .tag_a_w0_o(tag_data_a_w0_o),
                 .tag_b_w0_o(tag_data_b_w0_o),
                 .tag_a_w1_o(tag_data_a_w1_o),
                 .tag_b_w1_o(tag_data_b_w1_o),
                 .lsu_op_port1(lsu_op_port1),
                 .lsu_op_port2(lsu_op_port2),
                 .freeze(freeze_int1 | freeze_int2),
                 .w0_data_a(dcache_out_a_w0),
                 .w0_data_b(dcache_out_b_w0),
                 .w1_data_a(dcache_out_a_w1),
                 .w1_data_b(dcache_out_b_w1),
                 .dout_a(dout_a),
                 .dout_b(dout_b),
                 .hit_a(hit_a),
                 .hit_b(hit_b),
                 .mis_a(mis_a),
                 .mis_b(mis_b),
                 .a_w0_hit(w0_a_hit),
                 .a_w1_hit(w1_a_hit),
                 .b_w0_hit(w0_b_hit),
                 .b_w1_hit(w1_b_hit),
                 .tag_data_a_w0(tag_data_a_w0),
                 .tag_data_a_w1(tag_data_a_w1),
                 .tag_data_b_w0(tag_data_b_w0),
                 .tag_data_b_w1(tag_data_b_w1),
                 .byp_a(byp_a),
                 .byp_b(byp_b),
                 .vpn_to_ppn_req_port1(proc_rq_o_int1),
                 .vpn_to_ppn_req_port2(proc_rq_o_int2),
                 .tag_out_tlb_port1(tag_out_tlb_port1),
                 .tag_out_tlb_port2(tag_out_tlb_port2),
                 .tag_hit_tlb_port1(tag_hit_tlb_port1),
                 .tag_hit_tlb_port2(tag_hit_tlb_port2),
                 .freeze_tlb(dtop_freeze),
                 .tlb_freeze_dcache(tlb_freeze_dcache),
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
                 .wb_dat_o(wb_dat_o),
                 .addr_exception_port1(addr_exception_port1),
                 .addr_exception_port2(addr_exception_port2),
                 .Dirty_bit_Addr_a_w0(Dirty_bit_Addr_a_w0),                     
                 .Dirty_bit_Addr_a_w1(Dirty_bit_Addr_a_w1),                     
                 .Dirty_bit_Read_Data_a_w0(Dirty_bit_Read_Data_a_w0),           
                 .Dirty_bit_Read_Data_a_w1(Dirty_bit_Read_Data_a_w1),           
                 .Dirty_bit_Write_Data_a_w0(Dirty_bit_Write_Data_a_w0),         
                 .Dirty_bit_Write_Data_a_w1(Dirty_bit_Write_Data_a_w1),         
                 .Dirty_bit_Write_En_a_w0(Dirty_bit_Write_En_a_w0),             
                 .Dirty_bit_Write_En_a_w1(Dirty_bit_Write_En_a_w1),           
                 .Dirty_bit_Addr_b_w0(Dirty_bit_Addr_b_w0),                    
                 .Dirty_bit_Addr_b_w1(Dirty_bit_Addr_b_w1),                    
                 .Dirty_bit_Read_Data_b_w0(Dirty_bit_Read_Data_b_w0),          
                 .Dirty_bit_Read_Data_b_w1(Dirty_bit_Read_Data_b_w1),          
                 .Dirty_bit_Write_Data_b_w0(Dirty_bit_Write_Data_b_w0),        
                 .Dirty_bit_Write_Data_b_w1(Dirty_bit_Write_Data_b_w1),        
                 .Dirty_bit_Write_En_b_w0(Dirty_bit_Write_En_b_w0),            
                 .Dirty_bit_Write_En_b_w1(Dirty_bit_Write_En_b_w1));           
                 
                
endmodule        
                           