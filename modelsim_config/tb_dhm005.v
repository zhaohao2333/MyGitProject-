`timescale 1ns/1ns

module tb_dhm005;
    reg  [1:0]  data7,data6,data5,data4,data3,data2,data1,data0;
	wire [2:0]	cnt0,cnt1,cnt2,cnt3;
    wire [1:0]  max_data;

    initial begin
      {data7,data6,data5,data4,data3,data2,data1,data0} = 16'b1010_1101_0010_0110;//10
      #100
      {data7,data6,data5,data4,data3,data2,data1,data0} = 16'b1010_1010_1010_1000;//10
      #100
      {data7,data6,data5,data4,data3,data2,data1,data0} = 16'b1110_1110_1110_1100;//11
      #100
      {data7,data6,data5,data4,data3,data2,data1,data0} = 16'b0010_0000_1110_1100;//00
    end

    dhm005  inst(
		data7,
        data6,
        data5,
        data4,
        data3,
        data2,
        data1,
        data0,
		cnt0,
        cnt1,
        cnt2,
        cnt3,
		max_data
	);

endmodule //tb_dhm005