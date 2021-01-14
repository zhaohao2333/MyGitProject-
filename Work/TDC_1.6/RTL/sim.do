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
vsim -novopt work.tb_tdc_his


# =========================<     添加波形     >===============================
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_tdc_his/rst_n
add wave -noupdate /tb_tdc_his/rst
add wave -noupdate /tb_tdc_his/TDC_start
add wave -noupdate /tb_tdc_his/TDC_trigger
add wave -noupdate /tb_tdc_his/TDC_spaden
add wave -noupdate /tb_tdc_his/TDC_tgate
add wave -noupdate /tb_tdc_his/TDC_Odata
add wave -noupdate /tb_tdc_his/TDC_Oint
add wave -noupdate /tb_tdc_his/TDC_Onum
add wave -noupdate /tb_tdc_his/TDC_Olast
add wave -noupdate /tb_tdc_his/TDC_Ovalid
add wave -noupdate /tb_tdc_his/TDC_Oready
add wave -noupdate /tb_tdc_his/TDC_INT
add wave -noupdate /tb_tdc_his/TDC_Range
add wave -noupdate /tb_tdc_his/photon
add wave -noupdate /tb_tdc_his/rst_auto
add wave -noupdate /tb_tdc_his/HIS_En
add wave -noupdate /tb_tdc_his/HIS_TH
add wave -noupdate /tb_tdc_his/HIS_Ibatch
add wave -noupdate /tb_tdc_his/HIS_Odata
add wave -noupdate /tb_tdc_his/HIS_Oready
add wave -noupdate /tb_tdc_his/HIS_Ovalid
add wave -noupdate -radix decimal /tb_tdc_his/tdc_start/delay
add wave -noupdate /tb_tdc_his/tdc_top_dut/start_reg_out
add wave -noupdate /tb_tdc_his/tdc_top_dut/stop_reg_out
add wave -noupdate /tb_tdc_his/tdc_top_dut/counter_in
add wave -noupdate /tb_tdc_his/tdc_top_dut/cnt_start
add wave -noupdate /tb_tdc_his/tdc_top_dut/sync
add wave -noupdate /tb_tdc_his/tdc_top_dut/light_level
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_in
add wave -noupdate /tb_tdc_his/tdc_top_dut/cnt_start_d
add wave -noupdate /tb_tdc_his/tdc_top_dut/cnt_en
add wave -noupdate /tb_tdc_his/tdc_top_dut/hs
add wave -noupdate /tb_tdc_his/tdc_top_dut/n_state
add wave -noupdate /tb_tdc_his/tdc_top_dut/c_state
add wave -noupdate /tb_tdc_his/tdc_top_dut/Ovalid
add wave -noupdate /tb_tdc_his/tdc_top_dut/Ovalid_d
add wave -noupdate /tb_tdc_his/tdc_top_dut/Ovalid_d1
add wave -noupdate /tb_tdc_his/tdc_top_dut/Ovalid_d2
add wave -noupdate /tb_tdc_his/tdc_top_dut/Ovalid_d3
add wave -noupdate /tb_tdc_his/tdc_top_dut/trans_done
add wave -noupdate /tb_tdc_his/tdc_top_dut/tri_ign
add wave -noupdate /tb_tdc_his/tdc_top_dut/clr_n
add wave -noupdate /tb_tdc_his/tdc_top_dut/rst
add wave -noupdate /tb_tdc_his/tdc_top_dut/TDC_Ovalid_d
add wave -noupdate /tb_tdc_his/tdc_top_dut/shift_tri
add wave -noupdate /tb_tdc_his/tdc_top_dut/num
add wave -noupdate /tb_tdc_his/tdc_top_dut/counter
add wave -noupdate /tb_tdc_his/tdc_top_dut/counter_reg_out
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof
add wave -noupdate /tb_tdc_his/tdc_top_dut/range
add wave -noupdate /tb_tdc_his/tdc_top_dut/cal_stop
add wave -noupdate /tb_tdc_his/tdc_top_dut/out_valid
add wave -noupdate /tb_tdc_his/tdc_top_dut/cal_en
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_out
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_valid
add wave -noupdate /tb_tdc_his/tdc_top_dut/decode_in
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_en
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_out_valid
add wave -noupdate /tb_tdc_his/tdc_top_dut/dec_valid
add wave -noupdate /tb_tdc_his/tdc_top_dut/cnt
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_stop
add wave -noupdate /tb_tdc_his/tdc_top_dut/sync_inst0/s
add wave -noupdate /tb_tdc_his/tdc_top_dut/sync_inst0/TDC_trigger
add wave -noupdate /tb_tdc_his/tdc_top_dut/sync_inst0/rst_n
add wave -noupdate /tb_tdc_his/tdc_top_dut/sync_inst0/sync
add wave -noupdate /tb_tdc_his/tdc_top_dut/sync_inst0/stop_0
add wave -noupdate /tb_tdc_his/tdc_top_dut/sync_inst0/stop_1
add wave -noupdate /tb_tdc_his/tdc_top_dut/sync_inst0/vout
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/rst_n
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/decode_in
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/tof_data_in
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/cal_en
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/cal_stop
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/out_valid
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/dec_valid
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/cnt
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/TDC_Onum
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/counter_in
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/range
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/tof
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/decode
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/norbuf
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/sel1
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/sel2
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/sel3
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/dec_shift
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/start_dec_data
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/comp
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/comp_done
add wave -noupdate /tb_tdc_his/tdc_top_dut/tof_cal_inst/comp_done_d
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_cal_inst/INT
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_cal_inst/cal_en
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_cal_inst/int_out
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_cal_inst/out_valid
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_cal_inst/cal_stop
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_cal_inst/shift_tri
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_cal_inst/int_data
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_cal_inst/cnt
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_cal_inst/data_en
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_cal_inst/INT_shift
add wave -noupdate /tb_tdc_his/tdc_top_dut/int_cal_inst/cal_en_d1
add wave -noupdate /tb_tdc_his/spad_module_dut/photon
add wave -noupdate /tb_tdc_his/spad_module_dut/rst_auto
add wave -noupdate /tb_tdc_his/spad_module_dut/trig
add wave -noupdate /tb_tdc_his/spad_module_dut/time_gate
add wave -noupdate /tb_tdc_his/histogram_dut/HIS_En
add wave -noupdate /tb_tdc_his/histogram_dut/HIS_TH
add wave -noupdate /tb_tdc_his/histogram_dut/TDC_Oint
add wave -noupdate /tb_tdc_his/histogram_dut/HIS_Ibatch
add wave -noupdate /tb_tdc_his/histogram_dut/TDC_Odata
add wave -noupdate /tb_tdc_his/histogram_dut/TDC_Ovalid
add wave -noupdate /tb_tdc_his/histogram_dut/TDC_Oready
add wave -noupdate /tb_tdc_his/histogram_dut/HIS_Odata
add wave -noupdate /tb_tdc_his/histogram_dut/HIS_Oready
add wave -noupdate /tb_tdc_his/histogram_dut/HIS_Ovalid
add wave -noupdate /tb_tdc_his/histogram_dut/TDC_Onum
add wave -noupdate /tb_tdc_his/histogram_dut/Q_4bit
add wave -noupdate /tb_tdc_his/histogram_dut/count_max_en
add wave -noupdate /tb_tdc_his/histogram_dut/count_max_Oready
add wave -noupdate /tb_tdc_his/histogram_dut/max_4bit
add wave -noupdate /tb_tdc_his/histogram_dut/count_max_Ovalid
add wave -noupdate /tb_tdc_his/histogram_dut/count_max_hs
add wave -noupdate /tb_tdc_his/histogram_dut/TDC_hs
add wave -noupdate /tb_tdc_his/histogram_dut/HIS_hs
add wave -noupdate /tb_tdc_his/histogram_dut/count_max_out_first
add wave -noupdate /tb_tdc_his/histogram_dut/count_max_out_second
add wave -noupdate /tb_tdc_his/histogram_dut/count_max_out_third
add wave -noupdate /tb_tdc_his/histogram_dut/HIS_Odata_reg
add wave -noupdate /tb_tdc_his/histogram_dut/HIS_Ovalid_reg
add wave -noupdate /tb_tdc_his/histogram_dut/HIS_Ibatch1
add wave -noupdate /tb_tdc_his/histogram_dut/HIS_Ibatch2
add wave -noupdate /tb_tdc_his/histogram_dut/TDC_hs_cnt
add wave -noupdate /tb_tdc_his/histogram_dut/TDC_hs_set_num
add wave -noupdate /tb_tdc_his/histogram_dut/detection_peak
add wave -noupdate /tb_tdc_his/histogram_dut/detection_peak_minus1
add wave -noupdate /tb_tdc_his/histogram_dut/FSM_en
add wave -noupdate /tb_tdc_his/histogram_dut/NS
add wave -noupdate /tb_tdc_his/histogram_dut/CS
add wave -noupdate /tb_tdc_his/histogram_dut/judge_out
add wave -noupdate /tb_tdc_his/histogram_dut/uut/Q_4bit
add wave -noupdate /tb_tdc_his/histogram_dut/uut/count_max_en
add wave -noupdate /tb_tdc_his/histogram_dut/uut/count_max_Oready
add wave -noupdate /tb_tdc_his/histogram_dut/uut/max_4bit
add wave -noupdate /tb_tdc_his/histogram_dut/uut/count_max_Ovalid
add wave -noupdate /tb_tdc_his/histogram_dut/uut/count_max_hs
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_00
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_01
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_02
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_03
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_04
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_05
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_06
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_07
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_08
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_09
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_10
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_11
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_12
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_13
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_14
add wave -noupdate /tb_tdc_his/histogram_dut/uut/cnt_15
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_00
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_01
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_02
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_03
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_04
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_05
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_06
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_07
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_08
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_09
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_10
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_11
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_12
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_13
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_14
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_15
add wave -noupdate /tb_tdc_his/histogram_dut/uut/bin_cnt_all
add wave -noupdate /tb_tdc_his/histogram_dut/uut/d
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {416798 ns} 0} {{Cursor 2} {7410 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 434
configure wave -valuecolwidth 100
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {495712 ns}








# =========================<     仿真时间     >===============================

run -all
