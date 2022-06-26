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
// Create Date: 07.03.2018 02:28:07
// Design Name: 
// Module Name: EVA_update
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


module EVA_update(clk, clk_5, rst, update_EVA, hitCtr_R_1D, evictionCtr_R_1D, hitCtr_NR_1D, evictionCtr_NR_1D
                    , sorted_index_1D
                    
    );

    parameter k = 3;       /////////////age counter width//////////
    parameter j = 2;       /////////////set counter width- will be used for Age Granularity//////////
    parameter A = 2;        //////////////Age Granularity/////////////
    parameter ctrLen = 10;
    parameter N = 2**k;   /////number of rows
    parameter M = ctrLen;   /////number of column
    parameter bitLen = 15;

    input clk;
    input clk_5;
    input rst;
    input update_EVA;
    input [ctrLen*N-1 : 0] hitCtr_R_1D;
    input [ctrLen*N-1 : 0] evictionCtr_R_1D;
    input [ctrLen*N-1 : 0] hitCtr_NR_1D;
    input [ctrLen*N-1 : 0] evictionCtr_NR_1D;
    
//    output reg [19:0] evaReused;    /////** fixed point(Q5.15)  **/////
    output [4*16-1 : 0] sorted_index_1D;

    reg [(ctrLen - 1):0] hitCtr_R_intermediate[0:N-1];
    reg [(ctrLen - 1):0] evictionCtr_R_intermediate[0:N-1];
    reg [(ctrLen - 1):0] hitCtr_NR_intermediate[0:N-1];
    reg [(ctrLen - 1):0] evictionCtr_NR_intermediate[0:N-1];
    
    reg [(ctrLen - 1):0] hitCtr_R_final[0:N-1];
    reg [(ctrLen - 1):0] evictionCtr_R_final[0:N-1];
    reg [(ctrLen - 1):0] hitCtr_NR_final[0:N-1];
    reg [(ctrLen - 1):0] evictionCtr_NR_final[0:N-1];
    

    
//    (* KEEP = "TRUE" *) reg [(bitLen - 1):0] hits_R_avgd[0:N-1];
//    (* KEEP = "TRUE" *) reg [(bitLen - 1):0] events_R_avgd[0:N-1];
//    (* KEEP = "TRUE" *) reg [(bitLen - 1):0] hits_NR_avgd[0:N-1];
//    (* KEEP = "TRUE" *) reg [(bitLen - 1):0] events_NR_avgd[0:N-1];
    
//    (* KEEP = "TRUE" *) reg [(bitLen - 1):0] hits_R[0:N-1];
//    (* KEEP = "TRUE" *) reg [(bitLen - 1):0] hits_NR[0:N-1];
//    (* KEEP = "TRUE" *) reg [(bitLen - 0):0] events_R[0:N-1];
//    (* KEEP = "TRUE" *) reg [(bitLen - 0):0] events_NR[0:N-1];

//    (* KEEP = "TRUE" *) reg [(bitLen - 0):0] total_hits;
//    (* KEEP = "TRUE" *) reg [(bitLen + 1):0] total_events;
    
//    (* KEEP = "TRUE" *) reg [(bitLen + 2):0] hit_rate;
//    (* KEEP = "TRUE" *) reg [(bitLen + 2):0] pac;
    
//    (* KEEP = "TRUE" *) wire [(bitLen + 2):0] ratio_A_by_N;
    
    reg [(bitLen - 1):0] hits_R_avgd[0:N-1];
    reg [(bitLen - 1):0] events_R_avgd[0:N-1];
    reg [(bitLen - 1):0] hits_NR_avgd[0:N-1];
    reg [(bitLen - 1):0] events_NR_avgd[0:N-1];
    
    reg [(bitLen - 1):0] hits_R[0:N-1];
    reg [(bitLen - 1):0] hits_NR[0:N-1];
    reg [(bitLen - 0):0] events_R[0:N-1];
    reg [(bitLen - 0):0] events_NR[0:N-1];

    reg [(bitLen - 0):0] total_hits;
    reg [(bitLen + 1):0] total_events;
    
    reg [(bitLen + 2):0] hit_rate;    /////** fixed point(Q1.17)  **/////
    reg [(bitLen + 2):0] pac;
    
    wire [(bitLen + 2):0] ratio_A_by_N;
    assign ratio_A_by_N = 18'b00_0010_0000_0000_0000;   /////** fixed point(Q1.17) representation of 2/32 **/////
    
    reg [(bitLen + 1):0] h_R[0:N-1];    /////** fixed point(Q1.16)  **/////
    reg [(bitLen + 1):0] h_NR[0:N-1];   /////** fixed point(Q1.16)  **/////
    
    reg [12:0] hits_eva_R;
    reg [12:0] hits_eva_NR;
    reg [13:0] events_eva_R;
    reg [13:0] events_eva_NR;
    reg [15:0] expectedLifetime_R;
    reg [15:0] expectedLifetime_NR;
    
    reg [17:0] diff;    /////** fixed point(Q2.16)  **/////

//    (* KEEP = "TRUE" *) reg signed [17:0] eva_R[0:N-1];     /////** fixed point(Q5.13)  **/////
//    (* KEEP = "TRUE" *) reg signed [17:0] eva_NR[0:N-1];    /////** fixed point(Q5.13)  **/////
    
    reg signed [17:0] eva_R[0:N-1];     /////** fixed point(Q5.13)  **/////
    reg signed [17:0] eva_NR[0:N-1];    /////** fixed point(Q5.13)  **/////
    
//    (* KEEP = "TRUE" *) reg [19:0] evaReused;    /////** fixed point(Q5.15)  **/////
    reg [19:0] evaReused;    /////** fixed point(Q5.15)  **/////
    
//////////////**** converting 1-D array to 2-D vector ****///////////
    
    integer i;
    always @(*)
    begin
        for (i=0;i<N;i=i+1) begin
            hitCtr_R_intermediate[i]       = hitCtr_R_1D[i*M +: M];
            evictionCtr_R_intermediate[i]  = evictionCtr_R_1D[i*M +: M];
            hitCtr_NR_intermediate[i]      = hitCtr_NR_1D[i*M +: M];
            evictionCtr_NR_intermediate[i] = evictionCtr_NR_1D[i*M +: M];
            end
        end

//////////////////// ************************ /////////////////////////////

///////////////////********** 2D_array to 1D_array conversion **********/////////////////        
       
//    integer w;
//    always @(*)
//    begin
//        if(rst) begin
//            hitCtr_R_avgd_1D = 0;
//            evictionCtr_R_avgd_1D = 0;
//            hitCtr_NR_avgd_1D = 0;
//            evictionCtr_NR_avgd_1D = 0;
//            end
//        else begin
//            for (w=0;w<N;w=w+1) begin
//                hitCtr_R_avgd_1D[w*bitLen +: bitLen] = hitCtr_R_avgd[w];
//                evictionCtr_R_avgd_1D[w*bitLen +: bitLen] = evictionCtr_R_avgd[w];
//                hitCtr_NR_avgd_1D[w*bitLen +: bitLen] = hitCtr_NR_avgd[w];
//                evictionCtr_NR_avgd_1D[w*bitLen +: bitLen] = evictionCtr_NR_avgd[w];
//                end
//            end
//        end

////////////////// ****************** /////////////////////////

//////////////******** controller/FSM ********//////////////

//    reg [4:0] state;
//    reg [4:0] next_state;
//    reg [4:0] state_delayed;
    
//    (* KEEP = "TRUE" *) reg [4:0] state;
//    (* KEEP = "TRUE" *) reg [4:0] next_state;
//    (* KEEP = "TRUE" *) reg [4:0] state_delayed;
//    (* KEEP = "TRUE" *) reg [4:0] state_delayed1;

    reg [4:0] state;
    reg [4:0] next_state;
    reg [4:0] state_delayed;
    reg [4:0] state_delayed1;

    parameter idle     = 5'd0;
    parameter average  = 5'd1;
    parameter addition = 5'd2;
    parameter division_h = 5'd3;
    parameter cal_pac = 5'd4;
    parameter update_h_e = 5'd5;
    parameter update_el = 5'd6;
    parameter eva_div = 5'd7;
    parameter eva_dsp = 5'd8;
    parameter dummy_state1 = 5'd9;
    parameter dummy_state2 = 5'd10;
    parameter dummy_state3 = 5'd11;
    parameter cal_diff = 5'd12;
    parameter cal_evaReused = 5'd13;
    parameter update_eva_value = 5'd14;
    parameter dummy_state4 = 5'd15;
    parameter dummy_state5 = 5'd16;
    parameter dummy_state6 = 5'd17;
    parameter dummy_state7 = 5'd18;
    parameter arg_sort_eva = 5'd19;
    
//    (* KEEP = "TRUE" *) reg [2:0] b;
//    (* KEEP = "TRUE" *) reg [2:0] b_delayed;
//    (* KEEP = "TRUE" *) reg [2:0] b_delayed1;
//    (* KEEP = "TRUE" *) reg avg;
//    (* KEEP = "TRUE" *) reg add;
//    (* KEEP = "TRUE" *) reg start_div_h;
//    (* KEEP = "TRUE" *) reg start_div_hr;
//    (* KEEP = "TRUE" *) reg h_e_update;
//    (* KEEP = "TRUE" *) reg el_update;
//    (* KEEP = "TRUE" *) reg start_div_eva;
//    (* KEEP = "TRUE" *) reg start_div_evaR;
    
//    (* KEEP = "TRUE" *) reg div_h_done;
//    (* KEEP = "TRUE" *) wire div_h_done1;
//    (* KEEP = "TRUE" *) wire div_h_done2;
//    (* KEEP = "TRUE" *) wire div_h_done3;
//    (* KEEP = "TRUE" *) wire div_done_hr;

//    (* KEEP = "TRUE" *) reg div_done_eva;
//    (* KEEP = "TRUE" *) wire div_done_eva1;
//    (* KEEP = "TRUE" *) wire div_done_eva2;
//    (* KEEP = "TRUE" *) wire div_done_eva3;
//    (* KEEP = "TRUE" *) wire div_done_eva4;
//    (* KEEP = "TRUE" *) wire div_done_eva5;
    
//    (* KEEP = "TRUE" *) wire div_done_evaR;

    reg [2:0] b;
    reg [2:0] b_delayed;
    reg [2:0] b_delayed1;
    reg avg;
    reg add;
    reg start_div_h;
    reg start_div_hr;
    reg h_e_update;
    reg el_update;
    reg start_div_eva;
    reg start_div_evaR;
    reg start_sorting;
    
    reg div_h_done;
    wire div_h_done1;
    wire div_h_done2;
    wire div_h_done3;
    wire div_done_hr;

    reg div_done_eva;
    wire div_done_eva1;
    wire div_done_eva2;
    wire div_done_eva3;
    wire div_done_eva4;
    wire div_done_eva5;
    
    wire div_done_evaR;
    wire done_sorting;

    always @(posedge clk)
    begin
        #0.1 if(rst) begin 
            state <= idle;
            end
        else begin  
            state         <= next_state;
            state_delayed1 <= state_delayed;
            state_delayed <= state;
            end
        end

    always @(posedge clk)
    begin
        #0.1 b_delayed1 = b_delayed;
        b_delayed = b;  
        if(rst | update_EVA) begin
            b = 3'd7;
            b_delayed = 3'd7;
            b_delayed1 = 3'd7;
            end
        else if(state == average) begin
            if(b != 3'd0)begin 
                b = b-1;
                end
            else begin
                b = 3'd7;
                end
            end
        else if(state == division_h) begin
            if(div_h_done) begin
                if(b != 3'd0) begin
                    b = b-1;
                    end
                else begin
                    b = 3'd7;
                    end
                end
            end
        else if(state == cal_pac) begin
            b = 3'd7;
            end
        else if(state == update_h_e) begin
            b = b-1;
            end
        else if(state == cal_evaReused) begin
            b = 3'd7;
            end
        else if(state == update_eva_value) begin
            b = b-1;
            end
        end
        

    always @(*)
    begin
        case (state)
            idle:   begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                if(update_EVA) begin
                    next_state = average;
                    end
                else begin
                    next_state = idle;
                    end
                end
            average:    begin
                avg = 1'b1;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                if(b==0) begin
                    next_state = addition;
                    end
                else begin
                    next_state = average;
                    end
                end
            addition:   begin
                avg = 1'b0;
                add = 1'b1;
                h_e_update = 1'b0;
                el_update = 1'b0;
                next_state = division_h;
                end
            division_h: begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                if(div_h_done) begin
                    if(b == 0) begin
                        next_state = cal_pac;
                        end
                    else begin
                        next_state = addition;
                        end
                    end
                else begin
                    next_state = division_h;
                    end
                end
            cal_pac:    begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                next_state = update_h_e;
                end
            update_h_e: begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b1;
                el_update = 1'b0;
                next_state = update_el;
                end
            update_el:  begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b1;
                next_state = eva_div;
                end
            eva_div:    begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                if(div_done_eva) begin
                    next_state = eva_dsp;
                    end
                else begin
                    next_state = eva_div;
                    end
                end
            eva_dsp:    begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                if(b == 3'd0) begin
                    next_state = dummy_state1;
                    end
                else begin
                    next_state = update_h_e;
                    end
                end
            dummy_state1:   begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                next_state = dummy_state2;
                end
            dummy_state2:   begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                next_state = dummy_state3;
                end
            dummy_state3:   begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                next_state = cal_diff;
                end
            cal_diff:   begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                next_state = cal_evaReused;
                end
            cal_evaReused:  begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                if(div_done_evaR) begin
                    next_state = update_eva_value;
                    end
                else begin
                    next_state = cal_evaReused;
                    end
                end
            update_eva_value:   begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                if(b == 0) begin
                    next_state = dummy_state4;
                    end
                else begin
                    next_state = update_eva_value;
                    end
                end
            dummy_state4:   begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                next_state = dummy_state5;
                end
            dummy_state5:   begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                next_state = dummy_state6;
                    end
            dummy_state6:   begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                next_state = dummy_state7;
                end
            dummy_state7:   begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                next_state = arg_sort_eva;
                end
            arg_sort_eva:   begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                if(done_sorting) begin
                    next_state = idle;
                    end
                else begin
                    next_state = arg_sort_eva;
                    end
                end
            default:    begin
                avg = 1'b0;
                add = 1'b0;
                h_e_update = 1'b0;
                el_update = 1'b0;
                next_state = idle;
                end
            endcase
        end

//////////////////// ************************ ////////////////////

//////////////******** DSP i/p & o/p MUX ********//////////////

    reg [17:0] in1;
    reg [17:0] in2;
    reg [17:0] in3;
    reg [17:0] in4;
    reg [17:0] in5;
    wire [35:0] op1;
    wire [35:0] op2;
    wire [35:0] op3;
    wire [35:0] op4;
    
//    (* KEEP = "TRUE" *) reg [17:0] in1;
//    (* KEEP = "TRUE" *) reg [17:0] in2;
//    (* KEEP = "TRUE" *) reg [17:0] in3;
//    (* KEEP = "TRUE" *) reg [17:0] in4;
//    (* KEEP = "TRUE" *) reg [17:0] in5;
//    (* KEEP = "TRUE" *) wire [35:0] op1;
//    (* KEEP = "TRUE" *) wire [35:0] op2;
//    (* KEEP = "TRUE" *) wire [35:0] op3;
//    (* KEEP = "TRUE" *) wire [35:0] op4;
    
    always @(*)
    begin
        #0.1 if(rst) begin
            in1 = 0;
            in2 = 0;
            in3 = 0;
            in4 = 0;
            in5 = 0;
            end
        else if(state == average) begin
            in1 = {3'b000, hits_R[b]};
            in2 = {3'b000, events_R[b]};
            in3 = {3'b000, hits_NR[b]};
            in4 = {3'b000, events_NR[b]};
            in5 = 18'd3;
            end
        else if(state == cal_pac) begin
            in1 = hit_rate;
            in5 = ratio_A_by_N;
            end
        end

//////////////////// ************************ ////////////////////

//////////////******** division i/p & o/p MUX & signals ********//////////////

    always @(posedge clk)
    begin
        #0.1 if(start_div_h) begin
            start_div_h = 1'b0;
            end
        else if(add) begin
            start_div_h = 1'b1;
            end
        else begin
            start_div_h = 1'b0;
            end
        end

    always @(posedge clk)
    begin
        #0.1 if(start_div_hr) begin
            start_div_hr = 1'b0;
            end
        else if(add) begin
            if(b == 0) begin
                start_div_hr = 1'b1;
                end
            end
        else begin
            start_div_hr = 1'b0;
            end
        end

    assign div_h_done3 = div_h_done1 & div_h_done2;

    always @(posedge clk) 
    begin
        #0.1 if(div_h_done) begin
            div_h_done = 1'b0;
            end
        else if(div_h_done3) begin
            div_h_done = 1'b1;
            end
        else begin  
            div_h_done = 1'b0;
            end
        end

    always @(posedge clk)
    begin
        #0.1 if(start_div_eva) begin
            start_div_eva = 1'b0;
            end
        else if(el_update) begin
            start_div_eva = 1'b1;
            end
        else begin
            start_div_eva = 1'b0;
            end
        end
        
    assign div_done_eva5 = div_done_eva1 & div_done_eva2 & div_done_eva3 & div_done_eva4;

    always @(posedge clk) 
    begin
        #0.1 if(div_done_eva) begin
            div_done_eva = 1'b0;
            end
        else if(div_done_eva5) begin
            div_done_eva = 1'b1;
            end
        else begin  
            div_done_eva = 1'b0;
            end
        end

    always @(posedge clk)
    begin
        #0.1 if(start_div_evaR) begin
            start_div_evaR = 1'b0;
            end
        else if(state == cal_diff) begin
            start_div_evaR = 1'b1;
            end
        else begin
            start_div_evaR = 1'b0;
            end
        end

    reg [17:0] in6;
    reg [17:0] in7;
    reg [17:0] in8;
    reg [17:0] in9;
    wire [17:0] op5;
    wire [17:0] op6;
    
//    (* KEEP = "TRUE" *) reg [17:0] in6;
//    (* KEEP = "TRUE" *) reg [17:0] in7;
//    (* KEEP = "TRUE" *) reg [17:0] in8;
//    (* KEEP = "TRUE" *) reg [17:0] in9;
//    (* KEEP = "TRUE" *) wire [17:0] op5;
//    (* KEEP = "TRUE" *) wire [17:0] op6;
    
    reg [17:0] in10;
    reg [17:0] in11;
    wire [17:0] op7;

//    (* KEEP = "TRUE" *) reg [17:0] in10;
//    (* KEEP = "TRUE" *) reg [17:0] in11;
//    (* KEEP = "TRUE" *) wire [17:0] op7;
    
    always @(*)
    begin
        #0.1 if(rst) begin
            in6 = 0;
            in7 = 0;
            in8 = 0;
            in9 = 0;
            in10 = 0;
            in11 = 0;
            end
        else if(state == division_h) begin
            in6 = {2'b00, hits_R[b], 1'b0};
            in7 = {1'b0, events_R[b], 1'b0};
            in8 = {2'b00, hits_NR[b], 1'b0};
            in9 = {1'b0, events_NR[b], 1'b0};
            if(b == 0) begin
                in10 = {2'b00, total_hits};
                in11 = {1'b0, total_events};
                end
            end
        end

    integer e;
    always @(*)
    begin
        #0.1 if(rst) begin
            for(e=0; e<N; e=e+1) begin
                h_R[e] = 0;
                h_NR[e] = 0;
                end
            end
        else if(state == division_h) begin
            if(div_h_done) begin
                h_R[b] = op5[17:1];
                h_NR[b] = op6[17:1];
                end
            end
        end
        
    always @(posedge clk)
    begin
        #0.1 if(rst) begin
            hit_rate = 0;
            end
        else if(state == division_h) begin
            if(div_h_done) begin
                if(b == 0) begin
                    hit_rate = op7;
                    end
                end
            end
        end

//    (* KEEP = "TRUE" *) reg [17:0] in12;
//    (* KEEP = "TRUE" *) reg [17:0] in13;
//    (* KEEP = "TRUE" *) reg [17:0] in14;
//    (* KEEP = "TRUE" *) reg [17:0] in15;
//    (* KEEP = "TRUE" *) reg [17:0] in16;
//    (* KEEP = "TRUE" *) reg [17:0] in17;
//    (* KEEP = "TRUE" *) wire [17:0] op8;
//    (* KEEP = "TRUE" *) wire [17:0] op9;
//    (* KEEP = "TRUE" *) wire [17:0] op10;
//    (* KEEP = "TRUE" *) wire [17:0] op11;

    reg [17:0] in12;
    reg [17:0] in13;
    reg [17:0] in14;
    reg [17:0] in15;
    reg [17:0] in16;
    reg [17:0] in17;
    wire [17:0] op8;
    wire [17:0] op9;
    wire [17:0] op10;
    wire [17:0] op11;
    
    always @(*)
    begin
        if(rst) begin
            in12 = 0;
            in13 = 0;
            in14 = 0;
            in15 = 0;
            in16 = 0;
            in17 = 0;
            end
        else if(start_div_eva) begin
            in12 = {5'd0, hits_eva_R};
            in13 = {2'd0, expectedLifetime_R};
            in14 = {4'd0, events_eva_R};
            in15 = {5'd0, hits_eva_NR};
            in16 = {2'd0, expectedLifetime_NR};
            in17 = {4'd0, events_eva_NR};
            end
        end
            

//////////////////// ************************ ////////////////////

//////////////******** DSP i/p & o/p MUX - EVA computation ********//////////////

//    (* KEEP = "TRUE" *) reg [47:0] in18;
//    (* KEEP = "TRUE" *) reg [17:0] in19;
//    (* KEEP = "TRUE" *) reg [47:0] in20;
//    (* KEEP = "TRUE" *) reg [17:0] in21;
//    (* KEEP = "TRUE" *) wire [47:0] op12;
//    (* KEEP = "TRUE" *) wire [47:0] op13;

    reg [47:0] in18;
    reg [17:0] in19;
    reg [47:0] in20;
    reg [17:0] in21;
    wire [47:0] op12;
    wire [47:0] op13;
    
    always @(*)
    begin
        if(rst) begin
            in18 = 0;
            in19 = 0;
            in20 = 0;
            in21 = 0;
            end
        else if(state == eva_dsp) begin
            in18 = {13'd0, op8, 17'd0};
            in19 = op9;
            in20 = {13'd0, op10, 17'd0};
            in21 = op11;
            end
        end

//////////////////// ************************ ////////////////////

//////////////**** updating counter values for EVA claculations ****//////////////

    integer a;
    always @(posedge clk)
    begin
        #0.1 if(rst) begin
            for(a=0; a<N; a=a+1) begin
                hitCtr_R_final[a]       = 0;
                evictionCtr_R_final[a]  = 0;
                hitCtr_NR_final[a]      = 0;
                evictionCtr_NR_final[a] = 0;
                end
            end
        else if(update_EVA) begin
            for(a=0; a<N; a=a+1) begin
                hitCtr_R_final[a]       = hitCtr_R_intermediate[a];
                evictionCtr_R_final[a]  = evictionCtr_R_intermediate[a];
                hitCtr_NR_final[a]      = hitCtr_NR_intermediate[a];
                evictionCtr_NR_final[a] = evictionCtr_NR_intermediate[a];
                end
            end
        end

    integer c;
    always @(posedge clk)
//    always @(*)
    begin
        #0.2 if(rst) begin
            for(c=0; c<N; c=c+1) begin
                hits_R_avgd[c]    = 0;
                events_R_avgd[c]  = 0;
                hits_NR_avgd[c]   = 0;
                events_NR_avgd[c] = 0;
                end
            end
        else if(state_delayed1 == average) begin
            hits_R_avgd[b_delayed1]    = op1[16:2];
            events_R_avgd[b_delayed1]  = op2[16:2];
            hits_NR_avgd[b_delayed1]   = op3[16:2];
            events_NR_avgd[b_delayed1] = op4[16:2];
            end
        end

    integer d;
    always @(posedge clk)
    begin
        #0.1 if(rst) begin
            for(d=0; d<N; d=d+1) begin
                hits_R[d]    = d;
                events_R[d]  = d;
                hits_NR[d]   = d;
                events_NR[d] = d;
                end
            end
        else if(state == addition) begin
            if(b == 7) begin
                hits_R[b]    = hits_R_avgd[b]    + hitCtr_R_final[b];
                events_R[b]  = events_R_avgd[b]  + hitCtr_R_final[b] + evictionCtr_R_final[b];
                hits_NR[b]   = hits_NR_avgd[b]   + hitCtr_NR_final[b];
                events_NR[b] = events_NR_avgd[b] + hitCtr_NR_final[b] + evictionCtr_NR_final[b];
                end
            else begin
                hits_R[b]    = hits_R[b+1]    + hits_R_avgd[b]    + hitCtr_R_final[b];
                events_R[b]  = events_R[b+1]  + events_R_avgd[b]  + hitCtr_R_final[b] + evictionCtr_R_final[b];
                hits_NR[b]   = hits_NR[b+1]   + hits_NR_avgd[b]   + hitCtr_NR_final[b];
                events_NR[b] = events_NR[b+1] + events_NR_avgd[b] + hitCtr_NR_final[b] + evictionCtr_NR_final[b];
                end
            end
        end

    always @(posedge clk)
    begin
        #0.1 if(rst) begin
            total_hits = 0;
            total_events = 0;
            end
        else if(add) begin
            if(b == 0) begin
                total_hits   = hits_R[b+1] + hits_R_avgd[b] + hitCtr_R_final[b] + hits_NR[b+1] + hits_NR_avgd[b] + hitCtr_NR_final[b];
                total_events = events_R[b+1]  + events_R_avgd[b]  + hitCtr_R_final[b] + evictionCtr_R_final[b] + events_NR[b+1] + events_NR_avgd[b] + hitCtr_NR_final[b] + evictionCtr_NR_final[b];
                end
            end
        end

//////////////////// ************************ ////////////////////

//////////////**** updating pac ****//////////////

    always @(posedge clk)
    begin
        #0.1 if(rst) begin
            pac = 0;
            end
        else if(state_delayed1 == cal_pac) begin
            pac = op1[34:17];
            end
        end

//////////////////// ************************ ////////////////////

//////////////**** updating EVA- processing ****//////////////

    always @(posedge clk)
    begin
        #0.09 if(rst) begin
            hits_eva_R = 0;
            hits_eva_NR = 0;
            events_eva_R = 0;
            events_eva_NR = 0;
            expectedLifetime_R = 0;
            expectedLifetime_NR = 0;
            end
        else if(state == cal_pac) begin
            hits_eva_R = 0;
            hits_eva_NR = 0;
            events_eva_R = 0;
            events_eva_NR = 0;
            expectedLifetime_R = 0;
            expectedLifetime_NR = 0;
            end
        else if(h_e_update) begin
            hits_eva_R = hits_eva_R + hitCtr_R_final[b];
            hits_eva_NR = hits_eva_NR + hitCtr_NR_final[b];
            events_eva_R = events_eva_R + hitCtr_R_final[b] + evictionCtr_R_final[b];
            events_eva_NR = events_eva_NR + hitCtr_NR_final[b] + evictionCtr_NR_final[b];
            end
        else if(el_update) begin
            expectedLifetime_R = expectedLifetime_R + events_eva_R;
            expectedLifetime_NR = expectedLifetime_NR + events_eva_NR;
            end
        end

//////////////////// ************************ ////////////////////

//////////////**** diffrentiate classes ****//////////////

    always @(posedge clk)
    begin
        #0.1 if(rst) begin
            diff = 0;
            end
        else if(state == cal_diff) begin
            diff = 18'b01_0000_0000_0000_0000 - {1'b0, h_R[0]};
            end
        end

//    (* KEEP = "TRUE" *) reg [19:0] in22;
//    (* KEEP = "TRUE" *) reg [19:0] in23;
//    (* KEEP = "TRUE" *) wire [19:0] op14;

    reg [19:0] in22;
    reg [19:0] in23;
    wire [19:0] op14;

    always @(*)
    begin
        if(rst) begin
            in22 = 0;
            in23 = 0;
            end
        else if(start_div_evaR) begin
            in22 = {eva_R[0], 2'd0};
            in23 = {diff[17], diff[17], diff[17], diff[17:1]};
            end
        end

    always @(*)
    begin
        if(rst) begin
            evaReused = 0;
            end
        else if(div_done_evaR) begin
            evaReused = op14;
            end
        end

//////////////////// ************************ ////////////////////

//////////////******** DSP i/p & o/p MUX - diffrentiate classes ********//////////////
    
    reg [17:0] in24;
    reg [17:0] in25;
    reg [47:0] in26;
    reg [17:0] in27;
    reg [47:0] in28;
    reg [17:0] in29;
    wire [47:0] op15;
    wire [47:0] op16;
    
    always @(*)
    begin
        if(rst) begin
            in24 = 0;
            in25 = 0;
            in26 = 0;
            in27 = 0;
            in28 = 0;
            in29 = 0;
            end
        else if(state == update_eva_value) begin
            in24 = hit_rate;
            in25 = evaReused[19:2];
            in26 = {13'd0, eva_R[b], 13'd0};
            in27 = {h_R[b], 1'd0};
            in28 = {13'd0, eva_NR[b], 13'd0};
            in29 = {h_NR[b], 1'd0};
            end
        end

//////////////////// ************************ ////////////////////

//////////////******** updating eva values********//////////////

    integer f;
    always @(posedge clk)
    begin
        if(rst) begin
            for(f=0; f<N; f=f+1) begin
                eva_R[f] = 0;
                eva_NR[f] = 0;
                end
            end
        else if(state == eva_dsp) begin
            if(b == 3'd6) begin
                eva_R[b+1] = 0;
                eva_NR[b+1] = 0;
                end
            else begin
                eva_R[b+1] = -op12[35:18];
                eva_NR[b+1] = -op13[35:18];
                end
            end
        else if(state == cal_diff) begin
            eva_R[b] = -op12[35:18];
            eva_NR[b] = -op13[35:18];
            end
        else if(state == update_eva_value) begin
            if(b<4) begin
                eva_R[b+4] = op15[35:18];
                eva_NR[b+4] = op16[35:18];
                end
            end
        else if(state == dummy_state4) begin
            eva_R[3] = op15[35:18];
            eva_NR[3] = op16[35:18];
            end
        else if(state == dummy_state5) begin
            eva_R[2] = op15[35:18];
            eva_NR[2] = op16[35:18];
            end
        else if(state == dummy_state6) begin
            eva_R[1] = op15[35:18];
            eva_NR[1] = op16[35:18];
            end
        else if(state == dummy_state7) begin
            eva_R[0] = op15[35:18];
            eva_NR[0] = op16[35:18];
            end        end
            

//////////////////// ************************ ////////////////////

///////////////////********** 2D_array to 1D_array conversion **********/////////////////        
       
    reg [18*N-1 : 0] eva_R_1D;
    reg [18*N-1 : 0] eva_NR_1D;
    
    integer g;
    always @(*)
    begin
        if(rst) begin
            eva_R_1D = 0;
            eva_NR_1D = 0;
            end
        else begin
            for (g=0;g<N;g=g+1) begin
                eva_R_1D[g*18 +: 18] = eva_R[g];
                eva_NR_1D[g*18 +: 18] = eva_NR[g];
                end
            end
        end

    always @(posedge clk)
    begin
        #0.1 if(start_sorting) begin
            start_sorting = 1'b0;
            end
        else if(state == dummy_state7) begin
            start_sorting = 1'b1;
            end
        else begin
            start_sorting = 1'b0;
            end
        end


////////////////// ****************** /////////////////////////

//////////////******** function call ********//////////////

    xbip_dsp48_macro_0 mul_R1(.CLK(clk), .A(in1), .B(in5), .P(op1)
                            );

    xbip_dsp48_macro_0 mul_R2(.CLK(clk), .A(in2), .B(in5), .P(op2)
                            );

    xbip_dsp48_macro_0 mul_NR1(.CLK(clk), .A(in3), .B(in5), .P(op3)
                            );

    xbip_dsp48_macro_0 mul_NR2(.CLK(clk), .A(in4), .B(in5), .P(op4)
                            );

    div_18 div1(.i_dividend(in6), .i_divisor(in7), .i_start(start_div_h), .i_clk(clk_5), .o_quotient_out(op5),
                .o_complete(div_h_done1), .o_overflow(overflow_hr)
                );

    div_18 div2(.i_dividend(in8), .i_divisor(in9), .i_start(start_div_h), .i_clk(clk_5), .o_quotient_out(op6),
                .o_complete(div_h_done2), .o_overflow(overflow_hr)
                );

    div_18 cal_hr(.i_dividend(in10), .i_divisor(in11), .i_start(start_div_hr), .i_clk(clk_5), .o_quotient_out(op7),
                .o_complete(div_done_hr), .o_overflow(overflow_hr)
                );

    div_4_14 eva_R1(.i_dividend(in12), .i_divisor(in14), .i_start(start_div_eva), .i_clk(clk_5), .o_quotient_out(op8),
                .o_complete(div_done_eva1), .o_overflow(overflow_hr)
                );

    div_4_14 eva_R2(.i_dividend(in13), .i_divisor(in14), .i_start(start_div_eva), .i_clk(clk_5), .o_quotient_out(op9),
                .o_complete(div_done_eva2), .o_overflow(overflow_hr)
                );

    div_4_14 eva_NR1(.i_dividend(in15), .i_divisor(in17), .i_start(start_div_eva), .i_clk(clk_5), .o_quotient_out(op10),
                .o_complete(div_done_eva3), .o_overflow(overflow_hr)
                );

    div_4_14 eva_NR2(.i_dividend(in16), .i_divisor(in17), .i_start(start_div_eva), .i_clk(clk_5), .o_quotient_out(op11),
                .o_complete(div_done_eva4), .o_overflow(overflow_hr)
                );

    xbip_dsp48_macro_1 eva_dsp_R(.CLK(clk), .A(in19), .B(pac), .C(in18), .P(op12)
                                );

    xbip_dsp48_macro_1 eva_dsp_NR(.CLK(clk), .A(in21), .B(pac), .C(in20), .P(op13)
                                );

    div_5_15 div_evaR(.i_dividend(in22), .i_divisor(in23), .i_start(start_div_evaR), .i_clk(clk_5), .o_quotient_out(op14),
                .o_complete(div_done_evaR), .o_overflow(overflow_hr)
                );

    xbip_dsp48_macro_2 diff_classe_R(.CLK(clk), .A(in24), .B(in25), .C(in26), .D(in27), .P(op15)
                                );

    xbip_dsp48_macro_2 diff_classe_NR(.CLK(clk), .A(in24), .B(in25), .C(in28), .D(in29), .P(op16)
                                );

    EVA_ArgSort sorting(.clk(clk), .rst(rst), .start(start_sorting), .in({eva_R_1D,eva_NR_1D}), .done_sorting(done_sorting), 
                        .sorted_index_1D(sorted_index_1D)
                        );

//////////////////// ************************ ////////////////////

endmodule
