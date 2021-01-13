`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: guangjirongwei
// Engineer: liu bingqiang
// 
// Create Date: 2021/01/03
// Design Name: histogram.v
// Module Name: histogram
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
/* 

1.模块描述：本模块实现histogram功能，采用流式接口，其中峰值统计部分通过调用一个count_max模块实现。

*/
//////////////////////////////////////////////////////////////////////////////////
module histogram(
input wire  		clk,
input wire  		rstn,
input wire  		HIS_En,//高电平有效
input wire  [3:0]	HIS_TH,//输入阈值
input wire  [3:0]	TDC_Oint,//来自TDC的值，需要与输入阈值HIS_TH进行比较
input wire  [8:0]	HIS_Ibatch,//1:1:1:20，HIS_Ibatch为1份
input wire  [14:0]	TDC_Odata,//来自TDC的数据
input wire  		TDC_Ovalid,//来自TDC的数据有效信号
//input wire  		TDC_Olast,//当前设计没用到
output wire  		TDC_Oready,//当前设计为TDC_Oready=HIS_En，因为本模块一直需要来自TDC的数据进行统计

output wire [14:0]	HIS_Odata,//当前设计只输出最大值
//output wire 		HIS_Olast,//当前设计没用到
input wire 		    HIS_Oready,//来自外部顶层控制握手信号
output wire   		HIS_Ovalid,//当前设计当输出有效时，拉高，直到输出握手结束
input  wire	[1 :0]	TDC_Onum//当TDC输出有效数据个数不为0时，采集数据有效
);



//与count_max模块输入输出有关的信号
reg  [3:0] Q_4bit;
reg  count_max_en;
reg  count_max_Oready;
wire [3:0] max_4bit;
wire count_max_Ovalid;

//histogram模块与内部count_max模块的握手信号
wire count_max_hs;
assign count_max_hs=count_max_Oready&count_max_Ovalid;


//histogram模块与外部的握手信号
wire TDC_hs;            //TDC handshake
wire HIS_hs;           //HIS handshake
assign TDC_hs=TDC_Oready && TDC_Ovalid && (TDC_Onum != 0);
assign HIS_hs=HIS_Oready && HIS_Ovalid;
assign TDC_Oready=HIS_En;


//保存count_max模块不同阶段的输出值
reg [3:0] count_max_out_first;
reg [3:0] count_max_out_second;
reg [3:0] count_max_out_third;
reg [14:0] HIS_Odata_reg;
reg  HIS_Ovalid_reg;

//计算HIS_Ibatch1与HIS_Ibatch2
wire [8:0]  HIS_Ibatch1;
wire [12:0] HIS_Ibatch2;
assign HIS_Ibatch1=HIS_Ibatch;
assign HIS_Ibatch2=(HIS_Ibatch<<4)+(HIS_Ibatch<<2);


//TDC握手计数器
reg [12:0] TDC_hs_cnt;
reg [12:0] TDC_hs_set_num;
//reg TDC_hs_cnt_en;
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
begin
TDC_hs_cnt<=0;
count_max_Oready<=0;
end

else if(count_max_hs || HIS_hs)
begin
TDC_hs_cnt<=0;
count_max_Oready<=0;
end

else if (TDC_hs&&HIS_En&&(TDC_hs_cnt<TDC_hs_set_num))
begin
TDC_hs_cnt<=TDC_hs_cnt+1;
count_max_Oready<=0;
end

else if (HIS_En&&(TDC_hs_cnt==TDC_hs_set_num))//or else if (TDC_hs&&HIS_En&&(TDC_hs_cnt==TDC_hs_set_num))
begin 
TDC_hs_cnt<=0; 
count_max_Oready<=1;
end

end

//定义在peak detection阶段之后，histogram阶段的前12位的输入
wire [11:0] detection_peak;
wire [11:0] detection_peak_minus1;
assign detection_peak={count_max_out_first,count_max_out_second,count_max_out_third};
assign detection_peak_minus1=detection_peak-1;



//FSM control
wire FSM_en;
assign FSM_en=HIS_En;

reg [3:0] NS,CS;
parameter [3:0] //one hot with zero idle
IDLE = 4'b0000,
S1   = 4'b0001,
S2   = 4'b0010,
S3   = 4'b0100,
S4   = 4'b1000;

//sequential state transition
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
CS <=IDLE;

else if (FSM_en)
CS <=NS;

else
CS <=IDLE;
end

//combinational condition judgment
always @ (*)
begin
NS=CS;
case (CS)
	IDLE: begin
	TDC_hs_set_num=HIS_Ibatch1;
	count_max_en=0;
	Q_4bit=0;
	if (TDC_hs&&HIS_En) NS = S1;
	end
	
	S1: begin
	TDC_hs_set_num=HIS_Ibatch1;
	count_max_en=(TDC_Oint>=HIS_TH)?((TDC_hs==1&&HIS_En==1)?1'b1:1'b0):1'b0;
	Q_4bit=TDC_Odata[14:11];
		if (count_max_hs) 
			begin 
			NS = S2;
			end
	end

	S2: begin
	TDC_hs_set_num=HIS_Ibatch1;
	count_max_en=(TDC_Odata[14:11]==count_max_out_first)?((TDC_Oint>=HIS_TH)?((TDC_hs==1&&HIS_En==1)?1'b1:1'b0):1'b0):1'b0;
	Q_4bit=TDC_Odata[10:7];
		if (count_max_hs) 
			begin 
			NS = S3;
			end
	end
	
	S3: begin
	TDC_hs_set_num=HIS_Ibatch1;
	count_max_en=(TDC_Odata[14:7]=={count_max_out_first,count_max_out_second})?((TDC_Oint>=HIS_TH)?((TDC_hs==1&&HIS_En==1)?1'b1:1'b0):1'b0):1'b0;
	Q_4bit=TDC_Odata[6:3];
		if (count_max_hs) 
			begin 
			NS = S4;
			end
	end
	
	S4: begin
	TDC_hs_set_num=HIS_Ibatch2;
	count_max_en=(TDC_Odata[14:3]==detection_peak || TDC_Odata[14:3]==detection_peak_minus1)?((TDC_Oint>=HIS_TH)?((TDC_hs==1&&HIS_En==1)?1'b1:1'b0):1'b0):1'b0;
	Q_4bit=TDC_Odata[3:0];
	if (HIS_hs) NS = IDLE;
	end
	
	endcase
end





//save the first 4 bit 
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
count_max_out_first<=4'b0;

else if (HIS_hs)
count_max_out_first<=4'b0;

else if (CS==S1&&count_max_hs==1&&HIS_En)
count_max_out_first<=max_4bit;
end

//save the second 4 bit 
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
count_max_out_second<=4'b0;

else if (HIS_hs)
count_max_out_second<=4'b0;

else if (CS==S2&&count_max_hs==1&&HIS_En)
count_max_out_second<=max_4bit;
end

//save the third 4 bit 
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
count_max_out_third<=4'b0;

else if (HIS_hs)
count_max_out_third<=4'b0;

else if (CS==S3&&count_max_hs==1&&HIS_En)
count_max_out_third<=max_4bit;
end

//处理最后的四位输出,变成最后的15bit输出
wire judge_out;
assign judge_out=count_max_out_third[0]^max_4bit[3];
//如果histogram阶段的输出最高位与count_max_out_third[0]相同，即judge_out为0时，HIS_Odata_reg<={detection_peak,max_4bit[2:0]}
//如果histogram阶段的输出最高位与count_max_out_third[0]不同，即judge_out为1时，HIS_Odata_reg<={detection_peak_minus1,max_4bit[2:0]}
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
	begin
	HIS_Odata_reg<=15'b0;
	HIS_Ovalid_reg<=0;
	end
else if (HIS_hs)
	begin
	HIS_Odata_reg<=15'b0;
	HIS_Ovalid_reg<=0;
	end
else if (CS==S4&&count_max_hs==1&&HIS_En)
	begin
	if (judge_out==1&&HIS_En) begin
	HIS_Ovalid_reg<=1;
	HIS_Odata_reg<={detection_peak_minus1,max_4bit[2:0]};end
	else if (judge_out==0&&HIS_En)begin
	HIS_Ovalid_reg<=1;
	HIS_Odata_reg<={detection_peak,max_4bit[2:0]};end
	end
end


//handshake drive
assign HIS_Odata=HIS_Odata_reg;
assign HIS_Ovalid=HIS_Ovalid_reg;

//instance//instance//instance//instance//instance//instance//instance//instance//instance//instance//instance
count_max#(13,17) uut(
.clk(clk),
.rstn(rstn),
.Q_4bit(Q_4bit),
.count_max_en(count_max_en),
.count_max_Oready(count_max_Oready),
.max_4bit(max_4bit),
.count_max_Ovalid(count_max_Ovalid)
);

endmodule