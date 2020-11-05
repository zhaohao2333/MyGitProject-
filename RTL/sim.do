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
vsim -novopt work.afifo_tb 


# =========================<     添加波形     >===============================
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {write logic}
add wave -noupdate /afifo_tb/fifo1/wrst_n
add wave -noupdate /afifo_tb/fifo1/winc
add wave -noupdate /afifo_tb/fifo1/wfull
add wave -noupdate /afifo_tb/fifo1/wen
add wave -noupdate /afifo_tb/fifo1/wfull_almost
add wave -noupdate /afifo_tb/fifo1/wdata
add wave -noupdate -radix unsigned /afifo_tb/fifo1/w_rptr
add wave -noupdate -radix unsigned /afifo_tb/fifo1/wgap
add wave -noupdate -divider {read logic}
add wave -noupdate /afifo_tb/fifo1/rinc
add wave -noupdate /afifo_tb/fifo1/ren
add wave -noupdate /afifo_tb/fifo1/rdata
add wave -noupdate /afifo_tb/fifo1/rrst_n
add wave -noupdate -radix unsigned /afifo_tb/fifo1/wptr
add wave -noupdate -radix unsigned /afifo_tb/fifo1/rptr
add wave -noupdate -radix unsigned /afifo_tb/fifo1/w_rptr_g1
add wave -noupdate -radix unsigned /afifo_tb/fifo1/w_rptr_g2
add wave -noupdate -expand -group {New Group} /afifo_tb/fifo1/wclk
add wave -noupdate -expand -group {New Group} -radix unsigned /afifo_tb/fifo1/wptr
add wave -noupdate -expand -group {New Group} -radix unsigned /afifo_tb/fifo1/wptr_g
add wave -noupdate -expand -group {New Group} /afifo_tb/fifo1/rclk
add wave -noupdate -expand -group {New Group} -radix unsigned -childformat {{{/afifo_tb/fifo1/r_wptr_g1[8]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr_g1[7]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr_g1[6]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr_g1[5]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr_g1[4]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr_g1[3]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr_g1[2]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr_g1[1]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr_g1[0]} -radix unsigned}} -subitemconfig {{/afifo_tb/fifo1/r_wptr_g1[8]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr_g1[7]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr_g1[6]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr_g1[5]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr_g1[4]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr_g1[3]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr_g1[2]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr_g1[1]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr_g1[0]} {-height 18 -radix unsigned}} /afifo_tb/fifo1/r_wptr_g1
add wave -noupdate -expand -group {New Group} -radix unsigned /afifo_tb/fifo1/r_wptr_g2
add wave -noupdate -expand -group {New Group} -radix unsigned -childformat {{{/afifo_tb/fifo1/r_wptr[8]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[7]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[6]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[5]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[4]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[3]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[2]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[1]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[0]} -radix unsigned}} -subitemconfig {{/afifo_tb/fifo1/r_wptr[8]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[7]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[6]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[5]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[4]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[3]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[2]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[1]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[0]} {-height 18 -radix unsigned}} /afifo_tb/fifo1/r_wptr
add wave -noupdate -expand -group {New Group1} /afifo_tb/fifo1/rclk
add wave -noupdate -expand -group {New Group1} -radix unsigned -childformat {{{/afifo_tb/fifo1/r_wptr[8]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[7]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[6]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[5]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[4]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[3]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[2]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[1]} -radix unsigned} {{/afifo_tb/fifo1/r_wptr[0]} -radix unsigned}} -subitemconfig {{/afifo_tb/fifo1/r_wptr[8]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[7]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[6]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[5]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[4]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[3]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[2]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[1]} {-height 18 -radix unsigned} {/afifo_tb/fifo1/r_wptr[0]} {-height 18 -radix unsigned}} /afifo_tb/fifo1/r_wptr
add wave -noupdate -expand -group {New Group1} -radix unsigned /afifo_tb/fifo1/rptr
add wave -noupdate -expand -group {New Group1} -radix unsigned /afifo_tb/fifo1/rgap
add wave -noupdate -expand -group {New Group1} /afifo_tb/fifo1/rempty_almost
add wave -noupdate -expand -group {New Group1} /afifo_tb/fifo1/rempty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9050538 ps} 0} {{Cursor 2} {8835632 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
configure wave -valuecolwidth 73
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
WaveRestoreZoom {8621506 ps} {9050538 ps}


# =========================<     仿真时间     >===============================

run -all
