//Verilog HDL for "Tesla", "DLL_TOP" "functional"
// `timescale 1ns/1ps
`timescale 1ns/100fs
module DLL_TOP ( DLL_Phase, AGND, AVDD, DGND, DVDD, ICP_DLL, CKINP,CKINN, 
RESET, r_cp, r_ibias_cp );

  input DGND;
  output DLL_Phase;
  input CKINP;
  input CKINN;
  input AVDD;
  input AGND;
  input  [2:0] r_cp;
  input DVDD;
  input r_ibias_cp;
  input ICP_DLL;
  input RESET;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				parameter t_ref_TOP = 550;
				parameter t_lock = 980000;

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

always @(CKINP)
	begin 
	ref_last_tog = $realtime;	//recording refclk's last flap time
	end
always 
	begin
	#10;
	if ($realtime >= ref_last_tog + t_ref_TOP)
		ref_flag <= 1;
	end

always @(posedge CKINP) begin
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
//generate flag for DLL work mode, flag=00 normal; flag=01 BYPASS; flag=10 rst;
		wire [1:0] 	flag;
		reg  [1:0]	flag_delay;
		initial	flag_delay=2'b10;
		real lock_time;
		initial lock_time=0;

wire	i_dll_int;
assign	i_dll_int = r_ibias_cp ? ICP_DLL :1;

always @(RESET or i_dll_int or ref_flag  or dead_out_range)
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
assign flag = (~RESET& i_dll_int& ~ref_flag & ~dead_out_range) ?	
				flag_delay : (~RESET &	i_dll_int &	~ref_flag) ? 10 : 10;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//generate DLLOUT according to flag (normal/BYPASS/rst mode)

reg	[31:0] DLL_Phase;
initial	DLL_Phase[31]=0;
initial	DLL_Phase[30]=0;
initial	DLL_Phase[29]=0;
initial	DLL_Phase[28]=0;
initial	DLL_Phase[27]=0;
initial	DLL_Phase[26]=0;
initial	DLL_Phase[25]=0;
initial	DLL_Phase[24]=0;
initial	DLL_Phase[23]=0;
initial	DLL_Phase[22]=0;
initial	DLL_Phase[21]=0;
initial	DLL_Phase[20]=0;
initial	DLL_Phase[19]=0;
initial	DLL_Phase[18]=0;
initial	DLL_Phase[17]=0;
initial	DLL_Phase[16]=0;
initial	DLL_Phase[15]=0;
initial	DLL_Phase[14]=0;
initial	DLL_Phase[13]=0;
initial	DLL_Phase[12]=0;
initial	DLL_Phase[11]=0;
initial	DLL_Phase[10]=0;
initial	DLL_Phase[9]=0;
initial	DLL_Phase[8]=0;
initial	DLL_Phase[7]=0;
initial	DLL_Phase[6]=0;
initial	DLL_Phase[5]=0;
initial	DLL_Phase[4]=0;
initial	DLL_Phase[3]=0;
initial	DLL_Phase[2]=0;
initial	DLL_Phase[1]=0;
initial	DLL_Phase[0]=0;

		

always @ (flag	or vco_clk)
		begin
		if (flag == 2'b00)
		begin
		DLL_Phase[0] <= vco_clk;
		end
		else
			begin
				DLL_Phase[0] = 1'b0;
				
				end
		end
always @(DLL_Phase[0])
	begin
		DLL_Phase[1] <= #(1*vco_prd/32) DLL_Phase[0];
		DLL_Phase[2] <= #(2*vco_prd/32) DLL_Phase[0];
		DLL_Phase[3] <= #(3*vco_prd/32) DLL_Phase[0];
		DLL_Phase[4] <= #(4*vco_prd/32) DLL_Phase[0];
		DLL_Phase[5] <= #(5*vco_prd/32) DLL_Phase[0];
		DLL_Phase[6] <= #(6*vco_prd/32) DLL_Phase[0];
		DLL_Phase[7] <= #(7*vco_prd/32) DLL_Phase[0];
		DLL_Phase[8] <= #(8*vco_prd/32) DLL_Phase[0];
		DLL_Phase[9] <= #(9*vco_prd/32) DLL_Phase[0];
		DLL_Phase[10] <= #(10*vco_prd/32) DLL_Phase[0];
		DLL_Phase[11] <= #(11*vco_prd/32) DLL_Phase[0];
		DLL_Phase[12] <= #(12*vco_prd/32) DLL_Phase[0];
		DLL_Phase[13] <= #(13*vco_prd/32) DLL_Phase[0];
		DLL_Phase[14] <= #(14*vco_prd/32) DLL_Phase[0];
		DLL_Phase[15] <= #(15*vco_prd/32) DLL_Phase[0];
		DLL_Phase[16] <= #(16*vco_prd/32) DLL_Phase[0];
		DLL_Phase[17] <= #(17*vco_prd/32) DLL_Phase[0];
		DLL_Phase[18] <= #(18*vco_prd/32) DLL_Phase[0];
		DLL_Phase[19] <= #(19*vco_prd/32) DLL_Phase[0];
		DLL_Phase[20] <= #(20*vco_prd/32) DLL_Phase[0];
		DLL_Phase[21] <= #(21*vco_prd/32) DLL_Phase[0];
		DLL_Phase[22] <= #(22*vco_prd/32) DLL_Phase[0];
		DLL_Phase[23] <= #(23*vco_prd/32) DLL_Phase[0];
		DLL_Phase[24] <= #(24*vco_prd/32) DLL_Phase[0];
		DLL_Phase[25] <= #(25*vco_prd/32) DLL_Phase[0];
		DLL_Phase[26] <= #(26*vco_prd/32) DLL_Phase[0];
		DLL_Phase[27] <= #(27*vco_prd/32) DLL_Phase[0];
		DLL_Phase[28] <= #(28*vco_prd/32) DLL_Phase[0];
		DLL_Phase[29] <= #(29*vco_prd/32) DLL_Phase[0];
		DLL_Phase[30] <= #(30*vco_prd/32) DLL_Phase[0];
		DLL_Phase[31] <= #(31*vco_prd/32) DLL_Phase[0];
	end

endmodule
