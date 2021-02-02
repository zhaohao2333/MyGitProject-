library verilog;
use verilog.vl_types.all;
entity count_max is
    generic(
        CNT_DW          : integer := 13;
        BIN_CNT_DW      : integer := 17
    );
    port(
        clk             : in     vl_logic;
        rstn            : in     vl_logic;
        Q_4bit          : in     vl_logic_vector(3 downto 0);
        count_max_en    : in     vl_logic;
        count_max_Oready: in     vl_logic;
        max_4bit        : out    vl_logic_vector(3 downto 0);
        count_max_Ovalid: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CNT_DW : constant is 1;
    attribute mti_svvh_generic_type of BIN_CNT_DW : constant is 1;
end count_max;
