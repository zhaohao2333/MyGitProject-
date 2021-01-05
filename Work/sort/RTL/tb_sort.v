`timescale 1ns/1ns
module tb_sort;

    reg             clk;
    reg             rst_n;
    reg     [4:0]   int;
    reg     [9:0]   data;

sort sort_dut(

    .clk                (clk), 
    .rst_n              (rst_n), 
    .int                (int), 
    .data               (data)

);

initial begin
        clk = 0;
        rst_n = 1;
        int = 2;
        data = 10'b 11111_00000;
        #58  rst_n = 0;
        #20  rst_n = 1;

        #200 int = 3;
             data = 10'b 10000_00000;
            
        #200 int = 4;
             data = 10'b 10000_00001;

        #200 int = 2;
             data = 10'b 10000_00010;

        #200 int = 4;
             data = 10'b 10000_00011;

        #200 int = 1;
             data = 10'b 10000_00100;

        #200 int = 5;
             data = 10'b 10000_00101;

        #1000;
        $finish;
end

//-------------------------------------------------------------------------------------
always #50 clk = !clk;

endmodule
