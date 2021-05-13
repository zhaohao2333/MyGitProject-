module Core_Control // Core control module
(   
    // CLK and RST
    input  wire                 PLL_clk,
    input  wire                 rstn_osc,
    input  wire                 rstn_pll,
    input  wire                 OSC_clk,  
    output logic                CMUX_clk,         
    // TDC module interface starts here    
    input  wire [14:0]          TDC_Odata,
    input  wire [1:0]           TDC_Onum,
    input  wire                 TDC_Olast,
    input  wire                 TDC_Ovalid,
    output logic                TDC_Oready,   
    output logic                TDC_start,   
    input  wire                 TDC_busy,   
    // TDC module interface ends 

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

    // VSCEL Driver Siganl
    output logic                TX_Driver,
    output logic                DRiver_OEN,
    // two interrrupt Output
    output logic                INT0,   // raw/PLL division
    output logic                INT0_OEN,
    output logic                INT1,   // Peak interrupt
    output logic                INT1_OEN

);
    // OEN assignment 
	assign DRiver_OEN=1'b0;
	assign INT0_OEN=1'b0;
	assign INT1_OEN=1'b0;


    // Enable Control registers
    logic TDC_EN;
    logic EFUSE_PGMEN;  //self-reset
    logic TDC_EXTEN;    //self-reset
    logic TRIM_MUX;     //Trimming MUX, 1 for reg-OSC, 0 for NVM, OSC(init=1)->PLL(init=0)
    
    // Exposure Frequency control
    wire [15:0] cntfreq;
    logic [15:0] cnt_max;
    logic cntfreq_en;
    logic cntfreq_rstn;
    logic cntfreq_oen;
    logic TDC_start_reg;

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

// TDC Calibration register
    // TDC module
    logic [15:0]    TDC_Calib;  // TDC Calibration data
    logic           TDC_Inten;  // TDC Intensity output enable
    logic [1:0]     TDC_mode;   // TDC Working mode, detail 
    logic [1:0]     TDC_freqm;  // TDC and SPAD exposure frequency mode

// Initial Trimming readout 
    //logic           efuse_iread_en; // EFUSE read enable
    logic           efuse_prgen; // EFUSE program enable
    logic [31:0]    efuse_idata; // EFUSE initial read data

    // clock mux instantiation
    logic init_delay;   // init delay for 300us, 0 for OSC, 1 for PLL(init done)
    logic reg_div2;     // division reg
    // logic clk2;         // PLL clock after division
    logic CMUX_rst;
    logic CMUX_sel;     // 0 for OSC, 1 for PLL

    // PLL output Test - 64 div PLL_OUT
    logic cntpll_en;
    //logic [5:0] cntpll;
    logic cntpll_oen;
    logic cntpll_rstn;

// Buf module 
    logic INT_raw;
    logic INT_peak;
    logic PLL_div64;    // PLL clock divided by 64
    
// TX_Driver module
    // logic [3:0] cnttx;
    // logic cnttx_oen;
    logic [2:0] cnttx;  //delay counter for tx_driver
// register configuration assignment
    always_comb begin
        // TDC Module
        TDC_Range       =   {Add_Reg_01[6:0],Add_Reg_00};
        TDC_Calib       =   {Add_Reg_03,Add_Reg_02};
        TDC_mode        =   Add_Reg_04[1:0];
        TDC_freqm       =   Add_Reg_04[3:2];
        TDC_Inten       =   Add_Reg_04[4];
        SPI_Onum        =   Add_Reg_04[6:5];

        // Enable signal
        TDC_EN          =   Add_Reg_07[0];

        EFUSE_PGMEN     =   Add_Reg_07[2];
        TDC_EXTEN       =   Add_Reg_07[3];
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
            if(wreg_req_d[1])begin 
                case(reg_add_r[3:0])
                    4'h8:Add_Reg_08<=wreg_dat_r;
                    4'h9:Add_Reg_09<=wreg_dat_r;
                    4'ha:Add_Reg_0A<=wreg_dat_r;
                    4'hb:Add_Reg_0B<=wreg_dat_r;
                endcase
            end
            else if(efuse_rvalid) {Add_Reg_0B,Add_Reg_0A,Add_Reg_09,Add_Reg_08}<=efuse_rdat;
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
            efuse_rstart<=1'b1; efuse_idata<=32'b0; 
        end
        else begin 
			if(efuse_rstart&&efuse_rack_d[1]) begin
                efuse_rstart<=1'b0;
            end
            if(efuse_rvalid) begin 
                efuse_idata<=efuse_rdat;
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
        //cnt5k_rstn=rst_n&&(!cnt10k_oen)&&(!cnt50k_oen)&&(!cnt100k_oen);
        cnt_max=TDC_freqm==2'b0 ? 16'd49999:
                TDC_freqm==2'b1 ? 16'd24999:
                TDC_freqm==2'd2 ? 16'd4999 : 16'd2499;
        //cntfreq_rstn=rst_n;
        cntfreq_en=(TDC_EN&&TDC_mode==2'b1)|(!init_delay);
        //cntfreq_oen=cntfreq==cnt_max;
//        cnt10k_oen=cnt_5k==16'd24999&&cnt5k_en&&TDC_freqm==2'b1;
//        cnt50k_oen=cnt_5k==16'd4999&&cnt5k_en&&TDC_freqm==2'd2;
//        cnt100k_oen=cnt_5k==16'd2499&&cnt5k_en&&TDC_freqm==2'd3;
    end
    
    // TDC start driver
    always_ff@(posedge CMUX_clk or negedge rstn_osc)begin
        if(!rstn_osc) TDC_start_reg<=1'b0; 
        //else if(TDC_Mode_Reg==2'b1) begin
        else begin
            TDC_start_reg<=cntfreq_oen;
//            case(TDC_freqm)
//                2'b0:TDC_start_reg<=cnt5k_oen;
//                2'b1:TDC_start_reg<=cnt10k_oen;
//                2'd2:TDC_start_reg<=cnt50k_oen;
//                2'd3:TDC_start_reg<=cnt100k_oen;
//                default:TDC_start_reg<=1'b0;
//            endcase
        end
    end

    // init delay
    always_ff@(posedge CMUX_clk or negedge rstn_osc)begin
    /* ***** for final, use this, ~300us dead time ****/
            if(!rstn_osc) begin 
				init_delay <=1'b0;
			end
            else begin 
				if((&cntfreq[14:13])&&(!init_delay))
                    init_delay<=1'b1;
			end

    /* ***** for test only, 800ns dead time  ****/
    /*
	   if(!rst_n) begin 
            init_delay <=1'b0; 
        end else begin
        	if(cntfreq[5]&&!init_delay) init_delay<=1'b1;
        end
	*/
    end
    // clock divider
    // always_ff@(posedge PLL_clk or negedge rst_n)begin
    //     if(!rst_n)reg_div2<=0;
    //     else reg_div2<=~reg_div2;
    // end

    // cnttx driver
    always_ff@(posedge CMUX_clk or negedge rstn_osc) begin
        if(!rstn_osc)begin
            cnttx<='0;
            TDC_start<='0;
        end else begin
            if ((TDC_mode[1]?TDC_EXTEN:TDC_start_reg)|(cnttx!=3'b0))begin
                cnttx<=cnttx+1'b1; 
                if(cnttx==3'b0) begin TDC_start<=1'b1;      end
                else if(cnttx[1])  begin TDC_start<=1'b0;   end
            end
        end
    end
    
	//********** only for test, delete this for synthesis *********************
	logic [15:0] raw_cnt;
	logic TDC_start_del;
	always_ff@(posedge CMUX_clk or negedge rstn_osc) begin
		if(!rstn_osc)begin
			raw_cnt<='0;
			TDC_start_del<=1'b0;
		end
		else  begin 
			TDC_start_del<=TDC_start;
			if((!TDC_start_del)&&(TDC_start))begin
				raw_cnt<=raw_cnt+1'b1;
			end
		end
	end	
	
	//************ start counter ends, delete this when synthesis**********

    always_comb begin
        CMUX_sel=(init_delay&(!TRIM_MUX));
        cntpll_en=TRIM_MUX;
        //cntpll_rstn=rst_n;
        //init_pll=((!init_delay)&&(&cntfreq[14:13]))
        // clk2=reg_div2;
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
        //TDC_start=(TDC_mode[1]?TDC_EXTEN:TDC_start_reg)||(cnttx==3'b1);
        INT0 = TRIM_MUX ? PLL_div64 : INT_raw;
        //INT1=INT_peak;
        TX_Driver = (|cnttx);
        SPI_Oreg = rreg_dat_r;
        SPI_Orvalid = rreg_req_d[2];
        SPI_Irready = 1'b1;
    end
    
    // TX_Driver counter
    
    
    // Trimming Test outputc
    counterM #(.cnt_mod(32)) cnt_PLL  (.clk(PLL_clk),.rst_n(rstn_pll),.cnt_en(cntpll_en),.cntout( ),.cout_en(cntpll_oen));
    // Exposure frequency 
    counterMax #(.DW(16)) cntf_req (.clk(CMUX_clk),.rst_n(rstn_osc),.en(cntfreq_en),.max(cnt_max),.cnt(cntfreq),.co(cntfreq_oen));
    // TDC and Histogram Buffer 
    INPUT_BUF in_buf(.clk(CMUX_clk),.rst_n(rstn_osc),.TDC_Ovalid(TDC_Ovalid),.TDC_Onum(TDC_Onum),.TDC_Oint(TDC_Oint),
        .TDC_Calib(TDC_Calib), .TDC_Odata(TDC_Odata), .TDC_Oready(TDC_Oready), .HIS_Odata(HIS_Odata), .HIS_Ovalid(HIS_Ovalid), .HIS_Oready(HIS_Oready),
        //.TDC_Odata_cal(TDC_Odata_cal), .TDC_Ovalid_cal(TDC_Ovalid_cal),
        .SPI_Odstart(SPI_Odstart), .OUT(SPI_Odata), .INT_raw(INT_raw), .INT_peak(INT1));
    // SPI Instantiation
    SPI_top  #(.MAX_WIDTH(24),.IN_WIDTH(8)) spi ( .clk(CMUX_clk), .rst_n(rstn_osc), .SPI_Odata(SPI_Odata), .SPI_Odstart(SPI_Odstart), 
        .SPI_Irreg(SPI_Irreg), .SPI_Irvalid(SPI_Irvalid), .SPI_Irready(SPI_Irready), .SPI_Iadd(SPI_Iadd), .SPI_Oreg(SPI_Oreg), .SPI_Orreq(SPI_Orreq), 
        .SPI_Orvalid(SPI_Orvalid), .SPI_CS(SPI_CS), .SPI_CLK(SPI_CLK), .SPI_MOSI(SPI_MOSI), .SPI_MISO(SPI_MISO), .MISO_OEN(MISO_OEN));  
    // EFUSE Instantiation
    efuse_driver efuse ( .clk(OSC_clk),.rstn(rstn_osc),.read_start(efuse_rstart),.read_ack(efuse_rack), .dout(efuse_rdat), .dout_valid(efuse_rvalid), 
        .efuse_din(efuse_wdat), .prog_start(efuse_wstart),  .prog_ack(efuse_wack), .EFUSE_SCLK(EFUSE_SCLK), .EFUSE_CS(EFUSE_CS), .EFUSE_RW(EFUSE_RW), 
        .EFUSE_PGM(EFUSE_PGM), .EFUSE_DOUT(EFUSE_DOUT));
    // CLOCK MUX, sel 0 for OSC, 1 for PLL
    CLK_MUX clk_mux(.OSC_CLK(OSC_clk),.PLL_CLK(PLL_clk),.rstn_osc(rstn_osc),.rstn_pll(rstn_pll),.sel(CMUX_sel),.OUT_CLK(CMUX_clk));


    
endmodule


/*
module Regadd_dec(
    input wire clk,
    input wire rst_n,
    input wire [3:0] add,
    input wire add_valid,
    output logic [15:0] add_odat,
    output logic add_ovalid
);
    logic [2:0] valid_reg;
    //logic [1:0] sate_cnt
    logic [1:0] partial_dec;
    assign partial_dec=valid_reg[0]?add[3:2]:add[1:0];

    // valid delay line - 3 cycle for output
    always_ff@ (posedge clk or negedge rst_n) begin
        if(!rst_n) valid_reg<=3'b0;
        else begin
            valid_reg<={valid_reg[1:0],add_valid};
        end
    end

    // logic driver
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n) add_odat<=16'b0;
        else begin
           if(add_valid) begin
               case(partial_dec)
               2'b00:add_odat[15:4]<=12'b0;
               2'b01:begin add_odat[15:8]<=8'b0; add_odat[3:0]<=4'b0;end
               2'b10:begin add_odat[15:12]<=4'b0;add_odat[7:0]<=8'b0;end
               2'b11:add_odat[11:0]<=12'b0;
           end
           else if(valid_reg[0])begin
               case(partial_dec)
               2'b00:begin add_odat[3:1]<=3'b0; add_odat[]
               2'b01:

           end
        end
    end
endmodule 
 */
    


