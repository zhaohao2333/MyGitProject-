module top_ioed(
    input  wire             clk_osc,
    input  wire             rst_n,
    input  wire             TDC_start,
    input  wire             SPI_CS,   
    input  wire             SPI_CLK,  
    input  wire             SPI_MOSI, 
    output wire            SPI_MISO,
    output wire            INT0,
    output wire            INT1
);



chip_top chip_top_uut(
.clk_osc(clk_osc),
.rst_n(rst_n),
.TDC_start(TDC_start),
.SPI_CS(SPI_CS),   
.SPI_CLK(SPI_CLK),  
.SPI_MOSI(SPI_MOSI), 
.SPI_MISO(SPI_MISO),
.INT0(INT0),
.INT1(INT1)
);

endmodule
