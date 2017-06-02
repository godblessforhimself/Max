library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity gameControlUnit is
port(
	clk_25M, clk_100M : in std_logic;
	moveL, moveR, jump : in std_logic;
	--test : buffer std_logic;
	--test_inside : buffer std_logic;
	--test_dir : buffer std_logic_vector(2 downto 0);
	--box : buffer std_logic_vector(63 downto 0);
	player_x, player_y : buffer std_logic_vector(15 downto 0)
	--background : buffer std_logic_vector(10 downto 0)
	);
end gameControlUnit;

architecture bhv of gameControlUnit is

--------------------------------function----------------------------------------

function inside(x1, x2, x : std_logic_vector(15 downto 0)) return boolean is
begin
	return ((x1 <= x) and (x <= x2));
end inside;


------------------------------end function--------------------------------------

---------------------------------component---------------------------------------

component romOfBox
port(
	address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
	clock		: IN STD_LOGIC  := '1';
	q		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
);
end component;

component fp is 
port(
	clk : in std_logic;
	o : out std_logic
	);
end component;
-----------------------------end component---------------------------------------

---------------------------signal & variable define------------------------------
--type statsOfControlUnit is (waiting, running);
--type statsOfGameProcess is (initialize, start, running, dead, gameover);
--type statsOfPlayer is (onGround, up, down);
--type statsOfIntersectionWithBoxes is (startFor, outFor);
--type statsOfCoordinateCounting is (LR, fall, jump, down);
--type statsOfForControl is (before, in);
type myBox is array(0 to 3) of std_logic_vector(15 downto 0);
constant totalObjs : integer := 500;
constant zeros : std_logic_vector(20 downto 0) := "000000000000000000000";
signal step : std_logic_vector(15 downto 0) := "0000000000000111";
signal ijump_v : std_logic_vector(15 downto 0) := "0000000000001111";
constant screenLEdge : std_logic_vector(15 downto 0) := "0000000100000000";
constant screenREdge : std_logic_vector(15 downto 0) := "0000001100000000";
signal lastSaveX, lastSaveY, nextSaveX : std_logic_vector(15 downto 0);
signal absoluteX, absoluteY, lastX, lastY : std_logic_vector(15 downto 0);
signal jump_v : std_logic_vector(15 downto 0);
signal addressOfBox : std_logic_vector(8 downto 0);
signal cntOfControlUnit : std_logic_vector(20 downto 0) := "000000000000000000000";
signal CUS : std_logic := '0';
signal GPS : std_logic_vector(2 downto 0) := "000";
signal PS : std_logic_vector(1 downto 0);
signal IWBS : std_logic;
signal CCS : std_logic_vector(1 downto 0) := "00";
signal FCS : std_logic := '0';
signal box : std_logic_vector(63 downto 0);
signal minv, mins, deltaX : std_logic_vector(15 downto 0);
signal jumpToBottle, fallToGround, moveToEdge, onGround: std_logic := '0';
signal enableOfFor : std_logic;
signal dir : std_logic_vector(2 downto 0);
signal endFor : std_logic;
signal clk_1M : std_logic;
signal life : std_logic_vector(1 downto 0);
--------------------------end signal & variable define---------------------------

begin
	u1 : romOfBox port map(addressOfBox, clk_100M, box);
	u2 : fp port map(clk_25M, clk_1M);
	
	process(clk_1M)
	begin
		if(rising_edge(clk_1M)) then
			if(CUS = '0') then
				case(GPS) is
					when "000" =>
						life <= "01";
						GPS <= "001";
						IWBS <= '0';
						lastSaveX <= zeros(15 downto 7) & "1" & zeros(5 downto 0);
						lastSaveY <= zeros(15 downto 9) & "1" & zeros(7 downto 0);
						nextSaveX <= zeros(15 downto 13) & "1" & zeros(11 downto 0);
						
					when "001" =>
						if(moveR = '1' and life /= "00") then 
							GPS <= "010";
							PS <= "00";
						elsif(life = "00") then
							GPS <= "000";
							CUS <= '1';
						end if;
						absoluteX <= lastSaveX;
						absoluteY <= lastSaveY;
						life <= life + '1';
						
					when "010" =>
						case (CCS) is
							when "00" =>
								if(IWBS = '0') then
									enableOfFor <= '0';
									if((moveL xor moveR) = '1') then 
										IWBS <= '1';
										dir <= "00" & moveR;
									else
										if((PS = "01")) then
											CCS <= "10";
										elsif(PS = "10") then
											CCS <= "11";
										elsif((PS = "00") and (jump = '1')) then
											jump_v <= ijump_v;
											CCS <= "10";
											PS <= "01";
										else
											CUS <= '1';
										end if;
									end if;
								else 		
									enableOfFor <= '1';
									if(endFor = '1') then
										IWBS <= '0';
										if(dir = "00") then
											absoluteX <= absoluteX - mins;
										else
											absoluteX <= absoluteX + mins;
										end if;
										CCS <= "01";
									end if;
								end if;
							when "01" =>
								if(PS = "00") then
									dir <= "010";
									if(IWBS = '0') then
										enableOfFor <= '0';
										IWBS <= '1';
									else
										enableOfFor <= '1';
										if(endFor = '1') then
											IWBS <= '0';
											if(onGround = '0') then
												PS <= "10";
												jump_v <= zeros(15 downto 0);
												CCS <= "11";
											elsif(jump = '1') then
												jump_v <= ijump_v;
												CCS <= "10";
												PS <= "01";
											else
												CUS <= '1';
											end if;
										end if;
									end if;
								elsif(PS = "01") then
									CCS <= "10";
								else
									CCS <= "11";
								end if;
								
							when "10" =>
								dir <= "011";
								if(IWBS = '0') then
									enableOfFor <= '0';
									IWBS <= '1';
								else
									enableOfFor <= '1';
									if(endFor = '1') then
										IWBS <= '0';
										absoluteY <= absoluteY + minv;
										if((jumpToBottle = '1') or (jump_v = zeros(15 downto 0))) then
											PS <= "10";
										else
											jump_v <= jump_v  - '1';
										end if;
										CUS <= '1';
									end if;
								end if;
								
							when "11" =>
								dir <= "100";
								if(IWBS = '0') then
									enableOfFor <= '0';
									IWBS <= '1';
								else
									enableOfFor <= '1';
									if(endFor = '1') then
										IWBS <= '0';
										if((fallToGround = '1')) then
											PS <= "00";
											absoluteY <= absoluteY - minv;
										elsif(absoluteY < jump_v) then
											GPS <= "011";
										else
											jump_v <= jump_v + '1';
											absoluteY <= absoluteY - minv;
										end if;
										CUS <= '1';
									end if;
								end if;
								
						end case;
						
					when "011" =>
						GPS <= "001";
						CUS <= '1';
						
					when "100" =>
						GPS <= "001";
						CUS <= '1';
						
					when others =>
						GPS <= "001";
						CUS <= '1';
						
				end case;
				player_x <= absoluteX;
				player_y <= absoluteY;
				if(absoluteX > nextSaveX and PS = "00") then
					lastSaveX <= absoluteX;
					lastSaveY <= absoluteY;
					nextSaveX <= absoluteX + (zeros(15 downto 13) & "1" & zeros(11 downto 0));
				end if;
			else
				enableOfFor <= '0';
				cntofControlUnit <= cntOfControlUnit + '1';
				if(cntOfControlUnit(14) = '1') then
					cntOfControlUnit <= zeros;
					CUS <= '0';
					CCS <= "00";
				end if;
			end if;
		end if;
	end process;
	
	--15 downto 0
	--31 downto 16
	--47 downto 32
	--63 downto 48
	
	process(enableOfFor, clk_25M)
	begin
		if(rising_edge(clk_25M)) then
			if(enableOfFor = '1') then
				case (FCS) is
					when '0' =>
						mins <= step;
						minv <= jump_v;
						FCS <= '1';
						onGround <= '0';
						moveToEdge <= '0';
						jumpToBottle <= '0';
						fallToGround <= '0';
						addressOfBox <= zeros(8 downto 0);
						endFor <= '0';
					
					when '1' =>
						if((endFor = '0') and (addressOfBox < totalObjs)) then
							endFor <= '0';
							case(dir) is
								when "000" =>
									if(inside(box(47 downto 32), box(15 downto 0), absoluteY) and (absoluteX + '1' > box(31 downto 16)) and (absoluteX < box(31 downto 16) +mins + '1')) then
										mins <= absoluteX - box(31 downto 16);
										moveToEdge <= '1';
										--endFor <= '1';
									end if;
									
								when "001" =>
									if(inside(box(47 downto 32), box(15 downto 0), absoluteY) and (absoluteX < box(63 downto 48) + '1') and (absoluteX + mins + '1' > box(63 downto 48))) then
										mins <= box(63 downto 48) - absoluteX;
										moveToEdge <= '1';
										--endFor <= '1';
									end if;
									
								when "010" =>
									if(inside(box(63 downto 48), box(31 downto 16), absoluteX) and (absoluteY = box(15 downto 0))) then
										onGround <= '1';
										--endFor <= '1';
									end if;
						
								when "011" =>
									if(inside(box(63 downto 48), box(31 downto 16), absoluteX) and (absoluteY < box(47 downto 32) + '1') and (absoluteY + minv + '1' > box(47 downto 32))) then
										minv <= box(47 downto 32) - absoluteY;
										jumpToBottle <= '1';
										--endFor <= '1';
									end if;
						
								when "100" =>
									if(inside(box(63 downto 48), box(31 downto 16), absoluteX) and (absoluteY + '1' > box(15 downto 0)) and (absoluteY < box(15 downto 0) + minv + '1')) then
										minv <= absoluteY - box(15 downto 0);
										fallToGround <= '1';
										--endFor <= '1';
									end if;
									
								when others =>
									--endFor <= '1';
									
							end case;
							addressOfBox <= addressOfBox + '1';
						else
							endFor <= '1';
						end if;
				end case;
			else
				endFor <= '0';
				addressOfBox <= zeros(8 downto 0);
				FCS <= '0';
			end if;
		--test <= FCS;
		--test_dir <= dir;
		end if;
	end process;
end bhv;