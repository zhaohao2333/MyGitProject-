`timescale 1ns/1ps
module afifo_tb ();
    reg                 wclk;
    reg                 wrst_n;
    reg                 winc;
    reg     [7:0]       wdata;
    wire                wfull;
    wire                wfull_almost;
    // read clock domain
    reg                 rclk;
    reg                 rrst_n;
    reg                 rinc;
    wire    [7:0]       rdata;
    wire                rempty;
    wire                rempty_almost;

    // -------------------initial-------------------------- /
    // define two clocks
    always #5 wclk = ~ wclk;
    always #12 rclk = ~ rclk;
    // 
    initial begin
       wclk = 0;
       rclk = 1;
       wrst_n = 1;
       rrst_n = 1;
       winc = 0;
       rinc = 0;
       wdata = 8'b0000_0001;
       # 8
       wrst_n = 0;
       rrst_n = 0;
       # 30
       wrst_n = 1;
       rrst_n = 1;
       # 100
       winc = 1;
       rinc = 0;
       @ (posedge wfull)
       winc = 0;
       rinc = 1;
       # 8000
       $stop;
    end
    // -------------------module--------------------------- //
    async_fifo
    #(
    .DEPTH(8),
    .FIFO_DEEP(256),
    .WIDTH(4),
    .GAP(5)
    )
    fifo1(
    // write clock domain
    .wclk(wclk),
    .wrst_n(wrst_n),
    .winc(winc),
    .wdata(wdata),
    .wfull(wfull),
    .wfull_almost(wfull_almost),
    // read clock domain
    .rclk(rclk),
    .rrst_n(rrst_n),
    .rinc(rinc),
    .rdata(rdata),
    .rempty(rempty),
    .rempty_almost(rempty_almost)
    );
endmodule //afifo_tb