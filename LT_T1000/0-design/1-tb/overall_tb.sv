`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2021 02:39:50 PM
// Design Name: 
// Module Name: overall_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define wcmd_package(reg_addr,reg_wdata) {8'ha2,reg_addr,reg_wdata}
`define rcmd_package(reg_addr) {8'ha3,reg_addr,8'h0}

module overall_tb;
    // clk and rst
    logic               clk_osc;
    logic               rst_n;
    // External SPI Interface
    logic               SPI_CS=1'b0;       
    logic               SPI_CLK=1'b0;        
    logic               SPI_MOSI=1'b0;       
    logic               SPI_MISO;   
    // External PIN
    logic               INT0;
    logic               INT1;

    logic               TDC_START;
    // SPI buffer
    logic [23:0]        MOSI_buf;
    logic [7:0]         MISO_buf;
    logic [23:0]        data_buf;
    logic [7:0]         reg_addr;
    logic [7:0]         reg_rdata;
    logic [7:0]         reg_wdata;
    logic [15:0]        addr_data;
    //clk generation
    initial begin
        clk_osc<=1'b0;
        forever begin
            #20 clk_osc<=~clk_osc;
        end
    end

    initial begin
    // global reset
        TDC_START = 0;
        rst_n=1'b1;
            @(negedge clk_osc) rst_n<=1'b0;
        #200;
            @(negedge clk_osc) rst_n<=1'b1;

        SPI_CS<=1'b1;
        SPI_CLK<=1'b0;
    // waiting for pll dead time, 800 ns here
        # 1000;
    
    // Try to write reg once
            fork 
                SPI_CS<=1'b0;
                SPI_CLK<=1'b0;
                reg_addr<=8'h6;
                reg_wdata<=8'hab;
                #10  MOSI_buf<= `wcmd_package(reg_addr,reg_wdata);
                repeat(48) begin #20 SPI_CLK<=~SPI_CLK; end
                repeat(24) @(negedge SPI_CLK) MOSI_buf<=MOSI_buf<<1'b1;
                //repeat(24)@(posedge SPI_CLK) MOSI_buf<=MOSI_buf<<1'b1;
                #980 SPI_CS<=1'b1;
            join
        #40;

    // Read previoius written data
            fork 
                SPI_CS<=1'b0;
                SPI_CLK<=1'b0;
                MOSI_buf<= #1 `rcmd_package(reg_addr);
                repeat(48) begin #20 SPI_CLK<=~SPI_CLK; end
                repeat(24) begin 
                    @(negedge SPI_CLK) begin
                        MOSI_buf<=MOSI_buf<<1'b1;
                        MISO_buf<={MISO_buf[6:0],SPI_MISO};
                    end
                end
                #980 SPI_CS<=1'b1;
            join
        
        if(reg_wdata==MISO_buf) 
            $display("SPI write test ends, Reg_Addr=%d , Write_data=%d, Read_data=%d", reg_addr,reg_wdata,MISO_buf);
        else 
            $display("SPI Reg ERROR, Reg_Addr=%d , Write_data=%d, Read_data=%d", reg_addr,reg_wdata,MISO_buf);
        #100;
        //===============================================================//
        TDC_START = 1;
        #5
        TDC_START = 0;
        @ (posedge INT0)
        #40;
        //Read TOF data
        fork 
            SPI_CS<=1'b0;
            SPI_CLK<=1'b0;
            MOSI_buf<= #1 24'd0;
            repeat(48) begin #20 SPI_CLK<=~SPI_CLK; end
            repeat(24) begin 
                @(negedge SPI_CLK) begin
                    MOSI_buf<=MOSI_buf<<1'b1;
                    data_buf<={data_buf[22:0],SPI_MISO};
                end
            end
            #980 SPI_CS<=1'b1;
        join
        #100;
        $finish;
    end

    always_comb begin
        SPI_MOSI=MOSI_buf[23];
        addr_data={reg_addr,reg_wdata};
    end

top_ioed top(
    .clk_osc(clk_osc),
    .rst_n(rst_n),
    .TDC_START(TDC_START),
    .SPI_CS(SPI_CS),   
    .SPI_CLK(SPI_CLK),  
    .SPI_MOSI(SPI_MOSI), 
    .SPI_MISO(SPI_MISO),
    .INT0(INT0),
    .INT1(INT1)
);

endmodule
