onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sort/clk
add wave -noupdate /tb_sort/rst_n
add wave -noupdate /tb_sort/int
add wave -noupdate /tb_sort/data
add wave -noupdate /tb_sort/sort_dut/data_reg
add wave -noupdate /tb_sort/sort_dut/int_reg
add wave -noupdate /tb_sort/sort_dut/int_reg_min1
add wave -noupdate /tb_sort/sort_dut/int_reg_min2
add wave -noupdate /tb_sort/sort_dut/sel1
add wave -noupdate /tb_sort/sort_dut/sel2
add wave -noupdate /tb_sort/sort_dut/sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {339 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 267
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1196 ns}
