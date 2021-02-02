`define TEST
module tdc_top (
    input  wire [31:0]  DLL_Phase,
    input  wire         clk5, //500 Mhz for cnt, DLL_Phase[0]
    input  wire         clk, //250 Mhz for logic, axi stream logic
    input  wire         rst_n, //from external PIN, active low
    input  wire         TDC_start, //from core logic
    input  wire         TDC_trigger, //from SPAD
    input  wire [15:0]  TDC_spaden, //from 4*4 SPAD
    input  wire         TDC_tgate, //from analog end, 3ns pulse follow trigger signal
    input  wire [14:0]  TDC_Range, 
    //! for test
    //output wire [14:0]  TDC_Odata,
    output reg  [9 :0]  TDC_Odata, 
    //output wire [3 :0]  TDC_Oint, //output intensity counter for each depth data 
    output reg  [3 :0]  TDC_Oint, 
    output reg  [1 :0]  TDC_Onum, //output valid data number
    output reg          TDC_Olast, // output last data signal
    output reg          TDC_Ovalid, // output data valid signal
    input  wire         TDC_Oready, //output data ready signal
    output reg          TDC_INT,
    output wire         rst_auto
);
//-------------------------------------------------------------------
parameter IDLE    = 7'b0000000;
parameter DATA1   = 7'b0000001;
parameter DATA2   = 7'b0000010;
parameter DATA2_1 = 7'b0000100;
parameter DATA3   = 7'b0001000;
parameter DATA3_1 = 7'b0010000;
parameter DATA3_2 = 7'b0100000;
parameter DATA0   = 7'b1000000;
//-------------------------------------------------------------------
reg  [31:0]  start_reg_out;
wire [4:0]   start_data_out;
reg  [31:0]  stop_reg_out;
wire [4:0]   stop_data_out;
reg          cnt_start;
wire         sync;
//wire         clk5;
reg  [15:0]  light_level;
reg  [15:0]  INT[2:0];
wire [15:0]  INT_in; 
reg          cnt_start_d;
wire         cnt_en;
wire         hs;
reg  [6:0]   n_state;
reg  [6:0]   c_state;
reg          Ovalid, Ovalid_d, Ovalid_d1, Ovalid_d2, Ovalid_d3;
reg          trigger_d;
reg          trans_done;
reg          tri_ign;
reg          clr_n;
wire         rst;
reg          TDC_Ovalid_d;
wire         shift_tri;

//-------------------------------------------------------------------
//wire [14:0]  tof;
//reg  [14:0]  tof_data[2:0]; //depth = 3 
//reg  [9:0]   counter_reg_out;
//reg  [9:0]   counter;
reg  [4:0]  counter;
reg  [4:0]  counter_reg_out;
wire [9:0]  tof;
reg  [9:0]  tof_data[2:0]; //depth = 3 
reg  [14:0] tof_data_in;
reg  [14:0] range;

wire        cal_stop;
wire        out_valid;
reg         cal_en;
wire [3 :0] int_data_o[2:0]; 
reg  [15:0] cal_data;

//-------------------------------------------------------------------
assign rst_auto = (!TDC_tgate) & sync;

always @(posedge TDC_start or negedge rst_n) begin
    if (!rst_n) begin
        start_reg_out <= 32'h0000_0000;
        cnt_start <= 1'b0;
    end
    else begin
        start_reg_out <= DLL_Phase;
        cnt_start <= ~cnt_start;
    end
end

always @(posedge TDC_trigger or negedge rst) begin // rst
    if (!rst) begin
        stop_reg_out <= 32'h0000_0000;
        tri_ign <= 1;
    end
    else if (~cnt_en) begin
        stop_reg_out <= 32'h0000_0000;
        tri_ign <= 1;
    end
    else begin
        stop_reg_out <= DLL_Phase;
        tri_ign <= 0;
    end
end

always @(negedge TDC_tgate or negedge rst_n) begin
    if (!rst_n) begin
        light_level <= 0;
    end
    else begin
        light_level <= TDC_spaden[15:0];
        /* light_level <= TDC_spaden[15] + TDC_spaden[14] + TDC_spaden[13] + TDC_spaden[12] +
                       TDC_spaden[11] + TDC_spaden[10] + TDC_spaden[9]  + TDC_spaden[8]  +
                       TDC_spaden[7]  + TDC_spaden[6]  + TDC_spaden[5]  + TDC_spaden[4]  +
                       TDC_spaden[3]  + TDC_spaden[2]  + TDC_spaden[1]  + TDC_spaden[0]  ; */
    end
end
//---------------coarse counter----------------------

assign cnt_en = cnt_start ^ cnt_start_d;
always @(posedge clk5 or negedge rst_n) begin
    if(!rst_n) begin
        //counter <= 10'b00_0000_0000;
        counter <= 5'b0_0000;
        cnt_start_d <= 0;
    end
    else if(counter == range[9:5]) begin
        counter <= 5'b0_0000;
        cnt_start_d <= cnt_start;
    end
    else if(cnt_en) begin
        //counter <= counter + 10'b00_0000_0001;
        counter <= counter + 5'b0_0001;
    end
end

always @(posedge clk or negedge rst_n) begin //250 Mhz
    if (!rst_n) begin
        range <= 15'b00000_11111_11100;//! for test
    end
    else if (TDC_start) begin
        range <= TDC_Range;
    end
end

//---------------sync module-------------------------
sync sync_inst0(
    .s (stop_reg_out[0]),
    .TDC_trigger (TDC_trigger),
    .rst_n (rst_n),
    .sync_clk (clk5),
    .sync (sync)
);

//---------------coarse counter reg------------------

always @(posedge sync or negedge rst_n) begin
    if(!rst_n) begin
        //counter_reg_out <= 10'b00_0000_0000;
        counter_reg_out <= 5'b0_0000;
    end
    else begin
        counter_reg_out <= counter;
    end
end

//---------------decode------------------------------

decode decode_start(
      .data_in(start_reg_out),
      .data_out(start_data_out)
    );

decode decode_stop(
      .data_in(stop_reg_out),
      .data_out(stop_data_out)
    );

//---------------tof data out------------------------
//assign tof[14:0] = {counter_reg_out[9:0], stop_data_out[4:0]} - {10'b00_0000_0001, start_data_out[4:0]};
assign tof[9:0] = {counter_reg_out[4:0], stop_data_out[4:0]} - {5'b0_0001, start_data_out[4:0]};

always @( *) begin
    if (tof <= range) begin
        tof_data_in = tof;
    end
    else
        tof_data_in = 10'b11111_11111;
        //tof_data_in = 15'b11111_11111_11111;
end

always @(negedge TDC_trigger or negedge rst) begin // rst
    if (!rst) begin
        TDC_Onum <= 0;
    end
    else if (tri_ign) begin
        TDC_Onum <= TDC_Onum;
    end
    else if (TDC_Onum <= 2) begin
        TDC_Onum <= TDC_Onum + 1;
    end
end

assign INT_in = light_level;
always @(negedge TDC_trigger or negedge rst) begin //rst
    if (!rst) begin
        tof_data[2] <= 0;
        tof_data[1] <= 0;
        tof_data[0] <= 0;
        INT[2]  <= 0;
        INT[1]  <= 0;
        INT[0]  <= 0;
    end
    else if(!tri_ign) begin
        if (TDC_Onum == 0) begin
            tof_data[0] <= tof_data_in;
            INT[0]  <= INT_in;
        end
        else if (TDC_Onum == 1) begin
            tof_data[1] <= tof_data_in;
            INT[1]  <= INT_in;
        end
        else if (TDC_Onum == 2) begin
            tof_data[2] <= tof_data_in;
            INT[2]  <= INT_in;
        end
        else if (TDC_Onum == 3) begin
            tof_data[2] <= tof_data[2];
            tof_data[1] <= tof_data[1];
            tof_data[0] <= tof_data[0];
            INT[2]  <= INT[2];
            INT[1]  <= INT[1];
            INT[0]  <= INT[0];
        end
    end
end
//-------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        TDC_Ovalid_d <= 0;
    end
    else begin
        TDC_Ovalid_d <= TDC_Ovalid;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clr_n <= 1;
    end
    else if (!TDC_Ovalid & TDC_Ovalid_d) begin
        clr_n <= 0;
    end
    else
        clr_n <= 1;
end

assign rst = rst_n & clr_n;

//-------------------------------------------------------------------
//--------------------hand shake module--------------------
always @(posedge clk5 or negedge rst_n) begin //clk 500 Mhz
    if (!rst_n) begin
        Ovalid <= 0;
        TDC_INT <= 0;
    end
    else if (counter == range[9:5]) begin //! range
        Ovalid <= 1;
        TDC_INT <= 1;
    end
    else if (trans_done) begin
        Ovalid <= 0;
        TDC_INT <= 0; //! wait for clr signal from core logic
    end
end
//-------------------------------------------------------------------
//------------------------delay module--------------------

int_cal int_cal_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    .INT2       (INT[2]),
    .INT1       (INT[1]),
    .INT0       (INT[0]),
    .cal_en     (cal_en),
    .TDC_Onum   (TDC_Onum),
    .int_out2   (int_data_o[2]),
    .int_out1   (int_data_o[1]),
    .int_out0   (int_data_o[0]),
    .out_valid  (out_valid),
    .cal_stop   (cal_stop),
    .shift_tri  (shift_tri)
);

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        cal_en <= 0;
    end
    else if (Ovalid_d2 & !Ovalid_d3) begin
        cal_en <= 1;
    end
    else if (cal_stop) begin
        cal_en <= 0;
    end
end

//-------------------------------------------------------------------
//---------------intensity calculate module---------------

assign shift_tri = Ovalid_d & !Ovalid_d2;

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        Ovalid_d <= 0;
    end
    else begin
        Ovalid_d <= Ovalid;
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        Ovalid_d2 <= 0;
    end
    else begin
        Ovalid_d2 <= Ovalid_d;
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        Ovalid_d3 <= 0;
    end
    else begin
        Ovalid_d3 <= Ovalid_d2;
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        Ovalid_d1 <= 0;
    end
    else if ((n_state == DATA2_1)||(n_state == DATA1)||(n_state == DATA3_2)||(n_state == DATA0)) begin
        Ovalid_d1 <= 0;
    end
    else if (!trans_done) begin
        Ovalid_d1 <= Ovalid_d;
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        trans_done <= 0;
    end
    else if (trans_done) 
        trans_done <= 0;
    else if ((n_state == DATA2_1)||(n_state == DATA1)||(n_state == DATA3_2)||(n_state == DATA0)) begin
        trans_done <= 1;
    end
end

//-------------------------fsm-----------------------------------------------//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c_state <= IDLE;
    end
    else 
        c_state <= n_state;
end

//!assign hs = TDC_Oready & Ovalid_d1;
assign hs = TDC_Oready & out_valid;

always @(*) begin
    //!
    n_state = IDLE;
    case (c_state)
        IDLE: 
            if (hs) begin
                if (TDC_Onum == 0)
                    n_state = DATA0;
                else if (TDC_Onum == 1)
                    n_state = DATA1;
                else if (TDC_Onum == 2)
                    n_state = DATA2;
                else if (TDC_Onum == 3)
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
    end
    //else if (hs) begin
    else begin
        case (n_state)
            IDLE: begin // output data 0 or Z state?
                TDC_Odata <= 0;
                TDC_Olast <= 0;
                TDC_Oint  <= 0;
                TDC_Ovalid <= 0;
            end
            DATA0: begin
                TDC_Odata <= 0;
                TDC_Olast <= 0;
                TDC_Oint  <= 0;
                TDC_Ovalid <= 1;
            end
            DATA1: begin
                TDC_Odata <= tof_data[0];
                TDC_Oint  <= int_data_o[0];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
            end
            DATA2: begin
                TDC_Odata <= tof_data[0];
                TDC_Oint  <= int_data_o[0];
                TDC_Ovalid <= 1;
            end
            DATA2_1: begin
                TDC_Odata <= tof_data[1];
                TDC_Oint  <= int_data_o[1];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
            end
            DATA3: begin
                TDC_Odata <= tof_data[0];
                TDC_Oint  <= int_data_o[0];
                TDC_Ovalid <= 1;
            end
            DATA3_1: begin
                TDC_Odata <= tof_data[1];
                TDC_Oint  <= int_data_o[1];
                TDC_Ovalid <= 1;
            end
            DATA3_2: begin
                TDC_Odata <= tof_data[2];
                TDC_Oint  <= int_data_o[2];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
            end
            default : begin
                TDC_Odata <= 0;
                TDC_Olast <= 0;
                TDC_Oint  <= 0;
                TDC_Ovalid <= 0;
            end
        endcase
    end
/*     else begin
        TDC_Odata <= 0;
        TDC_Olast <= 0;
        TDC_Oint  <= 0;
        TDC_Ovalid <= 0;
    end */
end



endmodule //tdc_top

