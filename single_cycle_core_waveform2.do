onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix hexadecimal /single_cycle_core_testbench/reset
add wave -noupdate -format Logic -radix hexadecimal /single_cycle_core_testbench/clk
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_insn
add wave -noupdate -format Literal -radix unsigned /single_cycle_core_testbench/uut/sig_insn_if


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
