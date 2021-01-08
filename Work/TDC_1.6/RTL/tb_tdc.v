`timescale 1ns/1ns
module tb_tdc;

    reg          clk_i;
    reg  [31:0]  DLL_Phase;
    reg          clk5; 
    reg          clk;
    reg          rst_n; 
    reg          rst;
    reg          TDC_start;
    wire         TDC_trigger;
    reg  [15:0]  TDC_spaden; 
    wire         TDC_tgate; 
    wire [14:0]  TDC_Odata;
    //output wire [3 :0]  TDC_Oint, //output intensity counter for each depth data 
    wire [3 :0]  TDC_Oint;
    wire [1 :0]  TDC_Onum; 
    wire         TDC_Olast;
    wire         TDC_Ovalid; 
    reg          TDC_Oready;
    wire         TDC_INT;
    reg  [14:0]  TDC_Range;
    reg          photon;
    wire         rst_auto;


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
    
    .TDC_Oready         (TDC_Oready), //output data ready signal
    
    .TDC_INT            (TDC_INT), //output interrupt signal
    .rst_auto           (rst_auto)
);
spad_module spad_module_dut(
    .photon(photon),  //posdege for photon arrival
    .rst_auto(rst_auto), //(!time_gate) & sync, sync is provided by sync module
    .trig(TDC_trigger),
    .time_gate(TDC_tgate)
);
initial begin
    begin
        clk_i = 0;
        clk = 0;
        rst_n = 1;
        rst = 1;
        TDC_start = 0;
        TDC_spaden = 0;
        TDC_Oready = 1; //!todo
        TDC_Range = 15'b00000_11111_11100; // TDC_Range = 15'b xxxx;
    // start 1:
        #5   rst_n = 0;
             rst = 0;
        #20  rst_n = 1;
             rst = 1;
        #100;
        //#28 TDC_start = 1;
        @ (posedge clk)
             TDC_start = 1;
        #640 TDC_start = 0;

        #800 photon = 1;
             TDC_spaden = 16'b0000_0000_0000_1111;
        #50  photon = 0;

        @ (negedge rst_auto);
        #200 photon = 1;
             TDC_spaden = 16'b0000_0000_1111_1111;
        #50 photon = 0;
        @ (negedge rst_auto);
        #200 photon = 1;
             TDC_spaden = 16'b0000_1111_1111_1111;
        #50 photon = 0;
        @ (negedge rst_auto);
        #200 photon = 1;
             TDC_spaden = 16'b1111_1111_1111_1111;
        #50 photon = 0;

        #5500;
        #200 photon = 1;
             TDC_spaden = 16'b1111_1111_1111_1111;
        #50 photon = 0;
        @ (negedge rst_auto);
        #200 photon = 1;
             TDC_spaden = 16'b1111_1111_1111_1111;
        #50 photon = 0;
        @ (negedge rst_auto);
        #200 photon = 1;
             TDC_spaden = 16'b1111_1111_1111_1111;
        #50 photon = 0;

        ///////////////////////////////
        
        /* @ (negedge rst_auto);
        #628 ;
        @ (posedge clk)
             TDC_start = 1;
        #640 TDC_start = 0;

        #800 photon = 1;
             TDC_spaden = 16'b0000_0000_0000_1111;
        #50 photon = 0;

        #30000;
        
        @ (posedge clk)
             TDC_start = 1;
        #640 TDC_start = 0;
        #30000; */

        //---------------
        // #20000;
        #59750;
        @ (posedge clk)
             TDC_start = 1;
        #640 TDC_start = 0;

        #75000;
        @ (posedge clk)
             TDC_start = 1;
        #640 TDC_start = 0;
        #200 photon = 1;
             TDC_spaden = 16'b1111_1111_1111_1111;
        #50 photon = 0;
        @ (negedge rst_auto);

        #7830;
             photon = 1;
             TDC_spaden = 16'b0000_0000_0000_0011;
        #50 photon = 0;
        @ (negedge rst_auto);
        #200 photon = 1;
             TDC_spaden = 16'b0000_0000_0000_0111;
        #50 photon = 0;
        #75000;
    //----------------------------------------------------------------------------------------------

        $finish;
    end
end



//-------------------------------------------------------------------------------------
always #5 clk_i = !clk_i;
always #320 clk = !clk;
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
