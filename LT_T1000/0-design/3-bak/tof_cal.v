module tof_cal (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [15:0]  decode_in,
    output reg  [18:0]  tof_data_in,
    input  wire         cal_en,
    output reg          cal_stop,
    output reg          out_valid,
    input  wire [2:0]   cnt,
    input  wire [2:0]   num_cnt,
    input  wire [13:0]  counter_in,
    output reg  [2:0]   tof_num_cnt,
    input  wire         tri_en
);
//-------------------------------------------------------
reg     [18:0]  tof;
reg     [4 :0]  decode;
reg     [15:0]  norbuf;
reg     [7 :0]  sel1;
reg     [3 :0]  sel2;
reg     [1 :0]  sel3;
reg     [4 :0]  dec_shift;
reg     [4 :0]  start_dec_data;
reg             comp, comp_done;
reg             dec_valid_d,dec_valid_d2,dec_valid_d3,dec_valid_d4;
reg     [13:0]  tof_reg;
reg     [7 :0]  sum1;
reg     [6 :0]  sum2;
//-------------------------------------------------------
// 1 stage
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        norbuf <= 0;
        decode[4] <= 0;
    end
    else if (cal_en) begin
        norbuf <= decode_in ^ {~decode_in[0], decode_in[15:1]};
        decode[4] <= decode_in[15];
    end
end

always @(posedge clk or negedge rst_n) begin //shift
    if (!rst_n) begin
        dec_shift <= 10000;
    end
    else if (cal_en) begin
        dec_shift <= {dec_shift[0], dec_shift[4:1]};
    end
end

always @(posedge clk or negedge rst_n) begin //valid
    if (!rst_n) begin
        dec_valid <= 0;
    end
    //else if (cal_en) begin
    else begin
        dec_valid <= dec_shift[0];
    end
end

always @(posedge clk or negedge rst_n) begin //valid
    if (!rst_n) begin
        cal_stop <= 0;
    end
    else if (cal_en) begin
        cal_stop <= dec_shift[1];
    end
end
//2 stage
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sel1 <= 0;
        decode[3] <= 0;  
    end
    else if (cal_en) begin
        if (norbuf[14:7] == 0) begin
            sel1 <= {norbuf[6:0],norbuf[15]};
            decode[3] <= 1;
        end
        else begin
            sel1 <= norbuf[14:7];
            decode[3] <= 0;
        end
    end
end
//3 stage
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sel2 <= 0;
        decode[2] <= 0; 
    end
    else if (cal_en) begin
        if (sel1[7:4] == 0) begin
            sel2 <= sel1[3:0];
            decode[2] <= 1;
        end
        else begin
            sel2 <= sel1[7:4];
            decode[2] <= 0;
        end
    end
end
//4 stage
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sel3 <= 0;
        decode[1] <= 0; 
    end
    else if (cal_en) begin
        if (sel2[3:2] == 0) begin
            sel3 <= sel2[1:0];
            decode[1] <= 1;
        end
        else begin
            sel3 <= sel2[3:2];
            decode[1] <= 0;
        end
    end
end
//5 stage
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        decode[0] <= 0;
    end
    else if (cal_en) begin
        if (sel3[1] == 0) begin
            decode[0] <= 1;
        end
        else begin
            decode[0] <= 0;
        end
    end
end
//get decode out data
always @(posedge clk or negedge rst_n) begin //valid
    if (!rst_n) begin
        start_dec_data <= 0;
    end
    else if (dec_valid) begin
        if (cnt == 1)
            start_dec_data <= decode;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        comp <= 0;
        comp_done <= 0;
    end
    else if (dec_valid_d3) begin
        comp <= 0;
        comp_done <= 0;
    end
    else if (dec_valid_d2) begin
        if ((cnt == 2)||(cnt == 3)||(cnt == 4)||(cnt == 5)||(cnt == 6)) begin
            if (decode >= start_dec_data) begin
                comp <= 1;
                comp_done <= 1;
            end
            else begin
                comp <= 0;
                comp_done <= 1;
            end
        end
    end
end
// calculate tof data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum1[7:0] <= 0;
    end
    else if (dec_valid) begin
        sum1[7:0] <= counter_in[19:13] + counter_in[6:0]; //!todo
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tof[4:0] <= 0;
        sum2[6:0] <= 0;
    end
    else if (dec_valid_d) begin
        tof[4:0] <= decode - start_dec_data;
        sum2[6:0] <= counter_in[25:20] + counter_in[12:7] + sum1[7]; //!todo
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tof_reg <= 0;
    end
    else if (dec_valid_d2) begin
        tof_reg <= {sum2[6:0],sum1[6:0]};
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tof[18:5] <= 0;
    end
    else if (dec_valid_d3) begin
/*         if (counter_in == 0) begin
            if (comp)
                tof[14:5] <= range[14:5];
            else
                tof[14:5] <= range[14:5] - 1;
        end
        else begin */
            if (comp)
                tof[18:5] <= tof_reg - 1;
            else
                tof[18:5] <= tof_reg - 2;
        end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dec_valid_d <= 0;
    end
    else if (dec_valid_d) begin
        dec_valid_d <= 0;
    end
    else if (dec_valid && ((cnt == 2)||(cnt == 3)||(cnt == 4)||(cnt == 5)||(cnt == 6))) begin
        dec_valid_d <= 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dec_valid_d2 <= 0;
        dec_valid_d3 <= 0;
        dec_valid_d4 <= 0;
    end
    else begin
        dec_valid_d2 <= dec_valid_d;
        dec_valid_d3 <= dec_valid_d2;
        dec_valid_d4 <= dec_valid_d3;
    end
end
// out valid
always @(posedge clk or negedge rst_n) begin //valid
    if (!rst_n) begin
        out_valid <= 0;
    end
    else if (out_valid) begin
        out_valid <= 0;
    end
    else if (dec_valid && (cnt == 1)) begin
        out_valid <= 1;
    end
    else if (dec_valid_d4) begin
        out_valid <= 1;
    end
end

always @(posedge clk or negedge rst_n) begin //valid
    if (!rst_n) begin
        tof_data_in <= 0;
        tof_num_cnt <= 0;
    end
    else if (tri_en) begin
        tof_num_cnt <= num_cnt;
    end
    else if (dec_valid_d4) begin
        if (tof <= range) begin
            tof_data_in <= tof;
            tof_num_cnt <= tof_num_cnt;
        end
        else begin
            tof_data_in <= 19'b111_1111_1111_1111_1111;
            tof_num_cnt <= tof_num_cnt - 1;
        end
    end
end

endmodule //tof_cal