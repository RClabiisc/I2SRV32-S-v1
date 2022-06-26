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




module csr
(
    input clk,
    input rst,
    
    input [11:0] csr_adr_wr,
    input [31:0] csr_wrdata,
    input csr_wr_en,
    
    input [11:0] csr_adr_rd,
    output reg [31:0] csr_rddata,
    output reg [31:0] csr_mtvec,
    output mtie,
    
    input mret,
    input badaddr,
    input trap_en,
    input mepc_res,
    input addr_exception,    
    input freeze, 
    
    input FPU_Inst,
    input [4:0] FPU_flags,
    output [2:0] frm,
    
    input [31:0] pc_id_ex
          
);


reg [31:0] csr_mepc;   
reg [31:0] csr_mepc_shadow;   
reg [31:0] csr_mstatus;  
reg [31:0] csr_mcause;
reg [31:0] csr_mie;
reg [31:0] csr_misa;
reg [31:0] csr_medeleg;
reg [31:0] csr_mideleg;
reg [31:0] csr_mbadaddr;
reg [1:0] cur_prev_mode; 
reg mret1;

reg [31:0] csr_fcsr;


assign mtie = csr_mstatus[3] && csr_mie[7];                         //assign mtie = csr_mie[7];

assign frm = csr_fcsr[7:5];

always @(posedge clk) begin
    if(rst) 
        csr_mepc = 32'b0;
    else if(trap_en || ( csr_wr_en && (csr_adr_wr == `mepc)))
        csr_mepc <= csr_wrdata;                                     // when exception happens store pc to mepd which is csr[0]
    else if(mepc_res)          
        csr_mepc <= csr_mepc_shadow;                                // restore MEPC to mepc_shadow value
end


always @(posedge clk) begin
    if(rst) 
        csr_mepc_shadow = 32'b0;
    else if(trap_en || ( csr_wr_en && (csr_adr_wr == `mepc)))
        csr_mepc_shadow <= csr_mepc;                                // when exception happens store pc to mepd which is csr[0]
    else if( csr_wr_en && (csr_adr_wr == `mepc_shadow))
        csr_mepc_shadow <= csr_wrdata;                              // when exception happens store pc to mepd which is csr[0]
end


always @(posedge clk) begin
    if(rst) 
        csr_mstatus = `mstatus_default;
    /*else if(mret) begin
        case(csr_mstatus[12:11])
            2'b00 : csr_mstatus <= {csr_mstatus[31:13],2'b11,csr_mstatus[10:8],1'b1,csr_mstatus[6:1],csr_mstatus[7]};
            2'b01 : csr_mstatus <= {csr_mstatus[31:13],2'b11,csr_mstatus[10:8],1'b1,csr_mstatus[6:2],csr_mstatus[7],csr_mstatus[0]};
            2'b10 : csr_mstatus <= {csr_mstatus[31:13],2'b11,csr_mstatus[10:8],1'b1,csr_mstatus[6:3],csr_mstatus[7],csr_mstatus[1:0]};
            2'b11 : csr_mstatus <= {csr_mstatus[31:13],2'b11,csr_mstatus[10:8],1'b1,csr_mstatus[6:4],csr_mstatus[7],csr_mstatus[2:0]};
        endcase
    end  */   
    else if( csr_wr_en && (csr_adr_wr == `mstatus))
        csr_mstatus <= csr_wrdata;  
end


always @(posedge clk) begin
    if(rst) 
        csr_mtvec = `mtvec_default;
    else if(csr_wr_en && (csr_adr_wr == `mtvec))
        csr_mtvec <= {csr_wrdata[31:2], 2'b0};                      // lower two bits should be zero 
end


always @(posedge clk) begin
    if(rst) 
        csr_mcause = `mcause_default;
    else if(addr_exception)
            csr_mcause = 32'b01;
    else if(csr_wr_en && (csr_adr_wr == `mcause))
        csr_mcause <= csr_wrdata;                                   // ***Mcause is WLRL not required to be updated in hardware 
end


always @(posedge clk) begin
    if(rst) 
        csr_mie = `mie_default;
    else if( csr_wr_en && (csr_adr_wr == `mie))
        csr_mie <= ((csr_wrdata) & (`mie_mask)) ;                  
end


always @(posedge clk) begin
    if(rst) 
        csr_mbadaddr = `mbadaddr_default;
    else if(badaddr || addr_exception)
        csr_mbadaddr <= pc_id_ex ;                                  
    else if( csr_wr_en && (csr_adr_wr == `mbadaddr))
        csr_mbadaddr <= csr_wrdata; 
end


always @(posedge clk) begin
    if(rst) 
        csr_misa = `misa_default;
    else if( csr_wr_en && (csr_adr_wr == `misa))
        csr_misa <= (csr_wrdata[29:0] && `misa_mask) ;          
end


always @(posedge clk) begin
    if(rst) 
        csr_medeleg = `medeleg_default;                             //  this will be writable as other modes will be implemented 
end


always @(posedge clk) begin
    if(rst) 
        csr_mideleg = `mideleg_default;                             //  this will be writable as other modes will be implemented 
end


always @(posedge clk) begin
    if(rst) 
        csr_fcsr = `mtvec_default;
    else if(csr_wr_en && (csr_adr_wr == `fcsr))
        csr_fcsr[7:0] <= csr_wrdata; 
    else if(csr_wr_en && (csr_adr_wr == `frm))
        csr_fcsr[7:5] <= csr_wrdata; 
    else if(csr_wr_en && (csr_adr_wr == `fflags))
        csr_fcsr[4:0] <= csr_wrdata; 
    else if(FPU_Inst)
        csr_fcsr[4:0] <= FPU_flags; 
end


always @(posedge clk) begin
    if(rst) begin
        csr_rddata = 32'b0;
    end   
    else if(~freeze)
    begin
        if(csr_adr_rd == `mepc) begin
            csr_rddata = csr_mepc;
        end
        else if(csr_adr_rd == `mepc_shadow) begin
            csr_rddata = csr_mepc_shadow;
        end
        else if(csr_adr_rd == `mstatus) begin
            csr_rddata = csr_mstatus;
        end
        else if(csr_adr_rd == `mtvec) begin
            csr_rddata = csr_mtvec;
        end
        else if(csr_adr_rd == `mcause) begin
            csr_rddata = csr_mcause;
        end
        else if(csr_adr_rd == `mie) begin
            csr_rddata = csr_mie;
        end
        else if(csr_adr_rd == `misa) begin
            csr_rddata = csr_misa;
        end
        else if(csr_adr_rd == `medeleg) begin
            csr_rddata = csr_medeleg;
        end
        else if(csr_adr_rd == `mideleg) begin
            csr_rddata = csr_mideleg;
        end
        else if(csr_adr_rd == `mbadaddr) begin
            csr_rddata = csr_mbadaddr;
        end
        else if(csr_adr_rd == `fflags) begin
            csr_rddata = csr_fcsr[4:0];
        end
        else if(csr_adr_rd == `frm) begin
            csr_rddata = csr_fcsr[7:5];
        end
        else if(csr_adr_rd == `fcsr) begin
            csr_rddata = csr_fcsr[7:0];
        end
        else if((csr_adr_rd == `mvendorid) && (csr_adr_rd == `marchid) && (csr_adr_rd == `mimpid) && (csr_adr_rd == `mhartid)) begin
            csr_rddata = 32'b0;                                             //  to mention these registers ar enot implemented
        end
        else begin
            csr_rddata = 32'b0;
        end    
    end
end
 
    
always @(posedge clk) begin
    if(rst) 
        cur_prev_mode <= 2'b11;
end

endmodule
     