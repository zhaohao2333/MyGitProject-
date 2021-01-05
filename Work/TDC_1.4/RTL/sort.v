module sort (
    input  wire          clk, rst_n,
    input  wire    [4:0] data_a,
    input  wire    [4:0] data_b,
    input  wire    [4:0] data_c,
    output reg           data_max,
    output reg           data_mid,
    output reg           data_min
);// sort by intensity


//output max data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_max <= 0;
    else if (data_a >= data_b && data_a >= data_c)
        data_max <= data_a;
    else if (data_b >= data_a && data_b >= data_c)
        data_max <= data_b;
    else if (data_c >= data_a && data_c >= data_b)
        data_max <= data_c;
end

//output middle data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_mid <= 0;
    else if ((data_a >= data_b && data_a <= data_c) || 
             (data_a <= data_b && data_a >= data_c) )
        data_mid <= data_a;
    else if ((data_b >= data_a && data_b <= data_c) ||
             (data_b <= data_a && data_b >= data_c))
        data_mid <= data_b;
    else if ((data_c >= data_a && data_c <= data_b) ||
             (data_c <= data_a && data_c >= data_b))
        data_mid <= data_c;
end

//output min data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data_min <= 0;
    else if (data_a <= data_b && data_a <= data_c)
        data_min <= data_a;
    else if (data_b <= data_a && data_b <= data_c)
        data_min <= data_b;
    else if (data_c <= data_a && data_c <= data_b)
        data_min <= data_c;
end

endmodule //sort