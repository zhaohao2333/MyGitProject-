`timescale 1ns/10fs
module tb_spad;

    reg          clk_i;
    reg  [31:0]  DLL_Phase;
    reg          clk;
    reg          rst_n; 
    reg          rst;
    reg          TDC_start;
    wire         TDC_trigger;
    wire [15:0]  TDC_spaden; 
    wire         TDC_tgate; 
    wire [14:0]  TDC_Odata;
    //output wire [3 :0]  TDC_Oint, //output intensity counter for each depth data 
    wire [3 :0]  TDC_Oint;
    wire [1 :0]  TDC_Onum; 
    wire         TDC_Olast;
    wire         TDC_Ovalid; 
    wire         TDC_Oready;
    //wire         TDC_INT;
    reg  [14:0]  TDC_Range;
    reg          photon;
    wire         rst_auto;
    wire         busy;

    //histogram signal
    reg          HIS_En;
    reg  [3 :0]  HIS_TH;
    reg  [15:0]  HIS_Ibatch;
    wire [14:0]  HIS_Odata;
    reg 		 HIS_Oready; //! from core logic
    wire         HIS_Ovalid;
    reg          start;
    reg  [19:0]  core_cnt;

tdc_top tdc_top_dut(
    .DLL_Phase          (DLL_Phase),
    .clk5               (DLL_Phase[0]), //500 Mhz for cnt, DLL_Phase[0]
    .clk                (clk), //250 Mhz for logic, axi stream logic
    .rst_n              (rst_n), //from external PIN, active low
    .TDC_start          (TDC_start), //from core logic
    .TDC_trigger        (TDC_trigger), //from SPAD
    .TDC_spaden         (TDC_spaden), //from 4*4 SPAD
    .TDC_tgate          (TDC_tgate), //from analog end, 3ns pulse follow trigger signal
    .TDC_Range          (TDC_Range),
    .TDC_Odata          (TDC_Odata),
    //output wire [3 :0]  TDC_Oint, //output intensity counter for each depth data 
    .TDC_Oint           (TDC_Oint),
    .TDC_Onum           (TDC_Onum), //output valid data number
    .TDC_Olast          (TDC_Olast), //output last data signal
    .TDC_Ovalid         (TDC_Ovalid), //output data valid signal
    
    .TDC_Oready         (TDC_Oready), //input data ready signal
    
    //.TDC_INT            (TDC_INT), //output interrupt signal
    .rst_auto           (rst_auto),
    .busy               (busy)
);
spad_module spad_module_dut(
    //.photon(photon),  //posdege for photon arrival
    .TDC_start(TDC_start),
    .rst_auto(rst_auto), //(!time_gate) & sync, sync is provided by sync module
    .trig(TDC_trigger),
    .time_gate(TDC_tgate),
    .spad_int(TDC_spaden)
);

histogram histogram_dut(
     .clk           (clk),
     .rstn          (rst_n),
     .HIS_En        (HIS_En), //高电平有效
     .HIS_TH        (HIS_TH),
     .TDC_Oint      (TDC_Oint),
     .HIS_Ibatch    (HIS_Ibatch), //1:1:20
     .TDC_Odata     (TDC_Odata),
     .TDC_Ovalid    (TDC_Ovalid),
     .TDC_Oready    (TDC_Oready),//当前设计为TDC_Oready=HIS_En
     .HIS_Odata     (HIS_Odata), //当前设计只输出最大值
     .HIS_Oready    (HIS_Oready), //
     .HIS_Ovalid    (HIS_Ovalid), //当前设计当输出有效时，拉高，直到输出握手结束
     .TDC_Onum      (TDC_Onum)
);

initial begin
    begin
        clk_i = 0;
        clk = 0;
        rst_n = 1;
        rst = 1;
        TDC_start = 0;
        TDC_Range = 15'b11111_11111_11000; //
        HIS_En = 1;
        HIS_TH = 5; //! intensity
        HIS_Ibatch = 10; //! num
        HIS_Oready = 1; // from core logic

    // start 1:
        #5   rst_n = 0;
             rst = 0;
        #20  rst_n = 1;
             rst = 1;
    //===========================================================
        start = 1;
        @ (posedge TDC_start);
        #5000;
        $finish;
    end
end

//-------------------------------------------------------------------------------------
always #0.03125 clk_i = !clk_i;
always #2 clk = !clk;

/* always #5 clk_i = !clk_i;
always #320 clk = !clk; */
//1 cnt cycle 320 ns == 2 ns, light_pulse 5 ns = 800 ns ,time gate 3 ns == 480 ns

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
        if (core_cnt == 640) begin
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
    else if (core_cnt == 10) begin
        TDC_start <= 1;
    end
    else
        TDC_start <= 0;
end

endmodule
