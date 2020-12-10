`timescale 1ns/1ns
module tb_decode;

// Parameters
wire    [ 4:0] data_out;
reg     [31:0] phase;
reg            clk;
reg            rst;
// Ports
decode_1 decode_inst(
    phase,
    data_out
);

initial begin
    begin
        clk = 0;
        rst = 1;
        #5 rst = 0;
        #20 rst = 1;
        #200;
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
