module sync (
    input  wire         stop_s,
    input  wire         TDC_start,
    input  wire         TDC_trigger,
    input  wire         rst_n,
    input  wire         clk5,
    output wire			cnt_en,
    output wire         coarse_tri,
	input  wire			overflow,
	output wire			sync
);
//-------------------------------------------------------
wire        clk5_i;
reg         start_0;
reg         start_1;
reg         stop_0;
reg         stop_1;
//wire        sync;
reg         sync_d;
//-------------------------------------------------------
assign clk5_i = !clk5;
//------------------ start sync -------------------------
always @(posedge clk5 or negedge rst_n) begin
    if (!rst_n) begin
        start_r <= 0;
    end
    else if(TDC_start) begin    //! reset
        start_r <= 1;
    end
end

always @(posedge clk5_i or negedge rst_n) begin
    if (!rst_n) begin
        start_f <= 0;
    end
    else if(TDC_start) begin    //! reset
        start_f <= 1;
    end
end

/* always @(posedge clk5 or negedge rst_n) begin
    if(!rst_n) begin
        start_1 <= 1'b0;
    end
    else if (overflow) begin
        start_1 <= 0;
    end
    else if (TDC_start)begin
        start_1 <= 1;
    end
end

always @(posedge clk5_i or negedge rst_n) begin
    if(!rst_n) begin
        start_0 <= 1'b0;
    end
    else if (overflow) begin
        start_0 <= 0;
    end
    else if (TDC_start)begin
        start_0 <= 1;
    end
end */

assign cnt_en = (start_s == 1) ? start_1 : start_0;

/* always @(posedge clk5 or negedge rst_n) begin
    if(!rst_n) begin
        cnt_en <= 1'b0;
    end
    else if (start_s == 1) begin
        cnt_en <= start_1;
    end
    else if (start_s == 0) begin
        cnt_en <= start_0;
    end
end */

//------------------ stop sync --------------------------
always @(posedge clk5 or negedge rst_n) begin
    if(!rst_n) begin
        stop_1 <= 1'b0;
    end
    else begin
        stop_1 <= TDC_trigger;
    end
end

always @(posedge clk5_i or negedge rst_n) begin
    if(!rst_n) begin
        stop_0 <= 1'b0;
    end
    else begin
        stop_0 <= TDC_trigger;
    end
end

assign sync = (stop_s == 1) ? stop_1 : stop_0;

always @(posedge clk5 or negedge rst_n) begin
    if(!rst_n) begin
        sync_d <= 1'b0;
    end
    else begin
        sync_d <= sync;
    end
end

assign coarse_tri = sync & (!sync_d); //若综合不过，仍使用sync上升沿

endmodule //sync

