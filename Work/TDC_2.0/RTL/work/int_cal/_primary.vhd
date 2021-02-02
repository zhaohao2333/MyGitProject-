library verilog;
use verilog.vl_types.all;
entity int_cal is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        INT             : in     vl_logic_vector(15 downto 0);
        cal_en          : in     vl_logic;
        int_out         : out    vl_logic_vector(3 downto 0);
        out_valid       : out    vl_logic;
        cal_stop        : out    vl_logic;
        shift_tri       : in     vl_logic
    );
end int_cal;
