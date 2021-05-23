`timescale 1ns/1ps
module tb_efuse;

logic clk_osc=0;
logic rst_n;
// read and program start pulse
logic read_start;
logic read_ack;  // last for one clock cycle
logic [31:0] dout;
logic dout_valid;    // valid for one clock cycle
logic [31:0] efuse_din;       // valid with start pulse, make sure this data valid until ack
logic prog_start;           

logic prog_ack;              // last for one cycle
logic EFUSE_CS;
logic EFUSE_PGM;
logic EFUSE_SCLK;
logic EFUSE_RW;
wire  EFUSE_DOUT;

always #20 clk_osc = ~clk_osc;

initial begin
    // rst generate
    rst_n <= 1;
    prog_start <='0;
    read_start <='0;
    #50ns rst_n  <= 0;
    #200ns rst_n <=1;
    #1us;
    repeat(1) begin
        @(negedge clk_osc) 
        assert(std::randomize(efuse_din));
        // efuse_din  <= 32'habcdef01;
        prog_start <= 1'b1;
        
        // @(posedge prog_ack)
        wait (prog_ack);
        // #200ns
        prog_start <=1'b0;

        #330us
        @(negedge clk_osc)
        read_start <=1'b1;
        
        // @(posedge read_ack)
        wait (read_ack);
        // #200ns
        read_start <=1'b0;
        
        #41us
        wait(dout_valid);
        if(dout!=efuse_din) begin
            $display("Test failed");
            $finish;
        end 
        #100ns;
    end

    #100ns;
    $display ("Test PASSED");
    $finish;
end

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars;
    $fsdbDumpMDA();
end

efuse_driver driver( // one pgm for 2^13 * 40 ns = 330 us, one read for 32 * 32 * 40ns = 41 us
// 25M osc_clk and reset
clk_osc,
rst_n,
// read and program start pulse
read_start,
read_ack,  // last for one clock cycle
dout,
dout_valid,    // valid for one clock cycle
efuse_din,       // valid with start pulse, make sure this data valid until ack
prog_start,           
prog_ack,              // last for one cycle
EFUSE_CS,
EFUSE_PGM,
EFUSE_SCLK,
EFUSE_RW,
EFUSE_DOUT
);

S018V3EBCDEFUSE_SISO32B3M efuse( 
    .CS(EFUSE_CS),
    .RW(EFUSE_RW),
    .PGM(EFUSE_PGM),
    .SCLK(EFUSE_SCLK),
    .DOUT(EFUSE_DOUT),
    .AVDD(1'b1),
    .DVDD(1'b1),
    .DVSS(1'b0)
);

endmodule 