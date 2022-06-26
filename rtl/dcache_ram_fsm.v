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



module dcache_ram_fsm
(   
    input clk,
    input rst,
    
    input [4:0] Load_Store_op,                      // Load_store operation from pipeline
    input [31:0] MEM_Addr,                          // Data Memory Address from pipeline MEM stage
    input [31:0] Store_Data,                        // Store Data from pipeline
    output reg [31:0] Load_Data,                    // Load Data to pipeline

    output reg [6:0] DCache_Addr_w0,                // Dcache Address 
    output reg [6:0] DCache_Addr_w1,                // Dcache Address 
    input [255:0] DCache_Read_Data_w0,              // Dcache data output
    input [255:0] DCache_Read_Data_w1,              // Dcache data output
    input [31:0] DCache_Read_Word,                  // Dcache data output
    output reg [255:0] DCache_Write_Data_w0,        // Dcache data input
    output reg [255:0] DCache_Write_Data_w1,        // Dcache data input
    output reg [31:0] DCache_Write_En_w0,           // Dcache data write enable for 32 bytes
    output reg [31:0] DCache_Write_En_w1,           // Dcache data write enable for 32 bytes
    
    input hit,                                      // Dcache hit
    input mis,                                      // Dcache miss
    input w0_hit,                                   // Dcache hit for wo    
    input w1_hit,                                   // Dcache hit for w1
    input tag_comp_w0,                              // Dcache hit for wo 
    input tag_comp_w1,                              // Dcache hit for w1
        
    output reg [6:0] Tag_Addr_w0,                   // Tag ram Address
    output reg [6:0] Tag_Addr_w1,                   // Tag ram Address
    input [31:0] Tag_Read_Data_w0,                  // Tag ram data output
    input [31:0] Tag_Read_Data_w1,                  // Tag ram data output
    output reg [31:0] Tag_Write_Data_w0,            // Tag ram data input
    output reg [31:0] Tag_Write_Data_w1,            // Tag ram data input
    output reg [3:0] Tag_Write_En_w0,               // Tag ram write enable
    output reg [3:0] Tag_Write_En_w1,               // Tag ram write enable
    
    output reg [6:0] Dirty_bit_Addr_w0,             
    output reg [6:0] Dirty_bit_Addr_w1,             
    input Dirty_bit_Read_Data_w0,                   
    input Dirty_bit_Read_Data_w1,                   
    output reg Dirty_bit_Write_Data_w0,             
    output reg Dirty_bit_Write_Data_w1,             
    output reg Dirty_bit_Write_En_w0,               
    output reg Dirty_bit_Write_En_w1,               
   
    
    
    input [25:0] tag_out_tlb,                       // TLB tag output
    input tag_hit_tlb,                              // TLB tag hit
 
    input [1:0] LRU_Read_Data,                      // LRU output          
    output reg [6:0] LRU_Addr,                      // LRU address
    output reg [1:0] LRU_Write_Data,                // LRU input
    output reg LRU_Write_En,                        // LRU write enable
    
    output reg bus_rq,
    output reg bus_re,
    output reg bus_we,
    input bus_rdy,
    inout [255:0] bus_data,
    output reg [31:0] bus_addr,
    output reg bus_cntrl,
    
    input addr_exception,
    input prp_acs,                                  // Memory address is in peripheral address range
    output reg proc_rq_o,                           // Load store request
    output reg proc_rq_reg,
    
    input sc_chkdone,                               //For SC instruction, not violation has taken place. Else do not store result.
    output reg fsm_prp_acs,
    
    
    input Ext_Stall,
    input dcache_fsm_freeze,
    output reg freeze,
    

    input cache_flush,
    output cache_flush_o
);



parameter offset_start_bit = 0;
parameter offset_last_bit = 4;
parameter index_start_bit = 5;
parameter index_last_bit = 11;
parameter tag_start_bit = 12;
parameter tag_last_bit = 31;
parameter vpn_width = 20;

localparam START = 3'b000;
localparam WT_HIT = 3'b001;
localparam GET_MEM_DATA = 3'b010;
localparam WB_CYC_GAP = 3'b101;             //additional state to accomodate for one cycle gap between consecutive read/writes on the bus while writeback
localparam REPLACE = 3'b011;
localparam WAIT = 3'b100;
localparam FLUSH_COUNT_INCR = 3'b110;
localparam TAG_CLEAR = 3'b111;

wire [31:0] dcache_data_int;
reg [4:0] Load_Store_op__reg;                       //save the signal for the entire duration that mem operation is performed
reg [2:0] state,nextState,prev_state;
reg Read__reg,Write__reg,Write__reg__reg;
wire Read,Write;
reg prp_acs_int;
reg [31:0] MEM_Addr__reg;
reg [31:0] proc_addr_int2;
reg [31:0] Store_Data__reg;
wire Load_Store__req;
reg Load_Store__req__reg;
reg [31:0] tag_data_w0_int;
reg [31:0] tag_data_w1_int;

                        
reg [7:0] flush_count;                      //Cache Flushing Operation Specific Signals
reg cache_flush_int;                        //Cache Flushing Operation Specific Signals


wire [31:0] store_map[0:3];
reg [1:0] lru_data_int;
reg [31:0] proc_data_buff;
wire [255:0] write_buff;
wire [255:0] read_buff;
reg [255:0] write_buff_int;
wire [63:0] store_mask[0:3];
wire [255:0] load_mask[0:3];
reg [31:0] wb_adr_o;
wire [31:0] wb_adr_int;
reg bus_data_en;
reg bus_data_en_reg;
reg [31:0] tag_w0_reg;
reg [31:0] tag_w1_reg;
reg [19:0] tag_out_tlb_int;


reg [255:0] bus_cache_buff;
reg [255:0] queue_data_bus;
reg [31:0] queue_addr_bus;

reg [31:0] Store_Addr__Buffer;
reg [31:0] Store_Data__Buffer;
reg [4:0] Store_Op__Buffer;
reg [31:0] Store_Tag_w0__Buffer;
reg [31:0] Store_Tag_w1__Buffer;
reg Store_Buffer_Valid;
reg Store_Buffer_Valid__reg;
reg Store_w0_hit_Buffer;
reg Store_w1_hit_Buffer;
reg Store_addr_exception_Buffer;
reg [1:0] Store_LRU_Read_Data_Buffer;
reg Store_Buffer_Write;
reg [255:0] Store_Write_Buffer;

reg [255:0] DCache_Write_Data_w0_temp;
reg [255:0] DCache_Write_Data_w1_temp;

reg Dirty_bit_Read_Data_w0_reg;
reg Dirty_bit_Read_Data_w1_reg;

reg [1:0] LRU_Read_Data__reg;


integer i,j,k;
integer i__store,j__store,k__store;
integer i__store_buff,j__store_buff,k__store_buff;

always @(*) begin
    i__store <= Load_Store_op__reg[4:2];
    j__store <= MEM_Addr__reg[4:2];
    k__store <= MEM_Addr__reg[1:0];
    
    i__store_buff <= Store_Op__Buffer[4:2];         
    j__store_buff <= Store_Addr__Buffer[4:2];              
    k__store_buff <= Store_Addr__Buffer[1:0];
end


assign    store_map[0] = 32'b0000000000000001;         //store byte in cache       used in generating write enable signal    
assign    store_map[1] = 32'b0000000000000011;         //store half word in cache  used in generating write enable signal 
assign    store_map[2] = 32'b0000000000001111;         //store word in cache       used in generating write enable signal    
assign    store_map[3] = 32'b0000000000001111;         //store word in cache       used in generating write enable signal    
assign    store_mask[0] = 32'h000000FF;                //store byte in cache 
assign    store_mask[1] = 32'h0000FFFF;                //store half word in cache
assign    store_mask[2] = 32'hFFFFFFFF;                //store word in cache
assign    store_mask[3] = 32'hFFFFFFFF;                //store word in cache
assign    load_mask[0] = 256'h00000000000000000000000000000000000000000000000000000000000000FF; 
assign    load_mask[1] = 256'h000000000000000000000000000000000000000000000000000000000000FFFF;
assign    load_mask[2] = 256'h00000000000000000000000000000000000000000000000000000000FFFFFFFF;
assign    load_mask[3] = 256'h00000000000000000000000000000000000000000000000000000000FFFFFFFF;
assign    load_mask[4] = 256'h00000000000000000000000000000000000000000000000000000000000000FF; 
assign    load_mask[5] = 256'h000000000000000000000000000000000000000000000000000000000000FFFF;






assign Load_Store__req = (sc_chkdone) & (Load_Store_op[1] ^ Load_Store_op[0]) & (~prp_acs) & ( ~freeze) ;    

assign write_buff = (256'b0 | (((((state == START) || (state == WT_HIT)) ? Store_Data : Store_Data__reg) & store_mask[i]) << (j << 5) << (k << 3)));

assign read_buff = (write_buff_int & ((load_mask[i]) << (j << 5) << (k << 3))) | (bus_data & ~((load_mask[i]) << (j << 5) << (k << 3))); 

//always @(posedge clk) begin
//    if(rst)
//        read_buff = 32'b0; 
//    else if(state == GET_MEM_DATA)
//        read_buff = (write_buff_int & ((load_mask[i]) << (j << 5) << (k << 3))) | (bus_data & ~((load_mask[i]) << (j << 5) << (k << 3))); 
//end

//assign proc_data_buff = (bus_data >> (j__store << 5)) >> (k__store << 3); 

always @(posedge clk) begin
    if(rst)
        proc_data_buff = 32'b0; 
    else if(state == GET_MEM_DATA)
        proc_data_buff = (bus_data >> (j__store << 5)) >> (k__store << 3); 
end


assign cache_flush_o = cache_flush_int;

assign Read = (~Load_Store_op[1]) & (Load_Store_op[0]);
assign Write = (Load_Store_op[1]) & (~Load_Store_op[0]);

always @(*) begin
    if(rst) begin
        fsm_prp_acs <= 1'b0;
        proc_rq_o <= 1'b0;
    end
    else begin
        fsm_prp_acs <= prp_acs_int;
        proc_rq_o <= Load_Store__req;
    end
end

always @(posedge clk) begin
    if(rst) begin
        proc_rq_reg <= 1'b0;
    end
    else begin
        proc_rq_reg <= Load_Store__req;
    end
end
// Store Buffer


always @(posedge clk) begin
    if(rst) begin        
        Store_Addr__Buffer <= 32'b0; 
        Store_Data__Buffer <= 32'b0; 
        Store_Op__Buffer <= 5'b0;  
        Store_Tag_w0__Buffer <= 32'b0; 
        Store_Tag_w1__Buffer <= 32'b0; 
        Store_Buffer_Valid__reg <= 1'b0;
        Store_w0_hit_Buffer <= 1'b0;
        Store_w1_hit_Buffer <= 1'b0;
        Store_addr_exception_Buffer <= 1'b0;
        Store_Write_Buffer <= 256'b0;
    end
    else begin
        if(Load_Store__req & Write) begin
            Store_Addr__Buffer <= MEM_Addr; 
            Store_Data__Buffer <= Store_Data; 
            Store_Op__Buffer <= Load_Store_op; 
            Store_Write_Buffer <= write_buff;
        end 
        if (Load_Store__req__reg & Write__reg) begin
            Store_Tag_w0__Buffer <= Tag_Read_Data_w0; 
            Store_Tag_w1__Buffer <= Tag_Read_Data_w1;
            Store_w0_hit_Buffer <= tag_comp_w0; 
            Store_w1_hit_Buffer <= tag_comp_w1; 
            Store_addr_exception_Buffer <= addr_exception;
            Store_LRU_Read_Data_Buffer <= LRU_Read_Data;
        end   
        
        Store_Buffer_Valid__reg <= Store_Buffer_Valid;
    end
end

always @(posedge clk ) begin
    if(rst) begin
        MEM_Addr__reg <= 32'b0;
        Store_Data__reg <= 32'b0;
        Load_Store_op__reg <= 5'b0;
        Read__reg <= 1'b0;
        Write__reg <= 1'b0;
        Write__reg__reg <= 1'b0;
        tag_data_w0_int <= 32'b0;
        tag_data_w1_int <= 32'b0;
        lru_data_int <= 2'b00;
        write_buff_int <= 256'b0;
        prp_acs_int <= 1'b0;
        Load_Store__req__reg <= 1'b0;
        LRU_Read_Data__reg <= 2'b0;
    end
    else begin
        if(~freeze) begin
            MEM_Addr__reg <= MEM_Addr;
            Store_Data__reg <= Store_Data;
            Load_Store_op__reg <= Load_Store_op;
            Read__reg <= Read;
            Write__reg <= Write;  
            Write__reg__reg <= Write__reg;  
            tag_data_w0_int <= Tag_Read_Data_w0;
            tag_data_w1_int <= Tag_Read_Data_w1;
            lru_data_int <= LRU_Read_Data;
            write_buff_int <= write_buff;
            prp_acs_int <= prp_acs;
            Load_Store__req__reg <= Load_Store__req;
            LRU_Read_Data__reg <= LRU_Read_Data;
        end
    end
end



always @(posedge clk) begin
    if(rst) begin
        proc_addr_int2 <= 32'b0;
    end
    else begin
        if(state == WT_HIT) begin
            proc_addr_int2 <= MEM_Addr__reg;
        end
    end
end


always @(posedge clk) begin
    if(rst) begin
        cache_flush_int <= 1'b0;
    end
    else begin    
        if(state == FLUSH_COUNT_INCR) begin
            cache_flush_int <= cache_flush;
        end
    end
end





always @(posedge clk) begin
    if(rst) begin
        tag_out_tlb_int <= 20'b0;
    end
    else if(tag_hit_tlb) begin
        tag_out_tlb_int <= tag_out_tlb[23:4];
    end    
end


assign bus_data = ((state == REPLACE) | ((state == WAIT) & (bus_data_en | bus_data_en_reg))) ? 
                  (cache_flush_int ? ((state == REPLACE) ? (LRU_Read_Data[1] ? DCache_Read_Data_w0 : DCache_Read_Data_w1) : queue_data_bus) : (prp_acs_int ? write_buff : queue_data_bus)) : 256'bz; 


always @(posedge clk) begin
    if(rst) begin
        wb_adr_o <= 0; 
    end 
    if(cache_flush_int & (state == REPLACE)) begin
        wb_adr_o <=  (LRU_Read_Data[1] & Dirty_bit_Read_Data_w0) ? {{Tag_Read_Data_w0[(tag_last_bit-tag_start_bit):0]},{cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : MEM_Addr__reg[index_last_bit:index_start_bit]},{5'b00}} :
                    ((LRU_Read_Data[0] & Dirty_bit_Read_Data_w1) ? {{Tag_Read_Data_w1[(tag_last_bit-tag_start_bit):0]},{cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : MEM_Addr__reg[index_last_bit:index_start_bit]},{5'b00}} : 32'b0);    
    end 
    else if((state == WT_HIT) & ~dcache_fsm_freeze) begin
        wb_adr_o <=  (LRU_Read_Data[1] & Dirty_bit_Read_Data_w0) ? {{Tag_Read_Data_w0[(tag_last_bit-tag_start_bit):0]},{cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : MEM_Addr__reg[index_last_bit:index_start_bit]},{5'b00}} :
                    ((LRU_Read_Data[0] & Dirty_bit_Read_Data_w1) ? {{Tag_Read_Data_w1[(tag_last_bit-tag_start_bit):0]},{cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : MEM_Addr__reg[index_last_bit:index_start_bit]},{5'b00}} : 32'b0);
    end
end



always @(posedge clk) begin
    if(rst) begin
        tag_w0_reg <= 0;
        tag_w1_reg <= 0;
        queue_data_bus <= 256'hz;
        Dirty_bit_Read_Data_w0_reg <= 1'b0;
        Dirty_bit_Read_Data_w1_reg <= 1'b0; 
    end                            
    else if((state == REPLACE) & cache_flush_int) begin
        queue_data_bus <= LRU_Read_Data[1] ? DCache_Read_Data_w0 : DCache_Read_Data_w1;       
    end
    else if((state == WT_HIT) & ~dcache_fsm_freeze) begin
        tag_w0_reg <= Tag_Read_Data_w0;
        tag_w1_reg <= Tag_Read_Data_w1; 
        Dirty_bit_Read_Data_w0_reg <= Dirty_bit_Read_Data_w0;
        Dirty_bit_Read_Data_w1_reg <= Dirty_bit_Read_Data_w1;        
//        if( (mis & (Write__reg | Read__reg)) | prp_acs_int) begin
//            queue_data_bus <= LRU_Read_Data[1] ? DCache_Read_Data_w0 : DCache_Read_Data_w1;   
//        end
    end
    else if((state == GET_MEM_DATA) && (prev_state == WT_HIT)) begin
        queue_data_bus <= LRU_Read_Data[1] ? DCache_Read_Data_w0 : DCache_Read_Data_w1;   
    end
end


always @(posedge clk ) begin
    if(rst) begin
        flush_count <= 0;
    end
    else if(state == FLUSH_COUNT_INCR) begin
        if(cache_flush_int) begin
            flush_count <= flush_count + 1;
        end
        else begin
            flush_count <= 0;
        end
    end
end


 
assign dcache_data_int = ((Store_Buffer_Valid__reg == 1'b1) && (Store_Addr__Buffer == MEM_Addr__reg)) ? Store_Data__Buffer : (DCache_Read_Word >> (k__store << 3));

always @(*) begin  
    
    if (addr_exception) begin
        Load_Data <= 32'b0;
    end
    else if(state == WT_HIT) begin
        case(Load_Store_op__reg[4:2])
            3'b000:Load_Data <= {{24{dcache_data_int[7]}},{dcache_data_int[7:0]}};       //byte reading from dcache;sign extended
            3'b001:Load_Data <= {{16{dcache_data_int[15]}},{dcache_data_int[15:0]}};
            3'b010:Load_Data <= dcache_data_int;
            3'b011:Load_Data <= dcache_data_int;
            3'b100:Load_Data <= {{24{1'b0}},{dcache_data_int[7:0]}};
            3'b101:Load_Data <= {{16{1'b0}},{dcache_data_int[15:0]}};       //byte reading from dcache;sign extended
            default:Load_Data <= 32'b0;
        endcase;
    end
    else if(prev_state == GET_MEM_DATA) begin
        case(Load_Store_op__reg[4:2])
            3'b000:Load_Data <= {{24{proc_data_buff[7]}},{proc_data_buff[7:0]}};
            3'b001:Load_Data <= {{16{proc_data_buff[15]}},{proc_data_buff[15:0]}};
            3'b010:Load_Data <= proc_data_buff;
            3'b011:Load_Data <= proc_data_buff;
            3'b100:Load_Data <= {{24{1'b0}},{proc_data_buff[7:0]}};
            3'b101:Load_Data <= {{16{1'b0}},{proc_data_buff[15:0]}};
            default:Load_Data <= 32'b0;
        endcase;
    end
                 
end



always @(posedge clk) begin
    if(rst) begin
        DCache_Write_Data_w0_temp <= 0;
        DCache_Write_Data_w1_temp <= 0;
    end
    else if((state == GET_MEM_DATA) & ~dcache_fsm_freeze) begin
        if(Read__reg) begin
            DCache_Write_Data_w0_temp <= bus_data;
            DCache_Write_Data_w1_temp <= bus_data;
        end
        else begin 
            DCache_Write_Data_w0_temp <= read_buff;
            DCache_Write_Data_w1_temp <= read_buff;
        end
    end
    else begin
        DCache_Write_Data_w0_temp <= write_buff;
        DCache_Write_Data_w1_temp <= write_buff;    
    end
    
end

always @(*) begin

    if (Store_Buffer_Write == 1'b1) begin
        DCache_Write_Data_w0 <= Store_Write_Buffer;
        DCache_Write_Data_w1 <= Store_Write_Buffer;    
    end 
    else begin
        DCache_Write_Data_w0 <= DCache_Write_Data_w0_temp;
        DCache_Write_Data_w1 <= DCache_Write_Data_w0_temp;  
    end
    
end


always @(posedge clk) begin
    if(rst) begin
        queue_addr_bus <= 32'b0;
        bus_data_en_reg <= 1'b0;
    end
    else if (state == GET_MEM_DATA)
        queue_addr_bus <= 32'b0 | (Write__reg << 21) | (1 << 22) | tag_out_tlb_int;
    else if (state == REPLACE)
        bus_data_en_reg <= bus_data_en; 
end


reg [6:0] Tag_Addr_Counter;
reg Tag_Clear_Done;

always @(posedge clk) begin
    if(rst) begin
        Tag_Addr_Counter <= 7'b0;
    end
    else if (Tag_Clear_Done == 1'b0) begin
        Tag_Addr_Counter <= Tag_Addr_Counter + 1;   
    end
end

always @(*) begin
    if(rst) begin
        Tag_Clear_Done <= 1'b0;
    end
    else if(Tag_Addr_Counter == 7'b1111111) begin
        Tag_Clear_Done <= 1'b1;   
    end
end



always @(posedge clk) begin
    if(rst) begin
        prev_state <= START;
    end
    else begin
        prev_state <= state;   
    end
end


always @(posedge clk) begin
    if(rst == 1'b1)
        state <= TAG_CLEAR;
    else if((addr_exception) || ((Ext_Stall == 1'b1) && (state == WT_HIT))) begin
        state <= START;
    end
    else begin
        if(dcache_fsm_freeze == 1'b0) begin
            state <= nextState;
        end    
    end
end



always @(*) begin
    case(state)
        START : begin
            
            freeze <= 1'b0; 
            
            DCache_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
            DCache_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit];
            
            Tag_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
            Tag_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit];
            Dirty_bit_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
            Dirty_bit_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit];
            
            Tag_Write_Data_w0 <= 32'b0;
            Tag_Write_Data_w1 <= 32'b0;
            Dirty_bit_Write_Data_w0 <= 1'b0;
            Dirty_bit_Write_Data_w1 <= 1'b0;
            
            DCache_Write_En_w0 <= 32'b0;   
            DCache_Write_En_w1 <= 32'b0; 
            
            Tag_Write_En_w0 <= 4'b0; 
            Tag_Write_En_w1 <= 4'b0;   
            Dirty_bit_Write_En_w0 <= 1'b0;
            Dirty_bit_Write_En_w1 <= 1'b0; 
                                  
            LRU_Write_Data <= 2'bzz;
            LRU_Write_En <= 1'b1; 
           
            bus_cntrl <= 1'b0;
            bus_rq <= 1'b0;
            bus_re <= 1'b0;
            bus_we <= 1'b0;
            bus_data_en <= 1'b0;
            bus_addr <= 32'b0;
            
            if (Store_Buffer_Valid__reg)
                Store_Buffer_Valid <= 1'b1;
            else
                Store_Buffer_Valid <= 1'b0;  
                
            Store_Buffer_Write <= 1'b0;
            
            i <= Load_Store_op[4:2];
            j <= MEM_Addr[4:2];
            k <= MEM_Addr[1:0];
            
            if(Load_Store__req) begin
                LRU_Addr <= MEM_Addr[index_last_bit:index_start_bit];
                
                nextState <= WT_HIT;
            end
            else if(prp_acs & (~Load_Store_op[1] & Load_Store_op[0])) begin       //Peripheral read. Goto WT_HIT, generate bus signals and jump to bus transaction
                LRU_Addr <= 8'b0;
                
                nextState <= WT_HIT;            
            end
            else if(prp_acs & (Load_Store_op[1] & ~Load_Store_op[0])) begin       //Peripheral write. Goto REPLACE state directly
                LRU_Addr <= 8'b0;
                
                nextState <= REPLACE;            
            end            
            else begin
                LRU_Addr <= 8'b0;
                
                nextState <= START;
            end  
        end    
        
        WT_HIT: begin
           
            bus_we <= 1'b0;
            bus_data_en <= 1'b0;
            
            if (prp_acs_int) begin
                bus_addr <= MEM_Addr__reg;                          //In case of peripheral accesses, the address need not be aligned
            end
            else begin
                bus_addr <= {MEM_Addr__reg[31:5],5'b0}; 
            end
            
            
            if(~cache_flush_int) begin  
                 
                if(hit & Read__reg & ~prp_acs_int) begin
                    
                    if (Load_Store__req & Read) begin
                        
                        freeze <= 1'b0;    
                                                            
                        DCache_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        DCache_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit];
                        
                        Tag_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        Tag_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit]; 
                        Dirty_bit_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        Dirty_bit_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit];
                                        
                        Tag_Write_Data_w0 <= 32'b0;
                        Tag_Write_Data_w1 <= 32'b0;
                        Dirty_bit_Write_Data_w0 <= 1'b0;
                        Dirty_bit_Write_Data_w1 <= 1'b0;
                        
                        DCache_Write_En_w0 <= 32'b0;
                        DCache_Write_En_w1 <= 32'b0;
                        
                        Tag_Write_En_w0 <= 4'b0;     //whichever way was selected, update its dirty bit           
                        Tag_Write_En_w1 <= 4'b0;     //      "   "   "       "       "       "   "   "            
                        Dirty_bit_Write_En_w0 <= 1'b0;
                        Dirty_bit_Write_En_w1 <= 1'b0;
                        
                        LRU_Addr <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        LRU_Write_Data[1] <= (w1_hit) | ((~w0_hit) & ~LRU_Read_Data[1]); 
                        LRU_Write_Data[0] <= (w0_hit) | ((~w1_hit) & ~LRU_Read_Data[0]);                                          
                        LRU_Write_En <= 1'b0;                 //active low
                        
                        bus_cntrl <= 1'b0;    
                        bus_rq <= 1'b0;                                
                        bus_re <= 1'b0;
                        
                        if (Store_Buffer_Valid__reg)
                            Store_Buffer_Valid <= 1'b1;
                        else
                            Store_Buffer_Valid <= 1'b0;    
                            
                        Store_Buffer_Write <= 1'b0;
                        
                        i <= Load_Store_op[4:2];         
                        j <= MEM_Addr[4:2];              
                        k <= MEM_Addr[1:0];   
                              
                        nextState <= WT_HIT;
                        
                    end
                    else if (Store_Buffer_Valid__reg) begin
                        
                        freeze <= 1'b0;    
                                        
                        DCache_Addr_w0 <= Store_Addr__Buffer[index_last_bit:index_start_bit];
                        DCache_Addr_w1 <= Store_Addr__Buffer[index_last_bit:index_start_bit];
                        
                        Tag_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        Tag_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit]; 
                        Dirty_bit_Addr_w0 <= Store_Addr__Buffer[index_last_bit:index_start_bit];
                        Dirty_bit_Addr_w1 <= Store_Addr__Buffer[index_last_bit:index_start_bit];
                                        
                        Tag_Write_Data_w0 <= 32'b0;
                        Tag_Write_Data_w1 <= 32'b0;
                        Dirty_bit_Write_Data_w0 <= 1'b1;
                        Dirty_bit_Write_Data_w1 <= 1'b1;
                        
                        DCache_Write_En_w0 <= (Store_w0_hit_Buffer && ~Store_addr_exception_Buffer) ? ((store_map[i__store_buff] << (j__store_buff << 2)) << k__store_buff) : 32'b0;   
                        DCache_Write_En_w1 <= (Store_w1_hit_Buffer && ~Store_addr_exception_Buffer) ? ((store_map[i__store_buff] << (j__store_buff << 2)) << k__store_buff) : 32'b0; 
                        
                        Tag_Write_En_w0 <= 4'b0;     //whichever way was selected, update its dirty bit           
                        Tag_Write_En_w1 <= 4'b0;     //      "   "   "       "       "       "   "   "            
                        Dirty_bit_Write_En_w0 <= (Store_w0_hit_Buffer && ~Store_addr_exception_Buffer) ? 1'b1 : 1'b0;
                        Dirty_bit_Write_En_w1 <= (Store_w1_hit_Buffer && ~Store_addr_exception_Buffer) ? 1'b1 : 1'b0;
                        
                        LRU_Addr <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        LRU_Write_Data[1] <= (w1_hit) | ((~w0_hit) & ~LRU_Read_Data[1]); 
                        LRU_Write_Data[0] <= (w0_hit) | ((~w1_hit) & ~LRU_Read_Data[0]);                                          
                        LRU_Write_En <= 1'b0;                 //active low
                        
                        bus_cntrl <= 1'b0;    
                        bus_rq <= 1'b0;                                
                        bus_re <= 1'b0;
                      
                        
                        Store_Buffer_Valid <= 1'b0; 
                        Store_Buffer_Write <= 1'b1;
                        
                        i <= Load_Store_op[4:2];         
                        j <= MEM_Addr[4:2];              
                        k <= MEM_Addr[1:0];              
                                            
                        if (Load_Store__req & Write)
                            nextState <= WT_HIT;
                        else if(prp_acs & (~Load_Store_op[1] & Load_Store_op[0]))       //Peripheral read
                            nextState <= WT_HIT;
                        else if(prp_acs & (Load_Store_op[1] & ~Load_Store_op[0]))        //Peripheral write
                            nextState <= REPLACE;
                        else
                            nextState <= START;
                    end
                    else begin
                        
                        freeze <= 1'b0;    
                                        
                        DCache_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        DCache_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit];
                        
                        Tag_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        Tag_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit]; 
                        Dirty_bit_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        Dirty_bit_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit];
                                        
                        Tag_Write_Data_w0 <= 32'b0;
                        Tag_Write_Data_w1 <= 32'b0;
                        Dirty_bit_Write_Data_w0 <= 1'b0;
                        Dirty_bit_Write_Data_w1 <= 1'b0;
                        
                        DCache_Write_En_w0 <= 32'b0;
                        DCache_Write_En_w1 <= 32'b0;
                        
                        Tag_Write_En_w0 <= 4'b0;     //whichever way was selected, update its dirty bit           
                        Tag_Write_En_w1 <= 4'b0;     //      "   "   "       "       "       "   "   "            
                        Dirty_bit_Write_En_w0 <= 1'b0;
                        Dirty_bit_Write_En_w1 <= 1'b0;
                        
                        LRU_Addr <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        LRU_Write_Data[1] <= (w1_hit) | ((~w0_hit) & ~LRU_Read_Data[1]); 
                        LRU_Write_Data[0] <= (w0_hit) | ((~w1_hit) & ~LRU_Read_Data[0]);                                          
                        LRU_Write_En <= 1'b0;                 //active low
                        
                        bus_cntrl <= 1'b0;    
                        bus_rq <= 1'b0;                                
                        bus_re <= 1'b0;
                        
                        Store_Buffer_Valid <= 1'b0;
                        Store_Buffer_Write <= 1'b0;
                        
                        i <= Load_Store_op[4:2];         
                        j <= MEM_Addr[4:2];              
                        k <= MEM_Addr[1:0];              
                           
                        if (Load_Store__req)
                            nextState <= WT_HIT;
                        else if(prp_acs & (~Load_Store_op[1] & Load_Store_op[0]))       //Peripheral read
                            nextState <= WT_HIT;
                        else if(prp_acs & (Load_Store_op[1] & ~Load_Store_op[0]))        //Peripheral write
                            nextState <= REPLACE;
                        else
                            nextState <= START;
                    end
                end
                else if(hit & Write__reg & ~prp_acs_int) begin
                    
                    if (Load_Store__req & Read) begin
                    
                        freeze <= 1'b0;
                        
                        DCache_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        DCache_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit];
                        
                        Tag_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        Tag_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit];
                        Dirty_bit_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        Dirty_bit_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit];
                        
                        Tag_Write_Data_w0 <= 32'b0;
                        Tag_Write_Data_w1 <= 32'b0;
                        Dirty_bit_Write_Data_w0 <= 1'b0;
                        Dirty_bit_Write_Data_w1 <= 1'b0;
                        
                        DCache_Write_En_w0 <= 32'b0;   
                        DCache_Write_En_w1 <= 32'b0; 
                        
                        Tag_Write_En_w0 <= 4'b0; 
                        Tag_Write_En_w1 <= 4'b0;   
                        Dirty_bit_Write_En_w0 <= 1'b0;
                        Dirty_bit_Write_En_w1 <= 1'b0;
                        
                        LRU_Addr <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        LRU_Write_Data[1] <= (w1_hit) | ((~w0_hit) & ~LRU_Read_Data[1]); 
                        LRU_Write_Data[0] <= (w0_hit) | ((~w1_hit) & ~LRU_Read_Data[0]);                                          
                        LRU_Write_En <= 1'b0;                 //active low
                       
                        bus_cntrl <= 1'b0;
                        bus_rq <= 1'b0;
                        bus_re <= 1'b0;
                        
                        Store_Buffer_Valid <= 1'b1;
                        Store_Buffer_Write <= 1'b0;
                        
                        i <= Load_Store_op[4:2];         
                        j <= MEM_Addr[4:2];              
                        k <= MEM_Addr[1:0];              
                        
                        nextState <= WT_HIT;
                    end
                    else if (Load_Store__req & Write) begin
                    
                        freeze <= 1'b0;    
                        
                        DCache_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        DCache_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        
                        Tag_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        Tag_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit]; 
                        Dirty_bit_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        Dirty_bit_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                                                                
                        Tag_Write_Data_w0 <= 32'b0;                 
                        Tag_Write_Data_w1 <= 32'b0;                 
                        Dirty_bit_Write_Data_w0 <= 1'b1;
                        Dirty_bit_Write_Data_w1 <= 1'b1;
                        
                        DCache_Write_En_w0 <= (tag_comp_w0 && ~addr_exception) ? ((store_map[i__store] << (j__store << 2)) << k__store) : 32'b0;   
                        DCache_Write_En_w1 <= (tag_comp_w1 && ~addr_exception) ? ((store_map[i__store] << (j__store << 2)) << k__store) : 32'b0;   
                         
                        Tag_Write_En_w0 <= 4'b0;      
                        Tag_Write_En_w1 <= 4'b0;     
                        Dirty_bit_Write_En_w0 <= (tag_comp_w0 && ~addr_exception) ? 1'b1 : 1'b0;
                        Dirty_bit_Write_En_w1 <= (tag_comp_w1 && ~addr_exception) ? 1'b1 : 1'b0;
                        
                        LRU_Addr <= MEM_Addr__reg[11:5];
                        LRU_Write_Data[1] <= (w1_hit) | ((~w0_hit) & ~LRU_Read_Data[1]); 
                        LRU_Write_Data[0] <= (w0_hit) | ((~w1_hit) & ~LRU_Read_Data[0]);
                        LRU_Write_En <= 1'b0;                 //active low     
                        
                        bus_cntrl <= 1'b0; 
                        bus_rq <= 1'b0;                                   
                        bus_re <= 1'b0;
                        
                        Store_Buffer_Valid <= 1'b0;
                        Store_Buffer_Write <= 1'b0;
                        
                        i <= Load_Store_op[4:2];         
                        j <= MEM_Addr[4:2];              
                        k <= MEM_Addr[1:0];              
                        
                        nextState <= WT_HIT;
                        
                    end
                    else begin
                                        
                        freeze <= 1'b0;    
                        
                        DCache_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        DCache_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        
                        Tag_Addr_w0 <= MEM_Addr[index_last_bit:index_start_bit];
                        Tag_Addr_w1 <= MEM_Addr[index_last_bit:index_start_bit]; 
                        Dirty_bit_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        Dirty_bit_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                                                        
                        Tag_Write_Data_w0 <= 32'b0;                 
                        Tag_Write_Data_w1 <= 32'b0;                 
                        Dirty_bit_Write_Data_w0 <= 1'b1;
                        Dirty_bit_Write_Data_w1 <= 1'b1;
                        
                        DCache_Write_En_w0 <= (tag_comp_w0 && ~addr_exception) ? ((store_map[i] << (j << 2)) << k) : 32'b0;   
                        DCache_Write_En_w1 <= (tag_comp_w1 && ~addr_exception) ? ((store_map[i] << (j << 2)) << k) : 32'b0;   
                        
                        Tag_Write_En_w0 <= 4'b0;      
                        Tag_Write_En_w1 <= 4'b0;     
                        Dirty_bit_Write_En_w0 <= (tag_comp_w0 && ~addr_exception) ? 1'b1 : 1'b0;
                        Dirty_bit_Write_En_w1 <= (tag_comp_w1 && ~addr_exception) ? 1'b1 : 1'b0;
                        
                        LRU_Addr <= MEM_Addr__reg[11:5];
                        LRU_Write_Data[1] <= (w1_hit) | ((~w0_hit) & ~LRU_Read_Data[1]); 
                        LRU_Write_Data[0] <= (w0_hit) | ((~w1_hit) & ~LRU_Read_Data[0]);
                        LRU_Write_En <= 1'b0;                 //active low     
                        
                        bus_cntrl <= 1'b0; 
                        bus_rq <= 1'b0;                                   
                        bus_re <= 1'b0;
                        
                        Store_Buffer_Valid <= 1'b0;
                        Store_Buffer_Write <= 1'b0;
                        
                        i <= Load_Store_op__reg[4:2];         
                        j <= MEM_Addr__reg[4:2];              
                        k <= MEM_Addr__reg[1:0];              
                         
                        if (Load_Store__req)
                            nextState <= WT_HIT;
                        else if(prp_acs & (~Load_Store_op[1] & Load_Store_op[0]))       //Peripheral read
                            nextState <= WT_HIT;
                        else if(prp_acs & (Load_Store_op[1] & ~Load_Store_op[0]))        //Peripheral write
                            nextState <= REPLACE;
                        else
                            nextState <= START;
                    end
                
                end                              
                else if( (mis & (Write__reg | Read__reg)) | prp_acs_int) begin
                
                    freeze <= 1'b1;     
                    
                    Store_Buffer_Valid <= 1'b0;
                    
                    if (Store_Buffer_Valid__reg) begin
                    
                        DCache_Addr_w0 <= Store_Addr__Buffer[index_last_bit:index_start_bit];
                        DCache_Addr_w1 <= Store_Addr__Buffer[index_last_bit:index_start_bit];
                        
                        Tag_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        Tag_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit]; 
                        Dirty_bit_Addr_w0 <= Store_Addr__Buffer[index_last_bit:index_start_bit];
                        Dirty_bit_Addr_w1 <= Store_Addr__Buffer[index_last_bit:index_start_bit];
                                        
                        Tag_Write_Data_w0 <= 32'b0;
                        Tag_Write_Data_w1 <= 32'b0;
                        Dirty_bit_Write_Data_w0 <= 1'b1;
                        Dirty_bit_Write_Data_w1 <= 1'b1;
                        
                        DCache_Write_En_w0 <= (Store_w0_hit_Buffer && ~Store_addr_exception_Buffer) ? ((store_map[i] << (j << 2)) << k) : 32'b0;   
                        DCache_Write_En_w1 <= (Store_w1_hit_Buffer && ~Store_addr_exception_Buffer) ? ((store_map[i] << (j << 2)) << k) : 32'b0; 
                        
                        Tag_Write_En_w0 <= 4'b0;             
                        Tag_Write_En_w1 <= 4'b0;     
                        Dirty_bit_Write_En_w0 <= (Store_w0_hit_Buffer && ~Store_addr_exception_Buffer) ? 1'b1 : 1'b0;
                        Dirty_bit_Write_En_w1 <= (Store_w1_hit_Buffer && ~Store_addr_exception_Buffer) ? 1'b1 : 1'b0;
                        
                        LRU_Addr <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        LRU_Write_Data <= 2'bzz;
                        LRU_Write_En <= 1'b1;
                        
                        bus_cntrl <= 1'b0;    
                        bus_rq <= 1'b0;                                
                        bus_re <= 1'b0;
                        
                        Store_Buffer_Write <= 1'b1;
                        
                        i <= Store_Op__Buffer[4:2];         
                        j <= Store_Addr__Buffer[4:2];              
                        k <= Store_Addr__Buffer[1:0];           
                        
                        nextState <= WT_HIT;
                    end
                    else begin
                    
                        DCache_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        DCache_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        
                        Tag_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        Tag_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit]; 
                        Dirty_bit_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        Dirty_bit_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                        
                        Store_Buffer_Write <= 1'b0;
                        
                        i <= Load_Store_op__reg[4:2];         
                        j <= MEM_Addr__reg[4:2];              
                        k <= MEM_Addr__reg[1:0];              
                                    
                        if(bus_rdy) begin
                                        
                            Tag_Write_Data_w0 <= 32'b0;
                            Tag_Write_Data_w1 <= 32'b0;
                            Dirty_bit_Write_Data_w0 <= 1'b0;
                            Dirty_bit_Write_Data_w1 <= 1'b0;
                            
                            DCache_Write_En_w0 <= 32'b0;
                            DCache_Write_En_w1 <= 32'b0;
                            
                            Tag_Write_En_w0 <= 4'b0;
                            Tag_Write_En_w1 <= 4'b0;  
                            Dirty_bit_Write_En_w0 <= 1'b0;
                            Dirty_bit_Write_En_w1 <= 1'b0;
                            
                            LRU_Addr <= MEM_Addr__reg[index_last_bit:index_start_bit];
                            LRU_Write_Data <= 2'bzz;
                            LRU_Write_En <= 1'b1;
                            
                            bus_cntrl <= 1'b1;                
                            bus_rq <= 1'b1;
                            bus_re <= 1'b1;
                            
                            nextState <= GET_MEM_DATA;
                            
                        end
                        else begin
                            
                            Tag_Write_Data_w0 <= 32'b0;
                            Tag_Write_Data_w1 <= 32'b0;
                            Dirty_bit_Write_Data_w0 <= 1'b0;
                            Dirty_bit_Write_Data_w1 <= 1'b0;
                            
                            DCache_Write_En_w0 <= 32'b0;
                            DCache_Write_En_w1 <= 32'b0;
                            
                            Tag_Write_En_w0 <= 4'b0;
                            Tag_Write_En_w1 <= 4'b0; 
                            Dirty_bit_Write_En_w0 <= 1'b0;
                            Dirty_bit_Write_En_w1 <= 1'b0;
                            
                            LRU_Addr <= MEM_Addr__reg[index_last_bit:index_start_bit];
                            LRU_Write_Data <= 2'bzz;
                            LRU_Write_En <= 1'b1;  
                                                    
                            bus_cntrl <= 1'b1;                
                            bus_rq <= 1'b1;
                            bus_re <= 1'b1;
                            
                            nextState <= WT_HIT;
                            
                        end
                    end
                    
                end
                else begin
                
                    freeze <= 1'b1;   
                    
                    DCache_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                    DCache_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                    
                    Tag_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                    Tag_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit]; 
                    Dirty_bit_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                    Dirty_bit_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit];  
                    
                    Tag_Write_Data_w0 <= 32'b0;
                    Tag_Write_Data_w1 <= 32'b0;
                    Dirty_bit_Write_Data_w0 <= 1'b0;
                    Dirty_bit_Write_Data_w1 <= 1'b0;
                    
                    DCache_Write_En_w0 <= 32'b0;
                    DCache_Write_En_w1 <= 32'b0;
                    
                    Tag_Write_En_w0 <= 4'b0;
                    Tag_Write_En_w1 <= 4'b0;
                    Dirty_bit_Write_En_w0 <= 1'b0;
                    Dirty_bit_Write_En_w1 <= 1'b0;
                    
                    LRU_Addr <= MEM_Addr__reg[index_last_bit:index_start_bit];
                    LRU_Write_Data <= 2'bzz;
                    LRU_Write_En <= 1'b0;   
                                        
                    bus_cntrl <= 1'b0;    
                    bus_rq <= 1'b0;            
                    bus_re <= 1'b0;
                    
                    Store_Buffer_Valid <= 1'b0;
                    Store_Buffer_Write <= 1'b0;
                    
                    i <= Load_Store_op__reg[4:2]; 
                    j <= MEM_Addr__reg[4:2];      
                    k <= MEM_Addr__reg[1:0];      
                    
                    nextState <= WT_HIT;
                     
                end
            end
            else begin
            
                freeze <= 1'b1;          
                
                DCache_Addr_w0 <= flush_count[(index_last_bit-index_start_bit):0];
                DCache_Addr_w1 <= flush_count[(index_last_bit-index_start_bit):0];
                
                Tag_Addr_w0 <= flush_count[(index_last_bit-index_start_bit):0];
                Tag_Addr_w1 <= flush_count[(index_last_bit-index_start_bit):0];  
                Dirty_bit_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
                Dirty_bit_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit]; 
                
                Tag_Write_Data_w0 <= 32'b0;
                Tag_Write_Data_w1 <= 32'b0; 
                Dirty_bit_Write_Data_w0 <= 1'b0;
                Dirty_bit_Write_Data_w1 <= 1'b0;
                
                DCache_Write_En_w0 <= 32'b0;
                DCache_Write_En_w1 <= 32'b0;
                
                Tag_Write_En_w0 <= 4'b0;
                Tag_Write_En_w1 <= 4'b0; 
                Dirty_bit_Write_En_w0 <= 1'b0;
                Dirty_bit_Write_En_w1 <= 1'b0;
                
                LRU_Addr <= flush_count[(index_last_bit-index_start_bit):0];  
                LRU_Write_Data <= 2'bzz;
                LRU_Write_En <= 1'b1;
                
                bus_cntrl <= 1'b1;                
                bus_rq <= 1'b0;
                bus_re <= 1'b0;
                
                Store_Buffer_Valid <= 1'b0;
                Store_Buffer_Write <= 1'b0;
                
                i <= Load_Store_op__reg[4:2]; 
                j <= MEM_Addr__reg[4:2];      
                k <= MEM_Addr__reg[1:0];      
                                   
                nextState <= REPLACE;
                                     
            end
          
        end
                
        FLUSH_COUNT_INCR : begin
        
            freeze <= 1'b1;     //Cache Flush is because of the previous operation. Immediate next memory operation has to be stalled immediately.
            
            DCache_Addr_w0 <= flush_count[(index_last_bit-index_start_bit):0];
            DCache_Addr_w1 <= flush_count[(index_last_bit-index_start_bit):0];
            
            Tag_Addr_w0 <= flush_count[(index_last_bit-index_start_bit):0];
            Tag_Addr_w1 <= flush_count[(index_last_bit-index_start_bit):0];
            Dirty_bit_Addr_w0 <= flush_count[(index_last_bit-index_start_bit):0];
            Dirty_bit_Addr_w1 <= flush_count[(index_last_bit-index_start_bit):0];
            
            Tag_Write_Data_w0 <= 32'b0;
            Tag_Write_Data_w1 <= 32'b0;
            Dirty_bit_Write_Data_w0 <= 1'b0;
            Dirty_bit_Write_Data_w1 <= 1'b0;
            
            DCache_Write_En_w0 <= 32'b0;
            DCache_Write_En_w1 <= 32'b0;
            
            Tag_Write_En_w0 <= 4'b0;
            Tag_Write_En_w1 <= 4'b0;
            Dirty_bit_Write_En_w0 <= 1'b0;
            Dirty_bit_Write_En_w1 <= 1'b0;
            
            LRU_Addr <= flush_count[(index_last_bit-index_start_bit):0];
            LRU_Write_Data <= 2'bzz;
            LRU_Write_En <= 1'b1;        
            
            bus_cntrl <= 1'b0;
            bus_rq <= 1'b0;
            bus_re <= 1'b0;
            bus_we <= 1'b0;
            bus_data_en <= 1'b0;
            bus_addr <= 32'b0;
            
            Store_Buffer_Valid <= 1'b0;
            Store_Buffer_Write <= 1'b0;
            
            i <= Load_Store_op__reg[4:2]; 
            j <= MEM_Addr__reg[4:2];      
            k <= MEM_Addr__reg[1:0];      
            
            nextState <= &flush_count ? START: WT_HIT;
            
        end
        
        GET_MEM_DATA : begin
        
            freeze <= 1'b1;
            
            DCache_Addr_w0 <= 8'b0;
            DCache_Addr_w1 <= 8'b0;
            
            Tag_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
            Tag_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit]; 
            Dirty_bit_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
            Dirty_bit_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit];
            
            Tag_Write_Data_w0 <= 32'b0;
            Tag_Write_Data_w1 <= 32'b0;
            Dirty_bit_Write_Data_w0 <= 1'b0;
            Dirty_bit_Write_Data_w1 <= 1'b0;
            
            DCache_Write_En_w0 <= 32'b0;
            DCache_Write_En_w1 <= 32'b0;
            
            Tag_Write_En_w0 <= 4'b0;
            Tag_Write_En_w1 <= 4'b0;   
            Dirty_bit_Write_En_w0 <= 1'b0;
            Dirty_bit_Write_En_w1 <= 1'b0;
            
            LRU_Addr <= MEM_Addr__reg[index_last_bit:index_start_bit];                        
            LRU_Write_Data <= 2'bzz;
            LRU_Write_En <= 1'b1;
            
            bus_cntrl <= 1'b1;                
            bus_rq <= ~bus_rdy;
            bus_re <= ~bus_rdy;
            bus_we <= 1'b0;
            bus_data_en <= 1'b0;
            bus_addr <= prp_acs_int ? MEM_Addr__reg : {tag_out_tlb_int,MEM_Addr__reg[index_last_bit:index_start_bit],5'b0};
            
            Store_Buffer_Valid <= 1'b0;
            Store_Buffer_Write <= 1'b0;
            
            i <= Load_Store_op__reg[4:2]; 
            j <= MEM_Addr__reg[4:2];      
            k <= MEM_Addr__reg[1:0];      
            
            if(bus_rdy & (Write__reg | Read__reg) & ~prp_acs_int) begin
                if( (~LRU_Read_Data[0] & Dirty_bit_Read_Data_w0) | (~LRU_Read_Data[1] & Dirty_bit_Read_Data_w1)) begin           
                    nextState <= WB_CYC_GAP;
                end
                else begin
                    nextState <= REPLACE;                          
                end
            end
            else if(bus_rdy & Read__reg & prp_acs_int) begin       //Peripheral read action
                nextState <= WB_CYC_GAP;
            end
            else begin
                nextState <= GET_MEM_DATA;
            end
        end
        
        WB_CYC_GAP: begin
            
            freeze <= 1'b1;
            
            DCache_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
            DCache_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit];
            
            Tag_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
            Tag_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit]; 
            Dirty_bit_Addr_w0 <= MEM_Addr__reg[index_last_bit:index_start_bit];
            Dirty_bit_Addr_w1 <= MEM_Addr__reg[index_last_bit:index_start_bit];
            
            Tag_Write_Data_w0 <= 32'b0;
            Tag_Write_Data_w1 <= 32'b0;
            Dirty_bit_Write_Data_w0 <= 1'b0;
            Dirty_bit_Write_Data_w1 <= 1'b0;
            
            DCache_Write_En_w0 <= (cache_flush_int & (Tag_Read_Data_w0[22] | Tag_Read_Data_w1[22])) ? 32'hFFFFFFFF : ((~prp_acs_int & ~LRU_Read_Data[0] & ~cache_flush_int) ? 32'hFFFFFFFF : 32'b0);
            DCache_Write_En_w1 <= (cache_flush_int & (Tag_Read_Data_w0[22] | Tag_Read_Data_w1[22])) ? 32'hFFFFFFFF : ((~prp_acs_int & LRU_Read_Data[0]  & ~LRU_Read_Data[1] & ~cache_flush_int) ? 32'hFFFFFFFF : 32'b0);
                    
            Tag_Write_En_w0 <= 4'b0;
            Tag_Write_En_w1 <= 4'b0;
            Dirty_bit_Write_En_w0 <= 1'b0;
            Dirty_bit_Write_En_w1 <= 1'b0;
                      
            LRU_Write_Data <= 2'bzz;
            LRU_Write_En <= 1'b1;
            
            bus_rq <= 1'b0;
            bus_re <= 1'b0;
            bus_we <= 1'b0;                
            bus_data_en <= 1'b0;
            bus_addr <= 32'b0;
            
            Store_Buffer_Valid <= 1'b0;
            Store_Buffer_Write <= 1'b0;
            
            i <= Load_Store_op__reg[4:2]; 
            j <= MEM_Addr__reg[4:2];      
            k <= MEM_Addr__reg[1:0];      
            
            if(~prp_acs_int) begin
                LRU_Addr <= MEM_Addr__reg[index_last_bit:index_start_bit];
                
                nextState <= REPLACE;
                
                bus_cntrl <= 1'b1;
            end
            else begin 
                LRU_Addr <= 8'b0;
                
                nextState <= START;
                
                bus_cntrl <= 1'b0;
            end
                               
        end
        
        REPLACE: begin
        
            freeze <= 1'b1;
            
            DCache_Addr_w0 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : proc_addr_int2[index_last_bit:index_start_bit];//the address where to write is the same as index
            DCache_Addr_w1 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : proc_addr_int2[index_last_bit:index_start_bit];//the address where to write is the same as index
            
            Tag_Addr_w0 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : proc_addr_int2[index_last_bit:index_start_bit];
            Tag_Addr_w1 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : proc_addr_int2[index_last_bit:index_start_bit];
            Dirty_bit_Addr_w0 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : proc_addr_int2[index_last_bit:index_start_bit];
            Dirty_bit_Addr_w1 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : proc_addr_int2[index_last_bit:index_start_bit];
            
            Tag_Write_Data_w0 <= cache_flush_int ? 32'b0 : (~LRU_Read_Data[0] ? (queue_addr_bus) : 32'b0);   
            Tag_Write_Data_w1 <= cache_flush_int ? 32'b0 : (~LRU_Read_Data[1] ? (queue_addr_bus) : 32'b0);   
            Dirty_bit_Write_Data_w0 <= cache_flush_int ? 1'b0 : (~LRU_Read_Data[0] ? (queue_addr_bus[21]) : 1'b0);
            Dirty_bit_Write_Data_w1 <= cache_flush_int ? 1'b0 : (~LRU_Read_Data[1] ? (queue_addr_bus[21]) : 1'b0);   
               
            DCache_Write_En_w0 <= (cache_flush_int & (LRU_Read_Data[1] & Dirty_bit_Read_Data_w0)) ? 32'hFFFFFFFF : 
                          ((~prp_acs_int & ~LRU_Read_Data[0] & ~Dirty_bit_Read_Data_w0 & ~cache_flush_int) ? 32'hFFFFFFFF : 32'b0);          //write a new block into address denoted by index 
            DCache_Write_En_w1 <= (cache_flush_int & (LRU_Read_Data[0] & Dirty_bit_Read_Data_w1)) ? 32'hFFFFFFFF :
                          ((~prp_acs_int & LRU_Read_Data[0] & ~LRU_Read_Data[1] & ~Dirty_bit_Read_Data_w1 & ~cache_flush_int) ? 32'hFFFFFFFF : 32'b0);          //write a new block into address denoted by index
            
            Tag_Write_En_w0 <= (cache_flush_int & ((Dirty_bit_Read_Data_w0 | Tag_Read_Data_w0[22]) | (Dirty_bit_Read_Data_w1 | Tag_Read_Data_w1[22])) & ~LRU_Read_Data[0]) ? 4'b1111 : ((~prp_acs_int & ~LRU_Read_Data[0] & ~cache_flush_int) ? 4'b1111 : 4'b0);             //Dont write during peripheral access
            Tag_Write_En_w1 <= (cache_flush_int & ((Dirty_bit_Read_Data_w0 | Tag_Read_Data_w0[22]) | (Dirty_bit_Read_Data_w1 | Tag_Read_Data_w1[22])) & LRU_Read_Data[0] & ~LRU_Read_Data[1]) ? 4'b1111 : ((~prp_acs_int & LRU_Read_Data[0] & ~LRU_Read_Data[1] & ~cache_flush_int) ? 4'b1111 : 4'b0); //Dont write during peripheral access
            Dirty_bit_Write_En_w0 <= (cache_flush_int & ((Dirty_bit_Read_Data_w0 | Tag_Read_Data_w0[22]) | (Dirty_bit_Read_Data_w1 | Tag_Read_Data_w1[22])) & ~LRU_Read_Data[0]) ? 1'b1 : ((~prp_acs_int & ~LRU_Read_Data[0] & ~cache_flush_int) ? 1'b1 : 1'b0);
            Dirty_bit_Write_En_w1 <= (cache_flush_int & ((Dirty_bit_Read_Data_w0 | Tag_Read_Data_w0[22]) | (Dirty_bit_Read_Data_w1 | Tag_Read_Data_w1[22])) & LRU_Read_Data[0] & ~LRU_Read_Data[1]) ? 1'b1 : ((~prp_acs_int & LRU_Read_Data[0] & ~LRU_Read_Data[1] & ~cache_flush_int) ? 1'b1 : 1'b0);
                                      
            LRU_Addr <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : MEM_Addr__reg[index_last_bit:index_start_bit];     
            LRU_Write_Data[1] <= (cache_flush_int & flush_count[7]) ? 1'b1  : ((w1_hit) | ((~w0_hit) & ~LRU_Read_Data[1] & LRU_Read_Data[0])); // priority to way0 
            LRU_Write_Data[0] <= (cache_flush_int & flush_count[7]) ? 1'b0  : (w0_hit) | ((~w1_hit) & ~LRU_Read_Data[0]);
            LRU_Write_En <= cache_flush_int ? ~((Dirty_bit_Read_Data_w0 | Tag_Read_Data_w0[22]) | (Dirty_bit_Read_Data_w1 | Tag_Read_Data_w1[22])) : (prp_acs_int ? 1'b1 : 1'b0);                 //active low; write if there is not peripheral access i.e. prp_acs_int is low
            
            
            bus_cntrl <= 1'b1;                
            bus_rq <= cache_flush_int ? (LRU_Read_Data[1] ? Dirty_bit_Read_Data_w0 : Dirty_bit_Read_Data_w1) : (prp_acs_int | (LRU_Read_Data[1] & Dirty_bit_Read_Data_w0) | (LRU_Read_Data[0] & Dirty_bit_Read_Data_w1));                   
            bus_re <= 1'b0;
            bus_we <= cache_flush_int ? (LRU_Read_Data[1] ? Dirty_bit_Read_Data_w0 : Dirty_bit_Read_Data_w1) : (prp_acs_int | (LRU_Read_Data[1] & Dirty_bit_Read_Data_w0) | (LRU_Read_Data[0] & Dirty_bit_Read_Data_w1));                   
            bus_data_en <= cache_flush_int ? (LRU_Read_Data[1] ? Dirty_bit_Read_Data_w0 : Dirty_bit_Read_Data_w1) : (prp_acs_int | (LRU_Read_Data[1] & Dirty_bit_Read_Data_w0) | (LRU_Read_Data[0] & Dirty_bit_Read_Data_w1));   
            bus_addr <= cache_flush_int ? ((LRU_Read_Data[1] & Dirty_bit_Read_Data_w0) ? {{Tag_Read_Data_w0[(tag_last_bit-tag_start_bit):0]},{cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : MEM_Addr__reg[index_last_bit:index_start_bit]},{5'b00}} :
                                          ((LRU_Read_Data[0] & Dirty_bit_Read_Data_w1) ? {{Tag_Read_Data_w1[(tag_last_bit-tag_start_bit):0]},{cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : MEM_Addr__reg[index_last_bit:index_start_bit]},{5'b00}} : 32'b0)) : (prp_acs_int ? MEM_Addr__reg : wb_adr_o);     //Peripheral write
            
            Store_Buffer_Valid <= 1'b0;
            Store_Buffer_Write <= 1'b0;
            
            i <= Load_Store_op__reg[4:2]; 
            j <= MEM_Addr__reg[4:2];      
            k <= MEM_Addr__reg[1:0];      
            
            if(cache_flush_int & (Tag_Read_Data_w0[22] | Tag_Read_Data_w1[22])) begin
                nextState <= WAIT;
            end
            else if(cache_flush_int) begin
                nextState <= FLUSH_COUNT_INCR;
            end
            else if( prp_acs_int | (LRU_Read_Data[1] & Dirty_bit_Read_Data_w0) | (LRU_Read_Data[0] & Dirty_bit_Read_Data_w1)) begin
                nextState <= WAIT;              
            end
            else begin
                nextState <= START;      
            end
        end
        
        WAIT : begin
        
            freeze <= 1'b1;
            
            DCache_Addr_w0 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : proc_addr_int2[index_last_bit:index_start_bit];//the address where to write is the same as index
            DCache_Addr_w1 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : proc_addr_int2[index_last_bit:index_start_bit];//the address where to write is the same as index
            
            Tag_Addr_w0 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : MEM_Addr__reg[index_last_bit:index_start_bit];
            Tag_Addr_w1 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : MEM_Addr__reg[index_last_bit:index_start_bit]; 
            Dirty_bit_Addr_w0 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : MEM_Addr__reg[index_last_bit:index_start_bit];
            Dirty_bit_Addr_w1 <= cache_flush_int ? flush_count[(index_last_bit-index_start_bit):0] : MEM_Addr__reg[index_last_bit:index_start_bit];
            
            Tag_Write_Data_w0 <= 32'b0;
            Tag_Write_Data_w1 <= 32'b0;
            Dirty_bit_Write_Data_w0 <= 1'b0;
            Dirty_bit_Write_Data_w1 <= 1'b0;
            
            DCache_Write_En_w0 <= 32'b0;
            DCache_Write_En_w1 <= 32'b0;
                        
            Tag_Write_En_w0 <= 4'b0;
            Tag_Write_En_w1 <= 4'b0;   
            Dirty_bit_Write_En_w0 <= 1'b0;
            Dirty_bit_Write_En_w1 <= 1'b0;
                        
            LRU_Addr <= 8'bzzzzz;
            LRU_Write_Data <= 2'bzz;
            LRU_Write_En <= 1'b1;
            
            bus_cntrl <= 1'b1; 
            bus_rq <= ~bus_rdy;
            bus_re <= 1'b0;
            bus_we <= ~bus_rdy;
            bus_data_en <= 1'b0;
            bus_addr <= cache_flush_int ? wb_adr_o : (prp_acs_int ? MEM_Addr__reg : wb_adr_o);
            
            Store_Buffer_Valid <= 1'b0;
            Store_Buffer_Write <= 1'b0;
            
            i <= Load_Store_op__reg[4:2]; 
            j <= MEM_Addr__reg[4:2];      
            k <= MEM_Addr__reg[1:0];      
            
            if(bus_rdy) begin
                if(~cache_flush_int) begin
                    if(~cache_flush)    
                        nextState <= START;
                    else                
                        nextState <= FLUSH_COUNT_INCR;
                end
                else 
                    nextState <= FLUSH_COUNT_INCR;
            end
            else begin
                nextState <= WAIT;
            end
        end
           
        TAG_CLEAR : begin
                    
            DCache_Addr_w0 <= 8'b0;
            DCache_Addr_w1 <= 8'b0;
            
            Tag_Addr_w0 <= Tag_Addr_Counter;
            Tag_Addr_w1 <= Tag_Addr_Counter; 
            Dirty_bit_Addr_w0 <= 7'b0;   
            Dirty_bit_Addr_w1 <= 7'b0;   
            
            Tag_Write_Data_w0 <= 32'b0;
            Tag_Write_Data_w1 <= 32'b0;
            Dirty_bit_Write_Data_w0 <= 1'b0;
            Dirty_bit_Write_Data_w1 <= 1'b0;
            
            DCache_Write_En_w0 <= 32'b0;
            DCache_Write_En_w1 <= 32'b0;
            
            Tag_Write_En_w0 <= 4'b1111;
            Tag_Write_En_w1 <= 4'b1111;
            Dirty_bit_Write_En_w0 <= 1'b0;
            Dirty_bit_Write_En_w1 <= 1'b0;
            
            LRU_Addr <= 8'bzzzzz;
            LRU_Write_Data <= 2'bzz;
            LRU_Write_En <= 1'b1;
            
            bus_cntrl <= 1'b0;
            bus_rq <= 1'b0;
            bus_re <= 1'b0;
            bus_we <= 1'b0;
            bus_data_en <= 1'b0;
            bus_addr <= 32'b0;
            
            Store_Buffer_Valid <= 1'b0;
            Store_Buffer_Write <= 1'b0;
            
            i <= 3'b0; 
            j <= 3'b0;      
            k <= 2'b0;      
            
            if (Tag_Clear_Done == 1'b1) begin 
                freeze <= 1'b0;
                nextState <= START;
            end
            else begin
                freeze <= 1'b1;
                nextState <= TAG_CLEAR;
            end
        end
            
        default : begin
            
            freeze <= 1'b0;
            
            DCache_Addr_w0 <= 8'b0;
            DCache_Addr_w1 <= 8'b0;
            
            Tag_Addr_w0 <= 32'b0;
            Tag_Addr_w1 <= 32'b0; 
            Dirty_bit_Addr_w0 <= 7'b0;   
            Dirty_bit_Addr_w1 <= 7'b0;   
            
            Tag_Write_Data_w0 <= 32'b0;
            Tag_Write_Data_w1 <= 32'b0;
            Dirty_bit_Write_Data_w0 <= 1'b0;
            Dirty_bit_Write_Data_w1 <= 1'b0;
            
            DCache_Write_En_w0 <= 32'b0;
            DCache_Write_En_w1 <= 32'b0;
            
            Tag_Write_En_w0 <= 4'b0;
            Tag_Write_En_w1 <= 4'b0;
            Dirty_bit_Write_En_w0 <= 1'b0;
            Dirty_bit_Write_En_w1 <= 1'b0;
            
            LRU_Addr <= 8'bzzzzz;
            LRU_Write_Data <= 2'bzz;
            LRU_Write_En <= 1'b1;
            
            bus_cntrl <= 1'b0;
            bus_rq <= 1'b0;
            bus_re <= 1'b0;
            bus_we <= 1'b0;
            bus_data_en <= 1'b0;
            bus_addr <= 32'b0;
            
            Store_Buffer_Valid <= 1'b0;
            Store_Buffer_Write <= 1'b0;
            
            i <= 3'b0; 
            j <= 3'b0;      
            k <= 2'b0;      
            
            nextState <= START;
        end 
    endcase
end




endmodule

