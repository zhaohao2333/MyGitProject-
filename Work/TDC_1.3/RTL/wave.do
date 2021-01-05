onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_tdc/tdc_top_dut/DLL_Phase
add wave -noupdate /tb_tdc/tdc_top_dut/clk5
add wave -noupdate /tb_tdc/tdc_top_dut/clk
add wave -noupdate /tb_tdc/tdc_top_dut/rst_n
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_start
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_trigger
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_spaden
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_tgate
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Onum
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_INT
add wave -noupdate /tb_tdc/tdc_top_dut/start_reg_out
add wave -noupdate /tb_tdc/tdc_top_dut/start_data_out
add wave -noupdate /tb_tdc/tdc_top_dut/stop_reg_out
add wave -noupdate /tb_tdc/tdc_top_dut/stop_data_out
add wave -noupdate /tb_tdc/tdc_top_dut/cnt_start
add wave -noupdate /tb_tdc/tdc_top_dut/cnt_start_d
add wave -noupdate /tb_tdc/tdc_top_dut/cnt_en
add wave -noupdate /tb_tdc/tdc_top_dut/counter
add wave -noupdate /tb_tdc/tdc_top_dut/counter_reg_out
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_trigger
add wave -noupdate /tb_tdc/tdc_top_dut/clk5
add wave -noupdate /tb_tdc/tdc_top_dut/sync_inst0/s
add wave -noupdate /tb_tdc/tdc_top_dut/sync_inst0/stop_0
add wave -noupdate /tb_tdc/tdc_top_dut/sync_inst0/stop_1
add wave -noupdate /tb_tdc/tdc_top_dut/sync_inst0/vout
add wave -noupdate /tb_tdc/tdc_top_dut/sync
add wave -noupdate /tb_tdc/tdc_top_dut/out_valid
add wave -noupdate /tb_tdc/tdc_top_dut/tof
add wave -noupdate /tb_tdc/tdc_top_dut/tof_data
add wave -noupdate /tb_tdc/tdc_top_dut/INT_in
add wave -noupdate /tb_tdc/tdc_top_dut/INT
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Ovalid
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Oready
add wave -noupdate /tb_tdc/tdc_top_dut/hs
add wave -noupdate /tb_tdc/tdc_top_dut/clk5
add wave -noupdate /tb_tdc/tdc_top_dut/clk
add wave -noupdate /tb_tdc/tdc_top_dut/c_state
add wave -noupdate /tb_tdc/tdc_top_dut/n_state
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Odata
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Oint
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Olast
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2255000 ps} 0} {{Cursor 2} {20508370 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 155
configure wave -valuecolwidth 260
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
WaveRestoreZoom {17790169 ps} {22180877 ps}
