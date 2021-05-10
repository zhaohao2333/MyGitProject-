`timescale 1ns/10fs
module apd_module(
	input TDC_start,
	output reg trig
);
	reg photon;

	initial trig=0;
	initial photon = 0;

	always @(TDC_start) begin
		if(TDC_start) begin
			photon_gen();
		end
	end

/*	integer file_out;
	initial begin
    	file_out = $fopen("vector_delay_v1.txt","r");
    	if (!file_out) begin
        	$display("can't open file");
        	$finish;
    	end
	end
*/
	
	task photon_gen;
		reg   [15:0] delay1;
		reg   [15:0] delay2;
		reg   [15:0] delay3;
		begin
        /* 	delay1 = ({$random} % 100) + 1000;
			delay2 = ({$random} % 100) + 1120;
			delay3 = ({$random} % 100) + 1240;
		*/
			delay1 = 1000.0625 / 0.0625;
			delay2 = 1020.1250 / 0.0625;
			delay3 = 1043.7500 / 0.0625;
		//	$fscanf(file_out,"%b %b %b",delay1,delay2,delay3);
			//$readmemb("vector_delay.txt",mem,0,99);
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

	always @(posedge photon) begin
		trig <= 1;
		#10 trig <= 0;
	end //! todo
endmodule
