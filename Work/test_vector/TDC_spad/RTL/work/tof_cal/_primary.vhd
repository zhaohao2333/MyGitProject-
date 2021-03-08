library verilog;
use verilog.vl_types.all;
entity tof_cal is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        decode_in       : in     vl_logic_vector(15 downto 0);
        tof_data_in     : out    vl_logic_vector(14 downto 0);
        cal_en          : in     vl_logic;
        cal_stop        : out    vl_logic;
        out_valid       : out    vl_logic;
        dec_valid       : out    vl_logic;
        cnt             : in     vl_logic_vector(2 downto 0);
        num_cnt         : in     vl_logic_vector(1 downto 0);
        counter_in      : in     vl_logic_vector(17 downto 0);
        \range\         : in     vl_logic_vector(14 downto 0);
        tof_num_cnt     : out    vl_logic_vector(1 downto 0);
        tri_en          : in     vl_logic
    );
end tof_cal;
