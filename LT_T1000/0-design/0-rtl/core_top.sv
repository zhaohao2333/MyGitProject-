module Core_Top
(
// CLK and RST
    input  wire             clk_pll,        //from PLL, to core logic
    input  wire             clk_dll,        //from dll phase0, to TDC
    input  wire             clk_osc,        //from external PAD, 
    input  wire             rst_n,          //from external PAD, 

// Sensor Interface begins
    // SPAD Array Input
    input  wire             spad_trigger,   //from SPAD array, trigger   signal
    output wire             clk_pixel,      //new added, 250M clk pixel to sensor       
    // DLL Input
    input  wire [15:0]      dll_phase,      //from DLL, Note: Routing delay should be the same for every bit of this bus
// Sesnsor Interface ends 

// Analog Interface begins 
    // NVM management, Trimming Reg
    output wire [2:0]       sreg_pll_r_cp,
    output wire [5:0]       sreg_pll_r_div,
    output wire [2:0]       sreg_dll_r_cp,
    output wire [3:0]       sreg_vref_vbg_trim,
    output wire [3:0]       sreg_vref_v2i_trim,
    // output wire [2:0]       sreg_pix_vref,
    output wire [1:0]       sreg_ldo_p_select,
    output wire [1:0]       sreg_ldo_d_select,
    // Non Trimming Reg
    // output wire             sreg_pd_pll,
    // output wire             sreg_pd_dll,
    // output wire             sreg_pd_vref,
    output wire             sreg_pd_vbg,
    output wire             sreg_pd_v2v,
    // output wire             sreg_pd_vdac,
    output wire             sreg_pd_ldo_p,
    output wire             sreg_pd_ldo_d,
    // output wire             sreg_pd_tmux,
    output wire [4:0]       sreg_tmux_select,
    output wire             sreg_vbg_test_ctrl,
    output logic            reset_pd_pll_dll,
    output logic            start_dll, // rese
    output logic            dll_local_b,
    output logic            pll_local_b,
    output logic            bypass_all,
// Analog Interface ends 

// eFuse Interface begins
    output logic                EFUSE_SCLK,
    output logic                EFUSE_CS,
    output logic                EFUSE_RW,
    output logic                EFUSE_PGM,
    input  wire                 EFUSE_DOUT,
// eFuse Interface ends

// SPI Interface begins
    input  wire             SPI_CS,         // input PAD
    input  wire             SPI_CLK,        // input PAD
    input  wire             SPI_MOSI,       // input PAD
    output wire             SPI_MISO,       // output PAD
    
// SPI Interface ends
    
// two interrupt, to PAD 
    output wire             INT0,           // output PAD, Configurable for raw Interrupt / PLL Output

    output wire             INT1,           // output PAD, Configurable for peak Interrupt


// VSCEL Driver, to PAD
    output wire             VSCEL_Driver   // output PAD, MOS driver

);

// clock 
    //wire clk5;      assign clk5=dll_phase[0];
    wire CMUX_clk;
    wire rstn_osc;      // reset synchronize to osc
    wire rstn_pll;      // reset synchronize to pll
    assign clk_pixel=CMUX_clk;
// PAD 3.3V
    wire             clk_osc_core;
    wire             rst_n_core;
    wire             SPI_CS_core;   
    wire             SPI_CLK_core;  
    wire             SPI_MOSI_core; 
    wire            SPI_MISO_core;
    wire            MISO_OEN_core;
    wire            INT0_core;
    //wire            INT0_OEN_core;
    wire            INT1_core;
    wire            INT1_OEN_core;
    wire            VSCEL_Driver_core;
    //wire            VDriver_OEN_core;
// LS 1.8V
    wire SPI_MISO_LS;
    wire SPI_MISOEN_LS;
    wire INT0_LS;
    wire INT1_LS;
    wire VSDriver_LS;
    wire clk_osc_LS;
    wire rst_n_LS;   
    wire SPI_CS_LS;  
    wire SPI_CLK_LS; 
    wire SPI_MOSI_LS;



    
//output siganl -> I
PB4CUD16R_D5   transmitter_SPI_MISO       (.PAD(SPI_MISO       ),.OEN(MISO_OEN_core   ),.PU(1'b0),.PD(1'b0),.I(SPI_MISO_core        ),.DS0(1'b0),.DS1(1'b1),.C(),.IE(1'b0) );
PB4CUD16R_D5   transmitter_INT0           (.PAD(INT0           ),.OEN(1'b0   ),         .PU(1'b0),.PD(1'b0),.I(INT0_core            ),.DS0(1'b0),.DS1(1'b1),.C(),.IE(1'b0) );
PB4CUD16R_D5   transmitter_INT1           (.PAD(INT1           ),.OEN(1'b0   ),         .PU(1'b0),.PD(1'b0),.I(INT1_core            ),.DS0(1'b0),.DS1(1'b1),.C(),.IE(1'b0) );
PB4CUD16R_D5   transmitter_VSCEL_Driver   (.PAD(VSCEL_Driver   ),.OEN(1'b0   ),         .PU(1'b0),.PD(1'b0),.I(VSCEL_Driver_core    ),.DS0(1'b0),.DS1(1'b1),.C(),.IE(1'b0) );
Lvshift_1p8to3p3 LS_MISO    ( .A(SPI_MISO_LS),  .AGND(1'b0), .AVDD(1'b1), .DGND(1'b0), .DVDD(1'b1), .PD(1'b0), .Y(SPI_MISO_core) );
Lvshift_1p8to3p3 LS_MISOEN  ( .A(SPI_MISOEN_LS),.AGND(1'b0), .AVDD(1'b1), .DGND(1'b0), .DVDD(1'b1), .PD(1'b0), .Y(MISO_OEN_core) );
Lvshift_1p8to3p3 LS_INT0    ( .A(INT0_LS),      .AGND(1'b0), .AVDD(1'b1), .DGND(1'b0), .DVDD(1'b1), .PD(1'b0), .Y(INT0_core) );
Lvshift_1p8to3p3 LS_INT1    ( .A(INT1_LS),      .AGND(1'b0), .AVDD(1'b1), .DGND(1'b0), .DVDD(1'b1), .PD(1'b0), .Y(INT1_core) );
Lvshift_1p8to3p3 LS_VSDR    ( .A(VSDriver_LS),  .AGND(1'b0), .AVDD(1'b1), .DGND(1'b0), .DVDD(1'b1), .PD(1'b0), .Y(VSCEL_Driver_core) );


//input signal -> C
PB4CUD16R_D5 receiver_clk_osc       (.PAD(clk_osc        ),.OEN(1'b1),.PU(1'b0),.PD(1'b0),.I(1'b0),.DS0(1'b0),.DS1(1'b1),.C(clk_osc_core      ),.IE(1'b1) );
PB4CUD16R_D5 receiver_rst_n         (.PAD(rst_n          ),.OEN(1'b1),.PU(1'b0),.PD(1'b0),.I(1'b0),.DS0(1'b0),.DS1(1'b1),.C(rst_n_core        ),.IE(1'b1) );
PB4CUD16R_D5 receiver_SPI_CS        (.PAD(SPI_CS         ),.OEN(1'b1),.PU(1'b0),.PD(1'b0),.I(1'b0),.DS0(1'b0),.DS1(1'b1),.C(SPI_CS_core       ),.IE(1'b1) );
PB4CUD16R_D5 receiver_SPI_CLK       (.PAD(SPI_CLK        ),.OEN(1'b1),.PU(1'b0),.PD(1'b0),.I(1'b0),.DS0(1'b0),.DS1(1'b1),.C(SPI_CLK_core      ),.IE(1'b1) );
PB4CUD16R_D5 receiver_SPI_MOSI      (.PAD(SPI_MOSI       ),.OEN(1'b1),.PU(1'b0),.PD(1'b0),.I(1'b0),.DS0(1'b0),.DS1(1'b1),.C(SPI_MOSI_core     ),.IE(1'b1) );
Lvshift_3p3to1p8 LS_clk             ( .A(clk_osc_core), .DGND(1'b0), .DVDD(1'b1), .Y(clk_osc_LS) );
Lvshift_3p3to1p8 LS_rst             ( .A(rst_n_core),   .DGND(1'b0), .DVDD(1'b1), .Y(rst_n_LS) );
Lvshift_3p3to1p8 LS_SPICS           ( .A(SPI_CS_core),  .DGND(1'b0), .DVDD(1'b1), .Y(SPI_CS_LS) );
Lvshift_3p3to1p8 LS_SPICLK          ( .A(SPI_CLK_core), .DGND(1'b0), .DVDD(1'b1), .Y(SPI_CLK_LS) );
Lvshift_3p3to1p8 LS_SPIMOSI         ( .A(SPI_MOSI_core),.DGND(1'b0), .DVDD(1'b1), .Y(SPI_MOSI_LS) );

// TDC instantiation
    wire TDC_start;
    wire [14:0] TDC_Odata;
    wire [1:0]  TDC_Onum;
    wire        TDC_Olast;
    wire        TDC_Ovalid;
    wire        TDC_Oready;
    wire [14:0] TDC_Range;
    wire        TDC_busy;

tdc_top tdc(
    .DLL_Phase(dll_phase),
    .clk5(clk_dll), //500 Mhz for cnt, DLL_Phase[0]
    .clk(CMUX_clk), //250 Mhz for logic, axi stream logic
    .rst_n(rstn_osc), //from external PIN, active low
    .TDC_start(TDC_start), //from core logic
    .TDC_trigger(spad_trigger), //from SPAD
    .TDC_Odata(TDC_Odata),
    .TDC_Onum(TDC_Onum), //output valid data number
    .TDC_Olast(TDC_Olast), // output last data signal
    .TDC_Ovalid(TDC_Ovalid), // output data valid signal
    .TDC_Oready(TDC_Oready), //output data ready signal
    .rst_auto(rst_auto),
    .busy(TDC_busy)
);


Core_Control core(   
    // CLK and RST
    .PLL_clk(clk_pll),
    .rstn_osc(rstn_osc),
    .rstn_pll(rstn_pll),
    .OSC_clk(clk_osc_LS),   
    .CMUX_clk(CMUX_clk),         
    // TDC module interface starts here    
    .TDC_Odata(TDC_Odata),
    .TDC_Onum(TDC_Onum),
    .TDC_Olast(TDC_Olast),
    .TDC_Ovalid(TDC_Ovalid),
    .TDC_Oready(TDC_Oready), 
    .TDC_start(TDC_start),
    .TDC_busy(TDC_busy),    
    // TDC module interface ends 

    // SPI slave Interface starts here
    .SPI_CS(SPI_CS_LS),
    .SPI_CLK(SPI_CLK_LS),
    .SPI_MOSI(SPI_MOSI_LS),
    .SPI_MISO(SPI_MISO_LS),
    // SPI slave Interface ends

    // eFuse Interface starts here
    .EFUSE_SCLK(EFUSE_SCLK),
    .EFUSE_CS(EFUSE_CS),
    .EFUSE_RW(EFUSE_RW),
    .EFUSE_PGM(EFUSE_PGM),
    .EFUSE_DOUT(EFUSE_DOUT),
    .MISO_OEN(SPI_MISOEN_LS),
    // eFuse Interface ends

    // Analog end Interface starts here
        // NVM management, Trimming Reg
    .sreg_pll_r_cp(sreg_pll_r_cp),
    .sreg_pll_r_div(sreg_pll_r_div),
    .sreg_dll_r_cp(sreg_dll_r_cp),
    .sreg_vref_vbg_trim(sreg_vref_vbg_trim),
    .sreg_vref_v2i_trim(sreg_vref_v2i_trim),
    // .sreg_pix_vref(sreg_pix_vref),
    .sreg_ldo_p_select(sreg_ldo_p_select),
    .sreg_ldo_d_select(sreg_ldo_d_select),
       // Non Trimming Reg
    // .sreg_pd_pll(sreg_pd_pll),
    // .sreg_pd_dll(sreg_pd_dll),
    // .sreg_pd_vref(sreg_pd_vref),
    .sreg_pd_vbg(sreg_pd_vbg),
    .sreg_pd_v2v(sreg_pd_v2v),
    // .sreg_pd_vdac(sreg_pd_vdac),
    .sreg_pd_ldo_p(sreg_pd_ldo_p),
    .sreg_pd_ldo_d(sreg_pd_ldo_d),
    // .sreg_pd_tmux(sreg_pd_tmux),
    .sreg_tmux_sel(sreg_tmux_select),
    .sreg_vbg_test_ctrl(sreg_vbg_test_ctrl),
    .reset_pd_pll_dll(reset_pd_pll_dll),
    .start_dll(start_dll), // rese
    .dll_local_b(dll_local_b),
    .pll_local_b(pll_local_b),
    .bypass_all(bypass_all),
    // Analog end Interface ends

    // VSCEL Driver Siganl
    .TX_Driver(VSDriver_LS),
    .DRiver_OEN( ),

    // two interrrupt Output
    .INT0(INT0_LS),
    .INT0_OEN( ),
    .INT1(INT1_LS),
    .INT1_OEN( )
);


reset_best sync_osc (.clk(clk_osc_core),.asyn_resetn(rst_n_LS),.syn_resetn(rstn_osc));
reset_best sync_pll (.clk(clk_pll),.asyn_resetn(rst_n_LS),.syn_resetn(rstn_pll));

endmodule 
