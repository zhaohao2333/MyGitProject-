`timescale 1ns/1ns
module spad_module(
input photon,  //posdege for photon arrival
input rst_auto, //(!time_gate) & sync, sync is provided by sync module
output reg  trig,
output reg  time_gate
);
initial trig=0;
initial time_gate=0;
always @(posedge photon or posedge rst_auto)
	if(rst_auto == 1)
	 	#320 trig <= 0;
	else
		trig <= 1;
always @(photon)
	if(photon==1)
	begin
		time_gate =1;
		#480
		time_gate =0;
	end
endmodule