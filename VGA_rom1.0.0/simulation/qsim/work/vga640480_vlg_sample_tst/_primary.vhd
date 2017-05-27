library verilog;
use verilog.vl_types.all;
entity vga640480_vlg_sample_tst is
    port(
        clk_0           : in     vl_logic;
        q               : in     vl_logic_vector(2 downto 0);
        reset           : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end vga640480_vlg_sample_tst;
