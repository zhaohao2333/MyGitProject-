module int_cal (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [15:0]  INT,
    input  wire         cal_en,
    output reg  [3:0]   int_out,
    output reg          out_valid,
    output reg          cal_stop,
    input  wire         shift_tri
);

reg     [4:0]   int_data;
reg     [4:0]   cnt;
reg             data_en;
reg     [15:0]  INT_shift;
reg             cal_en_d1;

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) 
        int_data <= 0;
    else if (out_valid) begin
        int_data <= 0;
    end
    else if (cal_en_d1) begin
        int_data <= int_data + INT_shift[0];
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        data_en <= 0;
    end
    else if (data_en) begin
        data_en <= 0;
    end
    else if (cnt == 16) begin
        data_en <= 1;
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        cal_stop <= 0;
    end
    else if (out_valid) begin
        cal_stop <= 0;
    end
    else if (cnt == 15) begin
        cal_stop <= 1;
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        INT_shift <= 0;
    end
    else if (shift_tri) begin
        INT_shift <= INT;
    end
    else if (cal_en) begin
        if (cnt == 16)
            INT_shift <= 0;
        else
            INT_shift <= {INT_shift[0], INT_shift[15:1]};
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        cal_en_d1 <= 0;
    end
    else if (cal_en) begin
        if (cnt == 16)
            cal_en_d1 <= 0;
        else
            cal_en_d1 <= 1;
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        cnt <= 0;
    end
    else if (cal_en) begin
        if (cnt == 16)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
end

//--------------------------out stage--------------------------------//

always @(posedge clk or negedge rst_n) begin //1
    if (!rst_n) begin
        int_out <= 0;
    end if (data_en) begin
        int_out <= int_data - 1;
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n)
        out_valid <= 0;
    else if (out_valid)
        out_valid <= 0;
    else if (data_en)
        out_valid <= 1;
end

endmodule //int_cal