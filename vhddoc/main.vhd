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
	
	drawbutton: in std_logic;
	w,a,d: in std_logic;
	
	---------------------sd---------------------
	cs : out std_logic;
	mosi : out std_logic;
	miso : in std_logic;
	sclk : out std_logic;
	----------------------------sram----------------
	
    sram_addr: buffer std_logic_vector (20 downto 0) := (others=>'0');
    sram_data: inout std_logic_vector (31 downto 0);
    sram_rw:   buffer std_logic_vector (1 downto 0) := "11"
	
);
end main;

architecture one of main is

component vga640480 is
	 port(
			heart          :      in std_logic_vector(2 downto 0);
			rx,ry,mx,my    :      in std_LOGIC_vector(9 downto 0);
			lx             :      in std_logic_vector(15 downto 0);          --absolute coordinate
			rom_role_address, rom_brush_address, rom_box_address, rom_heart_address:		  out	STD_LOGIC_VECTOR(11 DOWNTO 0);
			
			reset       :         in  STD_LOGIC;
			clk25       :		  out std_logic; 
			rom_role_q, rom_brush_q, rom_box_q, rom_heart_q  :		  in STD_LOGIC_vector(8 downto 0);
			clk_0       :         in  STD_LOGIC; --100Mʱ������
			hs,vs       :         out STD_LOGIC; --��ͬ������ͬ���ź�
			r,g,b       :         out STD_LOGIC_vector(2 downto 0);
			----------------------------box--------------------------
			enable : out std_logic;
			finish : in std_logic;
			total : in std_logic_vector(4 downto 0);
			boxes : in std_logic_vector(760 downto 1);
			-----------------------------sram-------------------------
			ready : in std_logic;
			sram_address   :  out std_logic_vector(20 downto 0);
			in_data        :  in  std_logic_vector(31 downto 0)
	  );
end component;

component vga_rom is
port(
	role_address, brush_address, box_address, heart_address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
	clock		: IN STD_LOGIC ;
	role_q, brush_q, box_q, heart_q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
);
end component;
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

---------------------sdcard-------------------
component sd_test is
port (
    ---------------------sd---------------------
	cs : out std_logic;
	mosi : out std_logic;
	miso : in std_logic;
	sclk : out std_logic;
	----------------------------sram----------------
	
    sram_addr: buffer std_logic_vector (20 downto 0) := (others=>'0');
    sram_data: inout std_logic_vector (31 downto 0);
    sram_rw:   buffer std_logic_vector (1 downto 0) := "11";
    
	mode_ctrl: in std_logic;

	rd : in std_logic;
	reset_in : in std_logic;
	clk_in : in std_logic	-- twice the SPI clk
);
end component;
----------------------------------------------

-----------------------vga-------------------------------------
signal role_address_tmp, brush_address_tmp, box_address_tmp, heart_address_tmp: std_logic_vector(11 downto 0);
signal clk25: std_logic;
signal role_q_tmp, brush_q_tmp, box_q_tmp, heart_q_tmp: std_logic_vector(8 downto 0);
signal heart_tmp: std_logic_vector(2 downto 0);
signal xx: std_LOGIC_VECTOR(9 downto 0):="0100101100";
signal yy: std_LOGIC_VECTOR(9 downto 0):="0011100110";
signal enable, finish : std_logic;
signal total : std_logic_vector(4 downto 0);
signal boxes : std_logic_vector(760 downto 1);
signal ready: std_logic:='0';
-----------------------------------------------------------------

-----------------------mouse-----------------------
signal mouse_x, mouse_y: std_logic_vector(9 downto 0);
signal new_x1, new_x2, new_y1, new_y2: std_logic_vector(10 downto 0); 
signal lef,rig,mid: std_logic;
---------------------------------------------------

-----------------------keyboard-----------------------
signal adws : std_logic_vector(3 downto 0); 
---------------------------------------------------

-------------------------sram-------------------------
signal sram_addr_sd, sram_addr_vga: std_logic_vector (20 downto 0);
--------------------------------------------------------

-----------------------debug----------------------
signal nouse: std_logic;
signal xxx, yyy:std_LOGIC_vector(15 downto 0);
signal px, py : std_logic_vector(15 downto 0);
signal lx, ly, rx, ry : std_logic_vector(15 downto 0);

--------------------------------------------------
begin
--
u1: vga640480 port map(
						heart=>heart_tmp,
						rx=>xx, ry=>yy, mx=>mouse_x, my=>mouse_y,
						lx=>lx,
						rom_role_address=>role_address_tmp, rom_brush_address=>brush_address_tmp, rom_box_address=>box_address_tmp, rom_heart_address=>heart_address_tmp,
						reset=>reset, 
						clk25=>clk25,
						rom_role_q=>role_q_tmp, rom_brush_q=>brush_q_tmp, rom_box_q=>box_q_tmp, rom_heart_q=>heart_q_tmp,
						clk_0=>clk_0, 
						hs=>hs, vs=>vs, 
						r=>rr, g=>gg, b=>bb,
						enable=>enable, finish=>finish,
						total=>total,
						boxes=>boxes,
						-----------------------------sram-------------------------
						ready=>ready,
						sram_address=>sram_addr_vga,
						in_data=>sram_data
					);

rom: vga_rom port map(
					role_address=>role_address_tmp, brush_address=>brush_address_tmp, box_address=>box_address_tmp, heart_address=>heart_q_tmp,
					clock=>clk_0,
					role_q=>role_q_tmp, brush_q=>brush_q_tmp, box_q=>box_q_tmp, heart_q=>heart_q_tmp
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

keyboard: key port map (
							datain=>ps2data,
							clkin=>ps2clk,
							fclk=>clk_0,
							rst_in=> not reset,
							keys=>adws
						);

gc: gameControlUnit port map(
						clk_25M=>clk25, clk_100M=>clk_0,
						moveL=>adws(3),
						moveR=>'1',
						jump=>adws(1),
						player_x=>xxx,
						player_y=>yyy
                   );
sc: screenCoordinate port map(clk25, xxx, yyy, lx, ly, rx, ry, px, py);
bc: boxCollector port map(clk25, clk_0, enable, lx, ly, rx, ry, finish, total, boxes);			

sd_card: sd_test port map(
						cs=>cs,
						mosi=>mosi,
						miso=>miso,
						sclk=>sclk,

						sram_addr=>sram_addr_sd,
						sram_data=>sram_data,
						sram_rw=>sram_rw,
						mode_ctrl=>'0',
						rd=>'0',
						reset_in=>reset,
						clk_in=>clk_0
						);
			 
process (xxx)
begin 
	xx<= conv_std_logic_vector(conv_integer(px), 10);
end process;

process (yyy)
begin
	yy<= 479 - conv_std_logic_vector(conv_integer(py), 10);
end process;

process (sram_rw, sram_addr_sd, sram_addr_vga)
begin
	if sram_rw = "01" then
		ready<= '1';
		sram_addr<=sram_addr_vga;
	else
		ready<= '0';
		sram_addr<=sram_addr_sd;
	end if;
end process;

end one;