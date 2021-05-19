module counter(
	input 	wire			clk5,
	input	wire			rst_n,
	input	wire			cnt_en,
	
	//output  wire			enable,
	output  reg		[13:0]	counter
);
//wire		enable;
reg			pen1_0,pen1_1;
reg			pen2_0;
reg			pen2_1;
reg         pen3_0;

//===========================================================
//------------------  C1 ------------------------------------
always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[0] <= 0;
	end
	else begin
		counter[0] <= counter[0] ^ cnt_en;
	end
end

always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		pen1_0 <= 0;
		pen1_1 <= 0;
	end
	else if (cnt_en) begin
		pen1_0 <= ~pen1_0;
		pen1_1 <= ~pen1_1;
	end
end
//===========================================================
//------------------  C2 ------------------------------------
/* always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[4:1] <= 0;
	end
	else if(pen1_0) begin
		counter[4:1] <= counter[4:1] + 1;
	end
end */
always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[1] <= 0;
	end
	else begin
		counter[1] <= counter[1] ^ pen1_0;
	end
end

always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[2] <= 0;
	end
	else if (pen1_0) begin
		counter[2] <= counter[2] ^ (counter[1]);
	end
end

always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[3] <= 0;
	end
	else if (pen1_1) begin
		counter[3] <= counter[3] ^ (counter[1] & counter[2]);
	end
end

always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[4] <= 0;
	end
	else if (pen1_1) begin
		counter[4] <= counter[4] ^ (counter[1] & counter[2] & counter[3]);
	end
end

always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		pen2_0 <= 0;
        pen2_1 <= 0;
	end
	else if (counter[1] & counter[2] & counter[3] & counter[4]) begin
		pen2_0 <= ~pen2_0;
        pen2_1 <= ~pen2_1;
	end
end

/* always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		pen2_1 <= 0;
	end
	else if (counter[1] & counter[2] & counter[3] & counter[4] & counter[5]) begin
		pen2_1 <= ~pen2_1;
	end
end */

//assign enable = counter[1] & counter[2] & counter[3] & counter[4] & counter[5];
//===========================================================
//------------------  C2 ------------------------------------
always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[5] <= 0;
	end
	else begin
		counter[5] <= counter[5] ^ pen2_0;
	end
end

always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[6] <= 0;
	end
	else if (pen2_0) begin
		counter[6] <= counter[6] ^ (counter[5]);
	end
end

always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[7] <= 0;
	end
	else if (pen2_1) begin
		counter[7] <= counter[7] ^ (counter[5] & counter[6]);
	end
end

always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[8] <= 0;
	end
	else if (pen2_1) begin
		counter[8] <= counter[8] ^ (counter[5] & counter[6] & counter[7]);
	end
end

always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		pen3_0 <= 0;
	end
	else if (&counter[8:1]) begin
		pen3_0 <= ~pen3_0;
	end
end

//assign pen3_0 = counter[5] & counter[6] & counter[7] & counter[8] & pen2_0;
//------------------  C2 ------------------------------------
always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[13:9] <= 0;
	end
	else if (pen3_0) begin
		counter[13:9] <= counter[13:9] + 1;
	end
end

/* always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[10:6] <= 0;
	end
	else if (pen2_0) begin
		counter[10:6] <= counter[10:6] + 1;
	end
end

always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[12:11] <= 0;
	end
	else if (pen2_1 & (counter[10:6] == 4'b1111)) begin
		counter[12:11] <= counter[12:11] + 1;
	end
end

always @(posedge clk5 or negedge rst_n) begin
	if(!rst_n) begin
		counter[13] <= 0;
	end
	else if (pen2_1 & (counter[12:7] == 6'b111111)) begin
		counter[13] <= counter[13] + 1;
	end
end */
endmodule
