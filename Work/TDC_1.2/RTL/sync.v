module sync (
    input  wire         s,
    input  wire         TDC_trigger,
    input  wire         rst_n,
    input  wire         clk5,
    output reg          sync
);
wire        sync_clk_i;
reg         stop_0;
reg         stop_1;
wire        vout;

//assign s = stop_reg_out[0];
assign sync_clk_i = !clk5;
always @(posedge sync_clk_i or negedge rst_n) begin
    if(!rst_n) begin
        stop_0 <= 1'b0;
    end
    else begin
        stop_0 <= TDC_trigger;
    end
end

always @(posedge clk5 or negedge rst_n) begin
    if(!rst_n) begin
        stop_1 <= 1'b0;
    end
    else begin
        stop_1 <= TDC_trigger;
    end
end

assign vout = (s == 0) ? stop_0 : stop_1;
always @(posedge sync_clk_i or negedge rst_n) begin
    if(!rst_n) begin
        sync <= 1'b0;        
    end
    else if (sync == 1)begin //!
        sync <= 0;        
    end
    else
        sync <= vout;// next trigger s change, error
end
endmodule //sync

