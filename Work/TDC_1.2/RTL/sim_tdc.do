# ========================< 清空软件残留信息 >==============================

# 退出之前仿真
quit -sim

# 清空信息
.main clear

# =========================< 建立工程并仿真 >===============================

# 建立新的工程库
vlib work

# 映射逻辑库到物理目录
vmap work work

# 编译仿真文件(testbench)
vlog *.v

# 无优化simulation  *** 请修改文件名 ***
# vsim -novopt -L lpm -L altera_mf -L cyclone -L altera_primitive work.tb_fsm
vsim -novopt work.tb_tdc 


# =========================<     添加波形     >===============================
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
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Odata
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Oint
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Onum
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Olast
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Ovalid
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_Oready
add wave -noupdate /tb_tdc/tdc_top_dut/TDC_INT
add wave -noupdate /tb_tdc/tdc_top_dut/start_reg_out
add wave -noupdate /tb_tdc/tdc_top_dut/start_data_out
add wave -noupdate /tb_tdc/tdc_top_dut/stop_reg_out
add wave -noupdate /tb_tdc/tdc_top_dut/stop_data_out
add wave -noupdate /tb_tdc/tdc_top_dut/cnt_start
add wave -noupdate /tb_tdc/tdc_top_dut/counter
add wave -noupdate /tb_tdc/tdc_top_dut/sync
add wave -noupdate /tb_tdc/tdc_top_dut/counter_reg_out
add wave -noupdate /tb_tdc/tdc_top_dut/out_valid
add wave -noupdate /tb_tdc/tdc_top_dut/tof
add wave -noupdate /tb_tdc/tdc_top_dut/light_level
add wave -noupdate /tb_tdc/tdc_top_dut/INT_in
add wave -noupdate /tb_tdc/tdc_top_dut/tof_data
add wave -noupdate /tb_tdc/tdc_top_dut/INT
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1353000 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 223
configure wave -valuecolwidth 397
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
WaveRestoreZoom {207782 ps} {2642555 ps}

# =========================<     仿真时间     >===============================

run -all
