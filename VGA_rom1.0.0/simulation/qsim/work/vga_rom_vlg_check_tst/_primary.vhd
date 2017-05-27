library verilog;
use verilog.vl_types.all;
entity vga_rom_vlg_check_tst is
    port(
        bb              : in     vl_logic_vector(2 downto 0);
        gg              : in     vl_logic_vector(2 downto 0);
        hs              : in     vl_logic;
        rr              : in     vl_logic_vector(2 downto 0);
        tt              : in     vl_logic;
        vs              : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end vga_rom_vlg_check_tst;
