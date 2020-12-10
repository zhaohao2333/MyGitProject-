`timescale 1ns/1ns
module tb_tdc;

// Parameters

// Ports
reg    [31:0]   phase;
reg             clk;
reg             rst;
reg             start;
reg             light_pulse;
wire   [12:0]   tof;
wire    	    out_valid;

tdc_top tdc_top_dut(
    .phase (phase),
    .clk (clk),
    .rst (rst),
    .start (start),
    .light_pulse (light_pulse),
    .tof (tof),
    .out_valid (out_valid)
);

initial begin
    begin
        clk = 0;
        rst = 1;
        start = 0;
        light_pulse = 0;
    // start
        #5 rst = 0;
        #20 rst = 1;
        //#28 start = 1;
        #228 start = 1;
        #200 start = 0;
    // stop
        //#1000 light_pulse = 1; //done
        #900 light_pulse = 1; //done
        //#800 light_pulse = 1; //done 
        //#40 light_pulse = 1; //done
        //#350 light_pulse = 0;
        #350 light_pulse = 0;
        #300 ;
        $finish;
    end
end

always #5 clk = !clk;

//---------------------------------

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        phase <= 32'b1111_1111_1111_1111_0000_0000_0000_0000;
    end
    else begin
        phase <= {phase[0], phase[31:1]};
    end
end

endmodule
