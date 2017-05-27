library	ieee;
use		ieee.std_logic_1164.all;
use		ieee.std_logic_unsigned.all;
use		ieee.std_logic_arith.all;

entity main is
port(
	clk_0,reset: in std_logic;
	hs,vs: out std_logic; 
	rr,gg,bb: out std_logic_vector(2 downto 0);
	
	ps2clk, ps2data: inout std_logic;
	px, py : buffer std_logic_vector(15 downto 0);
	lx, ly, rx, ry : buffer std_logic_vector(15 downto 0);
	drawbutton: in std_logic;
	w,a,d: in std_logic
	
);
end main;

architecture one of main is

component vga640480 is
	 port(
			rx,ry,mx,my    :      in std_LOGIC_vector(9 downto 0);
			
			address , c_address	, b_address	:		  out	STD_LOGIC_VECTOR(11 DOWNTO 0);
			reset       :         in  STD_LOGIC;
			clk25       :		  out std_logic; 
			q, c_q , b_q   :		  in STD_LOGIC_vector(8 downto 0);
			clk_0       :         in  STD_LOGIC; --100Mʱ������
			hs,vs       :         out STD_LOGIC; --��ͬ������ͬ���ź�
			r,g,b       :         out STD_LOGIC_vector(2 downto 0);
			----------------------------box--------------------------
			enable : out std_logic;
			finish : in std_logic;
			total : in std_logic_vector(4 downto 0);
			boxes : in std_logic_vector(760 downto 1)
			---------------------------------------------------------

	  );
end component;

component r IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;

component g IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;

component b IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;

component c_r IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;

component c_g IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;

component c_b IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;

component b_r IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;

component b_g IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;

component b_b IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;
----------------------------mouse-------------------------------
component drawpoint is
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
end component;


-------------------game--------------------
component gameControlUnit is
port(
	clk_25M, clk_100M: in std_logic;
	moveL, moveR, jump : in std_logic;
	player_x, player_y : buffer std_logic_vector(15 downto 0) := "00000000000"
	);
end component;

component screenCoordinate is
port(
	clk : in std_logic;
	x, y : in std_logic_vector(15 downto 0);
	lx, ly : buffer std_logic_vector(15 downto 0) := "0000000000000000"; 
	rx : buffer std_logic_vector(15 downto 0) := "0000001010000000";
	ry : buffer std_logic_vector(15 downto 0) := "0000000111100000";
	px, py : buffer std_logic_vector(15 downto 0)
);
end component;

component boxCollector is
port(
	clk_25M, clk_100M, enable : in std_logic;
	lx, ly, rx, ry : in std_logic_vector(15 downto 0);
	finish : out std_logic;
	total : buffer std_logic_vector(4 downto 0);
	boxes : out std_logic_vector(760 downto 1)
);
end component;
-----------------keyboard------------------
component key is                                       
port(
datain,clkin,fclk,rst_in: in std_logic;
keys:out std_logic_vector(3 downto 0)
);
end component;
--------------------------------------------

signal address_tmp, c_address_tmp, b_address_tmp: std_logic_vector(11 downto 0);
signal clk25: std_logic;
signal q_tmp, c_q_tmp, b_q_tmp: std_logic_vector(8 downto 0);
signal xx: std_LOGIC_VECTOR(9 downto 0):="0100101100";
signal yy: std_LOGIC_VECTOR(9 downto 0):="0011100110";

-----------------------mouse-----------------------
signal mouse_x, mouse_y: std_logic_vector(9 downto 0);
signal new_x1, new_x2, new_y1, new_y2: std_logic_vector(10 downto 0); 
signal lef,rig,mid: std_logic;
---------------------------------------------------

-----------------------keyboard-----------------------
signal adws : std_logic_vector(3 downto 0); 
---------------------------------------------------


-----------------------debug----------------------
signal nouse: std_logic;
signal xxx, yyy:std_LOGIC_vector(15 downto 0);
--signal px, py : std_logic_vector(15 downto 0);
--signal lx, ly, rx, ry : std_logic_vector(15 downto 0);
signal enable, finish : std_logic;
signal total : std_logic_vector(4 downto 0);
signal boxes : std_logic_vector(760 downto 1);
--------------------------------------------------
begin
--
u1: vga640480 port map(
						rx=>xx, ry=>yy, mx=>mouse_x, my=>mouse_y,

						address=>address_tmp, c_address=>c_address_tmp, b_address=>b_address_tmp,
						reset=>reset, 
						clk25=>clk25,
						q=>q_tmp, c_q=>c_q_tmp, b_q=>b_q_tmp,
						clk_0=>clk_0, 
						hs=>hs, vs=>vs, 
						r=>rr, g=>gg, b=>bb,
						enable=>enable, finish=>finish,
						total=>total,
						boxes=>boxes
					);
rom1: r port map(	
						address=>address_tmp, 
						clock=>clk_0, 
						q=>q_tmp(2 downto 0)
					);
					
rom2: g port map(	
						address=>address_tmp, 
						clock=>clk_0, 
						q=>q_tmp(5 downto 3)
					);
					
rom3: b port map(	
						address=>address_tmp, 
						clock=>clk_0, 
						q=>q_tmp(8 downto 6)
					);

c_rom1: c_r port map(	
						address=>c_address_tmp, 
						clock=>clk_0, 
						q=>c_q_tmp(2 downto 0)
					);
					
c_rom2: c_g port map(	
						address=>c_address_tmp, 
						clock=>clk_0, 
						q=>c_q_tmp(5 downto 3)
					);
					
c_rom3: c_b port map(	
						address=>c_address_tmp, 
						clock=>clk_0, 
						q=>c_q_tmp(8 downto 6)
					);

b_rom1: b_r port map(	
						address=>b_address_tmp, 
						clock=>clk_0, 
						q=>b_q_tmp(2 downto 0)
					);
					
b_rom2: b_g port map(	
						address=>b_address_tmp, 
						clock=>clk_0, 
						q=>b_q_tmp(5 downto 3)
					);
					
b_rom3: b_b port map(	
						address=>b_address_tmp, 
						clock=>clk_0, 
						q=>b_q_tmp(8 downto 6)
					);					
					
mouse: drawpoint port map(
						clk100=>clk_0,
						reset_in=>reset,
						x1=>new_x1, x2=>new_x2,
						y1=>new_y1 ,y2=>new_y2,
						mousex=>mouse_x, mousey=>mouse_y,
						ps2_clk=>ps2clk,
						ps2_data=>ps2data,
						left_button=>lef,
						middle_button=>mid,
						right_button=>rig,
						drawbutton=>drawbutton
						);

--keyboard: key port map (
--							datain=>ps2data,
--							clkin=>ps2clk,
--							fclk=>clk_0,
--							rst_in=> not reset,
--							keys=>adws
--						);

gc: gameControlUnit port map(
						clk_25M=>clk25, clk_100M=>clk_0,
						moveL=>lef,
						moveR=>rig,
						jump=>mid,
						player_x=>xxx,
						player_y=>yyy
                   );
sc: screenCoordinate port map(clk25, xxx, yyy, lx, ly, rx, ry, px, py);
bc: boxCollector port map(clk25, clk_0, enable, lx, ly, rx, ry, finish, total, boxes);						 
process (xxx)
begin 
	xx<= conv_std_logic_vector(conv_integer(px), 10);
end process;

process (yyy)
begin
	yy<= 479 - conv_std_logic_vector(conv_integer(py), 10);
end process;
						
end one;