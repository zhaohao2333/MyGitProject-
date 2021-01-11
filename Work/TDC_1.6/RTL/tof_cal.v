module tof_cal (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [31:0]  decode_in,

    output reg  [14:0]  tof_data_in,
    input  wire         cal_en,
    output reg          cal_stop,
    output reg          out_valid,
    output reg          dec_valid,
    input  wire [2:0]   cnt,
    input  wire [1:0]   TDC_Onum,
    input  wire [9:0]   counter_in,
    input  wire [14:0]  range
);

reg     [14:0]  tof;
reg     [4 :0]  decode;
reg     [31:0]  norbuf;
reg     [7 :0]  sel1;
reg     [3 :0]  sel2;
reg     [1 :0]  sel3;
reg     [4 :0]  dec_shift;
reg     [4 :0]  start_dec_data;
reg             comp, comp_done, comp_done_d;

// 1 stage
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        norbuf <= 0;
        decode[4] <= 0;
    end
    else if (cal_en) begin
        norbuf <= decode_in ^ {decode_in[0], decode_in[31:1]};
        decode[4] <= decode_in[16];
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
        if (norbuf[15:8] == 0) begin
            sel1 <= norbuf[7:0];
            decode[3] <= 1;
        end
        else begin
            sel1 <= norbuf[15:8];
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
    else if (dec_valid) begin //! todo reset
        if (cnt == 1)
            start_dec_data <= decode;
    end
end



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        comp <= 0;
        comp_done <= 0;
    end
    else if (comp_done) begin
        comp <= 0;
        comp_done <= 0;
    end
    else if (dec_valid) begin
        if ((cnt == 2)||(cnt == 3)||(cnt == 4)) begin
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

always @(posedge clk or negedge rst_n) begin //valid
    if (!rst_n) begin
        tof[4:0] <= 0;
    end
    else if (comp_done) begin //! todo reset
        tof[4:0] = decode - start_dec_data;
    end
end

always @(posedge clk or negedge rst_n) begin //valid
    if (!rst_n) begin
        tof[14:5] <= 0;
    end
    else if (comp_done) begin
        if (counter_in == 0) begin
            if (comp)
                tof[14:5] <= range[14:5];
            else
                tof[14:5] <= range[14:5] - 1;
        end
        else begin
            if (comp)
                tof[14:5] <= counter_in - 1;
            else
                tof[14:5] <= counter_in - 2;
        end
    end
end

always @(posedge clk or negedge rst_n) begin //valid
    if (!rst_n) begin
        comp_done_d <= 0;
    end
    else if (comp_done_d) begin
        comp_done_d <= 0;
    end
    else if (comp_done) begin
        comp_done_d <= 1;
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
    else if (comp_done_d) begin
        out_valid <= 1;
    end
end

always @(posedge clk or negedge rst_n) begin //valid
    if (!rst_n) begin
        tof_data_in <= 0;
    end
    else if (comp_done_d) begin
        if (tof <= range) begin  //! reset
            tof_data_in <= tof;
        end
        else
            tof_data_in <= 15'b11111_11111_11111;
    end
end

endmodule //tof_cal