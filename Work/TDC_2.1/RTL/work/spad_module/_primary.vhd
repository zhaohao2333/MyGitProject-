library verilog;
use verilog.vl_types.all;
entity spad_module is
    port(
        photon          : in     vl_logic;
        rst_auto        : in     vl_logic;
        trig            : out    vl_logic;
        time_gate       : out    vl_logic
    );
end spad_module;
