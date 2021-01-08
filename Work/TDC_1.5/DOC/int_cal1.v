module int_cal1 (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [15:0]  INT,
    input  wire         cal_en,
    output wire [3 :0]  int_data     
);

reg [1:0]   int11, int12, int13, int14, int15, int16, int17, int18;
reg [2:0]   int21, int22, int23, int24;
reg [3:0]   int31, int32;
reg [4:0]   int41;
reg [3:0]   int_out;
reg         cal_en_d1, cal_en_d1, cal_en_d2, cal_en_d3;
reg         cal_en_d4;
reg         out_valid;
//--------------------------1 stage--------------------------------//
always @(posedge clk or negedge rst_n) begin //1
    if (!rst_n) begin
        int11 <= 0;
        cal_en_d1 <= 0;
    end if (cal_en) begin
        int11 <= INT[0] + INT[1];
        cal_en_d1 <= 1;
    end
end

always @(posedge clk or negedge rst_n) begin //2
    if (!rst_n) begin
        int12 <= 0;
    end if (cal_en) begin
        int12 <= INT[2] + INT[3];
    end
end

always @(posedge clk or negedge rst_n) begin //3
    if (!rst_n) begin
        int13 <= 0;
    end if (cal_en) begin
        int13 <= INT[4] + INT[5];
    end
end

always @(posedge clk or negedge rst_n) begin //4
    if (!rst_n) begin
        int14 <= 0;
    end if (cal_en) begin
        int14 <= INT[6] + INT[7];
    end
end

always @(posedge clk or negedge rst_n) begin //5
    if (!rst_n) begin
        int15 <= 0;
    end if (cal_en) begin
        int15 <= INT[8] + INT[9];
    end
end

always @(posedge clk or negedge rst_n) begin //6
    if (!rst_n) begin
        int16 <= 0;
    end if (cal_en) begin
        int16 <= INT[10] + INT[11];
    end
end

always @(posedge clk or negedge rst_n) begin //7
    if (!rst_n) begin
        int17 <= 0;
    end if (cal_en) begin
        int17 <= INT[12] + INT[13];
    end
end

always @(posedge clk or negedge rst_n) begin //8
    if (!rst_n) begin
        int18 <= 0;
    end if (cal_en) begin
        int18 <= INT[14] + INT[15];
    end
end

//--------------------------2 stage--------------------------------//

always @(posedge clk or negedge rst_n) begin //1
    if (!rst_n) begin
        int21 <= 0;
        cal_en_d2 <= 0;
    end if (cal_en_d1) begin
        int21 <= int11 + int12;
        cal_en_d2 <= 1;
    end
end

always @(posedge clk or negedge rst_n) begin //2
    if (!rst_n) begin
        int22 <= 0;
    end if (cal_en_d1) begin
        int22 <= int13 + int14;
    end
end

always @(posedge clk or negedge rst_n) begin //3
    if (!rst_n) begin
        int23 <= 0;
    end if (cal_en_d1) begin
        int23 <= int15 + int16;
    end
end

always @(posedge clk or negedge rst_n) begin //4
    if (!rst_n) begin
        int24 <= 0;
    end if (cal_en_d1) begin
        int24 <= int17 + int18;
    end
end
//--------------------------3 stage--------------------------------//
always @(posedge clk or negedge rst_n) begin //1
    if (!rst_n) begin
        int31 <= 0;
        cal_en_d3 <= 0;
    end if (cal_en_d2) begin
        int31 <= int21 + int22;
        cal_en_d3 <= 1;
    end
end

always @(posedge clk or negedge rst_n) begin //2
    if (!rst_n) begin
        int32 <= 0;
    end if (cal_en_d2) begin
        int32 <= int23 + int24;
    end
end

//--------------------------4 stage--------------------------------//
always @(posedge clk or negedge rst_n) begin //1
    if (!rst_n) begin
        int41 <= 0;
        cal_en_d4 <= 0;
    end if (cal_en_d3) begin
        int41 <= int31 + int32;
        cal_en_d4 <= 1;
    end
end

//--------------------------out stage--------------------------------//

always @(posedge clk or negedge rst_n) begin //1
    if (!rst_n) begin
        int_out <= 0;
        out_valid <= 0;
    end if (cal_en_d4) begin
        int_out <= int41 - 1;
        out_valid <= 1;
    end
end

assign int_data = int_out;

endmodule //int_cal