module Core_Top
(
// CLK and RST
    input  wire             clk_osc,        //from external PAD, 
    input  wire             rst_n,          //from external PAD, input
// SPI Interface begins
    input  wire             SPI_CS,         // input PAD
    input  wire             SPI_CLK,        // input PAD
    input  wire             SPI_MOSI,       // input PAD
    output wire             SPI_MISO,       // output PAD
// SPI Interface ends

// two interrupt, to PAD 
    output wire             INT0,           // output PAD, Configurable for raw Interrupt / PLL Output
    output wire             INT1,           // output PAD, Configurable for peak Interrupt

// VSCEL Driver, to PAD
    output wire             VSCEL_Driver    // output PAD, MOS driver
);
endmodule
