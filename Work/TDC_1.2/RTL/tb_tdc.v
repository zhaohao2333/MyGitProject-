`timescale 1ns/1ps
module tb_tdc;

    reg          clk_i;
//////////
    reg  [31:0]  DLL_Phase;
    reg          clk5; 
    reg          clk;
    reg          rst_n; 
    reg          rst;
    reg          TDC_start;
    reg          TDC_trigger;
    reg  [15:0]  TDC_spaden; 
    reg          TDC_tgate; 
    wire [14:0]  TDC_Odata;
    //output wire [3 :0]  TDC_Oint, //output intensity counter for each depth data 
    wire [4 :0]  TDC_Oint;
    wire [1 :0]  TDC_Onum; 
    wire         TDC_Olast;
    wire         TDC_Ovalid; 
    reg          TDC_Oready;
    wire         TDC_INT;


tdc_top tdc_top_dut(
    .DLL_Phase          (DLL_Phase),
    .clk5               (DLL_Phase[0]), //500 Mhz for cnt, DLL_Phase[0]
    .clk                (clk), //250 Mhz for logic, axi stream logic
    .rst_n              (rst_n), //from external PIN, active low
    .TDC_start          (TDC_start), //from core logic
    .TDC_trigger        (TDC_trigger), //from SPAD
    .TDC_spaden         (TDC_spaden), //from 4*4 SPAD
    .TDC_tgate          (TDC_tgate), //from analog end, 3ns pulse follow trigger signal
    .TDC_Odata          (TDC_Odata),
    //output wire [3 :0]  TDC_Oint, //output intensity counter for each depth data 
    .TDC_Oint           (TDC_Oint),
    .TDC_Onum           (TDC_Onum), //output valid data number
    .TDC_Olast          (TDC_Olast), //output last data signal
    .TDC_Ovalid         (TDC_Ovalid), //output data valid signal
    
    .TDC_Oready         (TDC_Oready), //output data ready signal
    
    .TDC_INT            (TDC_INT) //output interrupt signal
);

initial begin
    begin
        clk_i = 0;
        clk = 0;
        rst_n = 1;
        rst = 1;
        TDC_start = 0;
        TDC_trigger = 0;
        TDC_tgate = 0;
        TDC_spaden = 0;
        TDC_Oready = 1; //!todo
    // start 1:
        #5   rst_n = 0;
             rst = 0;
        #20  rst_n = 1;
             rst = 1;
        //#28 TDC_start = 1;
        #228 TDC_start = 1;
        #200 TDC_start = 0;
    // pulse 1:
        #900 TDC_trigger = 1;
             TDC_spaden = 16'b0000_0000_0000_0001; //int = 1
             TDC_tgate = 1;
        #480 TDC_tgate = 0;
        #320 TDC_trigger = 0; // light_pulse == 800 ns = 480 + 320 ns
    // pulse 2:
        #150
             TDC_trigger = 1;
             TDC_spaden = 16'b0000_0000_1111_0001; //int = 5
             TDC_tgate = 1;
        #480 TDC_tgate = 0;
        #320 TDC_trigger = 0;
    // pulse 3:
        #500
             TDC_trigger = 1;
             TDC_spaden = 16'b0000_1111_1111_0001; //int = 9
             TDC_tgate = 1;
        #480 TDC_tgate = 0;
        #320 TDC_trigger = 0;
    // pulse 4:
        #500
             TDC_trigger = 1;
             TDC_spaden = 16'b0011_1111_1111_0001; //int = 11
             TDC_tgate = 1;
        #480 TDC_tgate = 0;
        #320 TDC_trigger = 0;
    // pulse 5:
        #500
             TDC_trigger = 1;
             TDC_spaden = 16'b0011_0000_1111_0001; //int = 7
             TDC_tgate = 1;
        #480 TDC_tgate = 0;
        #320 TDC_trigger = 0;
        
        #5000 ;// overflow
    // test if trigger signal is valid
             TDC_trigger = 1;
             TDC_spaden = 16'b0011_0000_1111_0011; //int = 8
             TDC_tgate = 1;
        #480 TDC_tgate = 0;
        #320 TDC_trigger = 0;
        
    //----------------------------------------------------------------------------------------------
    //! reset
        #500 ;
        #5   rst_n = 0;
        #20  rst_n = 1;
    // start 2:
             TDC_start = 1;
        #200 TDC_start = 0;
    // pulse 1:
        #900 TDC_trigger = 1;
             TDC_spaden = 16'b0000_0000_0000_0001; //int = 1
             TDC_tgate = 1;
        #480 TDC_tgate = 0;
        #320 TDC_trigger = 0; // light_pulse == 800 ns = 480 + 320 ns
    // pulse 2:
        #150
             TDC_trigger = 1;
             TDC_spaden = 16'b0000_0000_1111_0001; //int = 5
             TDC_tgate = 1;
        #480 TDC_tgate = 0;
        #320 TDC_trigger = 0;

        #500 ;
        $finish;
    end
end



//-------------------------------------------------------------------------------------
always #5 clk_i = !clk_i;
//1 cnt cycle 320 ns == 2 ns, light_pulse 5 ns = 800 ns ,time gate 3 ns == 480 ns

always @(posedge clk_i or negedge rst) begin
    if (!rst) begin
        DLL_Phase <= 32'b1111_1111_1111_1111_0000_0000_0000_0000;
    end
    else begin
        DLL_Phase <= {DLL_Phase[0], DLL_Phase[31:1]};
    end
end

endmodule
