onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix hexadecimal /single_cycle_core_testbench/reset
add wave -noupdate -format Logic -radix hexadecimal /single_cycle_core_testbench/clk
add wave -noupdate -format Literal -radix decimal /single_cycle_core_testbench/uut/sig_curr_pc_if
add wave -noupdate -format Literal -radix decimal /single_cycle_core_testbench/uut/sig_curr_pc_id
add wave -noupdate -format Literal -radix decimal /single_cycle_core_testbench/uut/sig_next_pc
add wave -noupdate -format Literal -radix decimal /single_cycle_core_testbench/uut/sig_stall
add wave -noupdate -format Literal -radix decimal /single_cycle_core_testbench/uut/sig_pc_src
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_insn_if
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_insn_id
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_insn_pc
add wave -noupdate -format Literal -radix decimal /single_cycle_core_testbench/uut/sig_pc_stage_if
add wave -noupdate -format Literal -radix decimal /single_cycle_core_testbench/uut/sig_pc_stage_id
add wave -noupdate -format Literal -radix decimal /single_cycle_core_testbench/uut/sig_pc_stage_ex
add wave -noupdate -format Literal -radix decimal /single_cycle_core_testbench/uut/sig_pc_stage_dm
add wave -noupdate -format Literal -radix decimal /single_cycle_core_testbench/uut/sig_pc_stage_wb 

add wave -noupdate -format Literal -radix unsigned -expand /single_cycle_core_testbench/uut/reg_file/sig_regfile

add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_b_or_jmp
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_pc_src
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_reg_if_id_bubble
add wave -noupdate -format Literal -radix decimal /single_cycle_core_testbench/uut/sig_curr_pc_id
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_insn_id
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_jmp_flag

add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_reg_read_a_ex
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_reg_read_b_ex
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_write_register_dm
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_write_register_wb
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_src_a_ctrl
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_haz_res_src_a
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_src_b_ctrl
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_haz_res_src_b
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_fwd_dm_or_w_a
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_fwd_src_a
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_fwd_dm_or_w_b
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_fwd_src_b

add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/insn_mem/sig_insn_mem
add wave -noupdate -format Literal -radix unsigned -expand /single_cycle_core_testbench/uut/data_mem/sig_data_mem

add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_reg_write_id
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_reg_write_ex
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_reg_write_dm
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_reg_write_wb

add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_read_data_a_id
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_read_data_a_ex
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_alu_src_b
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_read_data_b_id
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_read_data_b_ex
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_read_data_b_dm
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_alu_result_ex
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_alu_result_dm
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_alu_result_wb
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_write_register_id
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_write_register_ex
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_write_register_dm
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_write_register_wb
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_data_mem_out_dm
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_data_mem_out_wb



TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 205
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {3633 ns}
