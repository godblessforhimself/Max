library verilog;
use verilog.vl_types.all;
entity vga640480 is
    port(
        address         : out    vl_logic_vector(18 downto 0);
        reset           : in     vl_logic;
        clk50           : out    vl_logic;
        q               : in     vl_logic_vector(2 downto 0);
        clk_0           : in     vl_logic;
        hs              : out    vl_logic;
        vs              : out    vl_logic;
        r               : out    vl_logic_vector(2 downto 0);
        g               : out    vl_logic_vector(2 downto 0);
        b               : out    vl_logic_vector(2 downto 0);
        temp            : out    vl_logic
    );
end vga640480;
