onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_decode/rst
add wave -noupdate /tb_decode/clk
add wave -noupdate /tb_decode/phase
add wave -noupdate /tb_decode/data_in
add wave -noupdate /tb_decode/decode_inst/i
add wave -noupdate /tb_decode/decode_inst/data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 277
configure wave -valuecolwidth 218
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
WaveRestoreZoom {0 ns} {811 ns}
