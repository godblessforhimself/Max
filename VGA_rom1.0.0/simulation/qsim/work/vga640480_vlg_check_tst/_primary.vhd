library verilog;
use verilog.vl_types.all;
entity vga640480_vlg_check_tst is
    port(
        address         : in     vl_logic_vector(18 downto 0);
        b               : in     vl_logic_vector(2 downto 0);
        clk50           : in     vl_logic;
        g               : in     vl_logic_vector(2 downto 0);
        hs              : in     vl_logic;
        r               : in     vl_logic_vector(2 downto 0);
        temp            : in     vl_logic;
        vs              : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end vga640480_vlg_check_tst;
