`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: guangjirongwei
// Engineer: liu bingqiang
// 
// Create Date: 2021/01/09
// Design Name: efuse_driver.v
// Module Name: efuse_driver
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

模块描述：此模块为efuse烧写与读取控制模块

此模块的时钟:25MHz，将其25MHz 40ns 10分频之后，周期为400ns

问题：
1.接下来该写读时序了
2.确定DVDD的值，以免读不到正确的数据
3.dout_valid last for cnt_32_for_prog cycle
4.cnt_1是1还是0





*/
//////////////////////////////////////////////////////////////////////////////////
module efuse_driver
(
//clk and reset
input wire clk,
input wire rstn,

//read and program start pluse
input wire read_start,
output reg read_ack,//last for one cycle
output reg [31:0] dout,
output reg dout_valid,//last for one cycle

input wire [31:0] efuse_din,//valid with start pluse
input wire prog_start,
output reg prog_ack,//last for one cycle

//EFUSE interface
output reg EFUSE_SCLK,
output reg EFUSE_CS,
output reg EFUSE_RW,
output reg EFUSE_PGM,
input wire EFUSE_DOUT
);

wire clk_div;
divider #(20) divider_2500KHz(clk, rstn, clk_div);

reg [4:0] NS,CS;
parameter [4:0] //one hot with zero idle
IDLE = 5'b00001,
S1   = 5'b00010,
S2   = 5'b00100,
S3   = 5'b01000,
S4   = 5'b10000;


reg cnt_12_en,cnt_24_en,COUNT_SCLK_en,cnt_32_for_prog_en,cnt_32_for_read_en;
reg [3:0]cnt_12;
reg [4:0]cnt_24;
reg [5:0]cnt_32_for_prog;
reg [5:0]cnt_32_for_read;
reg read_start_reg;
reg read_start_reg_reg;
reg prog_start_reg;
reg prog_start_reg_reg;

always@(posedge clk or negedge rstn)
begin
	if (~rstn)
		read_start_reg<=0;
	else 
		read_start_reg<=read_start;
end

always@(posedge clk or negedge rstn)
begin
	if (~rstn)
		read_start_reg_reg<=0;
	else 
		read_start_reg_reg<=read_start_reg;
end

always@(posedge clk or negedge rstn)
begin
	if (~rstn)
		prog_start_reg<=0;
	else 
		prog_start_reg<=prog_start;
end

always@(posedge clk or negedge rstn)
begin
	if (~rstn)
		prog_start_reg_reg<=0;
	else 
		prog_start_reg_reg<=prog_start_reg;
end

always@(posedge clk_div or negedge rstn)
begin
	if (~rstn)
		begin
		cnt_12<=0;
		end
    else if(cnt_12_en==1&&cnt_12==11)
		begin
		cnt_12<=0;
		end
    else if(cnt_12_en==1)
		begin
        cnt_12<=cnt_12+1;      
		end
    else 
		begin
        cnt_12<=0;      
		end
end


always@(posedge clk_div or negedge rstn)
begin
	if (~rstn)
		begin
		cnt_24<=0;
		end
    else if(cnt_24_en==1&&cnt_24==23)
		begin
		cnt_24<=0;
		end
    else if(cnt_24_en==1)
		begin
        cnt_24<=cnt_24+1;      
		end
    else 
		begin
        cnt_24<=0;      
		end
end


reg COUNT_SCLK;
always @ (posedge clk_div or negedge rstn)
begin
if (!rstn)
COUNT_SCLK <=0;

else if(cnt_12==8&&COUNT_SCLK_en==1)
COUNT_SCLK <=~COUNT_SCLK;

else if(COUNT_SCLK_en==0)
COUNT_SCLK <=0;

end

always @ (posedge clk or negedge rstn)
begin
if (!rstn)
EFUSE_SCLK <=0;

else if((EFUSE_CS==1)&&(2<cnt_32_for_prog)&&(cnt_32_for_prog<35))
EFUSE_SCLK <=COUNT_SCLK;

else if((EFUSE_CS==1)&&(2<cnt_32_for_read)&&(cnt_32_for_read<35))
EFUSE_SCLK <=COUNT_SCLK;

else 
EFUSE_SCLK <=0;

end



always @ (posedge COUNT_SCLK or negedge rstn)
begin
if (!rstn)
cnt_32_for_prog <=0;

else if(CS==IDLE)
cnt_32_for_prog <=0;

else if(cnt_32_for_prog==36)
cnt_32_for_prog <=0;

else if(cnt_32_for_prog_en==1)
cnt_32_for_prog <=cnt_32_for_prog+1;

else 
cnt_32_for_prog <=0;

end


always @ (posedge COUNT_SCLK or negedge rstn)
begin
if (!rstn)
cnt_32_for_read <=0;

else if(CS==IDLE)
cnt_32_for_read <=0;

else if(cnt_32_for_read==36)
cnt_32_for_read <=0;

else if(cnt_32_for_read_en==1)
cnt_32_for_read <=cnt_32_for_read+1;

else 
cnt_32_for_read <=0;

end


// EFUSE_RW
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
EFUSE_RW <=0;

else if(cnt_32_for_prog==1&&CS==S2)
EFUSE_RW <=1;

else if(cnt_32_for_prog==36&&CS==S2)
EFUSE_RW <=0;

// else if(cnt_32_for_prog==1&&CS==S4)
// EFUSE_RW <=0;

// else if(cnt_32_for_prog==36&&CS==S4)
// EFUSE_RW <=1;

end

// EFUSE_CS
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
EFUSE_CS <=0;

else if(CS==IDLE)
EFUSE_CS <=0;

else if(cnt_32_for_prog==2&&(CS==S2))
EFUSE_CS <=1;

else if(cnt_32_for_prog==35&&(CS==S2))
EFUSE_CS <=0;

else if(cnt_32_for_read==2&&(CS==S4))
EFUSE_CS <=1;

else if(cnt_32_for_read==35&&(CS==S4))
EFUSE_CS <=0;

end


// program din
reg [31:0] efuse_din_reg;
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
efuse_din_reg <=0;

else if(prog_start_reg_reg)
efuse_din_reg <=efuse_din;

end

// program EFUSE_PGM
always @ (posedge clk_div or negedge rstn)
begin
if (!rstn)
EFUSE_PGM <=0;

// else if((6<cnt_24)&&(cnt_24<10)&&(CS==S2)&&((cnt_32_for_prog==2)||(cnt_32_for_prog==3)))
// EFUSE_PGM <=efuse_din_reg[0];

else if((6<cnt_24)&&(cnt_24<10)&&(CS==S2)&&(cnt_32_for_prog==2))
EFUSE_PGM <=efuse_din_reg[0];

else if((6<cnt_24)&&(cnt_24<10)&&(CS==S2)&&(2<cnt_32_for_prog)&&(cnt_32_for_prog<34))
EFUSE_PGM <=efuse_din_reg[cnt_32_for_prog-2];

//else if((6<cnt_24)&&(cnt_24<10)&&(CS==S2)&&(cnt_32_for_prog==34))
//EFUSE_PGM <=efuse_din_reg[cnt_32_for_prog-3];

else 
EFUSE_PGM <=0;

end

// program prog_ack
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
prog_ack <=0;

else if(CS==S1)
prog_ack <=1;

else 
prog_ack <=0;

end


// read read_ack
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
read_ack <=0;

else if(CS==S3)
read_ack <=1;

else 
read_ack <=0;

end

// dout 
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
dout <=0;

else if(cnt_12==11&&CS==S4&&2<cnt_32_for_read<35)
dout [cnt_32_for_read-3]<=EFUSE_DOUT;

end

// dout_valid 
always @ (posedge clk or negedge rstn)
begin
if (!rstn)
dout_valid <=0;

else if(cnt_32_for_read==36&&CS==S4)
dout_valid <=0;

else if(cnt_32_for_read==35&&CS==S4)
dout_valid <=1;

end


//FSM control



//sequential state transition
always @ (posedge clk or negedge rstn) //!todo
begin
if (!rstn)
CS <=IDLE;

else
CS <=NS;

end

//combinational condition judgment
always @ (*)
begin
NS=CS;
case (CS)
	IDLE: 
	begin

		if (prog_start_reg_reg) NS = S1;
		else if(read_start_reg_reg) NS = S3;
	end
	
	S1: 
	begin

		NS = S2;
	end

	S2: 
	begin

		if (cnt_32_for_prog==36) NS = IDLE;
	end


	S3: 
	begin

		NS = S4;
	end

	S4: 
	begin

		if (cnt_32_for_read==36) NS = IDLE;
	end
	
	default:NS = IDLE;
	endcase
end




//sequential state transition
always @ (posedge clk or negedge rstn) //!todo
begin
if (!rstn)
begin
cnt_12_en<=0;
cnt_24_en<=0;
cnt_32_for_prog_en<=0;
cnt_32_for_read_en<=0;
COUNT_SCLK_en<=0;
end
else if (CS==IDLE)
begin
cnt_12_en<=0;
cnt_24_en<=0;
cnt_32_for_prog_en<=0;
cnt_32_for_read_en<=0;
COUNT_SCLK_en<=0;
end
else if(CS==S1)
begin
cnt_12_en<=1;
cnt_24_en<=1;
cnt_32_for_prog_en<=0;
cnt_32_for_read_en<=0;
COUNT_SCLK_en<=1;
end
else if(CS==S2)
begin
cnt_12_en<=1;
cnt_24_en<=1;
cnt_32_for_prog_en<=1;
cnt_32_for_read_en<=0;
COUNT_SCLK_en<=1;
end
else if(CS==S3)
begin
cnt_12_en<=1;
cnt_24_en<=1;
cnt_32_for_prog_en<=0;
cnt_32_for_read_en<=0;
COUNT_SCLK_en<=1;
end
else if(CS==S4)
begin
cnt_12_en<=1;
cnt_24_en<=1;
cnt_32_for_prog_en<=0;
cnt_32_for_read_en<=1;
COUNT_SCLK_en<=1;
end
else
begin
cnt_12_en<=0;
cnt_24_en<=0;
cnt_32_for_prog_en<=0;
cnt_32_for_read_en<=0;
COUNT_SCLK_en<=0;
end
end



endmodule









module divider#(parameter NUM_DIV = 14)(
input wire clk,
input wire rstn,
output reg clk_div
);

reg    [4:0] cnt;

always @(posedge clk or negedge rstn)
    if(!rstn) begin
        cnt     <= 4'd0;
        clk_div    <= 1'b0;
    end
    else if(cnt < NUM_DIV / 2 - 1) begin
        cnt     <= cnt + 1'b1;
        clk_div    <= clk_div;
    end
    else begin
        cnt     <= 4'd0;
        clk_div    <= ~clk_div;
    end
 endmodule