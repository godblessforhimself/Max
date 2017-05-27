library verilog;
use verilog.vl_types.all;
entity vga_rom_vlg_sample_tst is
    port(
        clk_0           : in     vl_logic;
        reset           : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end vga_rom_vlg_sample_tst;
