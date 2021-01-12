`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: guangjirongwei
// Engineer: liu bingqiang
// 
// Create Date: 2021/01/03
// Design Name: tb_count_max.v
// Module Name: tb_count_max
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
module tb_count_max();


reg  clk;
reg  rstn;
reg  [14:0] Q;
reg  [3:0] Q_4bit;
reg  count_max_en;
reg  count_max_Oready;
wire [3:0] max_4bit;
wire count_max_Ovalid;
reg  [9:0] cnt;





initial 
begin
clk<=0;
rstn<=1;
Q_4bit<=0;
count_max_en<=0;
count_max_Oready<=0;
#50  rstn<=0;
#50  rstn<=1;
#100 count_max_en<=1;
#500 count_max_Oready<=1;
#10 count_max_Oready<=0;
#300 count_max_Oready<=1;
#10 count_max_Oready<=0;
end

always #5 clk <=~clk;


reg [14:0] test_data [5000:1];

initial 
begin
    $readmemb("D:/tof/verilog_v2_20201229/75_yes/test_data.txt", test_data);  //将txt文件中的数据存储在数组中
end 



always @ (posedge clk or negedge rstn)
begin

if(~rstn)
begin
Q<=0;
Q_4bit<=0;
cnt<=1;
end


else if (count_max_en==1 && cnt<=50)
begin
Q   <= test_data[cnt];
Q_4bit<=Q[6:3];
cnt <= cnt+1;
end

else if (cnt==51)
begin
cnt <= 0;
end

end


count_max#(13,17) uut
(
clk,
rstn,
Q_4bit,
count_max_en,//模块总使能信号，高电平有效
count_max_Oready,//握手
max_4bit,
count_max_Ovalid//输出有效信号，握手
);

endmodule