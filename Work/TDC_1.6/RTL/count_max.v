`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: guangjirongwei
// Engineer: liu bingqiang
// 
// Create Date: 2021/01/03
// Design Name: count_max.v
// Module Name: count_max
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

1.模块描述：此模块为统计峰值模块，输入4bit，使能到来后，开始计数，外部输出握手信号（count_max_Oready）
以及本模块的输出有效信号（count_max_Ovalid）同时有效（即握手）时，输出出现次数最多的4bit，同时将模块内部
寄存器清零，等待下一次重新计数统计。当使能（count_max_en）不到来时，该模块里面的计数器不能置0，应该保持。

*/
//////////////////////////////////////////////////////////////////////////////////
module count_max#(
parameter CNT_DW = 13, BIN_CNT_DW=17
)
(
input wire clk,
input wire rstn,
input wire [3:0] Q_4bit,
input wire count_max_en,//模块使能信号，高电平有效，低电平内部寄存器保持
input wire count_max_Oready,//输入握手ready信号，来自外部的握手计数器
output reg [3:0] max_4bit,//输出的峰值
output reg count_max_Ovalid//输出握手valid信号
);

wire count_max_hs;
assign count_max_hs=count_max_Oready&count_max_Ovalid;

reg  [CNT_DW-1:0] cnt_00;
reg  [CNT_DW-1:0] cnt_01;
reg  [CNT_DW-1:0] cnt_02;
reg  [CNT_DW-1:0] cnt_03;
reg  [CNT_DW-1:0] cnt_04;
reg  [CNT_DW-1:0] cnt_05;
reg  [CNT_DW-1:0] cnt_06;
reg  [CNT_DW-1:0] cnt_07;
reg  [CNT_DW-1:0] cnt_08;
reg  [CNT_DW-1:0] cnt_09;
reg  [CNT_DW-1:0] cnt_10;
reg  [CNT_DW-1:0] cnt_11;
reg  [CNT_DW-1:0] cnt_12;
reg  [CNT_DW-1:0] cnt_13;
reg  [CNT_DW-1:0] cnt_14;
reg  [CNT_DW-1:0] cnt_15;


//峰值统计计数器
always@(posedge clk or negedge rstn)
begin

if (!rstn)
begin
cnt_00<=13'b00000_00000_000;
cnt_01<=13'b00000_00000_000;
cnt_02<=13'b00000_00000_000;
cnt_03<=13'b00000_00000_000;
cnt_04<=13'b00000_00000_000;
cnt_05<=13'b00000_00000_000;
cnt_06<=13'b00000_00000_000;
cnt_07<=13'b00000_00000_000;
cnt_08<=13'b00000_00000_000;
cnt_09<=13'b00000_00000_000;
cnt_10<=13'b00000_00000_000;
cnt_11<=13'b00000_00000_000;
cnt_12<=13'b00000_00000_000;
cnt_13<=13'b00000_00000_000;
cnt_14<=13'b00000_00000_000;
cnt_15<=13'b00000_00000_000;
end

else if(count_max_hs)
begin
cnt_00<=13'b00000_00000_000;
cnt_01<=13'b00000_00000_000;
cnt_02<=13'b00000_00000_000;
cnt_03<=13'b00000_00000_000;
cnt_04<=13'b00000_00000_000;
cnt_05<=13'b00000_00000_000;
cnt_06<=13'b00000_00000_000;
cnt_07<=13'b00000_00000_000;
cnt_08<=13'b00000_00000_000;
cnt_09<=13'b00000_00000_000;
cnt_10<=13'b00000_00000_000;
cnt_11<=13'b00000_00000_000;
cnt_12<=13'b00000_00000_000;
cnt_13<=13'b00000_00000_000;
cnt_14<=13'b00000_00000_000;
cnt_15<=13'b00000_00000_000;
end

else if(count_max_en==1)
begin
case(Q_4bit)
	4'b0000: cnt_00<=cnt_00+1;
	4'b0001: cnt_01<=cnt_01+1;
	4'b0010: cnt_02<=cnt_02+1;
	4'b0011: cnt_03<=cnt_03+1;
	4'b0100: cnt_04<=cnt_04+1;
	4'b0101: cnt_05<=cnt_05+1;
	4'b0110: cnt_06<=cnt_06+1;
	4'b0111: cnt_07<=cnt_07+1;
	4'b1000: cnt_08<=cnt_08+1;
	4'b1001: cnt_09<=cnt_09+1;
	4'b1010: cnt_10<=cnt_10+1;
	4'b1011: cnt_11<=cnt_11+1;
	4'b1100: cnt_12<=cnt_12+1;
	4'b1101: cnt_13<=cnt_13+1;
	4'b1110: cnt_14<=cnt_14+1;
	4'b1111: cnt_15<=cnt_15+1;
endcase          
end
end

//存储峰值统计计数器对应的bin+计数值
wire [BIN_CNT_DW-1:0] bin_cnt_00;
wire [BIN_CNT_DW-1:0] bin_cnt_01;
wire [BIN_CNT_DW-1:0] bin_cnt_02;
wire [BIN_CNT_DW-1:0] bin_cnt_03;
wire [BIN_CNT_DW-1:0] bin_cnt_04;
wire [BIN_CNT_DW-1:0] bin_cnt_05;
wire [BIN_CNT_DW-1:0] bin_cnt_06;
wire [BIN_CNT_DW-1:0] bin_cnt_07;
wire [BIN_CNT_DW-1:0] bin_cnt_08;
wire [BIN_CNT_DW-1:0] bin_cnt_09;
wire [BIN_CNT_DW-1:0] bin_cnt_10;
wire [BIN_CNT_DW-1:0] bin_cnt_11;
wire [BIN_CNT_DW-1:0] bin_cnt_12;
wire [BIN_CNT_DW-1:0] bin_cnt_13;
wire [BIN_CNT_DW-1:0] bin_cnt_14;
wire [BIN_CNT_DW-1:0] bin_cnt_15;

//峰值统计计数器对应的bin+计数值
assign bin_cnt_00={4'b0000,cnt_00};
assign bin_cnt_01={4'b0001,cnt_01};
assign bin_cnt_02={4'b0010,cnt_02};
assign bin_cnt_03={4'b0011,cnt_03};
assign bin_cnt_04={4'b0100,cnt_04};
assign bin_cnt_05={4'b0101,cnt_05};
assign bin_cnt_06={4'b0110,cnt_06};
assign bin_cnt_07={4'b0111,cnt_07};
assign bin_cnt_08={4'b1000,cnt_08};
assign bin_cnt_09={4'b1001,cnt_09};
assign bin_cnt_10={4'b1010,cnt_10};
assign bin_cnt_11={4'b1011,cnt_11};
assign bin_cnt_12={4'b1100,cnt_12};
assign bin_cnt_13={4'b1101,cnt_13};
assign bin_cnt_14={4'b1110,cnt_14};
assign bin_cnt_15={4'b1111,cnt_15};



wire[16*BIN_CNT_DW-1:0] bin_cnt_all;
assign bin_cnt_all={bin_cnt_00,bin_cnt_01,bin_cnt_02,bin_cnt_03,bin_cnt_04,bin_cnt_05,bin_cnt_06,bin_cnt_07,bin_cnt_08,bin_cnt_09,bin_cnt_10,bin_cnt_11,bin_cnt_12,bin_cnt_13,bin_cnt_14,bin_cnt_15};

wire[BIN_CNT_DW-1:0] d[15:0];
generate
    genvar i;
    for(i=0;i<16;i=i+1)
    begin:loop_assign
        assign d[i] = bin_cnt_all[BIN_CNT_DW*i+BIN_CNT_DW-1:BIN_CNT_DW*i];
    end
endgenerate

// 流水线设计
// stage 1
reg[BIN_CNT_DW-1:0] s1_max[7:0];
generate
    for(i=0;i<8;i=i+1)
    begin:loop_comp_1
        always@(posedge clk or negedge rstn)
		begin
			if (~rstn)
				s1_max[i]<=0;
            else if(d[2*i][BIN_CNT_DW-5:0]>d[2*i+1][BIN_CNT_DW-5:0])begin
                s1_max[i] <= d[2*i];
            end
            else begin
                s1_max[i] <= d[2*i+1];      
            end
		end
    end
endgenerate

// stage 2
reg[BIN_CNT_DW-1:0] s2_max[3:0];
generate
    for(i=0;i<4;i=i+1)
    begin:loop_comp_2
        always@(posedge clk)
		begin
			if (~rstn)
				s2_max[i]<=0;
            else if(s1_max[2*i][BIN_CNT_DW-5:0]>s1_max[2*i+1][BIN_CNT_DW-5:0])begin
                s2_max[i] <= s1_max[2*i];
            end
            else begin
                s2_max[i] <= s1_max[2*i+1];      
            end
		end
    end
endgenerate
 
// stage 3
reg[BIN_CNT_DW-1:0] s3_max[1:0];
generate
    for(i=0;i<2;i=i+1)
    begin:loop_comp_3
        always@(posedge clk)
		begin
			if (~rstn)
				s3_max[i]<=0;
            else if(s2_max[2*i][BIN_CNT_DW-5:0]>s2_max[2*i+1][BIN_CNT_DW-5:0])begin
                s3_max[i] <= s2_max[2*i];
            end
            else begin
                s3_max[i] <= s2_max[2*i+1];      
            end
		end
    end
endgenerate
 
 
// stage 4

always@(posedge clk)
begin
	if (~rstn)
	begin
	max_4bit<=0;
	count_max_Ovalid<=0;
	end
	
	else if(count_max_hs)
	begin
	max_4bit<=0;
	count_max_Ovalid<=0;
	end
	
    else if(s3_max[0][BIN_CNT_DW-5:0]>s3_max[1][BIN_CNT_DW-5:0])
	begin
	count_max_Ovalid<=1;
	max_4bit <= s3_max[0][BIN_CNT_DW-1:BIN_CNT_DW-4];
    end
	
    else 
	begin
	count_max_Ovalid<=1;
	max_4bit <= s3_max[1][BIN_CNT_DW-1:BIN_CNT_DW-4];      
	end
end

endmodule