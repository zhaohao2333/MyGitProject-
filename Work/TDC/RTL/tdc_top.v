module tdc_top (
    input  wire [31:0]  phase,
    input  wire         clk, //500Mhz
    input  wire         rst,
    input  wire         start,
    input  wire         light_pulse,
    output wire [12:0]  tof
);
reg [31:0]  start_reg_out;
reg [4:0]   start_data_out;
reg [31:0]  stop_reg_out;
reg [4:0]   stop_data_out;
reg         cnt_start;
reg [7:0]   counter;
reg         sync;
wire        s;
wire        sync_clk;
reg [7:0]   counter_reg_out;
//------------------------------------------


//------------------------------------------

always @(posedge start or negedge rst) begin:Fine Start Reg
    if (!rst) begin
        start_reg_out <= 32'h0000_0000;
        cnt_start <= 1'b0;
    end
    else begin
        start_reg_out <= phase;
        cnt_start <= 1'b1;
    end
end

always @(posedge light_pulse or negedge rst) begin:Fine Stop Reg
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
always @(posedge sync_clk or negedge rst) begin
    if(!rst) begin
        sync <= 1'b0;
        counter_reg_out <= 8'b0000_0000;
    end
    else if (light_pulse) begin
        sync <= s;
        counter_reg_out <= counter;//! correct?
    end
end

//---------------coarse counter reg------------------

/* always @(posedge clk or negedge rstn) begin//! the clk?
    if(!rst) begin
        
    end
    else if () begin//! triger in sync negedge?
        counter_reg_out <= counter;
    end
end */

//---------------decode------------------------------

decode decode_start(
      .data_in(start_reg_out),
      .data_out(start_data_out)
    );

decode decode_stop(
      .data_in(stop_reg_out),
      .data_out(stop_data_out)
    );

endmodule //tdc_top
