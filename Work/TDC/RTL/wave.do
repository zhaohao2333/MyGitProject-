onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_tdc_sync/tdc_top_dut/clk
add wave -noupdate /tb_tdc_sync/tdc_top_dut/rst
add wave -noupdate /tb_tdc_sync/tdc_top_dut/phase
add wave -noupdate /tb_tdc_sync/tdc_top_dut/start
add wave -noupdate /tb_tdc_sync/tdc_top_dut/light_pulse
add wave -noupdate /tb_tdc_sync/tdc_top_dut/start_data_out
add wave -noupdate /tb_tdc_sync/tdc_top_dut/stop_data_out
add wave -noupdate /tb_tdc_sync/tdc_top_dut/cnt_start
add wave -noupdate /tb_tdc_sync/tdc_top_dut/counter
add wave -noupdate /tb_tdc_sync/tdc_top_dut/sync_clk
add wave -noupdate /tb_tdc_sync/tdc_top_dut/stop_0
add wave -noupdate /tb_tdc_sync/tdc_top_dut/stop_1
add wave -noupdate /tb_tdc_sync/tdc_top_dut/s
add wave -noupdate /tb_tdc_sync/tdc_top_dut/sync
add wave -noupdate /tb_tdc_sync/tdc_top_dut/tof
add wave -noupdate /tb_tdc_sync/tdc_top_dut/counter_reg_out
add wave -noupdate /tb_tdc_sync/tdc_top_dut/out_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {333 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 179
configure wave -valuecolwidth 164
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
WaveRestoreZoom {274 ns} {1638 ns}
