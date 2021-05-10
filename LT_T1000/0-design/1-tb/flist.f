// compile options
+v2k
-sverilog
-timescale=1ns/10fs

// source file path
+incdir+../0-rtl
+incdir+./

// source file
../0-rtl/tdc_top.v
../0-rtl/tof_cal.v
../0-rtl/sync.v
../0-rtl/apd_module.v
../0-rtl/latch_model.v
../0-rtl/counter.v
// testbench file
./tb_tdc.v
