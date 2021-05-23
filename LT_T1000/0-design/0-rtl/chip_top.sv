module chip_top(
    input  wire             clk_osc,
    input  wire             rst_n,

    input  wire             TDC_START,

    input  wire             SPI_CS,   
    input  wire             SPI_CLK,  
    input  wire             SPI_MOSI, 
    output logic            SPI_MISO,
    //output logic            MISO_OEN,

    output logic            INT0,
    //output logic            INT0_OEN,
    output logic            INT1
    //output logic            INT1_OEN,
);

// core logic instantiation
    logic clk_pll;
    logic clk_plln;
    logic clk_dll;
    // APD interface
    logic trigger1;
    logic trigger2;
    // dll interface
    logic [31:0] dll_phase_all;
    logic [15:0] dll_phase;
    // reg for analog end
    logic [2:0]       sreg_pll_r_cp;
    logic [5:0]       sreg_pll_r_div;
    logic [2:0]       sreg_dll_r_cp;
    logic [3:0]       sreg_vref_vbg_trim;
    logic [3:0]       sreg_vref_v2i_trim;
    // logic [2:0]       sreg_pix_vref;
    logic [1:0]       sreg_ldo_p_select;
    logic [1:0]       sreg_ldo_d_select;
    // logic             sreg_pd_pll;
    // logic             sreg_pd_dll;
    // logic             sreg_pd_vref;
    logic             sreg_pd_vbg;
    logic             sreg_pd_v2v;
    // logic             sreg_pd_vdac;
    logic             sreg_pd_ldo_p;
    logic             sreg_pd_ldo_d;
	logic			  sreg_vbg_test_ctrl;
    // logic             sreg_pd_tmux;
    `ifdef POSTSIM
    logic 			  clk_pixel;
    `endif
    logic [4:0]       sreg_tmux_sel;
    logic             reset_pd_pll_dll;
    logic             start_dll; // reset for dll, initial is 0 and pull up after 300us
    logic             dll_local_b;
    logic             pll_local_b;
    logic             bypass_all;

    // EFUSE Interface
    logic           EFUSE_SCLK;
    logic           EFUSE_CS;
    logic           EFUSE_RW;
    logic           EFUSE_PGM;
    logic           EFUSE_DOUT;
	
    assign clk_dll=dll_phase_all[31];
    assign dll_phase={<<{dll_phase_all[30:15]}};

Core_Top  core(
// CLK and RST
    .clk_pll(clk_pll),        //from PLL, to core logic
    .clk_dll(clk_dll),        //from dll phase0, to TDC
    .clk_osc(clk_osc),        //from external PAD, 
    .rst_n(rst_n),          //from external PAD, 
// Sensor Interface begins
    // APD Input
	.TDC_start(TDC_START),	        //from external PAD
	.trigger1(trigger1),	        //from APD --> TIA --> VCP1
    .trigger2(trigger2),            //from APD --> TIA --> VCP2
    // DLL Input
    .dll_phase(dll_phase),          //from DLL, Note: Routing delay should be the same for every bit of this bus
// Sesnsor Interface ends 

// Analog Interface begins 
    // NVM management, Trimming Reg
    .sreg_pll_r_cp(sreg_pll_r_cp),
    .sreg_pll_r_div(sreg_pll_r_div),
    .sreg_dll_r_cp(sreg_dll_r_cp),
    .sreg_vref_vbg_trim(sreg_vref_vbg_trim),
    .sreg_vref_v2i_trim(sreg_vref_v2i_trim),
    // .sreg_pix_vref(),
    .sreg_ldo_p_select(sreg_ldo_p_select),
    .sreg_ldo_d_select(sreg_ldo_d_select),
    .dll_local_b(dll_local_b),
    .pll_local_b(pll_local_b),
	// Non Trimming Reg
    // .sreg_pd_pll(),
    // .sreg_pd_dll(),
    // .sreg_pd_vref(),
    .sreg_pd_vbg(sreg_pd_vbg),
    .sreg_pd_v2v(sreg_pd_v2v),
    // .sreg_pd_vdac(),
    .sreg_pd_ldo_p(sreg_pd_ldo_p),
    .sreg_pd_ldo_d(sreg_pd_ldo_d),
    // .sreg_pd_tmux(),

    .sreg_tmux_select(sreg_tmux_sel),
	`ifndef POSTSIM
    .sreg_vbg_test_ctrl(sreg_vbg_test_ctrl),
    `endif
	.reset_pd_pll_dll(reset_pd_pll_dll),
    .start_dll(start_dll),
    .bypass_all(bypass_all),
    .clk_pixel(clk_pixel),
// Analog Interface ends 

// eFuse Interface begins
    .EFUSE_SCLK(EFUSE_SCLK),
    .EFUSE_CS(EFUSE_CS),
    .EFUSE_RW(EFUSE_RW),
    .EFUSE_PGM(EFUSE_PGM),
    .EFUSE_DOUT(EFUSE_DOUT),

// SPI Interface begins
    .SPI_CS(SPI_CS),         // input PAD
    .SPI_CLK(SPI_CLK),        // input PAD
    .SPI_MOSI(SPI_MOSI),       // input PAD
    .SPI_MISO(SPI_MISO),       // output PAD
    
// two interrupt, to PAD 
    .INT0(INT0),           // output PAD, Configurable for raw Interrupt / PLL Output
    .INT1(INT1),           // output PAD, Configurable for peak Interrupt
    );

S018V3EBCDEFUSE_SISO32B3M efuse( 
    .CS(EFUSE_CS),
    .RW(EFUSE_RW),
    .PGM(EFUSE_PGM),
    .SCLK(EFUSE_SCLK),
    .DOUT(EFUSE_DOUT),
    .AVDD(1'b1),
    .DVDD(1'b1),
    .DVSS(1'b0)
    );
    
DLL_TOP   dll(   
    .DLL_Phase(dll_phase_all), 
    .AGND(1'b0), 
    .AVDD(1'b1), 
    .DGND(1'b0), 
    .DVDD(1'b1), 
    .ICP_DLL(1'b1), 
    .CKINP(clk_pll),
    .CKINN(1'b0), 
    .RESET(1'b0),
    .r_cp(sreg_dll_r_cp), 
    .r_ibias_cp(dll_local_b) 
   
    //.r_cp(3'b0), 
    //.r_ibias_cp(1'b0) 
   );

PLL_TOP #(.t_lock(800)) pll( 
    .PLLOUTN(clk_pll), 
    .PLLOUTP(clk_plln), 
    .AGND(1'b0), 
    .AVDD(1'b1), 
    .DGND(1'b0), 
    .DVDD(1'b1), 
    .ICP_PLL(1'b1),
    .REFCLK(clk_osc), 
    .RESET(1'b0), 
    //
	.r_cp(sreg_pll_r_cp), 
    .r_div(sreg_pll_r_div),
    .r_ibias_cp(pll_local_b), 
	//*/
	/*
    .r_cp(3'b0), 
	.r_div(6'b010100),
	.r_ibias_cp(3'b0),
	*/
	.BYPASS(1'b0) 
	);
// for pre-sim
apd_module apd_module_dut(
    .TDC_start(TDC_START),
    .trig(trigger1),
    .trig_d(trigger2)
);

endmodule 
