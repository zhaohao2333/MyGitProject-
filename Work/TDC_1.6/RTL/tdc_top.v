module tdc_top (
    input  wire [31:0]  DLL_Phase,  //reverse with signal ck
    input  wire         clk5,       //500 Mhz for cnt, DLL_Phase[0]
    input  wire         clk,        //250 Mhz for logic
    input  wire         rst_n,      //from external PIN, active low
    input  wire         TDC_start,  //from core logic
    input  wire         TDC_trigger,//from SPAD
    input  wire [15:0]  TDC_spaden, //from 4*4 SPAD
    input  wire         TDC_tgate,  //from analog end, 3ns pulse follow trigger signal
    input  wire [14:0]  TDC_Range, 
    output reg  [14:0]  TDC_Odata,
    output reg  [3 :0]  TDC_Oint, 
    output reg  [1 :0]  TDC_Onum,   //output valid data number
    output reg          TDC_Olast,  //output last data signal
    output reg          TDC_Ovalid, //output data valid signal
    input  wire         TDC_Oready, //output data ready signal
    output wire         rst_auto,
    output reg          busy
);
//-------------------------------------------------------
parameter IDLE    = 7'b0000000;
parameter DATA1   = 7'b0000001;
parameter DATA2   = 7'b0000010;
parameter DATA2_1 = 7'b0000100;
parameter DATA3   = 7'b0001000;
parameter DATA3_1 = 7'b0010000;
parameter DATA3_2 = 7'b0100000;
parameter DATA0   = 7'b1000000;
//-------------------------------------------------------
reg  [15:0]  start_reg_out;
reg  [15:0]  stop_reg_out;
reg  [15:0]  stop_reg[2:0];
reg  [9 :0]  counter_reg[2:0];
reg  [9 :0]  counter_in;
reg          cnt_start;
wire         sync;
reg  [15:0]  light_level;
reg  [15:0]  INT[2:0];
reg  [15:0]  int_in; 
reg          cnt_start_d;
wire         cnt_en;
wire         hs;
reg  [6:0]   n_state;
reg  [6:0]   c_state;
reg          Ovalid, Ovalid_d1, Ovalid_d2, Ovalid_d3;
reg          tri_ign;
reg          clr_n;
wire         rst;
reg          shift_tri;
reg  [1:0]   num;
//-------------------------------------------------------
reg  [9:0]  counter;
reg  [9:0]  counter_reg_out;
wire [14:0] tof;
reg  [14:0] tof_data[2:0];
reg  [14:0] range;
wire        cal_stop;
wire        out_valid;
reg         cal_en;
reg  [3 :0] int_data_o[2:0]; 
wire [3 :0] int_out;
reg         int_valid;
reg  [15:0] decode_in;
reg         tof_cal_en;
wire        tof_out_valid;
wire        dec_valid;
reg  [2 :0] cnt;
wire        tof_cal_stop;
wire [1 :0] tof_num_cnt;
wire        tri_en;
reg  [1 :0] num_cnt;
//-------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        busy <= 0;
    end
    else if (TDC_start) begin
        busy <= 1;
    end
    else if (TDC_Olast) begin
        busy <= 0;
    end
end

assign rst_auto = (!TDC_tgate) & sync;

always @(posedge TDC_start or negedge rst_n) begin
    if (!rst_n) begin
        start_reg_out <= 16'h0000;
        cnt_start <= 1'b0;
    end
    else if (!busy) begin
        start_reg_out <= DLL_Phase[16:1];
        cnt_start <= ~cnt_start;
    end
end

always @(posedge TDC_trigger or negedge rst_n) begin
    if (!rst_n) begin
        stop_reg_out <= 0;
        tri_ign <= 1;
    end
    else if (~cnt_en) begin
        stop_reg_out <= 0;
        tri_ign <= 1;
    end
    else begin
        stop_reg_out <= DLL_Phase[16:1];
        tri_ign <= 0;
    end
end

always @(negedge TDC_tgate or negedge rst_n) begin
    if (!rst_n) begin
        light_level <= 0;
    end
    else begin
        light_level <= TDC_spaden[15:0];
    end
end
//---------------coarse counter--------------------------

assign cnt_en = cnt_start ^ cnt_start_d;
always @(posedge clk5 or negedge rst_n) begin
    if(!rst_n) begin
        counter <= 0;
        cnt_start_d <= 0;
    end
    else if(counter >= range[14:5]) begin
        counter <= 0;
        cnt_start_d <= cnt_start;
    end
    else if(cnt_en) begin
        counter <= counter + 1;
    end
end

always @(posedge clk or negedge rst_n) begin //250 Mhz
    if (!rst_n) begin
        range <= 15'b11111_11111_11111;//! initial value
    end
    else if (TDC_start & !busy) begin
        range <= TDC_Range;
    end
end

//---------------sync module-----------------------------
sync sync_inst0(
    .s (~stop_reg_out[15]),
    .TDC_trigger (TDC_trigger),
    .rst_n (rst_n),
    .sync_clk (clk5),
    .sync (sync)
);

//---------------coarse counter reg----------------------

always @(posedge sync or negedge rst_n) begin
    if(!rst_n) begin
        counter_reg_out <= 0;
    end
    else begin
        counter_reg_out <= counter;
    end
end

//---------------tof data out----------------------------
assign rst = rst_n & clr_n;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clr_n <= 1;
    end
    else if (TDC_Olast) begin
        clr_n <= 0;
    end
    else
        clr_n <= 1;
end

always @(negedge TDC_trigger or negedge rst) begin //! rst
    if (!rst) begin
        num_cnt <= 0;
    end
    else if (tri_ign) begin
        num_cnt <= num_cnt;
    end
    else if (num_cnt <= 2) begin
        num_cnt <= num_cnt + 1;
    end
end
//-------------------------------------------------------
always @(negedge TDC_trigger or negedge rst_n) begin
    if (!rst_n) begin
        counter_reg[2] <= 0;
        counter_reg[1] <= 0;
        counter_reg[0] <= 0;
        stop_reg[2] <= 0;
        stop_reg[1] <= 0;
        stop_reg[0] <= 0;
        INT[2]  <= 0;
        INT[1]  <= 0;
        INT[0]  <= 0;
    end
    else if(!tri_ign) begin
        if (num_cnt == 0) begin
            counter_reg[0] <= counter_reg_out;
            stop_reg[0] <= stop_reg_out;
            INT[0]  <= light_level;
        end
        else if (num_cnt == 1) begin
            counter_reg[1] <= counter_reg_out;
            stop_reg[1] <= stop_reg_out;
            INT[1]  <= light_level;
        end
        else if (num_cnt == 2) begin
            counter_reg[2] <= counter_reg_out;
            stop_reg[2] <= stop_reg_out;
            INT[2]  <= light_level;
        end
        else if (num_cnt == 3) begin
            counter_reg[0] <= counter_reg[0];
            counter_reg[1] <= counter_reg[1];
            counter_reg[2] <= counter_reg[2];
            stop_reg[2] <= stop_reg[2];
            stop_reg[1] <= stop_reg[1];
            stop_reg[0] <= stop_reg[0];
            INT[2]  <= INT[2];
            INT[1]  <= INT[1];
            INT[0]  <= INT[0];
        end
    end
end

//-------------------------------------------------------
always @(posedge clk5 or negedge rst_n) begin //clk 500 Mhz
    if (!rst_n) begin
        Ovalid <= 0;
    end
    else if (counter >= range[14:5]) begin
        Ovalid <= 1;
    end
    else if (TDC_Olast) begin
        Ovalid <= 0;
    end
end

//----------tof cal control logic------------------------
tof_cal tof_cal_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    .decode_in          (decode_in),
    .tof_data_in        (tof),
    .cal_en             (tof_cal_en),
    .cal_stop           (tof_cal_stop),
    .out_valid          (tof_out_valid),
    .dec_valid          (dec_valid),
    .cnt                (cnt),
    .num_cnt            (num_cnt),
    .counter_in         (counter_in),
    .range              (range),
    .tof_num_cnt        (tof_num_cnt),
    .tri_en             (tri_en)
);

assign tri_en = Ovalid_d2 & !Ovalid_d3;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tof_cal_en <= 0;
        decode_in <= 0;
        counter_in <= 0;
        cnt <= 0;
    end
    else if (Ovalid_d2 & !Ovalid_d3) begin
        if (num_cnt == 0) begin
            tof_cal_en <= 0;
            decode_in <= 0;
            counter_in <= 0;
        end
        else begin
            tof_cal_en <= 1;
            decode_in <= start_reg_out;
            counter_in <= 0;
        end
    end
    else if (tof_cal_en) begin
        if (tof_cal_stop) begin
            tof_cal_en <= 0;
            decode_in <= 0;
            cnt <= cnt + 1;
        end
    end
    else if (tof_out_valid) begin
        if (num_cnt == 1) begin
            if (cnt == 1) begin
                tof_cal_en <= 1;
                decode_in <= stop_reg[0];
                counter_in <= counter_reg[0];
            end
            else if (cnt == 2) begin
                tof_cal_en <= 0;
                decode_in <= 0;
                counter_in <= 0;
                cnt <= 0;
            end
        end
        else if (num_cnt == 2) begin
            if (cnt == 1) begin
                tof_cal_en <= 1;
                decode_in <= stop_reg[0];
                counter_in <= counter_reg[0];
            end
            else if (cnt == 2) begin
                tof_cal_en <= 1;
                decode_in <= stop_reg[1];
                counter_in <= counter_reg[1];
            end
            else if (cnt == 3) begin
                tof_cal_en <= 0;
                decode_in <= 0;
                counter_in <= 0;
                cnt <= 0;
            end
        end
        else if (num_cnt == 3) begin
            if (cnt == 1) begin
                tof_cal_en <= 1;
                decode_in <= stop_reg[0];
                counter_in <= counter_reg[0];
            end
            else if (cnt == 2) begin
                tof_cal_en <= 1;
                decode_in <= stop_reg[1];
                counter_in <= counter_reg[1];
            end
            else if (cnt == 3) begin
                tof_cal_en <= 1;
                decode_in <= stop_reg[2];
                counter_in <= counter_reg[2];
            end
            else if (cnt == 4) begin
                tof_cal_en <= 0;
                decode_in <= 0;
                counter_in <= 0;
                cnt <= 0;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tof_data[2] <= 0;
        tof_data[1] <= 0;
        tof_data[0] <= 0;
    end
    else if (tof_out_valid)begin
        if (num_cnt == 1) begin
            if (cnt == 2) begin
                tof_data[0] <= tof;
            end
        end
        else if (num_cnt == 2) begin
            if (cnt == 2) begin
                tof_data[0] <= tof;
            end
            else if (cnt == 3) begin
                tof_data[1] <= tof;
            end
        end
        else if (num_cnt == 3) begin
            if (cnt == 2) begin
                tof_data[0] <= tof;
            end
            else if (cnt == 3) begin
                tof_data[1] <= tof;
            end
            else if (cnt == 4) begin
                tof_data[2] <= tof;
            end
        end
    end
end
//-------------------------------------------------------

int_cal int_cal_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    .INT        (int_in),
    .cal_en     (cal_en),
    .int_out    (int_out),
    .out_valid  (out_valid),
    .cal_stop   (cal_stop),
    .shift_tri  (shift_tri)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cal_en <= 0;
        int_in <= 0;
        num <= 0;
    end
    else if (Ovalid_d2 & !Ovalid_d3) begin
        if (num_cnt == 0) begin
            cal_en <= 0;
            int_in <= 0;
        end
        else begin
            cal_en <= 1;
            int_in <= INT[0];
        end
    end
    else if (cal_en) begin
        if (cal_stop) begin
           cal_en <= 0;
           int_in <= 0;
        end
    end
    else if (out_valid) begin
        if (num_cnt == 1) begin
            cal_en <= 0;
            int_in <= 0;
            num <= 0;
        end
        else if (num_cnt == 2) begin
            if (num == 0) begin
                cal_en <= 1;
                int_in <= INT[1];
                num <= 1;
            end
            else if (num == 1) begin
                cal_en <= 0;
                int_in <= 0;
                num <= 0;
            end
        end
        else if (num_cnt == 3) begin
            if (num == 0) begin
                cal_en <= 1;
                int_in <= INT[1];
                num <= 1;
            end
            else if (num == 1) begin
                cal_en <= 1;
                int_in <= INT[2];
                num <= 2;
            end
            else if (num == 2) begin
                cal_en <= 0;
                int_in <= 0;
                num <= 0;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_tri <= 0;
    end
    else if (shift_tri) begin
        shift_tri <= 0;
    end
    else if (Ovalid_d2 & !Ovalid_d3) begin
        if (num_cnt == 0) begin
            shift_tri <= 0;
        end
        else begin
            shift_tri <= 1;
        end
    end
    else if (out_valid) begin
        if (num_cnt == 1) begin
            shift_tri <= 0;
        end
        else if (num_cnt == 2) begin
            if (num == 0) begin
                shift_tri <= 1;
            end
            else if (num == 1) begin
                shift_tri <= 0;
            end
        end
        else if (num_cnt == 3) begin
            if (num == 0) begin
                shift_tri <= 1;
            end
            else if (num == 1) begin
                shift_tri <= 1;
            end
            else if (num == 2) begin
                shift_tri <= 0;
            end
        end
    end
end

//-----------------get  intensity  data------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        int_data_o[2] <= 0;
        int_data_o[1] <= 0;
        int_data_o[0] <= 0;
    end
    else if (out_valid)begin
        if (num_cnt == 1) begin
            int_data_o[0] <= int_out;
        end
        else if (num_cnt == 2) begin
            if (num == 0) begin
                int_data_o[0] <= int_out;
            end
            else if (num == 1) begin
                int_data_o[1] <= int_out;
            end
        end
        else if (num_cnt == 3) begin
            if (num == 0) begin
                int_data_o[0] <= int_out;
            end
            else if (num == 1) begin
                int_data_o[1] <= int_out;
            end
            else if (num == 2) begin
                int_data_o[2] <= int_out;
            end
        end
    end
end

//-------------hand shake start signal generate----------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        int_valid <= 0;
    end
    else if (int_valid) begin
        int_valid <= 0;
    end
    else if (num_cnt == 0) begin
        if (Ovalid_d2 & !Ovalid_d3) begin
            int_valid <= 1;
        end
    end
    else if (out_valid)begin
        if (num_cnt == 1) begin
            int_valid <= 1;
        end
        else if (num_cnt == 2) begin
            if (num == 1) begin
                int_valid <= 1;
            end
        end
        else if (num_cnt == 3) begin
            if (num == 2) begin
                int_valid <= 1;
            end
        end
    end
end

//-------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Ovalid_d1 <= 0;
    end
    else begin
        Ovalid_d1 <= Ovalid;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Ovalid_d2 <= 0;
    end
    else begin
        Ovalid_d2 <= Ovalid_d1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Ovalid_d3 <= 0;
    end
    else begin
        Ovalid_d3 <= Ovalid_d2;
    end
end

//-------------------------fsm---------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c_state <= IDLE;
    end
    else 
        c_state <= n_state;
end

assign hs = TDC_Oready & int_valid;
//assign hs = 0;

always @(*) begin
    n_state = IDLE;
    case (c_state)
        IDLE: 
            if (hs) begin
                if ((num_cnt == 0)||(tof_num_cnt == 0))
                    n_state = DATA0;
                else if (tof_num_cnt == 1)
                    n_state = DATA1;
                else if (tof_num_cnt == 2)
                    n_state = DATA2;
                else if (tof_num_cnt == 3)
                    n_state = DATA3;
            end
        DATA0:
            n_state = IDLE;
        DATA1:
            n_state = IDLE;
        DATA2:
            n_state = DATA2_1;
        DATA2_1:
            n_state = IDLE;
        DATA3:
            n_state = DATA3_1;
        DATA3_1:
            n_state = DATA3_2;
        DATA3_2:
            n_state = IDLE;
        default :
            n_state = IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        TDC_Odata <= 0;
        TDC_Olast <= 0;
        TDC_Oint  <= 0;
        TDC_Ovalid <= 0;
        TDC_Onum <= 0;
    end
    //else if (hs) begin
    else begin
        case (n_state)
            IDLE: begin
                TDC_Odata <= 0;
                TDC_Olast <= 0;
                TDC_Oint  <= 0;
                TDC_Ovalid <= 0;
                TDC_Onum <= 0;
            end
            DATA0: begin
                TDC_Odata <= 15'b11111_11111_11111;
                TDC_Olast <= 1;
                TDC_Oint  <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 0;
            end
            DATA1: begin
                TDC_Odata <= tof_data[0];
                TDC_Oint  <= int_data_o[0];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
                TDC_Onum <= 1;
            end
            DATA2: begin
                TDC_Odata <= tof_data[0];
                TDC_Oint  <= int_data_o[0];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 2;
            end
            DATA2_1: begin
                TDC_Odata <= tof_data[1];
                TDC_Oint  <= int_data_o[1];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
                TDC_Onum <= 2;
            end
            DATA3: begin
                TDC_Odata <= tof_data[0];
                TDC_Oint  <= int_data_o[0];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 3;
            end
            DATA3_1: begin
                TDC_Odata <= tof_data[1];
                TDC_Oint  <= int_data_o[1];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 3;
            end
            DATA3_2: begin
                TDC_Odata <= tof_data[2];
                TDC_Oint  <= int_data_o[2];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
                TDC_Onum <= 3;
            end
            default : begin
                TDC_Odata <= 0;
                TDC_Olast <= 0;
                TDC_Oint  <= 0;
                TDC_Ovalid <= 0;
                TDC_Onum <= 0;
            end
        endcase
    end
end

endmodule //tdc_top


