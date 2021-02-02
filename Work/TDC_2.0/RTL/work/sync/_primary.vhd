library verilog;
use verilog.vl_types.all;
entity sync is
    port(
        s               : in     vl_logic;
        TDC_trigger     : in     vl_logic;
        rst_n           : in     vl_logic;
        sync_clk        : in     vl_logic;
        sync            : out    vl_logic
    );
end sync;
