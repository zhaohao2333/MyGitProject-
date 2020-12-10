module tdc_top (
    input  wire [31:0]  phase,
    input  wire         clk, //500Mhz
    input  wire         rst,
    input  wire         start,
    input  wire         light_pulse,
    output wire [12:0]  tof,
    output reg		    out_valid
);
reg  [31:0]  start_reg_out;
wire [4:0]   start_data_out;
reg  [31:0]  stop_reg_out;
wire [4:0]   stop_data_out;
reg          cnt_start;
reg  [7:0]   counter;
reg          sync;
wire         vout;
wire         s;
wire         sync_clk;
reg  [7:0]   counter_reg_out;
reg          stop_0;
reg          stop_1;
wire         sync_clk_i;

//------------------------------------------


//------------------------------------------

always @(posedge start or negedge rst) begin
    if (!rst) begin
        start_reg_out <= 32'h0000_0000;
        cnt_start <= 1'b0;
    end
    else begin
        start_reg_out <= phase;
        cnt_start <= 1'b1;
    end
end

always @(posedge light_pulse or negedge rst) begin
    if (!rst) begin
        stop_reg_out <= 32'h0000_0000;
    end
    else begin
        stop_reg_out <= phase;
    end
end

//---------------coarse counter----------------------

assign sync_clk = phase[0];
always @(posedge sync_clk or negedge rst) begin
    if(!rst) begin
        counter <= 8'h00;
    end
    else if(cnt_start) begin
        counter <= counter + 8'h01;
    end
end

//---------------sync module-------------------------

assign s = stop_reg_out[0];
assign sync_clk_i = !sync_clk;
always @(posedge sync_clk_i or negedge rst) begin
    if(!rst) begin
        stop_0 <= 1'b0;
    end
    else begin
        stop_0 <= light_pulse;
    end
end

always @(posedge sync_clk or negedge rst) begin
    if(!rst) begin
        stop_1 <= 1'b0;
    end
    else begin
        stop_1 <= light_pulse;
    end
end

/* always @(*) begin
    case (s)
        0:
            sync = stop_0;
        1:
            sync = stop_1;
        default:
            sync = stop_0;
    endcase
end */

assign vout = (s == 0) ? stop_0 : stop_1;
always @(posedge sync_clk_i or negedge rst) begin
    if(!rst) begin
        sync <= 1'b0;        
    end
    else begin
        sync <= vout;        
    end
end

//---------------coarse counter reg------------------

always @(posedge sync or negedge rst) begin
    if(!rst) begin
        counter_reg_out <= 8'b0000_0000;
        out_valid <= 1'b0;
    end
    else if(sync) begin
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

assign tof[12:0] = {counter_reg_out[7:0], stop_data_out[4:0]} - {8'b0000_0001, start_data_out[4:0]};

endmodule //tdc_top
