//******************************************************************************
// Copyright (c) 2014 - 2018, Indian Institute of Science, Bangalore.
// All Rights Reserved. See LICENSE for license details.
//------------------------------------------------------------------------------

// Contributors
// Akshay Birari (akshay@alum.iisc.ac.in), Piyush Birla (piyush@alum.iisc.ac.in)
// Suseela Budi (suseela@alum.iisc.ac.in), Pradeep Gupta (gupta@alum.iisc.ac.in)
// Kavya Sharat (kavyasharat@alum.iisc.ac.in), Sumeet Bandishte (sumeet.bandishte30@gmail.com)
// Kuruvilla Varghese (kuru@iisc.ac.in)
`timescale 1ns/1ps

module or1200_wb_biu(
		     // RISC clock, reset and clock control
		     clk, rst, clmode,freeze,

		     // WISHBONE interface
		     wb_clk_i, wb_rst_i, wb_ack_i, wb_err_i, wb_rty_i, wb_dat_i,
		     wb_cyc_o, wb_adr_o, wb_stb_o, wb_we_o, wb_sel_o, wb_dat_o,
		     wb_cti_o, wb_bte_o,

//to be removed///////////
		     // Internal RISC bus
		     biu_adr_i, biu_cyc_i, biu_stb_i, biu_we_i, biu_sel_i, biu_cab_i,
		     biu_dat_o,
/////////////////////////		     
		     //risc-v proc interface
		     bus_data,bus_rdy,prp_acs);

   parameter dw = 32;
   parameter aw = 32;
   parameter bl = 8; /* Can currently be either 4 or 8 - the two optional line
		      sizes for the OR1200. */
		      
   
   //
   // RISC clock, reset and clock control
   //
   input				clk;		// RISC clock
   input				rst;		// RISC reset
   input [1:0] 				clmode;		// 00 WB=RISC, 01 WB=RISC/2, 10 N/A, 11 WB=RISC/4
   input                freeze;     //Freeze when icache working
   input                prp_acs;    //signal to indicate whether peripheral access or memory access. FSM behaves differently for both 
   //
   // WISHBONE interface
   //
   input				wb_clk_i;	// clock input
   input				wb_rst_i;	// reset input
   input				wb_ack_i;	// normal termination
   input				wb_err_i;	// termination w/ display
   input				wb_rty_i;	// termination w/ retry
   input [dw-1:0] 			wb_dat_i;	// input data bus
   output				wb_cyc_o;	// cycle valid output
   output [aw-1:0] 			wb_adr_o;	// address bus outputs
   output				wb_stb_o;	// strobe output
   output				wb_we_o;	// indicates write transfer
   output [3:0] 			wb_sel_o;	// byte select outputs for the signals-byte select and extend
   output [dw-1:0] 			wb_dat_o;	// output data bus
   output [2:0] 			wb_cti_o;	// cycle type identifier
   output [1:0]             wb_bte_o;   // burst type identifier(00 here because we only have linear burst support presently)
   //
   // Internal RISC interface
   //
   input [aw-1:0] 			biu_adr_i;	// address bus
   input				biu_cyc_i;	// WB cycle
   input				biu_stb_i;	// WB strobe
   input				biu_we_i;	// WB write enable
   input				biu_cab_i;	// CAB input
   input [3:0] 				biu_sel_i;	// byte selects
   output [31:0] 			biu_dat_o;	// output data bus
   output reg           bus_rdy;   //interface to the dcache unit

   //riscv-proc interface
   inout [255:0] bus_data;          //to be able to communicate with proc interface
//   output [255:0] bus_data_o;          //to be able to communicate with proc interface
   //
   //register to concatenate the words
   reg [255:0] bus_reg;
   
   //
   // Registers
   //
   wire 				wb_ack;		// normal termination
   reg [aw-1:0] 			wb_adr_o;	// address bus outputs
   reg 					wb_cyc_o;	// cycle output
   reg 					wb_stb_o;	// strobe output
   reg 					wb_we_o;	// indicates write transfer
   reg [3:0] 				wb_sel_o;	// byte select outputs
   reg [2:0] 				wb_cti_o;	// cycle type identifier
   reg [1:0] 				wb_bte_o;	// burst type extension
   reg [dw-1:0]             wb_dat_o;
   
   reg [3:0] 				burst_len;	// burst counter

   wire                 biu_ack_o;
   reg  				biu_stb_reg;	// WB strobe
   wire  				biu_stb;	// WB strobe
   reg 					wb_cyc_nxt;	// next WB cycle value
   reg 					wb_stb_nxt;	// next WB strobe value
   reg [2:0] 				wb_cti_nxt;	// next cycle type identifier value
   
   reg 					wb_ack_cnt;	// WB ack toggle counter
   reg 					wb_err_cnt;	// WB err toggle counter
   reg 					wb_rty_cnt;	// WB rty toggle counter
   reg 					biu_ack_cnt;	// BIU ack toggle counter
   reg 					biu_err_cnt;	// BIU err toggle counter
   reg 					biu_rty_cnt;	// BIU rty toggle counter
   wire 				biu_rty;	// BIU rty indicator

   reg [1:0] 				wb_fsm_state_cur;	// WB FSM - current state
   reg [1:0] 				wb_fsm_state_nxt;	// WB FSM - next state
   wire [1:0] 				wb_fsm_idle	= 2'h0;	// WB FSM state - IDLE
   wire [1:0] 				wb_fsm_trans	= 2'h1;	// WB FSM state - normal TRANSFER
   wire [1:0] 				wb_fsm_last	= 2'h2;	// EB FSM state - LAST transfer
   reg                  prp_acs_int;        //Latch the peripheral access signal

   //
   // WISHBONE I/F <-> Internal RISC I/F conversion
   //
   //assign wb_ack = wb_ack_i;
   assign wb_ack = wb_ack_i & !wb_err_i & !wb_rty_i;            //notmal termination only if no display.

   //
   // WB FSM - register part
   // 
   always @(posedge wb_clk_i ) begin
      if (wb_rst_i) 
	wb_fsm_state_cur <=  wb_fsm_idle;
      else if(~freeze) 
	wb_fsm_state_cur <=  wb_fsm_state_nxt;                      //next state becomes current state on clock posedge
   end

   assign bus_data = biu_we_i ? 256'bz : bus_reg;
    
    always @(posedge clk) begin
        if(~prp_acs) begin
            case(burst_len)
                4'b0110: begin
                    bus_reg[31:0] <= wb_dat_i;
                end               
                4'b0101: begin            
                    bus_reg[63:32] <= wb_dat_i;
                end
                4'b0100: begin
                    bus_reg[95:64] <= wb_dat_i;        
                end
                4'b0011: begin
                    bus_reg[127:96] <= wb_dat_i;            
                end              
                4'b0010: begin
                    bus_reg[159:128] <= wb_dat_i;
                end               
                4'b0001: begin            
                    bus_reg[191:160] <= wb_dat_i;
                end
                4'b0000: begin
                    bus_reg[223:192] <= wb_dat_i;        
                end
                4'b1111: begin
                    bus_reg[255:224] <= wb_dat_i;            
                end              
                default: begin
                    bus_reg <= bus_reg;
                end
            endcase;
        end
        else begin
            case(biu_adr_i[4:2])
                3'b000:bus_reg[31:0] <= wb_dat_i;
                3'b001:bus_reg[63:32] <= wb_dat_i;                
                3'b010:bus_reg[95:64] <= wb_dat_i;                
                3'b011:bus_reg[127:96] <= wb_dat_i;                
                3'b100:bus_reg[159:128] <= wb_dat_i;                
                3'b101:bus_reg[191:160] <= wb_dat_i;                
                3'b110:bus_reg[223:192] <= wb_dat_i;                
                3'b111:bus_reg[255:224] <= wb_dat_i;
                default: bus_reg <= 0;                
            endcase;
        end
    end

   //
   // WB burst tength counter
   // 
   always @(posedge wb_clk_i ) begin
      if (wb_rst_i) begin
	 burst_len <= 0;
      end
      else if(~freeze) begin
	 // burst counter
	 if (wb_fsm_state_cur == wb_fsm_idle)
	   burst_len <=  bl[3:0] - 2;
	 else if (wb_stb_o & wb_ack)
	   burst_len <=  burst_len - 1;
      end
   end

   // 
   // WB FSM - combinatorial part
   // 
   always @(*) begin
      // States of WISHBONE Finite State Machine
      case(wb_fsm_state_cur)
	// IDLE 
	wb_fsm_idle : begin
	   wb_cyc_nxt <= biu_cyc_i & biu_stb;
	   wb_stb_nxt <= biu_cyc_i & biu_stb;
	   wb_cti_nxt <= biu_cyc_i & biu_stb ? {prp_acs | !biu_cab_i, 1'b1,prp_acs | !biu_cab_i} : 3'b000;
	   if (biu_cyc_i & biu_stb)
	     if(prp_acs) begin
	       wb_fsm_state_nxt <= wb_fsm_last;
	     end
	     else begin
	       wb_fsm_state_nxt <= wb_fsm_trans;
	     end
	   else
	     wb_fsm_state_nxt <= wb_fsm_idle;
	end
	// normal TRANSFER
	wb_fsm_trans : begin
	   wb_cyc_nxt <= !wb_stb_o | !wb_err_i & !wb_rty_i & !(wb_ack & (prp_acs | wb_cti_o == 3'b111));	   
	   wb_stb_nxt <= !wb_stb_o | !wb_err_i & !wb_rty_i & !wb_ack | !wb_err_i & !wb_rty_i & (~prp_acs & wb_cti_o == 3'b010) ;
	   wb_cti_nxt[2] <= wb_stb_o & wb_ack & burst_len == 'h0 | wb_cti_o[2];
	   wb_cti_nxt[1] <= 1'b1  ;
	   wb_cti_nxt[0] <= wb_stb_o & wb_ack & burst_len == 'h0 | wb_cti_o[0];
	   if ((!biu_cyc_i | !biu_stb | !biu_cab_i | biu_sel_i != wb_sel_o | biu_we_i != wb_we_o) & ~prp_acs & wb_cti_o == 3'b010)
	     wb_fsm_state_nxt <= wb_fsm_last;
	   else if ((wb_err_i | wb_rty_i | wb_ack)& wb_stb_o) begin
	     if(prp_acs) begin
	       wb_fsm_state_nxt <= wb_fsm_idle;
	     end
	     else if(wb_cti_o == 3'b111) begin
	       wb_fsm_state_nxt <= wb_fsm_idle;
	     end  
	     else
	       wb_fsm_state_nxt <= wb_fsm_trans;
	   end
	   else 
           wb_fsm_state_nxt <= wb_fsm_trans;
	end
	
	// LAST transfer
	wb_fsm_last : begin
	   wb_cyc_nxt <= !wb_stb_o | !wb_err_i & !wb_rty_i & !(wb_ack & wb_cti_o == 3'b111);
	   wb_stb_nxt <= !wb_stb_o | !wb_err_i & !wb_rty_i & !(wb_ack & wb_cti_o == 3'b111);
	   wb_cti_nxt[2] <= wb_ack & wb_stb_o | wb_cti_o[2];
	   wb_cti_nxt[1] <= 1'b1;
	   wb_cti_nxt[0] <= wb_ack & wb_stb_o | wb_cti_o[0];
	   if (((wb_err_i | wb_rty_i | wb_ack) & wb_cti_o == 3'b111) & wb_stb_o)
	     wb_fsm_state_nxt <= wb_fsm_idle;
	   else
	     wb_fsm_state_nxt <= wb_fsm_last;
	end
	// default state
	default:begin
	   wb_cyc_nxt <= 1'b0;
	   wb_stb_nxt <= 1'b0;
	   wb_cti_nxt <= 3'b111;
	   wb_fsm_state_nxt <= 2'b00;
	end
      endcase
   end

   //
   // WB FSM - output signals
   // 
   always @(posedge wb_clk_i) begin
      if (wb_rst_i) begin
	 wb_cyc_o	<=  1'b0;
	 wb_stb_o	<=  1'b0;
	 wb_cti_o	<=  3'b111;
	 wb_bte_o	<=  2'b00;
	 wb_we_o		<=  1'b0;
	 wb_sel_o	<=  4'hf;
	 wb_adr_o	<=  {aw{1'b0}};
      end
      else if(~freeze) begin
	 wb_cyc_o	<=  wb_cyc_nxt;
         if (wb_ack & wb_cti_o == 3'b111) 
           wb_stb_o        <=  1'b0;
         else
           wb_stb_o        <=  wb_stb_nxt;
           wb_cti_o   <=  wb_cti_nxt; 
	 wb_bte_o	<= 2'b00;
	 // we and sel - set at beginning of access 
	 if (wb_fsm_state_cur == wb_fsm_idle) begin
	    wb_we_o		<=  biu_we_i;
	    wb_sel_o	<=  biu_sel_i;
	 end
	 // adr - set at beginning of access and changed at every termination 
	 if (wb_fsm_state_cur == wb_fsm_idle) begin
	    wb_adr_o	<=  biu_adr_i;
	 end 
	 else if (wb_stb_o & wb_ack) begin
	    if (bl==4) begin
	       wb_adr_o[3:2]	<=  wb_adr_o[3:2] + 1;
	    end
	    if (bl==8) begin
	       wb_adr_o[4:2]	<=  wb_adr_o[4:2] + 1;
	    end
	 end
      end
   end

   //
   // WB & BIU termination toggle counters
   // 
   always @(posedge wb_clk_i ) begin
      if (wb_rst_i) begin
	 wb_ack_cnt	<=  1'b0;
	 wb_err_cnt	<=  1'b0;
	 wb_rty_cnt	<=  1'b0;
      end
      else if(~freeze) begin
	 // WB ack toggle counter
	 if (wb_fsm_state_cur == wb_fsm_idle | !(|clmode))
	   wb_ack_cnt	<=  1'b0;
	 else if (wb_stb_o & wb_ack)
	   wb_ack_cnt	<=  !wb_ack_cnt;
	 // WB err toggle counter
	 if (wb_fsm_state_cur == wb_fsm_idle | !(|clmode))
	   wb_err_cnt	<=  1'b0;
	 else if (wb_stb_o & wb_err_i)
	   wb_err_cnt	<=  !wb_err_cnt;
	 // WB rty toggle counter
	 if (wb_fsm_state_cur == wb_fsm_idle | !(|clmode))
	   wb_rty_cnt	<=  1'b0;
	 else if (wb_stb_o & wb_rty_i)
	   wb_rty_cnt	<=  !wb_rty_cnt;
      end
   end

   always @(posedge clk ) begin
      if (rst) begin
         biu_stb_reg	<=  1'b0;
         biu_ack_cnt	<=  1'b0;
         biu_err_cnt	<=  1'b0;
         biu_rty_cnt	<=  1'b0;
      end
      else if(~freeze) begin
         // BIU strobe
         if (biu_stb_i & !biu_cab_i & biu_ack_o)
           biu_stb_reg	<=  1'b0;
         else
            biu_stb_reg	<=  biu_stb_i;
            // BIU ack toggle counter
        if (wb_fsm_state_cur == wb_fsm_idle | !(|clmode))
            biu_ack_cnt	<=  1'b0 ;
        else if (biu_ack_o)
            biu_ack_cnt	<=  !biu_ack_cnt ;
        // BIU err toggle counter
        if (wb_fsm_state_cur == wb_fsm_idle | !(|clmode))
            biu_err_cnt	<=  1'b0 ;
        else if (wb_err_i)
            biu_err_cnt	<=  !biu_err_cnt ;
        // BIU rty toggle counter
        if (wb_fsm_state_cur == wb_fsm_idle | !(|clmode))
            biu_rty_cnt	<=  1'b0 ;
        else if (biu_rty)
            biu_rty_cnt	<=  !biu_rty_cnt ;
        end
end


always @( posedge clk) begin
    if(rst) begin
        bus_rdy <= 1'b1;
    end
    else if((biu_stb_i | biu_cyc_i) & (~freeze)) begin
        if(prp_acs) begin
            bus_rdy <= wb_ack_i;
        end
        else if(~prp_acs & (burst_len == 4'b1111)) begin
            bus_rdy <= 1'b1;
        end
        else begin
            bus_rdy <= 1'b0;
        end
    end
end



   assign biu_stb = biu_stb_i & biu_stb_reg;

   //
   // Input BIU data bus
   //
   assign	biu_dat_o	= wb_dat_i;

   //
   // Input BIU termination signals 
   //
   assign	biu_rty		= (wb_fsm_state_cur == wb_fsm_trans) & wb_rty_i & wb_stb_o & (wb_rty_cnt ~^ biu_rty_cnt);
   assign   biu_ack_o	    = (wb_fsm_state_cur == wb_fsm_trans) & wb_ack & wb_stb_o & (wb_ack_cnt ~^ biu_ack_cnt);    
`ifdef OR1200_WB_RETRY
     | biu_rty & retry_cnt[`OR1200_WB_RETRY-1];
`endif



// processor output bus
always @(*) begin
     if(rst) begin
         wb_dat_o <= 32'd0;
     end
     else begin
        if(~prp_acs) begin
            case(burst_len[2:0])                    //using only the last 2 bits of burst len so that glitches are less. Also decreases the comparator size
                3'b110:    wb_dat_o <= bus_data[31:0];
                3'b101:    wb_dat_o <= bus_data[63:32];
                3'b100:    wb_dat_o <= bus_data[95:64];
                3'b011:    wb_dat_o <= bus_data[127:96];
                3'b010:    wb_dat_o <= bus_data[159:128];
                3'b001:    wb_dat_o <= bus_data[191:160];
                3'b000:    wb_dat_o <= bus_data[223:192];
                3'b111:    wb_dat_o <= bus_data[255:224];
                default:    wb_dat_o <= 32'b0;            
            endcase;
        end
        else begin
            case(biu_adr_i[4:2]) 
                3'b000: wb_dat_o <= bus_data[31:0];
                3'b001: wb_dat_o <= bus_data[63:32];
                3'b010: wb_dat_o <= bus_data[95:64];
                3'b011: wb_dat_o <= bus_data[127:96];
                3'b100: wb_dat_o <= bus_data[159:128];
                3'b101: wb_dat_o <= bus_data[191:160];
                3'b110: wb_dat_o <= bus_data[223:192];
                3'b111: wb_dat_o <= bus_data[255:224];
                default: wb_dat_o <= 32'b0;
            endcase;
        end
    end
end

endmodule
