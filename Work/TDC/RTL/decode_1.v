module decode_1 (
    input  wire [31:0]  data_in,
    output reg  [ 4:0]  data_out
);

integer i;
always @( *) begin
    data_out = 5'b0_0000;
    for (i = 1;i <= 31;i = i + 1) begin
        if((data_in[i] == 0) && (data_in[i-1] == 1))
            data_out = i;
    end
end

endmodule //decode