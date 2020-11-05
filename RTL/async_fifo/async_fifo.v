module async_fifo #(
    parameter DEPTH = 8,
    parameter FIFO_DEEP = 256,
    parameter WIDTH = 4,
    parameter GAP = 3)
    (
    // write clock domain
    input               wclk,
    input               wrst_n,
    input               winc,
    input  [DEPTH-1:0]  wdata,
    output              wfull,
    output reg          wfull_almost,
    // read clock domain
    input                   rclk,
    input                   rrst_n,
    input                   rinc,
    output reg [DEPTH-1:0]  rdata,
    output                  rempty,
    output reg              rempty_almost);

    // **************************************************************** //
    wire                wen;
    wire                ren;
    //reg    [WIDTH-1:0]  mem[DEPTH-1:0];
    reg    [WIDTH-1:0]  mem[FIFO_DEEP-1:0];
    reg    [DEPTH  :0]  wptr, r_wptr_g1, r_wptr_g2, wgap;
    reg    [DEPTH  :0]  rptr, w_rptr_g1, w_rptr_g2, rgap;
    wire   [DEPTH  :0]  wptr_g, r_wptr;
    wire   [DEPTH  :0]  rptr_g, w_rptr;

    // **************************************************************** //
    // ---------------------write logic-------------------------------- //

    assign wen = winc && (~wfull);
    always @(posedge wclk or negedge wrst_n) begin
        if(!wrst_n)
            wptr <= 0;
        else if(wen) begin
            wptr <= wptr + 1;
            mem[wptr[DEPTH-1:0]] <= wdata;
        end
    end
    // bin to gary
    assign wptr_g = wptr ^ (wptr >> 1);
    // rptr_g synchronzier controled by wclk 
    always @(posedge wclk) begin
        w_rptr_g1 <= rptr_g;
        w_rptr_g2 <= w_rptr_g1;
    end
    // gary to bin
    /* assign w_rptr = w_rptr_g2 ^ (w_rptr_g2 >> 1) ^ 
                    (w_rptr_g2 >> 2) ^ (w_rptr_g2 >> 3); */
    assign w_rptr = w_rptr_g2 ^ (w_rptr_g2 >> 1) ^
                    (w_rptr_g2 >> 2) ^ (w_rptr_g2 >> 3) ^
                    (w_rptr_g2 >> 4) ^ (w_rptr_g2 >> 5) ^
                    (w_rptr_g2 >> 6) ^ (w_rptr_g2 >> 7) ^
                    (w_rptr_g2 >> 8);
    // ---------------------read logic----------------------------------//
    assign ren = rinc && (~rempty);
    always @(posedge rclk or negedge rrst_n) begin
        if(!rrst_n)
            rptr = 0;
        else if (ren) begin
            rptr <= rptr + 1;
            rdata <= mem[rptr[DEPTH-1:0]];
        end
    end
    // bin to gary
    assign rptr_g = rptr ^ (rptr >> 1);
    // wptr_g synchronizer controled by rclk
    always @(posedge rclk) begin
        r_wptr_g1 <= wptr_g;
        r_wptr_g2 <= r_wptr_g1;
    end
    // gary to bin 
    /* assign r_wptr = r_wptr_g2 ^ (r_wptr_g2 >> 1) ^
                    (r_wptr_g2 >> 2) ^ (r_wptr_g2 >> 3); */
    assign r_wptr = r_wptr_g2 ^ (r_wptr_g2 >> 1) ^
                    (r_wptr_g2 >> 2) ^ (r_wptr_g2 >> 3) ^
                    (r_wptr_g2 >> 4) ^ (r_wptr_g2 >> 5) ^
                    (r_wptr_g2 >> 6) ^ (r_wptr_g2 >> 7) ^
                    (r_wptr_g2 >> 8);
                    

    // --------------------wfull and wfull_almost--------------------- //
    assign wfull = ((wptr[DEPTH-1:0]) == w_rptr[DEPTH-1:0]) &&
                    (wptr[DEPTH] != w_rptr[DEPTH]);
    always @( *) begin
        if(wptr[DEPTH] != w_rptr[DEPTH])
            wgap = w_rptr[DEPTH-1:0] - wptr[DEPTH-1:0];
        else 
            wgap = FIFO_DEEP + w_rptr - wptr;
    end
    always @(posedge wclk or negedge wrst_n) begin
        if(!wrst_n)
            wfull_almost <= 1'b0;
        else if(wgap < GAP)
            wfull_almost <= 1'b1;
        else
            wfull_almost <= 1'b0;
    end
    // ------------------rempty and rempty_almost-------------------- //
    always @( *) begin
        rgap = r_wptr - rptr;//! is it right?
    end
    always @(posedge rclk or negedge rrst_n) begin
        if(!rrst_n)
            rempty_almost <= 1'b0;
        else if(rgap < GAP)
            rempty_almost <= 1'b1;
        else 
            rempty_almost <= 1'b0;
    end
    //assign rempty = (rgap == 0)||((rgap == 1)&&(rinc));
    assign rempty = (rgap == 0);
endmodule //async_fifo