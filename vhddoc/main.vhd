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
			dashenergy, dashspeed: in std_logic_vector(2 downto 0);
			victory        :      in std_logic;
			rom_role_address, rom_brush_address, rom_box_address, rom_heart_address, rom_dash_address:		  out	STD_LOGIC_VECTOR(11 DOWNTO 0);
			
			reset       :         in  STD_LOGIC;
			clk25       :		  out std_logic; 
			rom_role_q, rom_brush_q, rom_box_q, rom_heart_q, rom_dash_q  :		  in STD_LOGIC_vector(8 downto 0);
			clk_0       :         in  STD_LOGIC; --100M闂佸搫鍟悥濂稿极閹捐妫橀柕鍫濇椤忓爼姊虹捄銊ユ瀾闁哄顭烽獮蹇涙倻閼恒儲娅㈤梺鍝勫€堕崐鏍偓
			hs,vs       :         out STD_LOGIC; --闂備浇娉曢崰鎰板几婵犳艾绠€瑰嫮澧楅崐閬嶆⒑鐠恒劌鏋戦柡瀣煼楠炲繘鎮滈懞銉︽闂佸搫鍊堕崐鏍偓姘秺閺屻劑鎮㈤崨濠勪紕闂佺懓鍢查崲鏌ュ箖閹剧粯鐓ラ柣鏂挎啞閻忣噣鏌熸搴″幋闁轰焦鎹囬幊妯侯潩閸楃偟娈ら梺
			r,g,b       :         out STD_LOGIC_vector(2 downto 0);
			----------------------------box--------------------------
			enable : out std_logic;
			finish : in std_logic;
			total : in std_logic_vector(4 downto 0);
			boxes : in std_logic_vector(760 downto 1);
			box_mark: in std_logic_vector(0 to 31);
			-----------------------------sram-------------------------
			ready : in std_logic;
			sram_address   :  out std_logic_vector(20 downto 0);
			in_data        :  in  std_logic_vector(31 downto 0)
			
	  );
end component;

component vga_rom is
port(
	role_address, brush_address, box_address, heart_address, dash_address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
	clock		: IN STD_LOGIC ;
	role_q, brush_q, box_q, heart_q, dash_q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
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
	ready : in std_logic;
	clk_25M, clk_100M: in std_logic;
	moveL, moveR, jump, moveD, dash : in std_logic;
	heart : buffer std_logic_vector(2 downto 0);
	dashEnergy, dashSpeed : buffer std_logic_vector(2 downto 0);
	victory : out std_logic;
	ha : buffer std_logic_vector(0 to 10);
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
	used : in std_logic_vector(0 to 10);
	finish : out std_logic;
	total : buffer std_logic_vector(4 downto 0);
	mark : out std_logic_vector(0 to 31);
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
signal role_address_tmp, brush_address_tmp, box_address_tmp, heart_address_tmp, dash_address_tmp: std_logic_vector(11 downto 0);
signal clk25: std_logic;
signal role_q_tmp, brush_q_tmp, box_q_tmp, heart_q_tmp, dash_q_tmp: std_logic_vector(8 downto 0);
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

-------------------------sd-----------------------------
signal rst_tmp: std_logic;
--------------------------------------------------------

-----------------------debug----------------------
signal nouse: std_logic;
signal xxx, yyy:std_LOGIC_vector(15 downto 0);
signal px, py : std_logic_vector(15 downto 0);
signal lx, ly, rx, ry : std_logic_vector(15 downto 0);
signal dashEnergy, dashSpeed : std_logic_vector(2 downto 0);
signal victory : std_logic;
signal boxMark : std_logic_vector(0 to 31);
signal used : std_logic_vector(0 to 10);

--------------------------------------------------
begin
--
u1: vga640480 port map(
						heart=>heart_tmp,
						rx=>xx, ry=>yy, mx=>mouse_x, my=>mouse_y,
						lx=>lx,
						dashenergy=>dashEnergy, dashspeed=>dashSpeed,
						victory=>victory,
						rom_role_address=>role_address_tmp, rom_brush_address=>brush_address_tmp, rom_box_address=>box_address_tmp, rom_heart_address=>heart_address_tmp, rom_dash_address=>dash_address_tmp,
						reset=>reset, 
						clk25=>clk25,
						rom_role_q=>role_q_tmp, rom_brush_q=>brush_q_tmp, rom_box_q=>box_q_tmp, rom_heart_q=>heart_q_tmp, rom_dash_q=>dash_q_tmp,
						clk_0=>clk_0, 
						hs=>hs, vs=>vs, 
						r=>rr, g=>gg, b=>bb,
						enable=>enable, finish=>finish,
						total=>total,
						boxes=>boxes,
						box_mark=>boxMark,
						-----------------------------sram-------------------------
						ready=>ready,
						sram_address=>sram_addr_vga,
						in_data=>sram_data
					);

rom: vga_rom port map(
					role_address=>role_address_tmp, brush_address=>brush_address_tmp, box_address=>box_address_tmp, heart_address=>heart_address_tmp, dash_address=>dash_address_tmp,
					clock=>clk_0,
					role_q=>role_q_tmp, brush_q=>brush_q_tmp, box_q=>box_q_tmp, heart_q=>heart_q_tmp, dash_q=>dash_q_tmp
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
						ready=>ready,
						clk_25M=>clk25, clk_100M=>clk_0,
						moveL=>'0',
						moveR=>'1',
						jump=>adws(1),
						moveD=>adws(0),
						dash=>adws(2),
						heart=>heart_tmp,
						dashEnergy=>dashEnergy,
						dashSpeed=>dashSpeed,
						victory=>victory,
						ha=>used,
						player_x=>xxx,
						player_y=>yyy
                   );
sc: screenCoordinate port map(clk25, xxx, yyy, lx, ly, rx, ry, px, py);
bc: boxCollector port map(clk25, clk_0, enable, lx, ly, rx, ry, used, finish, total, boxMark, boxes);			

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