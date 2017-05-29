library	ieee;
use		ieee.std_logic_1164.all;
use		ieee.std_logic_unsigned.all;
use		ieee.std_logic_arith.all;

entity vga_rom is
port(
	role_address, brush_address, box_address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
	clock		: IN STD_LOGIC ;
	role_q, brush_q, box_q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
);
end vga_rom;

architecture one of vga_rom is
COMPONENT role_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END COMPONENT;

COMPONENT brush_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END COMPONENT;

COMPONENT box_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END COMPONENT;

begin

rom1: role_rom port map(	
						address=>role_address, 
						clock=>clock, 
						q=>role_q
					);
					
rom2: brush_rom port map(	
						address=>brush_address, 
						clock=>clock, 
						q=>brush_q
					);

rom3: box_rom port map(	
						address=>box_address, 
						clock=>clock, 
						q=>box_q
					);

					

end one;