`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: guangjirongwei
// Engineer: liu bingqiang
// 
// Create Date: 2020/01/03
// Design Name: tb_top_histogram.v
// Module Name: tb_top_histogram
// Project Name: tof
// Target Devices: SMIC
// Tool Versions: 
// Description: 
// 
// Dependencies: 
//
// Revision: 
//
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module tb_top_histogram();

reg 		clk         ;
reg 		rstn	    ;
reg 		HIS_En		;	//高电平有效
reg [3:0]	HIS_TH      ;
reg [3:0]	TDC_Oint    ;
reg [8:0]	HIS_Ibatch	;	//1:1:20
reg [14:0]	TDC_Odata   ;
reg 		TDC_Ovalid  ;
wire  		TDC_Oready	;	//当前设计为TDC_Oready=HIS_En
wire [14:0]	HIS_Odata	;	//当前设计只输出最大值
reg		    HIS_Oready	;	//
wire   		HIS_Ovalid	;	//当前设计当输出有效时，拉高，直到输出握手结束
wire		HIS_hs;
wire [1 :0] TDC_Onum;


assign		HIS_hs=HIS_Oready&HIS_Ovalid;


reg [12:0]  	cnt;

initial 
begin
clk<=0;
rstn<=1;
TDC_Odata<=0;
HIS_TH<=4'd5;

HIS_En<=0;
HIS_Oready<=0;
HIS_Ibatch<=100;
TDC_Ovalid<=0;
#50  rstn<=0;
#50  rstn<=1;
#100  HIS_En<=1;
#25000 HIS_Oready<=1;
#100   HIS_Oready<=0;
#25000 HIS_Oready<=1;
end

always 
  begin
    #5 clk <=~clk;
  end 

reg [14:0] test_data [10000:1];

initial 
begin
    $readmemb("D:/tof/verilog_v3_20210102/test_data.txt", test_data);  //将txt文件中的数据存储在数组中
end 



always @ (posedge clk or negedge rstn)
begin

if(~rstn)
begin
TDC_Odata<=0;
cnt<=1;
TDC_Ovalid<=0;
end

// else if (HIS_En==1 && 1100<cnt<1110)
// begin
// cnt <= cnt+1;
// TDC_Oint<=4'd3;
// TDC_Odata  <= test_data[cnt];
// TDC_Ovalid<=1;
// end


else if (HIS_En==1 && cnt<10000)
begin
TDC_Odata  <= test_data[cnt];
TDC_Ovalid<=1;
cnt <= cnt+1;
TDC_Oint<=4'd6; //! todo
end

else if (cnt==10000)
begin
TDC_Odata<=0;
TDC_Ovalid<=0;
cnt <= 0;
TDC_Oint<=0;
end

end

histogram uut_top(
clk,
rstn,
HIS_En,//高电平有效
HIS_TH,
TDC_Oint,
HIS_Ibatch,//1:1:20
TDC_Odata,
TDC_Ovalid,
TDC_Oready,//当前设计为TDC_Oready=HIS_En
HIS_Odata,//当前设计只输出最大值
HIS_Oready,//
HIS_Ovalid,//当前设计当输出有效时，拉高，直到输出握手结束
TDC_Onum
);

endmodule