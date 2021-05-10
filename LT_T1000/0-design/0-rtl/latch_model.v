module latch_model (
    input  wire         enable,
    input  wire [15:0]  phase,
    output wire [15:0]  latch
);
//-------------------------------------------------------
reg [15:0]      latch_data;
always @(posedge enable) begin
    latch_data <= phase;
end
assign latch = (enable) ? latch_data : 0;
//-------------------------------------------------------

endmodule //latch_model