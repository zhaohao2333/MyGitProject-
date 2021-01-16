library verilog;
use verilog.vl_types.all;
entity tdc_top is
    generic(
        IDLE            : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        DATA1           : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1);
        DATA2           : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0);
        DATA2_1         : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0);
        DATA3           : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0);
        DATA3_1         : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0);
        DATA3_2         : vl_logic_vector(0 to 6) := (Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0);
        DATA0           : vl_logic_vector(0 to 6) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        DLL_Phase       : in     vl_logic_vector(31 downto 0);
        clk5            : in     vl_logic;
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        TDC_start       : in     vl_logic;
        TDC_trigger     : in     vl_logic;
        TDC_spaden      : in     vl_logic_vector(15 downto 0);
        TDC_tgate       : in     vl_logic;
        TDC_Range       : in     vl_logic_vector(14 downto 0);
        TDC_Odata       : out    vl_logic_vector(14 downto 0);
        TDC_Oint        : out    vl_logic_vector(3 downto 0);
        TDC_Onum        : out    vl_logic_vector(1 downto 0);
        TDC_Olast       : out    vl_logic;
        TDC_Ovalid      : out    vl_logic;
        TDC_Oready      : in     vl_logic;
        rst_auto        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of DATA1 : constant is 1;
    attribute mti_svvh_generic_type of DATA2 : constant is 1;
    attribute mti_svvh_generic_type of DATA2_1 : constant is 1;
    attribute mti_svvh_generic_type of DATA3 : constant is 1;
    attribute mti_svvh_generic_type of DATA3_1 : constant is 1;
    attribute mti_svvh_generic_type of DATA3_2 : constant is 1;
    attribute mti_svvh_generic_type of DATA0 : constant is 1;
end tdc_top;
