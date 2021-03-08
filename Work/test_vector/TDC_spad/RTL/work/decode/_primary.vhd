library verilog;
use verilog.vl_types.all;
entity decode is
    port(
        data_in         : in     vl_logic_vector(31 downto 0);
        data_out        : out    vl_logic_vector(4 downto 0)
    );
end decode;
