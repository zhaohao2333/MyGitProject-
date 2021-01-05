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
    output reg  [4 :0]  TDC_Oint, 
    output wire [1 :0]  TDC_Onum, //output valid data number
    output reg          TDC_Olast, // output last data signal
    output reg          TDC_Ovalid, // output data valid signal
    input  wire         TDC_Oready, //output data ready signal
    output wire         TDC_INT,
    output wire         rst_auto
);
//-------------------------------------------------------------------
parameter IDLE    = 6'b000000;
parameter DATA1   = 6'b000001;
parameter DATA2   = 6'b000010;
parameter DATA2_1 = 6'b000100;
parameter DATA3   = 6'b001000;
parameter DATA3_1 = 6'b010000;
parameter DATA3_2 = 6'b100000;
//-------------------------------------------------------------------
reg  [31:0]  start_reg_out;
wire [4:0]   start_data_out;
reg  [31:0]  stop_reg_out;
wire [4:0]   stop_data_out;
reg          cnt_start;
wire         sync;
//wire         clk5;
reg  [4:0]   light_level;
reg  [4:0]   INT[2:0];
wire [4:0]   INT_in; 
reg          cnt_start_d;
wire         cnt_en;
wire         hs;
reg  [5:0]   n_state;
reg  [5:0]   c_state;
reg          clr_num;
reg          Ovalid,Ovalid_d,Ovalid_d1,Ovalid_d2;
reg          trigger_d;
reg  [1:0]   Onum;
reg          trans_done;

//-------------------------------------------------------------------
//! for test
//wire [14:0]  tof;
//reg  [14:0]  tof_data[2:0]; //depth = 3 
//reg  [9:0]   counter_reg_out;
//reg  [9:0]   counter;
reg  [4:0]  counter;
reg  [4:0]  counter_reg_out;
wire [9:0]  tof;
reg  [9:0]  tof_data[2:0]; //depth = 3 

reg  [9:0]  range;


//-------------------------------------------------------------------
assign rst_auto = (!TDC_tgate) & sync;

always @(posedge TDC_start or negedge rst_n) begin
    if (!rst_n) begin
        start_reg_out <= 32'h0000_0000;
        cnt_start <= 1'b0;
    end
    else begin
        start_reg_out <= DLL_Phase;
        cnt_start <= ~cnt_start; //! test
    end
end

always @(posedge TDC_trigger or negedge rst_n) begin
    if (!rst_n) begin
        stop_reg_out <= 32'h0000_0000;
    end
    else if (~cnt_en) begin
        stop_reg_out <= 32'h0000_0000;
    end
    else begin
        stop_reg_out <= DLL_Phase;        
    end
end

/* always @(posedge TDC_trigger or negedge rst_n) begin
    if (!rst_n) begin
        TDC_Onum <= 0;
    end
    else if (clr_num ^ cnt_start) begin
        TDC_Onum <= 1;
    end
    else if (~cnt_en) begin
        TDC_Onum <= TDC_Onum;//! ??
    end
    else if (TDC_Onum <= 2) begin
        TDC_Onum <= TDC_Onum + 1;
    end
end */

/* always @(posedge TDC_trigger or negedge rst_n) begin
    if (!rst_n) begin
        clr_num <= 0;
    end
    else if (cnt_en) begin
        clr_num <= cnt_start;
    end
end */


always @(negedge TDC_tgate or negedge rst_n) begin
    if (!rst_n) begin
        light_level <= 5'b0_0000;
    end
    else if (~cnt_en) begin
        light_level <= 5'b0_0000;
    end
    else begin
        light_level <= TDC_spaden[15] + TDC_spaden[14] + TDC_spaden[13] + TDC_spaden[12] +
                       TDC_spaden[11] + TDC_spaden[10] + TDC_spaden[9]  + TDC_spaden[8]  +
                       TDC_spaden[7]  + TDC_spaden[6]  + TDC_spaden[5]  + TDC_spaden[4]  +
                       TDC_spaden[3]  + TDC_spaden[2]  + TDC_spaden[1]  + TDC_spaden[0]  ;
    end
end
//assign TDC_Oint = light_level;
//---------------coarse counter----------------------

assign cnt_en = cnt_start ^ cnt_start_d;
always @(posedge clk5 or negedge rst_n) begin
    if(!rst_n) begin
        //! for test
        //counter <= 10'b00_0000_0000;
        counter <= 5'b0_0000;
        cnt_start_d <= 0;
    end
    else if(counter == range) begin
        counter <= 5'b0_0000;
        cnt_start_d <= cnt_start;
    end
    else if(cnt_en) begin
        //counter <= counter + 10'b00_0000_0001;
        counter <= counter + 5'b0_0001;
    end
end
//! when counter overflows, ignore TDC_trigger signal

always @(posedge clk or negedge rst_n) begin //clk or clk5?
    if (!rst_n) begin
        range <= 5'b11111;//! for test
    end
    else if (~cnt_en & TDC_Oready) begin //! ~cnt_en?
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
        //! for test
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
//! for test
//assign tof[14:0] = {counter_reg_out[9:0], stop_data_out[4:0]} - {10'b00_0000_0001, start_data_out[4:0]};
assign tof[9:0] = {counter_reg_out[4:0], stop_data_out[4:0]} - {5'b0_0001, start_data_out[4:0]};


assign INT_in = light_level;
/* always @(negedge TDC_trigger or negedge rst_n) begin //clk?
    if (!rst_n) begin
        tof_data[2] <= 0;
        tof_data[1] <= 0;
        tof_data[0] <= 0;
        INT[2]  <= 0;
        INT[1]  <= 0;
        INT[0]  <= 0;
    end
    else if (TDC_Onum == 1) begin //! test
        tof_data[2] <= 0;
        tof_data[1] <= 0;
        tof_data[0] <= tof;
        INT[2]  <= 0;
        INT[1]  <= 0;
        INT[0]  <= INT_in;
    end
    else if(INT[0] <= INT[1] && INT[0] <= INT[2] && INT[0] <= INT_in) begin
        tof_data[0] <= tof;
        INT[0] <= INT_in;
    end
    else if(INT[1] <= INT[0] && INT[1] <= INT[2] && INT[1] <= INT_in) begin
        tof_data[1] <= tof;
        INT[1] <= INT_in;
    end
    else if(INT[2] <= INT[0] && INT[2] <= INT[1] && INT[2] <= INT_in) begin
        tof_data[2] <= tof;
        INT[2] <= INT_in;
    end
end */
//-------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        trigger_d <= 0;
    end
    else begin
        trigger_d <= TDC_trigger;
    end
end

//assign rst = rst_n & (!start); start pulse width 

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Onum <= 0;
    end
    else if (TDC_Olast) begin
        Onum <= 0;
    end
    else if (cnt_en) begin
        if (!TDC_trigger & trigger_d) begin
            if (~cnt_en) begin
                Onum <= Onum;
            end
            else if (Onum <= 2) begin
                Onum <= Onum + 1;
            end
        end
    end
end
assign TDC_Onum = Onum;
//-------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin //clk?
    if (!rst_n) begin
        tof_data[2] <= 0;
        tof_data[1] <= 0;
        tof_data[0] <= 0;
        INT[2]  <= 0;
        INT[1]  <= 0;
        INT[0]  <= 0;
    end
    else if (TDC_Olast) begin
        tof_data[2] <= 0;
        tof_data[1] <= 0;
        tof_data[0] <= 0;
        INT[2]  <= 0;
        INT[1]  <= 0;
        INT[0]  <= 0;
    end
    else if (cnt_en) begin
        if (!TDC_trigger & trigger_d) begin
            if (Onum == 0) begin
                tof_data[0] <= tof;
                INT[0]  <= INT_in;
            end
            else if (Onum == 1) begin
                tof_data[1] <= tof;
                INT[1]  <= INT_in;
            end
            else if (Onum == 2) begin
                tof_data[2] <= tof;
                INT[2]  <= INT_in;
            end
            else if (Onum == 3) begin
                tof_data[2] <= tof_data[2];
                tof_data[1] <= tof_data[1];
                tof_data[0] <= tof_data[0];
                INT[2]  <= INT[2];
                INT[1]  <= INT[1];
                INT[0]  <= INT[0];
            end
        end
    end 
end

//---------------hand shake module--------------------
always @(posedge clk5 or negedge rst_n) begin //clk 500 Mhz
    if (!rst_n) begin
        Ovalid <= 0;
    end
    else if (counter == range && TDC_Onum != 0) begin
        Ovalid <= 1;
    end
    else if (TDC_Olast) begin
        Ovalid <= 0;
    end
end

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
        Ovalid_d1 <= 0;
    end
    else begin
        Ovalid_d1 <= Ovalid_d;
    end
end

assign TDC_INT = Ovalid_d & (!Ovalid_d1);

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        Ovalid_d2 <= 0;
    end
    else if ((n_state == DATA2_1)||(n_state == DATA1)||(n_state == DATA3_2)) begin
        Ovalid_d2 <= 0;
    end
    else if (!trans_done) begin
        Ovalid_d2 <= Ovalid_d;
    end
end

always @(posedge clk or negedge rst_n) begin //clk 250 Mhz
    if (!rst_n) begin
        trans_done <= 0;
    end
    else if (trans_done)
        trans_done <= 0;
    else if ((n_state == DATA2_1)||(n_state == DATA1)||(n_state == DATA3_2)) begin
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

assign hs = TDC_Oready & Ovalid_d2;

always @(*) begin
    //!
    n_state = IDLE;
    case (c_state)
        IDLE: 
            if ((TDC_Onum == 0) & hs)
                n_state = IDLE;
            else if ((TDC_Onum == 1) & hs)
                n_state = DATA1;
            else if ((TDC_Onum == 2) & hs)
                n_state = DATA2;
            else if ((TDC_Onum == 3) & hs)
                n_state = DATA3;
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
    else if (hs) begin
        case (n_state)
            IDLE: begin // output data 0 or Z state?
                TDC_Odata <= 0;
                TDC_Olast <= 0;
                TDC_Oint  <= 0;
                TDC_Ovalid <= 0;
            end
            DATA1: begin
                TDC_Odata <= tof_data[0];
                TDC_Oint  <= INT[0];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
            end
            DATA2: begin
                TDC_Odata <= tof_data[0];
                TDC_Oint  <= INT[0];
                TDC_Ovalid <= 1;
            end
            DATA2_1: begin
                TDC_Odata <= tof_data[1];
                TDC_Oint  <= INT[1];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
            end
            DATA3: begin
                TDC_Odata <= tof_data[0];
                TDC_Oint  <= INT[0];
                TDC_Ovalid <= 1;
            end
            DATA3_1: begin
                TDC_Odata <= tof_data[1];
                TDC_Oint  <= INT[1];
                TDC_Ovalid <= 1;
            end
            DATA3_2: begin
                TDC_Odata <= tof_data[2];
                TDC_Oint  <= INT[2];
                TDC_Olast <= 1;
                TDC_Ovalid <= 1;
            end
            default : begin
                TDC_Odata <= 0;
                TDC_Olast <= 0;
                TDC_Oint  <= 0;
                TDC_Ovalid <= 1;
            end
        endcase
    end
    else begin
        TDC_Odata <= 0;
        TDC_Olast <= 0;
        TDC_Oint  <= 0;
        TDC_Ovalid <= 0;
    end
end



endmodule //tdc_top


