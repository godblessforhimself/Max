library verilog;
use verilog.vl_types.all;
entity vga_rom is
    port(
        clk_0           : in     vl_logic;
        reset           : in     vl_logic;
        hs              : out    vl_logic;
        vs              : out    vl_logic;
        rr              : out    vl_logic_vector(2 downto 0);
        gg              : out    vl_logic_vector(2 downto 0);
        bb              : out    vl_logic_vector(2 downto 0);
        tt              : out    vl_logic
    );
end vga_rom;
