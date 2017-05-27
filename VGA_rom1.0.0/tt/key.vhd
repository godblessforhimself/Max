library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity key is
port(
datain,clkin,fclk,rst_in: in std_logic;
keys:out std_logic_vector(3 downto 0)
);
end key;

architecture behave of key is
component Keyboard is
port (
	datain, clkin : in std_logic ; -- PS2 clk and data
	fclk, rst : in std_logic ;  -- filter clock
	fok : out std_logic ;  -- data output enable signal
	scancode : out std_logic_vector(7 downto 0) -- scan code signal output
	) ;
end component ;

component movement is
port(
code: in std_logic_vector(7 downto 0);
fok,rst: in std_logic;
keys: out std_logic_vector(3 downto 0)
);
end component;


signal scancode : std_logic_vector(7 downto 0);
signal okbfer: std_logic;
signal rst : std_logic;

begin

u0: Keyboard port map(datain=>datain,clkin=>clkin,fclk=>fclk, rst=>'0', fok=>okbfer, scancode=>scancode);
u1: movement port map(code=>scancode, fok=>okbfer,rst=>'0', keys=>keys);

end behave;

--keys (A,D,W,S)
--只有当fok上升沿时接受code,接受f0后进入断码状态
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity movement is
port(
code: in std_logic_vector(7 downto 0);
fok,rst: in std_logic;
keys: out std_logic_vector(3 downto 0)
);
end movement;

architecture behave of movement is
type s is(s0, s1);
signal state,nextstate:s;
signal key: std_logic_vector(3 downto 0):=(others=>'0');
begin
	
	process(fok)
	begin
		if rst = '1'then
			state<=s0;
		elsif rising_edge(fok)then
			state <= nextstate;
		end if;
		
	end process;
	process(state)
	variable t: std_logic_vector(7 downto 0);
	begin
		if fok = '1'then
			t := code;
			if t = "11110000"then
				nextstate <= s1;
			else
				nextstate <= s0;
			end if;
			case (state) is
				when s0=>
					if t = "00011100"then
						key(3) <= '1';
					elsif t ="00100011"then
						key(2) <= '1';
					elsif t = "00011101"then
						key(1) <= '1';
					elsif t ="00011011"then
						key(0) <= '1';
					end if;
				when s1=>
					if t = "00011100"then
						key(3) <= '0';
					elsif t ="00100011"then
						key(2) <= '0';
					elsif t = "00011101"then
						key(1) <= '0';
					elsif t ="00011011"then
						key(0) <= '0';
					end if;
				when others=>
					NULL;
			end case;
		end if;
	end process;
	keys <= key;
end behave;

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Keyboard is
port (
	datain, clkin : in std_logic ; -- PS2 clk and data
	fclk, rst : in std_logic ;  -- filter clock
  	fok : out std_logic ;  -- data output enable signal
	scancode : out std_logic_vector(7 downto 0) -- scan code signal output
	) ;
end Keyboard ;

architecture rtl of Keyboard is
type state_type is (delay, start, d0, d1, d2, d3, d4, d5, d6, d7, parity, stop, finish) ;
signal data, clk, clk1, clk2, odd, fok1: std_logic ; -- 毛刺处理内部信号, odd为奇偶校验
signal code : std_logic_vector(7 downto 0) ; 
signal state : state_type ;
begin
	clk1 <= clkin when rising_edge(fclk) ;
	clk2 <= clk1 when rising_edge(fclk) ;
	clk <= (not clk1) and clk2 ;
	
	data <= datain when rising_edge(fclk) ;
	
	fok <= fok1;
	odd <= code(0) xor code(1) xor code(2) xor code(3) 
		xor code(4) xor code(5) xor code(6) xor code(7) ;
	
	scancode <= code when fok1 = '1' ;
	
	process(rst, fclk)
	begin
		if rst = '1' then
			state <= delay ;
			code <= (others => '0') ;
			fok1 <= '0' ;
		elsif rising_edge(fclk) then
			fok1 <= '0' ;
			case state is 
				when delay =>
					state <= start ;
				when start =>
					if clk = '1' then
						if data = '0' then
							state <= d0 ;
						else
							state <= delay ;
						end if ;
					end if ;
				when d0 =>
					if clk = '1' then
						code(0) <= data ;
						state <= d1 ;
					end if ;
				when d1 =>
					if clk = '1' then
						code(1) <= data ;
						state <= d2 ;
					end if ;
				when d2 =>
					if clk = '1' then
						code(2) <= data ;
						state <= d3 ;
					end if ;
				when d3 =>
					if clk = '1' then
						code(3) <= data ;
						state <= d4 ;
					end if ;
				when d4 =>
					if clk = '1' then
						code(4) <= data ;
						state <= d5 ;
					end if ;
				when d5 =>
					if clk = '1' then
						code(5) <= data ;
						state <= d6 ;
					end if ;
				when d6 =>
					if clk = '1' then
						code(6) <= data ;
						state <= d7 ;
					end if ;
				when d7 =>
					if clk = '1' then
						code(7) <= data ;
						state <= parity ;
					end if ;
				WHEN parity =>
					IF clk = '1' then
						if (data xor odd) = '1' then
							state <= stop ;
						else
							state <= delay ;
						end if;
					END IF;

				WHEN stop =>
					IF clk = '1' then
						if data = '1' then
							state <= finish;
						else
							state <= delay;
						end if;
					END IF;

				WHEN finish =>
					state <= delay ;
					fok1 <= '1' ;
				when others =>
					state <= delay ;
			end case ; 
		end if ;
	end process ;
end rtl ;
			
						

