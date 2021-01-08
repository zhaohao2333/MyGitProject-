module int_cal (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [15:0]  INT2,
    input  wire [15:0]  INT1,
    input  wire [15:0]  INT0,
    input  wire         cal_en,
    input  wire [1:0]   TDC_Onum,
    output reg  [3:0]   int_out2,
    output reg  [3:0]   int_out1,
    output reg  [3:0]   int_out0,
    output reg          out_valid,
    output reg          cal_stop,
    input  wire         shift_tri
);

reg     [4:0]   int_data[2:0];
reg     [4:0]   cnt;
reg             data_en;
reg     [15:0]  INT_shift[2:0];
reg             cal_en_d1;

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        int_data[0] <= 0;
        int_data[1] <= 0;
        int_data[2] <= 0;
    end
    else if (cal_en_d1) begin
        if (TDC_Onum == 0) begin
            int_data[0] <= 0;
            int_data[1] <= 0;
            int_data[2] <= 0;
        end
        else if (TDC_Onum == 1) begin
            int_data[0] <= int_data[0] + INT_shift[0][0];
        end
        else if (TDC_Onum == 2) begin
            int_data[0] <= int_data[0] + INT_shift[0][0];
            int_data[1] <= int_data[1] + INT_shift[1][0];
        end
        else if (TDC_Onum == 3) begin
            int_data[0] <= int_data[0] + INT_shift[0][0];
            int_data[1] <= int_data[1] + INT_shift[1][0];
            int_data[2] <= int_data[2] + INT_shift[2][0];
        end 
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
        INT_shift[0] <= 0;
        INT_shift[1] <= 0;
        INT_shift[2] <= 0;
    end
    else if (shift_tri) begin
        INT_shift[0] <= INT0;
        INT_shift[1] <= INT1;
        INT_shift[2] <= INT2;
    end
    else if (cal_en) begin
        if (cnt == 16) begin
            INT_shift[0] <= 0;
            INT_shift[1] <= 0;
            INT_shift[2] <= 0;
        end
        else begin
            if (TDC_Onum == 0) begin
                INT_shift[0] <= 0;
                INT_shift[1] <= 0;
                INT_shift[2] <= 0;
            end
            else if (TDC_Onum == 1) begin
                INT_shift[0] <= {INT_shift[0][0],INT_shift[0][15:1]};
            end
            else if (TDC_Onum == 2) begin
                INT_shift[0] <= {INT_shift[0][0],INT_shift[0][15:1]};
                INT_shift[1] <= {INT_shift[1][0],INT_shift[1][15:1]};
            end
            else if (TDC_Onum == 3) begin
                INT_shift[0] <= {INT_shift[0][0],INT_shift[0][15:1]};
                INT_shift[1] <= {INT_shift[1][0],INT_shift[1][15:1]};
                INT_shift[2] <= {INT_shift[2][0],INT_shift[2][15:1]};
            end 
        end
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
        int_out0 <= 0;
        int_out1 <= 0;
        int_out2 <= 0;
    end if (data_en) begin
        if (TDC_Onum == 0) begin
            int_out0 <= 0;
            int_out1 <= 0;
            int_out2 <= 0;
        end
        else if (TDC_Onum == 1) begin
            int_out0 <= int_data[0] - 1;
        end
        else if (TDC_Onum == 2) begin
            int_out0 <= int_data[0] - 1;
            int_out1 <= int_data[1] - 1;
        end
        else if (TDC_Onum == 3) begin
            int_out0 <= int_data[0] - 1;
            int_out1 <= int_data[1] - 1;
            int_out2 <= int_data[2] - 1;
        end 
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