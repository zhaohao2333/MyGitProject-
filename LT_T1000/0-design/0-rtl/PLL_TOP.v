//Verilog HDL for "Tesla", "PLL_TOP" "functional"
`timescale 1ns/1ps
module PLL_TOP ( PLLOUTN, PLLOUTP, AGND, AVDD, DGND, DVDD, ICP_PLL, REFCLK,
RESET, r_cp, r_div, r_ibias_cp, BYPASS );

  input DGND;
  output PLLOUTP;
  input REFCLK;
  input AGND;
  output PLLOUTN;
  input  [2:0] r_cp;
  input DVDD;
  input r_ibias_cp;
  input  [5:0] r_div;
  input ICP_PLL;
  input RESET;
  input AVDD;
  input BYPASS;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				parameter t_ref_TOP = 550;
				parameter t_lock = 680000;

				parameter warning_fast = 1;
				parameter warning_slow = 10;

				parameter dead_fast	= 0.8;
				parameter dead_slow = 12;
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//detect refclk extistance and measure refclk period
				real ref_prd;
				real last_time;
				real ref_last_tog;
				reg ref_flag;
				initial ref_last_tog = 0;
				initial ref_flag = 1;
				initial last_time = -200;
				initial ref_prd = 83;

always @(REFCLK)
	begin 
	ref_last_tog = $realtime;	//recording refclk's last flap time
	end
always 
	begin
	#10;
	if ($realtime >= ref_last_tog + t_ref_TOP)
		ref_flag <= 1;
	end

always @(posedge REFCLK) begin
	last_time <= $realtime;
	if ($realtime - last_time < t_ref_TOP) 
		ref_flag <= 0;
	else 
		ref_flag <= 1;
	
	if (ref_flag == 0)	
		ref_prd <= $realtime - last_time;
	else 
		ref_prd	= 83;
end


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//generate VCO CLOCK

real vco_prd;
reg vco_clk;
real div_ratio_instant;

initial vco_prd=1;
initial vco_clk=1'b0;
initial div_ratio_instant=1.0;

always @(RESET or r_div)
begin
	if (r_div==0)	
		div_ratio_instant = 10;
	else 
		div_ratio_instant = r_div;
end


always @(ref_prd or div_ratio_instant or RESET)	
	vco_prd = ref_prd / div_ratio_instant;		//gen vco clk;

always begin
	#(vco_prd/2)	vco_clk=0;
	#(vco_prd/2)	vco_clk=1;
end

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//generate warning info

wire	warning_underflow = vco_prd > warning_slow;
wire	warning_overflow = vco_prd < warning_fast;
wire	warning_out_range = warning_underflow | warning_overflow;

wire	dead_underflow = vco_prd > dead_slow;
wire	dead_overflow = vco_prd < dead_fast;
wire	dead_out_range = dead_underflow | dead_overflow;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//generate flag for PLL work mode, flag=00 normal; flag=01 BYPASS; flag=10 rst;
		wire [1:0] 	flag;
		reg  [1:0]	flag_delay;
		initial	flag_delay=2'b10;
		real lock_time;
		initial lock_time=0;

wire	i_pll_int;
assign	i_pll_int = r_ibias_cp ? ICP_PLL :1;

always @(RESET or BYPASS or i_pll_int or ref_flag or r_div or dead_out_range)
		begin
				lock_time <= $realtime;
				flag_delay <= 2'b10;
		end

always
		begin
		#10;
		if ($realtime >= lock_time + t_lock)		
			flag_delay <= 2'b00;	//after lock time, normal mode;
		end
assign flag = (~RESET &	~BYPASS	& i_pll_int& ~ref_flag & ~dead_out_range) ?	
				flag_delay : (~RESET & BYPASS &	i_pll_int &	~ref_flag) ? 10 : 10;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//generate PLLOUT according to flag (normal/BYPASS/rst mode)

				reg	PLLOUTP,	PLLOUTN;
				initial	PLLOUTP=0;
				initial PLLOUTN=1;

always @ (flag	or vco_clk)
		begin
		if (flag == 2'b00)
		begin
		PLLOUTP <= vco_clk;
		PLLOUTN <= ~vco_clk;
		end
		else
			begin
				PLLOUTP = 1'b0;
				PLLOUTN =  1'b1;
				end
		end

endmodule
