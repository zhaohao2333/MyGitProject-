module sync (
    input  wire         s,
    input  wire         TDC_trigger,
    input  wire         rst_n,
    input  wire         sync_clk,
    output reg          sync
);
//-------------------------------------------------------
wire        sync_clk_i;
reg         stop_0;
reg         stop_1;
wire        vout;
//-------------------------------------------------------
assign sync_clk_i = !sync_clk;

always @(posedge sync_clk_i or negedge rst_n) begin
    if(!rst_n) begin
        stop_1 <= 1'b0;
    end
    else begin
        stop_1 <= TDC_trigger;
    end
end

always @(posedge sync_clk or negedge rst_n) begin
    if(!rst_n) begin
        stop_0 <= 1'b0;
    end
    else begin
        stop_0 <= TDC_trigger;
    end
end

assign vout = (s == 1) ? stop_1 : stop_0;

always @(posedge sync_clk_i or negedge rst_n) begin
    if(!rst_n) begin
        sync <= 1'b0;        
    end
    else
        sync <= vout;
end
endmodule //sync

