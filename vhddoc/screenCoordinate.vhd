library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity screenCoordinate is
port(
	clk : in std_logic;
	x, y : in std_logic_vector(15 downto 0);
	lx, ly, rx, ry : buffer std_logic_vector(15 downto 0);
	px, py : buffer std_logic_vector(15 downto 0)
);
end screenCoordinate;

architecture bhv of screenCoordinate is
signal lastX : std_logic_vector(15 downto 0) := "0000000100000000";
signal lastY : std_logic_vector(15 downto 0) := "0000000100000000";
signal start : std_logic := '0';
begin
	process(x, y, clk)
	begin
		if(rising_edge(clk)) then
			if(x > 320) then
				px <= "0000000000000000" + 320;
				lx <= x - 320;
				rx <= x + 319;
			else
				px <= x;
				lx <= "0000000000000000";
				rx <= "0000000000000000" + 639;
			end if;
			py <= y;
			ly <= "0000000000000000";
			ry <= "0000000000000000" + 479;
		end if;
	end process;
end bhv;