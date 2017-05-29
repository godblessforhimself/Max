library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity boxCollector is
port(
	clk_25M, clk_100M, enable : in std_logic;
	lx, ly, rx, ry : in std_logic_vector(15 downto 0);
	finish : out std_logic;
	total : buffer std_logic_vector(4 downto 0);
	boxes : out std_logic_vector(760 downto 1)
);
end boxCollector;

architecture bhv of boxCollector is

function min(x1, x2 : std_logic_vector(15 downto 0)) return std_logic_vector is
begin
	if(x1 < x2) then
		return x1;
	else
		return x2;
	end if;
end min;

function max(x1, x2 : std_logic_vector(15 downto 0)) return std_logic_vector is
begin
	if(x1 < x2) then
		return x2;
	else
		return x1;
	end if;
end max;

component romOfBox
port(
	address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
	clock		: IN STD_LOGIC  := '1';
	q		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
);
end component;

constant totalObjs : integer := 500;
signal address : std_logic_vector(8 downto 0) := "000000000";
signal box : std_logic_vector(63 downto 0);
begin

	u1 : romOfBox port map(address, clk_100M, box);
	
	process(clk_25M)
	variable ix, iy, ax, ay : std_logic_vector(15 downto 0);
	variable tot : integer range 0 to 760;
	begin
		if(rising_edge(clk_25M)) then
			if(enable = '0') then
				address <= "000000000";
				finish <= '0';
				total <= "00000";
				tot := 760;
			else
				if(address + 1 > totalobjs) then
					finish <= '1';
				else
					ix := max(lx, box(63 downto 48));
					ax := min(rx, box(31 downto 16));
					iy := max(ly, box(47 downto 32));
					ay := min(ry, box(15 downto 0));
					if((ix < ax) and (iy < ay)) then
						ix := ix - lx;
						ax := ax - lx;
						iy := iy - ly;
						ay := ay - ly;
						boxes(tot downto tot - 37) <= ix(9 downto 0) & iy(8 downto 0) & ax(9 downto 0) & ay(8 downto 0);
						total <= total + '1';
						tot := tot - 38;
					end if;
					address <= address + '1';
				end if;
			end if;
		end if;
	end process;
	
end bhv;