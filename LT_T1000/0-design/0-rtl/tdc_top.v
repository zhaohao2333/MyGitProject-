//==========================================================
//== design name : tdc_top.v
//== creator name : howie
//== company : LighTrace
//== creat date : 2021.04.20
//==========================================================
`define COARSE_CNT_BIT 14
`define COARSE_CNT_LOW_BIT 13
`define COARSE_CNT_HIGH_BIT 13
`define PHASE_BIT 16
`define TOF_BIT 19
`define FSM_STATE_BIT 16
`define NUM_BIT 3
`define RANGE_3KM 14'b10_0111_0001_0000
//------------------- tdc top ------------------------------
module tdc_top (
    input  wire [`PHASE_BIT - 1:0]  DLL_Phase,      //reverse with signal ck
    input  wire                     clk5,           //500 Mhz for cnt, DLL_Phase[0]
    input  wire                     clk,            //250 Mhz for logic
    input  wire                     rst_n,          //from external PIN, active low
    input  wire                     TDC_start,      //from external PIN
    input  wire                     TDC_trigger,    //from comparator
    output reg  [`TOF_BIT - 1:0]    TDC_Odata,      // 14bit coarse counter + 5bit fine register
    output reg  [`NUM_BIT - 1:0]    TDC_Onum,       //output valid data number
    output reg                      TDC_Olast,      //output last data signal
    output reg                      TDC_Ovalid,     //output data valid signal
    input  wire                     TDC_Oready,     //output data ready signal
    output reg                      busy
);
//------------------- fsm state ----------------------------
parameter IDLE    = `FSM_STATE_BIT'b0000_0000_0000_0000;
parameter DATA0   = `FSM_STATE_BIT'b0000_0000_0000_0001;
parameter DATA1   = `FSM_STATE_BIT'b0000_0000_0000_0010;
parameter DATA2   = `FSM_STATE_BIT'b0000_0000_0000_0100;
parameter DATA2_1 = `FSM_STATE_BIT'b0000_0000_0000_1000;
parameter DATA3   = `FSM_STATE_BIT'b0000_0000_0001_0000;
parameter DATA3_1 = `FSM_STATE_BIT'b0000_0000_0010_0000;
parameter DATA3_2 = `FSM_STATE_BIT'b0000_0000_0100_0000;
parameter DATA4   = `FSM_STATE_BIT'b0000_0000_1000_0000;
parameter DATA4_1 = `FSM_STATE_BIT'b0000_0001_0000_0000;
parameter DATA4_2 = `FSM_STATE_BIT'b0000_0010_0000_0000;
parameter DATA4_3 = `FSM_STATE_BIT'b0000_0100_0000_0000;
parameter DATA5   = `FSM_STATE_BIT'b0000_1000_0000_0000;
parameter DATA5_1 = `FSM_STATE_BIT'b0001_0000_0000_0000;
parameter DATA5_2 = `FSM_STATE_BIT'b0010_0000_0000_0000;
parameter DATA5_3 = `FSM_STATE_BIT'b0100_0000_0000_0000;
parameter DATA5_4 = `FSM_STATE_BIT'b1000_0000_0000_0000;
//-------------- register/wire define ----------------------
reg  [`PHASE_BIT - 1:0]                 start_phase_latch;
reg  [`PHASE_BIT - 1:0]                 stop_phase_latch;
reg  [`PHASE_BIT - 1:0]                 start_reg_out;
reg  [`PHASE_BIT - 1:0]                 stop_reg_out;
reg  [`PHASE_BIT - 1:0]                 stop_reg[2:0];
reg  [`PHASE_BIT - 1:0]                 decode_in;
reg  [`COARSE_CNT_LOW_BIT - 1:0]        counter_low;
reg  [`COARSE_CNT_HIGH_BIT - 1:0]       counter_high;
reg  [2 * `COARSE_CNT_HIGH_BIT - 1:0]   counter_reg_out;
reg  [2 * `COARSE_CNT_HIGH_BIT - 1:0]   counter_reg[2:0];
reg  [2 * `COARSE_CNT_HIGH_BIT - 1:0]   counter_in;
reg  [`FSM_STATE_BIT - 1:0]             n_state;
reg  [`FSM_STATE_BIT - 1:0]             c_state;
wire [`TOF_BIT - 1:0]                   tof;
reg  [`TOF_BIT - 1:0]                   tof_data[2:0];
reg  [`NUM_BIT - 1:0]                   num_cnt;
wire [`NUM_BIT - 1:0]                   tof_num_cnt;
reg          cnt_start;
wire         sync;
reg          cnt_start_d;
wire         cnt_en;
wire         hs;
reg          Ovalid_d1, Ovalid_d2, Ovalid_d3;
reg          clr_n;
wire         rst;
wire         cal_stop;
wire         out_valid;
reg          cal_en;
reg          int_valid; //hand shake valid signal
reg          tof_cal_en;
wire         dec_valid;
reg  [2:0]   cnt;
wire         tof_cal_stop;
wire         tri_en;
wire         TDC_trigger_n;
reg          overflow_low, overflow_high;
reg          clk5_2;
wire         clk5_2_i;
reg          start_d;
reg          tri_ign;
reg          overflow_low_d, overflow_low_dd;
reg          overflow_high_d, overflow_high_dd;
//----------------------------------------------------------

//-------------- RTL codes start from here -----------------
assign TDC_trigger_n = !TDC_trigger;

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

always @(posedge TDC_start or negedge rst_n) begin
    if (!rst_n) begin
        cnt_start <= 1'b0;
    end
    else begin
        if (!busy) begin             
            cnt_start <= ~cnt_start;
        end
    end
end

//--------------phase latch---------------------------------
always @(*) begin
    if (!TDC_start) begin
        start_phase_latch = DLL_Phase;
    end
end

always @(*) begin
    if (!TDC_trigger) begin
        stop_phase_latch = DLL_Phase;
    end
end
//--------------phase sync module---------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_d <= 0;
    end
    else begin
        start_d <= TDC_start; //! todo
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250M
    if (!rst_n) begin
        start_reg_out <= 0;
    end
    else if (TDC_start & !start_d) begin
        start_reg_out <= start_phase_latch; //! todo
    end
end

always @(posedge clk5 or negedge rst_n) begin //clk 5
    if (!rst_n) begin
        stop_reg_out <= 0;
    end
    else if (TDC_trigger) begin
        stop_reg_out <= stop_phase_latch;
    end
end
//----------------------------------------------------------
//! stop_reg_out 直接用 TDC_tgate_n 来采，此时一定是稳定的
//! sync 等于 vout0 的关键是 s = 1时，vout0和vout1相同
//! cnt_en 仅在trigger低电平时变化

//---------------clk divider--------------------------------
always @(posedge clk5 or negedge rst_n) begin
    if(!rst_n) begin
        clk5_2 <= 0;
    end
    else begin
        clk5_2 <= !clk5_2;
    end
end
//---------------range compare module-----------------------
assign clk5_2_i = !clk5_2;
always @(posedge clk5_2 or negedge rst_n) begin
    if(!rst_n) begin
        overflow_low <= 0;
        overflow_low_d <= 0;
        overflow_low_dd <= 0;
    end
    else begin
        overflow_low <= (counter_low >= range_dd_low);
        overflow_low_d <= overflow_low;
        overflow_low_dd <= overflow_low_d;
    end
end
always @(posedge clk5_2_i or negedge rst_n) begin
    if(!rst_n) begin
        overflow_high <= 0;
        overflow_high_d <= 0;
        overflow_high_dd <= 0;
    end
    else begin
        overflow_high <= (counter_high >= range_dd_high);
        overflow_high_d <= overflow_high;
        overflow_high_dd <= overflow_high_d;
    end
end
//---------------coarse counter-----------------------------

assign cnt_en = cnt_start ^ cnt_start_d;
always @(posedge clk5_2 or negedge rst_n) begin
    if(!rst_n)
        cnt_start_d <= 0;
    else if(overflow_low | overflow_high)
        cnt_start_d <= cnt_start;
end

always @(posedge clk5_2 or negedge rst_n) begin
    if(!rst_n) begin
        counter_low <= 0;
    end
    else if(overflow_low_dd) begin
        counter_low <= 0;
    end
    else if(cnt_en) begin
        counter_low <= counter_low + 1;
    end
end
always @(posedge clk5_2_i or negedge rst_n) begin
    if(!rst_n) begin
        counter_high <= 0;
    end
    else if(overflow_high_dd) begin
        counter_high <= 0;
    end
    else if(cnt_en) begin
        counter_high <= counter_high + 1;
    end
end

//---------------sync module--------------------------------
sync sync_inst0(
    .s (~stop_reg_out[15]), //! todo
    .TDC_trigger (TDC_trigger),
    .rst_n (rst_n),
    .sync_clk (clk5),
    .sync (sync)
);

//---------------coarse counter reg-------------------------

always @(posedge sync or negedge rst_n) begin
    if(!rst_n) begin
        counter_reg_out <= 0;
    end
    else begin
        counter_reg_out <= {counter_high, counter_low};
    end
end

//---------------tof data out-------------------------------
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

always @(posedge TDC_trigger or negedge rst_n) begin
    if (!rst_n) begin
        tri_ign <= 1;
    end
    else if (~cnt_en) begin //! todo
        tri_ign <= 1;
    end
    else begin
        tri_ign <= 0;
    end
end

always @(posedge TDC_trigger_n or negedge rst) begin //! rst, change to synchronous reset
    if (!rst) begin
        num_cnt <= 0;
    end
    else if (tri_ign) begin
    //else if (!cnt_en) begin
        num_cnt <= num_cnt;
    end
    else if (num_cnt <= 4) begin
        num_cnt <= num_cnt + 1;
    end
end
//----------------------------------------------------------
always @(posedge TDC_trigger_n or negedge rst_n) begin
    if (!rst_n) begin
        counter_reg[0] <= 0;
        counter_reg[1] <= 0;
        counter_reg[2] <= 0;
        counter_reg[3] <= 0;
        counter_reg[4] <= 0;
        stop_reg[0] <= 0;
        stop_reg[1] <= 0;
        stop_reg[2] <= 0;
        stop_reg[3] <= 0;
        stop_reg[4] <= 0;
    end
    else if(!tri_ign) begin
    //else if (cnt_en) begin
        if (num_cnt == 0) begin
            counter_reg[0] <= counter_reg_out;
            stop_reg[0] <= stop_reg_out;
        end
        else if (num_cnt == 1) begin
            counter_reg[1] <= counter_reg_out;
            stop_reg[1] <= stop_reg_out;
        end
        else if (num_cnt == 2) begin
            counter_reg[2] <= counter_reg_out;
            stop_reg[2] <= stop_reg_out;
        end
        else if (num_cnt == 3) begin
            counter_reg[3] <= counter_reg_out;
            stop_reg[3] <= stop_reg_out;
        end
        else if (num_cnt == 4) begin
            counter_reg[4] <= counter_reg_out;
            stop_reg[4] <= stop_reg_out;
        end
    end
end

//----------------------------------------------------------
/* always @(posedge clk5 or negedge rst_n) begin //clk 500 Mhz
    if (!rst_n) begin
        Ovalid <= 0;
    end
    else if (overflow_low | overflow_high) begin
        Ovalid <= 1;
    end
    else if (TDC_Olast) begin
        Ovalid <= 0;
    end
end */
//----------tof cal control logic---------------------------
tof_cal tof_cal_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    .decode_in          (decode_in),
    .tof_data_in        (tof),
    .cal_en             (tof_cal_en),
    .cal_stop           (tof_cal_stop),
    .out_valid          (out_valid),
    .cnt                (cnt),
    .num_cnt            (num_cnt),
    .counter_in         (counter_in),
    .tof_num_cnt        (tof_num_cnt),
    .tri_en             (tri_en)
);

assign tri_en = !Ovalid_d2 & Ovalid_d3;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tof_cal_en <= 0;
        decode_in <= 0;
        counter_in <= 0;
        cnt <= 0;
    end
    else if (!Ovalid_d2 & Ovalid_d3) begin
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
    else if (out_valid) begin
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
        else if (num_cnt == 4) begin
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
                tof_cal_en <= 1;
                decode_in <= stop_reg[3];
                counter_in <= counter_reg[3];
            end
            else if (cnt == 5) begin
                tof_cal_en <= 0;
                decode_in <= 0;
                counter_in <= 0;
                cnt <= 0;
            end
        end
        else if (num_cnt == 5) begin
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
                tof_cal_en <= 1;
                decode_in <= stop_reg[3];
                counter_in <= counter_reg[3];
            end
            else if (cnt == 5) begin
                tof_cal_en <= 1;
                decode_in <= stop_reg[4];
                counter_in <= counter_reg[4];
            end
            else if (cnt == 6) begin
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
        tof_data[0] <= 0;
        tof_data[1] <= 0;
        tof_data[2] <= 0;
        tof_data[3] <= 0;
        tof_data[4] <= 0;
    end
    else if (out_valid)begin
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
        else if (num_cnt == 4) begin
            if (cnt == 2) begin
                tof_data[0] <= tof;
            end
            else if (cnt == 3) begin
                tof_data[1] <= tof;
            end
            else if (cnt == 4) begin
                tof_data[2] <= tof;
            end
            else if (cnt == 5) begin
                tof_data[3] <= tof;
            end
        end
        else if (num_cnt == 5) begin
            if (cnt == 2) begin
                tof_data[0] <= tof;
            end
            else if (cnt == 3) begin
                tof_data[1] <= tof;
            end
            else if (cnt == 4) begin
                tof_data[2] <= tof;
            end
            else if (cnt == 5) begin
                tof_data[2] <= tof;
            end
            else if (cnt == 6) begin
                tof_data[2] <= tof;
            end
        end
    end
end

//-------------hand shake start signal generate-------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fsm_valid <= 0;
    end
    else if (fsm_valid) begin
        fsm_valid <= 0;
    end
    else if (num_cnt == 0) begin
        if (!Ovalid_d2 & Ovalid_d3) begin
            fsm_valid <= 1;
        end
    end
    else if (out_valid)begin
        /* 
        if (cnt == num_cnt + 1) begin
            fsm_valid <= 1;
        end
        */
        if (num_cnt == 1) begin
            if (cnt == 2) begin
                fsm_valid <= 1;
            end
        end
        else if (num_cnt == 2) begin
            if (cnt == 3) begin
                fsm_valid <= 1;
            end
        end
        else if (num_cnt == 3) begin
            if (cnt == 4) begin
                fsm_valid <= 1;
            end
        end
        else if (num_cnt == 4) begin
            if (cnt == 5) begin
                fsm_valid <= 1;
            end
        end
        else if (num_cnt == 5) begin
            if (cnt == 6) begin
                fsm_valid <= 1;
            end
        end
    end
end

//----------------------------------------------------------
always @(posedge clk or negedge rst_n) begin //sync from clk5
    if (!rst_n) begin
        Ovalid_d1 <= 0;
        Ovalid_d2 <= 0;
        Ovalid_d3 <= 0;
    end
    else begin
        //Ovalid_d1 <= Ovalid;
        Ovalid_d1 <= cnt_en;
        Ovalid_d2 <= Ovalid_d1;
        Ovalid_d3 <= Ovalid_d2;
    end
end

//-------------------------fsm------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c_state <= IDLE;
    end
    else 
        c_state <= n_state;
end

assign hs = TDC_Oready & fsm_valid;
//assign hs = 0;

always @(*) begin
    n_state = IDLE;
    case (c_state)
        IDLE: 
            if (hs) begin
                if ((num_cnt == 0)||(tof_num_cnt == 0)) begin
                    n_state = DATA0;
                end
                else if (tof_num_cnt == 1) begin
                    n_state = DATA1;
                end
                else if (tof_num_cnt == 2) begin
                    n_state = DATA2;
                end
                else if (tof_num_cnt == 3) begin
                    n_state = DATA3;
                end
                else if (tof_num_cnt == 4) begin
                    n_state = DATA4;
                end
                else if (tof_num_cnt == 5) begin
                    n_state = DATA5;
                end
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

        DATA4:
            n_state = DATA4_1;
        DATA4_1:
            n_state = DATA4_2;
        DATA4_2:
            n_state = DATA4_3;
        DATA4_3:
            n_state = IDLE;

        DATA5:
            n_state = DATA5_1;
        DATA5_1:
            n_state = DATA5_2;
        DATA5_2:
            n_state = DATA5_3;
        DATA5_3:
            n_state = DATA5_4;
        DATA5_4:
            n_state = IDLE;
        default :
            n_state = IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        TDC_Odata <= 0;
        TDC_Olast <= 0;
        TDC_Ovalid <= 0;
        TDC_Onum <= 0;
    end
    //else if (hs) begin
    else begin
        case (n_state)
            IDLE: begin
                TDC_Odata <= 0;
                TDC_Olast <= 0;
                TDC_Ovalid <= 0;
                TDC_Onum <= 0;
            end
            DATA0: begin
                TDC_Odata <= 15'b11111_11111_11111;
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
                TDC_Onum <= 0;
            end
            DATA1: begin
                TDC_Odata <= tof_data[0];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
                TDC_Onum <= 1;
            end
            DATA2: begin
                TDC_Odata <= tof_data[0];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 2;
            end
            DATA2_1: begin
                TDC_Odata <= tof_data[1];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
                TDC_Onum <= 2;
            end
            DATA3: begin
                TDC_Odata <= tof_data[0];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 3;
            end
            DATA3_1: begin
                TDC_Odata <= tof_data[1];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 3;
            end
            DATA3_2: begin
                TDC_Odata <= tof_data[2];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
                TDC_Onum <= 3;
            DATA4: begin
                TDC_Odata <= tof_data[0];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 4;
            end
            DATA4_1: begin
                TDC_Odata <= tof_data[1];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 4;
            end
            DATA4_2: begin
                TDC_Odata <= tof_data[2];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 4;
            end
            DATA4_3: begin
                TDC_Odata <= tof_data[3];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
                TDC_Onum <= 4;
            end
            DATA5: begin
                TDC_Odata <= tof_data[0];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 5;
            end
            DATA5_1: begin
                TDC_Odata <= tof_data[1];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 5;
            end
            DATA5_2: begin
                TDC_Odata <= tof_data[2];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 5;
            end
            DATA5_3: begin
                TDC_Odata <= tof_data[3];
                TDC_Olast <= 0;
                TDC_Ovalid <= 1;
                TDC_Onum <= 5;
            end
            DATA5_4: begin
                TDC_Odata <= tof_data[4];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
                TDC_Onum <= 5;
            end
            default : begin
                TDC_Odata <= 0;
                TDC_Olast <= 0;
                TDC_Ovalid <= 0;
                TDC_Onum <= 0;
            end
        endcase
    end
end

endmodule //tdc_top


