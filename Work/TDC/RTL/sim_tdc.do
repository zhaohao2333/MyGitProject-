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
add wave -noupdate /tb_tdc/tdc_top_dut/phase
add wave -noupdate /tb_tdc/tdc_top_dut/clk
add wave -noupdate /tb_tdc/tdc_top_dut/rst
add wave -noupdate /tb_tdc/tdc_top_dut/start
add wave -noupdate /tb_tdc/tdc_top_dut/light_pulse
add wave -noupdate /tb_tdc/tdc_top_dut/start_reg_out
add wave -noupdate /tb_tdc/tdc_top_dut/start_data_out
add wave -noupdate /tb_tdc/tdc_top_dut/stop_reg_out
add wave -noupdate /tb_tdc/tdc_top_dut/stop_data_out
add wave -noupdate /tb_tdc/tdc_top_dut/cnt_start
add wave -noupdate /tb_tdc/tdc_top_dut/counter
add wave -noupdate /tb_tdc/tdc_top_dut/sync_clk
add wave -noupdate /tb_tdc/tdc_top_dut/s
add wave -noupdate /tb_tdc/tdc_top_dut/stop_0
add wave -noupdate /tb_tdc/tdc_top_dut/stop_1
add wave -noupdate /tb_tdc/tdc_top_dut/sync_clk_i
add wave -noupdate /tb_tdc/tdc_top_dut/vout
add wave -noupdate /tb_tdc/tdc_top_dut/sync
add wave -noupdate /tb_tdc/tdc_top_dut/counter_reg_out
add wave -noupdate /tb_tdc/tdc_top_dut/tof
add wave -noupdate /tb_tdc/tdc_top_dut/out_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1013 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 164
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ns} {1452 ns}
# =========================<     仿真时间     >===============================

run -all
