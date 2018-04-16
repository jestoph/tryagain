onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix hexadecimal /single_cycle_core_testbench/reset
add wave -noupdate -format Logic -radix hexadecimal /single_cycle_core_testbench/clk
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_curr_pc
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_next_pc
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/insn_mem/sig_addr_in1
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/insn_mem/sig_addr_in2
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_jump_pc
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_comp_eq
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_insn
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_sign_extended_offset
add wave -noupdate -format Logic -radix hexadecimal /single_cycle_core_testbench/uut/sig_reg_dst
add wave -noupdate -format Logic -radix hexadecimal /single_cycle_core_testbench/uut/sig_reg_write
add wave -noupdate -format Logic -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_src
add wave -noupdate -format Logic -radix hexadecimal /single_cycle_core_testbench/uut/sig_mem_write
add wave -noupdate -format Logic -radix hexadecimal /single_cycle_core_testbench/uut/sig_mem_to_reg
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_write_register
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_write_data
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_read_data_a
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_read_data_b
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_src_b
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_result
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_data_mem_out
add wave -noupdate -format Literal -radix unsigned -expand /single_cycle_core_testbench/uut/reg_file/sig_regfile
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/insn_mem/sig_insn_mem
add wave -noupdate -format Literal -radix unsigned -expand /single_cycle_core_testbench/uut/data_mem/sig_data_mem
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_op
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_alu_type
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_sll_result
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/sig_srl_result
add wave -noupdate -format Literal -radix unsigned -expand /single_cycle_core_testbench/uut/shf_r/sig_srl_16b
add wave -noupdate -format Literal -radix unsigned -expand /single_cycle_core_testbench/uut/shf_l/sig_sll_16b
add wave -noupdate -format Literal -radix hexadecimal /single_cycle_core_testbench/uut/shf_r/sig_srl_test
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/alu/sig_alu_src_a
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/alu/sig_alu_src_b
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_reg_write
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
