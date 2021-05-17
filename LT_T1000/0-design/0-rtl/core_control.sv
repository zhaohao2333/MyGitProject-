module Core_Control // Core control module
(   
    // CLK and RST
    input  wire                 PLL_clk,
    input  wire                 rstn_osc,
    input  wire                 rstn_pll,
    input  wire                 OSC_clk,  //25 Mhz
    output logic                CMUX_clk,
    // TDC1 module interface starts here    
    input  wire [18:0]          TDC1_Odata,
    input  wire [2:0]           TDC1_Onum,
    input  wire                 TDC1_Ovalid,
    // TDC1 module interface ends

    // TDC2 module interface starts here    
    input  wire [18:0]          TDC2_Odata,
    input  wire [2:0]           TDC2_Onum,
    input  wire                 TDC2_Ovalid,
    // TDC2 module interface ends 

    // SPI slave Interface starts here
    input  wire                 SPI_CS,
    input  wire                 SPI_CLK,
    input  wire                 SPI_MOSI,
    output logic                SPI_MISO,
    output logic                MISO_OEN,
    // SPI slave Interface ends
    
    // eFuse Interface starts here
    output logic                EFUSE_SCLK,
    output logic                EFUSE_CS,
    output logic                EFUSE_RW,
    output logic                EFUSE_PGM,
    input  wire                 EFUSE_DOUT,
    // eFuse Interface ends

    // Analog end Interface starts here
        // NVM management, Trimming Reg
    output logic [2:0]          sreg_pll_r_cp,
    output logic [5:0]          sreg_pll_r_div,
    output logic [2:0]          sreg_dll_r_cp,
    output logic [3:0]          sreg_vref_vbg_trim,
    output logic [3:0]          sreg_vref_v2i_trim,
    // output logic [2:0]          sreg_pix_vref,
    output logic [1:0]          sreg_ldo_p_select,
    output logic [1:0]          sreg_ldo_d_select,
    output logic                dll_local_b,
    output logic                pll_local_b,
       // Non Trimming Reg
    // output logic                sreg_pd_pll,
    // output logic                sreg_pd_dll,
    // output logic                sreg_pd_vref,
    output logic                sreg_pd_vbg,
    output logic                sreg_pd_v2v,
    // output logic                sreg_pd_vdac,
    output logic                sreg_pd_ldo_p,
    output logic                sreg_pd_ldo_d,
    // output logic                sreg_pd_tmux,
    output logic [4:0]          sreg_tmux_sel,
    output logic                sreg_vbg_test_ctrl,
    output logic                reset_pd_pll_dll,
    output logic                start_dll, //initial 0, pull up after clk_cmux switch to pll_clk
    output logic                bypass_all,
    // Analog end Interface ends

    // two interrrupt Output
    output logic                INT0,
    output logic                INT0_OEN,
    output logic                INT1,
    output logic                INT1_OEN

);
    // OEN assignment 
	assign INT0_OEN   = 1'b0;
	assign INT1_OEN   = 1'b0;

    // Enable Control registers
    logic TDC_EN;
    logic EFUSE_PGMEN;  //self-reset
    logic TRIM_MUX;     //Trimming MUX, 1 for reg-OSC, 0 for NVM, OSC(init=1)->PLL(init=0)

    // eFuse Interface            
    logic           efuse_rstart; 
    logic [31:0]    efuse_rdat;     
    logic           efuse_rvalid; 
    logic [31:0]    efuse_wdat;
    logic           efuse_wstart;
    logic           efuse_rack;
    logic [1:0]     efuse_rack_d;
    logic           efuse_wack;
    logic [1:0]     efuse_wack_d;

    //Addressed Register Table
    logic [7:0]  Add_Reg_00;
    logic [7:0]  Add_Reg_01;
    logic [7:0]  Add_Reg_02;
    logic [7:0]  Add_Reg_03;
    logic [7:0]  Add_Reg_04;
    logic [7:0]  Add_Reg_05;
    logic [7:0]  Add_Reg_06;
    logic [7:0]  Add_Reg_07;
    logic [7:0]  Add_Reg_08;
    logic [7:0]  Add_Reg_09;
    logic [7:0]  Add_Reg_0A;
    logic [7:0]  Add_Reg_0B;
    logic [7:0]  Add_Reg_0C;
    logic [7:0]  Add_Reg_0D;
    //logic [5:0]  Add_Reg_0E;
    //logic [6:0]  Add_Reg_0F;

// SPI instantiation 
    logic [1:0]     SPI_Onum;
    logic [23:0]    SPI_Odata;
    logic           SPI_Odstart; //start puluse to denote one successful handshake
    logic [7:0]     SPI_Irrerg;
    logic           SPI_Irvalid;
    logic           SPI_Irready;
    logic [7:0]     SPI_Irreg;
    logic [7:0]     SPI_Iadd;
    logic [7:0]     SPI_Oreg;
    logic           SPI_Orreq;
    logic           SPI_Orvalid;

// SPI Read/Write register Driver
    logic [7:0] reg_add_r,wreg_dat_r,rreg_dat_r;
    logic [2:0] wreg_req_d,rreg_req_d;

// TDC Module
    logic [19:0]    TDC_Calib;  // TDC Calibration data
    logic [1:0]     TDC_mode;   // TDC Working mode, detail 
    logic           TDC1_Oready;
    logic           TDC2_Oready;
// Initial Trimming readout 
    //logic           efuse_iread_en; // EFUSE read enable
    logic           efuse_prgen;    // EFUSE program enable
    logic [31:0]    efuse_idata;    // EFUSE initial read data

    // clock mux instantiation
    logic init_delay;       // init delay for 300us, 0 for OSC, 1 for PLL(init done)
    logic reg_div2;         // division reg
    // logic clk2;          // PLL clock after division
    logic CMUX_rst;
    logic CMUX_sel;         // 0 for OSC, 1 for PLL

    // PLL output Test - 64 div PLL_OUT
    logic cntpll_en;
    //logic [5:0] cntpll;
    logic cntpll_oen;
    logic cntpll_rstn;

// Buf module 
    logic TDC1_INT;
    logic TDC2_INT;
    logic [23:0]    OUT1;
    logic [23:0]    OUT2;
    logic TDC1_rdone;   // TDC1 BUF read done, start read TDC2 BUF
    logic PLL_div64;    // PLL clock divided by 64

    logic [23:0] OUT;

// register configuration assignment
    always_comb begin
        // TDC Module
        TDC_Calib       =   {Add_Reg_03,Add_Reg_02};
        TDC_mode        =   Add_Reg_04[1:0];
        SPI_Onum        =   Add_Reg_04[6:5];
        // Enable signal
        TDC_EN          =   Add_Reg_07[0];
        EFUSE_PGMEN     =   Add_Reg_07[2];
        TRIM_MUX        =   Add_Reg_07[4];

        // Analog End
        reset_pd_pll_dll     =   Add_Reg_0C[0];
        // sreg_pd_dll     =   Add_Reg_0C[1];
        // sreg_pd_vref    =   Add_Reg_0C[2];
        sreg_pd_vbg     =   Add_Reg_0C[1];
        sreg_pd_v2v     =   Add_Reg_0C[2];
        // sreg_pd_vdac    =   Add_Reg_0C[5];
        sreg_pd_ldo_p   =   Add_Reg_0C[3];
        sreg_pd_ldo_d   =   Add_Reg_0C[4];  
        bypass_all      =   Add_Reg_0C[5];
        sreg_vbg_test_ctrl  =   Add_Reg_0C[6];
        sreg_tmux_sel   =   Add_Reg_0D[4:0];
        start_dll       =   init_delay;

        //Trimming assignment
        // sreg_pll_r_cp        =   Add_Reg_08[2:0];
        // sreg_pll_r_div       =   Add_Reg_;
        // sreg_dll_r_cp        =   Add_Reg_09[3:1];
        // sreg_vref_vbg_trim   =   Add_Reg_09[7:4];
        // sreg_vref_v2i_trim   =   Add_Reg_0A[3:0];
        // sreg_pix_vref        =   Add_Reg_0A[6:4];
        // sreg_ldo_p_select    =   {Add_Reg_0B[0],Add_Reg_0A[7]};
        // sreg_ldo_d_select    =   Add_Reg_0B[2:1];
    end
// Trimming register assignment
    always_ff@(posedge CMUX_clk or negedge rstn_osc)begin
        if(!rstn_osc)begin
            sreg_pll_r_cp<=3'b0;
            sreg_pll_r_div<=6'b010100;
            sreg_dll_r_cp<=3'b0;
            sreg_vref_vbg_trim<=4'b1000;
            sreg_vref_v2i_trim<=4'b1000;
            sreg_ldo_p_select<=2'b10;
            sreg_ldo_d_select<=2'b10;
            dll_local_b<=1'b0;
            pll_local_b<=1'b0;
        end
        else begin
           if (TRIM_MUX) begin
                sreg_pll_r_cp   <=  Add_Reg_08[2:0];
                sreg_pll_r_div  <=  {Add_Reg_09[0],Add_Reg_08[7:3]};
                sreg_dll_r_cp   <=  Add_Reg_09[3:1];
                sreg_vref_vbg_trim  <=  Add_Reg_09[7:4];
                sreg_vref_v2i_trim  <=  Add_Reg_0A[3:0];
                sreg_ldo_p_select   <=  Add_Reg_0A[5:4];
                sreg_ldo_d_select   <=  Add_Reg_0A[7:6];
                dll_local_b     <=  Add_Reg_0B[0];
                pll_local_b     <=  Add_Reg_0B[1];
            end
            else if (efuse_rvalid) begin
                sreg_pll_r_cp   <=  efuse_rdat[2:0];
                sreg_pll_r_div  <=  efuse_rdat[8:3]^6'b010100;
                sreg_dll_r_cp   <=  efuse_rdat[11:9];
                sreg_vref_vbg_trim  <=  efuse_rdat[15:12]^4'b1000;
                sreg_vref_v2i_trim  <=  efuse_rdat[19:16]^4'b1000;
                sreg_ldo_p_select   <=  efuse_rdat[21:20]^2'b10;
                sreg_ldo_d_select   <=  efuse_rdat[23:22]^2'b10;
                dll_local_b     <=  efuse_rdat[24];
                pll_local_b     <=  efuse_rdat[25];
            end
        end
    end
    // write control signal driver
    always_ff@(posedge CMUX_clk or negedge rstn_osc)begin
        if(!rstn_osc) begin 
            reg_add_r<=8'b0; 
            wreg_dat_r<=8'd0; 
            wreg_req_d<=3'b0; 
            rreg_req_d<=3'b0;
        end
        else begin
            wreg_req_d<={wreg_req_d[1:0],SPI_Irvalid};
            rreg_req_d<={rreg_req_d[1:0],SPI_Orreq};
            if(SPI_Irvalid&&SPI_Irready) begin 
                wreg_dat_r<=SPI_Irreg; 
            end

            if(SPI_Orreq|(SPI_Irvalid&&SPI_Irready)) begin 
                reg_add_r<=SPI_Iadd;
            end
        end
    end

    // common register write
    always_ff@(posedge CMUX_clk or negedge rstn_osc)begin
        if(!rstn_osc) begin
            Add_Reg_00<=8'b0; Add_Reg_01<=8'b0; Add_Reg_02<=8'b0; Add_Reg_03<=8'b0; Add_Reg_04<=8'b0; Add_Reg_05<=8'b0;
            Add_Reg_06<=8'b0; Add_Reg_07<=8'b0; Add_Reg_0C<=8'b0; Add_Reg_0D<=8'b1000;
        end else begin
            if(wreg_req_d[1])begin
                case(reg_add_r[3:0])
                4'h0:Add_Reg_00<=wreg_dat_r;
                4'h1:Add_Reg_01<=wreg_dat_r;
                4'h2:Add_Reg_02<=wreg_dat_r;
                4'h3:Add_Reg_03<=wreg_dat_r;
                4'h4:Add_Reg_04<=wreg_dat_r;
                4'h5:Add_Reg_05<=wreg_dat_r;
                4'h6:Add_Reg_06<=wreg_dat_r;
                4'h7:Add_Reg_07<=wreg_dat_r;
                4'hc:Add_Reg_0C<=wreg_dat_r;
                4'hd:Add_Reg_0D<=wreg_dat_r;
                //4'he:Add_Reg_0E<=wreg_dat_r;
                endcase
            end
            // self-reset enable bit
            else begin
                if(Add_Reg_07[2]&&(EFUSE_CS|efuse_wack_d[1]))       
                    Add_Reg_07[2]<=1'b0;
                if(Add_Reg_07[3])        
                    Add_Reg_07[3]<=1'b0;
            end
        end
    end

    // trimming register write
    always_ff@(posedge CMUX_clk or negedge rstn_osc) begin
        if(!rstn_osc)begin  
            Add_Reg_08<=8'b0; Add_Reg_09<=8'b0; Add_Reg_0A<=8'b0; Add_Reg_0B<='0;
        end
        else begin
            if(wreg_req_d[1]) begin 
                case(reg_add_r[3:0])
                    4'h8:Add_Reg_08<=wreg_dat_r;
                    4'h9:Add_Reg_09<=wreg_dat_r;
                    4'ha:Add_Reg_0A<=wreg_dat_r;
                    4'hb:Add_Reg_0B<=wreg_dat_r;
                endcase
            end
            else if(efuse_rvalid) 
                {Add_Reg_0B,Add_Reg_0A,Add_Reg_09,Add_Reg_08} <= efuse_rdat;
        end
    end

    // register read
        always_ff@(posedge CMUX_clk or negedge rstn_osc) begin
            if(!rstn_osc) begin 
                rreg_dat_r<=8'b0; 
            end
            else begin
                if(rreg_req_d[1])begin
                    case(reg_add_r[3:0])
                    4'h0:rreg_dat_r<=Add_Reg_00;
                    4'h1:rreg_dat_r<=Add_Reg_01;
                    4'h2:rreg_dat_r<=Add_Reg_02;
                    4'h3:rreg_dat_r<=Add_Reg_03;
                    4'h4:rreg_dat_r<=Add_Reg_04;
                    4'h5:rreg_dat_r<=Add_Reg_05;
                    4'h6:rreg_dat_r<=Add_Reg_06;
                    4'h7:rreg_dat_r<=Add_Reg_07;
                    4'h8:rreg_dat_r<=Add_Reg_08;
                    4'h9:rreg_dat_r<=Add_Reg_09;
                    4'ha:rreg_dat_r<=Add_Reg_0A;
                    4'hb:rreg_dat_r<=Add_Reg_0B;
                    4'hc:rreg_dat_r<=Add_Reg_0C;
                    4'hd:rreg_dat_r<=Add_Reg_0D;
                    endcase
                    //4'he:rreg_dat_r<={2'b0,Add_Reg_0E};
                end
            end
        end
        
    // Initial Trimming read, working at 25M Oscillator clock
    always_ff@ (posedge OSC_clk or negedge rstn_osc) begin
        if(!rstn_osc) begin 
            efuse_rstart <= 1'b1;
            efuse_idata <= 32'b0; 
        end
        else begin 
			if(efuse_rstart&&efuse_rack_d[1]) begin
                efuse_rstart <= 1'b0;
            end
            if(efuse_rvalid) begin 
                efuse_idata <= efuse_rdat;
            end
        end
    end

    // Efuse Program Driver
    always_ff@(posedge CMUX_clk or negedge rstn_osc)begin
        if(!rstn_osc) begin 
            efuse_wstart<=1'b0;
            efuse_rack_d<=2'b0;
            efuse_wack_d<=2'b0;
        end
        else begin  
            efuse_rack_d<={efuse_rack_d[0],efuse_rack};
            efuse_wack_d<={efuse_wack_d[0],efuse_wack};
            if((!efuse_wstart)&&EFUSE_PGMEN&&TRIM_MUX)      
                efuse_wstart<=1'b1;
            else if((efuse_wack_d[1]|EFUSE_CS)&&efuse_wstart)   
                efuse_wstart<=1'b0;
        end
    end
    assign efuse_wdat={Add_Reg_0B,Add_Reg_0A,Add_Reg_09,Add_Reg_08};

    // Exposure Frequency Counter driver
    always_comb begin
        cntfreq_en = (TDC_EN&&TDC_mode==2'b1)|(!init_delay);
    end

    // init delay
    always_ff@(posedge CMUX_clk or negedge rstn_osc)begin
    // for final, ~300us dead time
        if(!rstn_osc) begin 
			init_delay <=1'b0;
		end
        else begin 
			if((&cntfreq[14:13])&&(!init_delay))
                init_delay<=1'b1;
		end
    // for test, 800ns dead time
    /*
	    if(!rst_n) begin
            init_delay <=1'b0; 
        end 
        else begin
        	if(cntfreq[5]&&!init_delay) 
                init_delay<=1'b1;
        end
	*/
    end


    always_comb begin
        CMUX_sel=(init_delay&(!TRIM_MUX));
        cntpll_en=TRIM_MUX;
    end

    always_ff@(posedge PLL_clk or negedge rstn_pll)begin
        if(!rstn_pll) begin
            PLL_div64<=1'b0;
        end
        else if(cntpll_oen) begin
            PLL_div64<=~PLL_div64;
        end
    end

    // External PAD assignment
    always_comb begin   
        INT0 = TRIM_MUX ? PLL_div64 : TDC1_INT;//   ?????????????????????????????????????????????????????
        INT1 = TDC2_INT;
        SPI_Oreg = rreg_dat_r;
        SPI_Orvalid = rreg_req_d[2];
        SPI_Irready = 1'b1;
    end
    
    // Trimming Test output
    counterM #(.cnt_mod(32)) cnt_PLL(
        .clk(PLL_clk),
        .rst_n(rstn_pll),
        .cnt_en(cntpll_en),
        .cntout(),
        .cout_en(cntpll_oen)
    );
    // Exposure frequency 
    counterMax #(.DW(16)) cnt_freq(
        .clk(CMUX_clk),
        .rst_n(rstn_osc),
        .en(cntfreq_en),
        .max(cnt_max),         // set cnt_max
        .cnt(cntfreq),         // for init_delay
        .co( )
    );
    // TDC and Histogram Buffer 
    INPUT_BUF tdc1_buf(
        .clk(CMUX_clk),
        .rst_n(rstn_osc),
        .TDC_Ovalid(TDC1_Ovalid),
        .TDC_Onum(TDC1_Onum),
        .TDC_Calib(TDC_Calib),
        .TDC_Odata(TDC1_Odata),
        .TDC_Oready(TDC1_Oready), // always high for TDC
        .SPI_Odstart(SPI_Odstart),
        .OUT(OUT1),
        .INT(TDC1_INT),
        .read_en(1'b1),
        .read_done(TDC1_rdone)
    );

    INPUT_BUF tdc2_buf(
        .clk(CMUX_clk),
        .rst_n(rstn_osc),
        .TDC_Ovalid(TDC2_Ovalid),
        .TDC_Onum(TDC2_Onum),
        .TDC_Calib(TDC_Calib),
        .TDC_Odata(TDC2_Odata),
        .TDC_Oready(TDC2_Oready), // always high for TDC
        .SPI_Odstart(SPI_Odstart),
        .OUT(OUT2),
        .INT(TDC2_INT),
        .read_en(TDC1_rdone),
        .read_done()
    );
    //===========================================================================
    assign SPI_Odata =  TDC1_INT ? OUT1:
                        TDC2_INT ? OUT2:24'b0;

    
    //===========================================================================

    // SPI Instantiation
    SPI_top  #(.MAX_WIDTH(24),.IN_WIDTH(8)) spi(
        .clk(CMUX_clk),
        .rst_n(rstn_osc),
        .SPI_Odata(SPI_Odata),
        .SPI_Odstart(SPI_Odstart), 
        .SPI_Irreg(SPI_Irreg),
        .SPI_Irvalid(SPI_Irvalid),
        .SPI_Irready(SPI_Irready),
        .SPI_Iadd(SPI_Iadd),
        .SPI_Oreg(SPI_Oreg),
        .SPI_Orreq(SPI_Orreq), 
        .SPI_Orvalid(SPI_Orvalid),
        .SPI_CS(SPI_CS),
        .SPI_CLK(SPI_CLK),
        .SPI_MOSI(SPI_MOSI),
        .SPI_MISO(SPI_MISO),
        .MISO_OEN(MISO_OEN)
    );  
    // EFUSE Instantiation
    efuse_driver efuse (
        .clk(OSC_clk),
        .rstn(rstn_osc),
        .read_start(efuse_rstart),
        .read_ack(efuse_rack),
        .dout(efuse_rdat),
        .dout_valid(efuse_rvalid), 
        .efuse_din(efuse_wdat),
        .prog_start(efuse_wstart),
        .prog_ack(efuse_wack),
        .EFUSE_SCLK(EFUSE_SCLK),
        .EFUSE_CS(EFUSE_CS),
        .EFUSE_RW(EFUSE_RW), 
        .EFUSE_PGM(EFUSE_PGM),
        .EFUSE_DOUT(EFUSE_DOUT)
    );
    // CLOCK MUX, sel 0 for OSC, 1 for PLL
    CLK_MUX clk_mux(
        .OSC_CLK(OSC_clk),
        .PLL_CLK(PLL_clk),
        .rstn_osc(rstn_osc),
        .rstn_pll(rstn_pll),
        .sel(CMUX_sel),
        .OUT_CLK(CMUX_clk)
    );

endmodule
