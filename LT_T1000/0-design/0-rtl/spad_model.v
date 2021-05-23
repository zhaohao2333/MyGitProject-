`timescale 1ns/10fs
module spad_module(
	//input photon,  //posdege for photon arrival
	input TDC_start,
	input rst_auto, //(!time_gate) & sync, sync is provided by sync module
	input clk_250M,//not used in simulation
	output reg trig,
	output reg time_gate,
	output reg [15:0] spad_int
);
	reg photon;

	initial trig=0;
	initial time_gate=0;
	initial spad_int=0;
	initial photon = 0;

	always @(TDC_start) begin
		if(TDC_start) begin
			photon_gen();
		end
	end
	
	int vec_sel = 1;	
	string tof_file,int_file;
	integer file_out,file_out1;
	initial begin
		if($value$plusargs("FUNC_VECTOR_SEL=%0d",vec_sel))
			$display("CURRENT VEC_SEL=%0d",vec_sel);
		
	 	tof_file=$sformatf("/home/LT/hxf/S1000_test/vector/vector_tof_data_V%0d.txt",vec_sel);	
    	int_file=$sformatf("/home/LT/hxf/S1000_test/vector/vector_int_V%0d.txt",vec_sel);
		//file_out = $fopen("/home/LT/hxf/S1000_test/vector/vector_tof_data_V12.txt","r");
    	file_out  = $fopen(tof_file,"r");
		file_out1 = $fopen(int_file,"r");
		if (!file_out) begin
        	$display("can't open delay vector file");
        	$finish;
    	end
    	// file_out1 = $fopen("\home\LT\hxf\S1000_test\vector_v1_20210309\V1\vector_int_V1.txt","r");
    	if (!file_out1) begin
        	$display("can't open int vector file");
        	$finish;
    	end
	end

	
	task photon_gen;
		reg   [15:0] delay1;
		reg   [15:0] delay2;
		reg   [15:0] delay3;
		begin
        	/* delay1 = ({$random} % 100);
        	delay2 = ({$random} % 10);	
        	delay3 = ({$random} % 10); */
			//$fdisplay(file_out, "%d %d %d", delay1,delay1+delay2+10,delay1+delay2+delay3+20);
			$fscanf(file_out,"%b %b %b",delay1,delay2,delay3);
			//$readmemb("vector_delay.txt",mem,0,99);
			//------------------------------------------
			//--------- range = 2048 ns ----------------
			#(delay1*0.0625)
				photon = 1;
			#10 photon = 0;
			#(delay2*0.0625-delay1*0.0625-10)
				photon = 1;
			#10 photon = 0;
			#(delay3*0.0625-delay2*0.0625-10)
				photon = 1;
			#10 photon = 0;
		end
	endtask

	always @(posedge photon or posedge rst_auto)
		if(rst_auto == 1)
	 		#2 trig <= 0;
		else
			trig <= 1;


	reg [15:0] spad;
	
	always @(posedge photon or posedge rst_auto)
		if(rst_auto == 1)
			#2 spad_int <= 0;
		else begin
			//spad_int <= 5 + ({$random} % 5);
			//$fdisplay(file_out1,"%b",spad_int);
			$fscanf(file_out1,"%b",spad_int);
			// spad_int <= spad;
		end

	always @(photon)
		if(photon==1)
		begin
			time_gate =1;
			#4
			time_gate =0;
		end
endmodule
