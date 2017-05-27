library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity gameControlUnit is
port(
	rclk, fclk : in std_logic;
	moveL, moveR, jump : in std_logic;
	x, y : buffer std_logic_vector(10 downto 0)
	--v : buffer std_logic_vector(7 downto 0)
	);
end gameControlUnit;

architecture bhv of gameControlUnit is

component inputFilter
port(
	clk, input : in std_logic;
	output : out std_logic
	);
end component;

component fp
port(
	clk : in std_logic;
	o : out std_logic
	);
end component;

signal m, j, clk : std_logic;
signal s : std_logic_vector(2 downto 0) := "000";
signal v, step : std_logic_vector(10 downto 0) := "00000001000";

begin
	--u0 : inputFilter port map(fclk, move, m);
	--u1 : inputFilter port map(fclk, jump, j);
	u2 : fp port map(rclk, clk); 
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(s = "000") then
				x <= "00000000000";
				y <= "00100000000";
				s <= "001";
			else
				if(x /= "00000000000" and moveL = '1') then
					x <= x - step;
				elsif(x /= "10000000000" and moveR = '1') then
					x <= x + step;
				elsif(x + step >= "10000000000" and moveR = '1') then
					x <= "00000000000";
				elsif(x <= step and moveL = '1') then
					x <= "10000000000";
				end if;
				if(s = "001" and jump = '1') then
					v <= "10000100000";
					s <= "010";
					y <= y + ("0" & v(9 downto 0));
				elsif (s = "010") then
					if(v = "10000000000") then
						s <= "011";
						v <= "00000000000";
					else
						v <= v - '1';
						y <= y + ("0" & v(9 downto 0));
					end if;
				elsif(s = "011") then
					if(not (y > "00100000000" + v)) then
						s <= "001";
						y <= "00100000000";
					else 
						v <= v + '1';
						y <= y - v;
					end if;
				end if;
			end if;
		end if;
	end process;	
	
--	process(v)
--	begin
--		if(v(7) = '1') then
--			y <= y + ("000000" & v(4 downto 0));
--		else 
--			if(y > "000" & v) then
--				y <= y - ("000" & v);
--			else 
--				y <= "00000000000";
--			end if;
--		end if;
--	end process;
end bhv;