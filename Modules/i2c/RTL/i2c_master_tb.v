`timescale 1us/1ns
module i2c_master_tb;

  // Parameters

  // Ports
  reg  clk;
  reg  rstn;
  wire  sda;
  wire  scl;
  reg  i2c_start;
  reg  clk1;

  i2c_master i2c_master_dut (
      .clk (clk),
      .rstn (rstn),
      .sda (sda),
      .scl (scl),
      .i2c_start (i2c_start),
      .clk1 (clk1)
    );

    initial begin
        clk = 0;
        #2 clk1 = 0;
        rstn = 1;
        i2c_start = 0;
        #12 rstn = 0;
        #30 rstn = 1;
        #100 i2c_start = 1;
        #20 i2c_start = 0;
        #500;
        $stop;
    end

  // clk: 100kHZ ; period: 10us
  always begin
     #5  clk =  ! clk;
     #5  clk1 = ! clk1;   
  end
endmodule
