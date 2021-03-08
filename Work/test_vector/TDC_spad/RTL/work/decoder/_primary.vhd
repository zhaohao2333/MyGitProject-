library verilog;
use verilog.vl_types.all;
entity decoder is
    port(
        decode_in       : in     vl_logic_vector(31 downto 0);
        decode_out      : out    vl_logic_vector(4 downto 0)
    );
end decoder;
