library verilog;
use verilog.vl_types.all;
entity histogram is
    generic(
        IDLE            : vl_logic_vector(3 downto 0) := (Hi0, Hi0, Hi0, Hi0);
        S1              : vl_logic_vector(3 downto 0) := (Hi0, Hi0, Hi0, Hi1);
        S2              : vl_logic_vector(3 downto 0) := (Hi0, Hi0, Hi1, Hi0);
        S3              : vl_logic_vector(3 downto 0) := (Hi0, Hi1, Hi0, Hi0);
        S4              : vl_logic_vector(3 downto 0) := (Hi1, Hi0, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rstn            : in     vl_logic;
        HIS_En          : in     vl_logic;
        HIS_TH          : in     vl_logic_vector(3 downto 0);
        TDC_Oint        : in     vl_logic_vector(3 downto 0);
        HIS_Ibatch      : in     vl_logic_vector(8 downto 0);
        TDC_Odata       : in     vl_logic_vector(14 downto 0);
        TDC_Ovalid      : in     vl_logic;
        TDC_Oready      : out    vl_logic;
        HIS_Odata       : out    vl_logic_vector(14 downto 0);
        HIS_Oready      : in     vl_logic;
        HIS_Ovalid      : out    vl_logic;
        TDC_Onum        : in     vl_logic_vector(1 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 2;
    attribute mti_svvh_generic_type of S1 : constant is 2;
    attribute mti_svvh_generic_type of S2 : constant is 2;
    attribute mti_svvh_generic_type of S3 : constant is 2;
    attribute mti_svvh_generic_type of S4 : constant is 2;
end histogram;
