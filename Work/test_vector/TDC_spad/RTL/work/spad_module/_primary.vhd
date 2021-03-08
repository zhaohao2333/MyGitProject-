library verilog;
use verilog.vl_types.all;
entity spad_module is
    port(
        TDC_start       : in     vl_logic;
        rst_auto        : in     vl_logic;
        clk_250M        : in     vl_logic;
        trig            : out    vl_logic;
        time_gate       : out    vl_logic;
        spad_int        : out    vl_logic_vector(15 downto 0)
    );
end spad_module;
