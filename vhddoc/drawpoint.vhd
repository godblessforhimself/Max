--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity drawpoint is
  port( 
		clk100 : in std_logic;
		reset_in : in std_logic;
		x1,x2: out std_logic_vector(10 downto 0);
		y1,y2: out std_logic_vector(10 downto 0);
		mousex,mousey: out std_logic_vector(9 downto 0);
		drawbutton: in std_logic;
		left_button,right_button,middle_button: out std_logic;
		ps2_clk : inout std_logic;
		ps2_data : inout std_logic
		);
       
end entity;

architecture bhv of drawpoint is
component ps2_mouse is
	port( 
			clk_in : in std_logic;
			reset_in : in std_logic;
			ps2_clk : inout std_logic;
			ps2_data : inout std_logic;
			
			left_button : out std_logic;
			right_button : out std_logic;
			middle_button : out std_logic;
			mousex: buffer std_logic_vector(9 downto 0);
			mousey: buffer std_logic_vector(9 downto 0);
			error_no_ack : out std_logic 
			);
end component ps2_mouse;


signal up12: integer range 1 to 2;
signal le,ri,mi:std_logic;
signal xb,yb: std_logic_vector(9 downto 0);
signal xr,yr: std_logic_vector(10 downto 0);
signal xs,ys: std_logic_vector(10 downto 0);
constant sixhundred: std_logic_vector(9 downto 0):= "1001011011";
constant lowx,lowy: std_logic_vector(9 downto 0) := "0000001010"; --10
constant topx: std_logic_vector(9 downto 0) := "1001011000";--600
constant topy: std_logic_vector(9 downto 0):= "0110111000";--440
begin
	left_button <= le;
	right_button <= ri;
	middle_button <= mi;
	process (xb, yb)
	begin
		if xb > lowx and xb < topx then
			mousex <= xb;
		elsif xb <= lowx then
			mousex <= lowx;
		elsif xb >= topx then
			mousex <= topx;
		end if;
		if yb > lowy and yb < topy then
			mousey <= yb;
		elsif yb <= lowy then
			mousey <= lowy;
		elsif yb >= topy then
			mousey <= topy;
		end if;
	end process;
	mouse: ps2_mouse port map(clk_in => clk100, reset_in=>reset_in,ps2_clk=>ps2_clk,ps2_data=>ps2_data, left_button=>le, right_button=>ri, middle_button=>mi, mousex=> xb, mousey=>yb);
	process(drawbutton)
	begin
		if rising_edge(drawbutton) then
			xr <= "0" & xb;
			yr <= "0" & (sixhundred - yb);
		end if;
		if falling_edge(drawbutton) then 
			xs <= "0" & xb;
			ys <= "0" & (sixhundred-yb);
		
		end if;
	end process;
	process(xr,xs)
	begin
		if xr < xs then
			x1 <= xr;
			x2 <= xs;
		else
			x1 <= xs;
			x2 <= xr;
		end if;
		
	end process;
	process (yr,ys)
	begin
		if yr < ys then
			y1 <= yr;
			y2 <= ys;
		else
			y1 <= ys;
			y2 <= yr;
		end if;
	end process;
end architecture bhv;