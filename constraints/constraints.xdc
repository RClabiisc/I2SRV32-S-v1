set_false_path -from [get_pins {cpu1/fdem/mh/icache1/set0/U0/inst_blk_mem_gen/gnbram.gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[*].ram.r/prim_noinit.ram/DEVICE_7SERIES.NO_BMM_INFO.SP.WIDE_PRIM36.ram/CLK*}]
set_false_path -from [get_pins {cpu1/fdem/mh/icache1/set1/U0/inst_blk_mem_gen/gnbram.gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[*].ram.r/prim_noinit.ram/DEVICE_7SERIES.NO_BMM_INFO.SP.WIDE_PRIM36.ram/CLK*}]
set_false_path -from [get_pins {cpu1/fdem/mh/icache1/tag*_v_dirty/U0/inst_blk_mem_gen/gnbram.gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[*].ram.r/prim_init.ram/DEVICE_7SERIES.NO_BMM_INFO.SP.WIDE_PRIM18.ram/CLK*}]
set_false_path -from [get_pins {cpu1/fdem/db1/dt1/dd/tag_w*/U0/inst_blk_mem_gen/gnbram.gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[*].ram.r/prim_noinit.ram/DEVICE_7SERIES.NO_BMM_INFO.TRUE_DP.SIMPLE_PRIM36.ram/CLK*}]

set_false_path -from [get_pins {em1/Main/U0/inst_blk_mem_gen/gnbram.gnative_mem_map_bmg.native_mem_map_blk_mem_gen/valid.cstr/has_mux_a.A/no_softecc_sel_reg.ce_pri.sel_pipe_reg[*]/*}]
set_false_path -from [get_pins {em1/Main/U0/inst_blk_mem_gen/gnbram.gnative_mem_map_bmg.native_mem_map_blk_mem_gen/valid.cstr/ramloop[*].ram.r/prim_init.ram/DEVICE_7SERIES.WITH_BMM_INFO.SP.SIMPLE_PRIM36.ram/CLK*}]

set_false_path -to [get_pins {cpu1/fdem/db1/dt1/dd/ram_w*/U0/inst_blk_mem_gen/gnbram.gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[*].ram.r/prim_noinit.ram/DEVICE_7SERIES.NO_BMM_INFO.TRUE_DP.SIMPLE_PRIM36.ram/*[*]}]

set_false_path -to [get_pins {em1/Main/U0/inst_blk_mem_gen/gnbram.gnative_mem_map_bmg.native_mem_map_blk_mem_gen/valid.cstr/ramloop[*].ram.r/prim_init.ram/DEVICE_7SERIES.WITH_BMM_INFO.SP.SIMPLE_PRIM36.ram/*[*]}]
set_false_path -to [get_pins {em1/Main/U0/inst_blk_mem_gen/gnbram.gnative_mem_map_bmg.native_mem_map_blk_mem_gen/valid.cstr/ramloop[*].ram.r/prim_init.ram/DEVICE_7SERIES.WITH_BMM_INFO.SP.SIMPLE_PRIM36.ram/EN*}]

set_false_path -setup -from [get_pins rst_reg/C]

set_multicycle_path -setup -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_add/FPADD_DP] 4
set_multicycle_path -setup -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_add/FPADD_SP] 3
set_multicycle_path -setup -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_mult/FPMULT_DP] 3
set_multicycle_path -setup -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_mult/FPMULT_SP] 2
set_multicycle_path -setup -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_div/FPDIV_DP] 15
set_multicycle_path -setup -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_div/FPDIV_SP] 6
set_multicycle_path -setup -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_sqrt/FPSQRT_DP] 12
set_multicycle_path -setup -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_sqrt/FPSQRT_SP] 5

set_multicycle_path -hold -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_add/FPADD_DP] 3
set_multicycle_path -hold -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_add/FPADD_SP] 2
set_multicycle_path -hold -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_mult/FPMULT_DP] 2
set_multicycle_path -hold -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_mult/FPMULT_SP] 1
set_multicycle_path -hold -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_div/FPDIV_DP] 14
set_multicycle_path -hold -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_div/FPDIV_SP] 5
set_multicycle_path -hold -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_sqrt/FPSQRT_DP] 11
set_multicycle_path -hold -through [get_cells cpu1/fdem/Pipeline/FP_EX/Floating_point_unit/fpu_sqrt/FPSQRT_SP] 4

set_property PACKAGE_PIN AM39 [get_ports {led[0]}]
set_property PACKAGE_PIN AN39 [get_ports {led[1]}]
set_property PACKAGE_PIN AR37 [get_ports {led[2]}]
set_property PACKAGE_PIN AT37 [get_ports {led[3]}]
set_property PACKAGE_PIN AR35 [get_ports {led[4]}]
set_property PACKAGE_PIN AP41 [get_ports {led[5]}]
set_property PACKAGE_PIN AP42 [get_ports {led[6]}]
set_property PACKAGE_PIN AU39 [get_ports {led[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[7]}]


set_property PACKAGE_PIN AU33 [get_ports srx_pad_i]
set_property PACKAGE_PIN AU36 [get_ports stx_pad_o]


set_property IOSTANDARD LVCMOS18 [get_ports srx_pad_i]
set_property IOSTANDARD LVCMOS18 [get_ports stx_pad_o]


set_property PACKAGE_PIN AV40 [get_ports rst_in]
set_property IOSTANDARD LVCMOS18 [get_ports rst_in]

set_property PACKAGE_PIN E19 [get_ports clk_in1_p]
set_property IOSTANDARD LVDS [get_ports clk_in1_p]



set_property PACKAGE_PIN AU38 [get_ports {int_in[0]}]
set_property PACKAGE_PIN AP40 [get_ports {int_in[1]}]
set_property PACKAGE_PIN AV39 [get_ports {int_in[2]}]


set_property IOSTANDARD LVCMOS18 [get_ports {int_in[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {int_in[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {int_in[2]}]

#----------------------LCD--------------------------------

set_property PACKAGE_PIN AT42 [get_ports {lcd_data_o[0]}]
set_property PACKAGE_PIN AR38 [get_ports {lcd_data_o[1]}]
set_property PACKAGE_PIN AR39 [get_ports {lcd_data_o[2]}]
set_property PACKAGE_PIN AN40 [get_ports {lcd_data_o[3]}]
set_property PACKAGE_PIN AT40 [get_ports lcd_en_o]
set_property PACKAGE_PIN AN41 [get_ports lcd_rs_o]
set_property PACKAGE_PIN AR42 [get_ports lcd_rw_o]


set_property IOSTANDARD LVCMOS18 [get_ports {lcd_data_o[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {lcd_data_o[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {lcd_data_o[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {lcd_data_o[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports lcd_en_o]
set_property IOSTANDARD LVCMOS18 [get_ports lcd_rs_o]
set_property IOSTANDARD LVCMOS18 [get_ports lcd_rw_o]


set_property PACKAGE_PIN AV30 [get_ports {temp_set_in[0]}]
set_property PACKAGE_PIN AY33 [get_ports {temp_set_in[1]}]
set_property PACKAGE_PIN BA31 [get_ports {temp_set_in[2]}]
set_property PACKAGE_PIN BA32 [get_ports {temp_set_in[3]}]
set_property PACKAGE_PIN AW30 [get_ports {temp_set_in[4]}]
set_property PACKAGE_PIN AY30 [get_ports {temp_set_in[5]}]
set_property PACKAGE_PIN BA30 [get_ports {temp_set_in[6]}]
set_property PACKAGE_PIN BB31 [get_ports {temp_set_in[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports {temp_set_in[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {temp_set_in[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {temp_set_in[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {temp_set_in[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {temp_set_in[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {temp_set_in[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {temp_set_in[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {temp_set_in[7]}]

set_property PACKAGE_PIN AW40 [get_ports temp_set_en]
set_property IOSTANDARD LVCMOS18 [get_ports temp_set_en]
#--------------------------------------------------------

#set_property PACKAGE_PIN AN40 [get_ports pwm_o]
#set_property IOSTANDARD LVCMOS18 [get_ports pwm_o]


set_property PACKAGE_PIN AA21 [get_ports vp_in]

set_property PACKAGE_PIN BB24 [get_ports pwm_o]
set_property IOSTANDARD LVCMOS18 [get_ports pwm_o]
set_property PACKAGE_PIN BB23 [get_ports buzzer_o]
set_property IOSTANDARD LVCMOS18 [get_ports buzzer_o]
#set_property PACKAGE_PIN AN31 [get_ports pwm_sma]
#set_property IOSTANDARD LVCMOS18 [get_ports pwm_sma]




