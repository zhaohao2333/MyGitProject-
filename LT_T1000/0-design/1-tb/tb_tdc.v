`timescale 1ns/10fs
module tb_tdc;

    reg          clk_i;
    reg  [31:0]  DLL_Phase;
    reg          clk;
    reg          rst_n; 
    reg          rst;
    reg          TDC_start;
    wire         TDC_trigger;
    wire [18:0]  TDC_Odata;
    wire [2 :0]  TDC_Onum; 
    wire         TDC_Olast;
    wire         TDC_Ovalid; 
    wire         busy;
    reg          start;
    reg  [26:0]  core_cnt;

tdc_top tdc_top_dut(
    .DLL_Phase          (DLL_Phase[16:1]),
    .clk5               (DLL_Phase[0]),     //500 Mhz for cnt, DLL_Phase[0]
    .clk                (clk),              //250 Mhz for logic
    .rst_n              (rst_n),            //from external PIN, active low
    .TDC_start          (TDC_start),        //from external PIN
    .TDC_trigger        (TDC_trigger),      //from APD module
    .TDC_Odata          (TDC_Odata),    
    .TDC_Onum           (TDC_Onum),         //output valid data number
    .TDC_Olast          (TDC_Olast),        //output last data signal
    .TDC_Ovalid         (TDC_Ovalid),       //output data valid signal
    .TDC_Oready         (1'b1),             //input data ready signal
    .busy               (busy)
);
apd_module apd_module_dut(
    .TDC_start(TDC_start),
    .trig(TDC_trigger)
);

initial begin
	$fsdbDumpfile("test.fsdb");
	$fsdbDumpvars;
	$fsdbDumpMDA();
end
initial begin
    begin
        clk_i = 0;
        clk = 0;
        rst_n = 1;
        rst = 1;
        TDC_start = 0;
    // start 1:
        #5   rst_n = 0;
             rst = 0;
        #20  rst_n = 1;
             rst = 1;
    //===========================================================
        start = 1;
        @ (posedge TDC_start);
        #50000;
        $finish;
    end
end

//-------------------------------------------------------------------------------------
always #0.03125 clk_i = !clk_i;
always #2 clk = !clk;

always @(posedge clk_i or negedge rst) begin
    if (!rst) begin
        DLL_Phase <= 32'b1111_1111_1111_1111_0000_0000_0000_0000;
    end
    else begin
        DLL_Phase <= {DLL_Phase[0], DLL_Phase[31:1]};
    end
end

//generate TDC_start signal
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        core_cnt <= 0;
    end
    else if (start) begin
        if (core_cnt == 10000) begin
            core_cnt <= 0;
        end
        else
            core_cnt <= core_cnt + 1;
    end
end

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        TDC_start <= 0;
    end
    else if ((core_cnt == 10)||(core_cnt == 11)) begin
        TDC_start <= 1;
    end
    else
        TDC_start <= 0;
end

endmodule
