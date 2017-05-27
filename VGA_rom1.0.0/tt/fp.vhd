library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity fp is 
port(
	clk : in std_logic;
	o : out std_logic
	);
end fp;

architecture bhv of fp is
signal cnt : std_logic_vector(4 downto 0) := "00000";
begin
	process(clk)
	begin
		if(rising_edge(clk)) then
			cnt <= cnt + '1';
		end if;
	end process;
	
	process(cnt)
	begin
		if(cnt(4) = '1') then
			o <= '1';
		else 
			o <= '0';
		end if;
	end process;
end bhv;
