module 	dhm005(
		data7,data6,data5,data4,data3,data2,data1,data0,
		cnt0,cnt1,cnt2,cnt3,
		max_data
	);
	input  wire 	[1 :0]	data7,data6,data5,data4,data3,data2,data1,data0;
	output wire 	[2 :0]	cnt0,cnt1,cnt2,cnt3;
	output reg  	[1 :0]	max_data;

	wire 			[7 :0]	cnt00,cnt01,cnt10,cnt11;
	wire			[15:0]	data;

	assign	data[15:0] = {data7,data6,data5,data4,data3,data2,data1,data0};

	assign  data[15:0] = {data6,data5,data4,max_data};
	
	
	generate
		genvar i;
		for(i = 0;i < 8;i = i + 1)
		
			assign  cnt00[i] = (data[i+i+1:i+i] == 2'b00)? 1'b1:1'b0;
	endgenerate

	assign	cnt0[2:0] = cnt00[0]+cnt00[1]+cnt00[2]+cnt00[3]+cnt00[4]+cnt00[5]+cnt00[6]+cnt00[7];
	
	generate
		genvar k;
		for(k = 0;k < 8;k = k + 1)
			assign  cnt01[k] = (data[k+k+1:k+k] == 2'b01)? 1'b1:1'b0;
	endgenerate

	assign	cnt1[2:0] = cnt01[0]+cnt01[1]+cnt01[2]+cnt01[3]+cnt01[4]+cnt01[5]+cnt01[6]+cnt01[7];
	//-------------------------------------------------------------	
	generate
		genvar j;
		for(j = 0;j < 8;j = j + 1)
			assign  cnt10[j] = (data[j+j+1:j+j] == 2'b10)? 1'b1:1'b0;
	endgenerate

	assign	cnt2[2:0] = cnt10[0]+cnt10[1]+cnt10[2]+cnt10[3]+cnt10[4]+cnt10[5]+cnt10[6]+cnt10[7];
	//-------------------------------------------------------------
	generate
		genvar n;
		for(n = 0;n < 8;n = n + 1)
			assign  cnt11[n] = (data[n+n+1:n+n] == 2'b11)? 1'b1:1'b0;
	endgenerate

	assign	cnt3[2:0] = cnt11[0]+cnt11[1]+cnt11[2]+cnt11[3]+cnt11[4]+cnt11[5]+cnt11[6]+cnt11[7];

	always @( *) begin
		if(cnt0>=cnt1 && cnt0>=cnt2 && cnt0>=cnt3)
			max_data = 2'b00;
		else if(cnt1>=cnt0 && cnt1>=cnt2 && cnt1>=cnt3)
			max_data = 2'b01;
		else if(cnt2>=cnt0 && cnt2>=cnt1 && cnt2>=cnt3)
			max_data = 2'b10;
		else if(cnt3>=cnt0 && cnt3>=cnt1 && cnt3>=cnt2)
			max_data = 2'b11;
		else
			max_data = 2'b00;
	end
endmodule//!this is the main module