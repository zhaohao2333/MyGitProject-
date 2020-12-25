module tdc_top (
    input  wire [31:0]  DLL_Phase,
    input  wire         clk5, //500 Mhz for cnt, DLL_Phase[0]
    input  wire         clk, //250 Mhz for logic, axi stream logic
    input  wire         rst_n, //from external PIN, active low
    input  wire         TDC_start, //from core logic
    input  wire         TDC_trigger, //from SPAD
    input  wire [15:0]  TDC_spaden, //from 4*4 SPAD
    input  wire         TDC_tgate, //from analog end, 3ns pulse follow trigger signal
    output wire [14:0]  TDC_Odata, //!todo
    //output wire [3 :0]  TDC_Oint, //output intensity counter for each depth data 
    output wire [4 :0]  TDC_Oint, //!todo
    output reg  [1 :0]  TDC_Onum, //output valid data number
    output wire         TDC_Olast, //!todo output last data signal
    output wire         TDC_Ovalid, //!todo output data valid signal
    input  wire         TDC_Oready, //output data ready signal
    output wire         TDC_INT //!todo output interrupt signal
);
//-------------------------------------------------------------------
reg  [31:0]  start_reg_out;
wire [4:0]   start_data_out;
reg  [31:0]  stop_reg_out;
wire [4:0]   stop_data_out;
reg          cnt_start;
reg  [9:0]   counter;
wire         sync;
//wire         clk5;
reg  [9:0]   counter_reg_out;
reg          out_valid;
//-------------------------------------------------------------------
wire [14:0]  tof;
reg  [14:0]  tof_data[2:0]; //depth = 3 
reg  [4:0]   light_level;
reg  [4:0]   INT[2:0];
wire [4:0]   INT_in;
//reg  [31:0]  stop_data[2:0]; //depth = 3 

//-------------------------------------------------------------------

always @(posedge TDC_start or negedge rst_n) begin
    if (!rst_n) begin
        start_reg_out <= 32'h0000_0000;
        cnt_start <= 1'b0;
    end
    else begin
        start_reg_out <= DLL_Phase;
        cnt_start <= 1'b1;
    end
end

always @(posedge TDC_trigger or negedge rst_n) begin
    if (!rst_n) begin
        //stop_data <= 0;
        TDC_Onum <= 0;
        stop_reg_out <= 32'h0000_0000;
    end
    else if (TDC_Onum <= 2) begin
        TDC_Onum <= TDC_Onum + 1;
        //stop_data <= {stop_data[1:0], DLL_Phase};
        stop_reg_out <= DLL_Phase;
    end
    else if (TDC_Onum == 3) begin
        //TDC_Onum <= 3;
        //stop_data <= {stop_data[1:0], DLL_Phase};
        stop_reg_out <= DLL_Phase;
    end
        
end

always @(negedge TDC_tgate or negedge rst_n) begin
    if (!rst_n) begin
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

//assign clk5 = DLL_Phase[0]; // clk5 from external pin
always @(posedge clk5 or negedge rst_n) begin
    if(!rst_n) begin
        counter <= 10'b00_0000_0000;
    end
    else if(cnt_start) begin
        counter <= counter + 10'b00_0000_0001;
    end
end

//---------------sync module-------------------------
sync sync_inst0(
    .s (stop_reg_out[0]),
    .TDC_trigger (TDC_trigger),
    .rst_n (rst_n),
    .clk5 (clk5),
    .sync (sync)
);

//---------------coarse counter reg------------------

always @(posedge sync or negedge rst_n) begin
    if(!rst_n) begin
        counter_reg_out <= 10'b00_0000_0000;
        out_valid <= 1'b0;
    end
    else begin
        counter_reg_out <= counter;
        out_valid <= 1'b1;
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

assign tof[14:0] = {counter_reg_out[9:0], stop_data_out[4:0]} - {10'b00_0000_0001, start_data_out[4:0]};


assign INT_in = light_level;
always @(negedge TDC_trigger or negedge rst_n) begin //clk?
    if (!rst_n) begin
        tof_data[2] <= 0;
        tof_data[1] <= 0;
        tof_data[0] <= 0;
        INT[2]  <= 0;
        INT[1]  <= 0;
        INT[0]  <= 0;
    end
    else if(INT[0] <= INT[1] && INT[0] <= INT[2] && INT[0] <= INT_in) begin
        tof_data[0] <= tof;
        INT[0] <= INT_in;
    end
    else if(INT[1] <= INT[0] && INT[1] <= INT[2] && INT[1] <= INT_in) begin
        tof_data[1] <= tof;
        INT[1] <= INT_in;
    end
    else if (INT[2] <= INT[0] && INT[2] <= INT[1] && INT[2] <= INT_in) begin
        tof_data[2] <= tof;
        INT[2] <= INT_in;
    end
    /* else if(INT_in <= INT[0] && INT_in <= INT[1] && INT_in <= INT[2]) begin
        data[2:0][14:0] <= {data[2], data[1], data[0]};
        INT[2:0][ 4:0] <= {INT[2], INT[1], INT[0]};
    end */
end
//! -------------------------------------------------------

assign TDC_Odata = 0;
assign TDC_Oint = 0;
assign TDC_Olast = 0;
assign TDC_Ovalid = 0;
assign TDC_INT = 0;
endmodule //tdc_top


