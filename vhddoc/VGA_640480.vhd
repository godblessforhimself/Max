library	ieee;
use		ieee.std_logic_1164.all;
use		ieee.std_logic_unsigned.all;
use		ieee.std_logic_arith.all;

entity vga640480 is
	 port(
			heart       :         in std_logic_vector(2 downto 0);
			rx,ry,mx,my :         in std_logic_vector(9 downto 0);                   --人物，鼠标坐标
			lx          :         in std_logic_vector(15 downto 0);                  --absolute coordinate
			rom_role_address, rom_brush_address, rom_box_address, rom_heart_address:		    out	std_logic_vector(11 DOWNTO 0);
			reset       :         in  std_logic;
			clk25:		    out std_logic; 
			rom_role_q, rom_brush_q, rom_box_q, rom_heart_q:		    in std_logic_vector(8 downto 0);
			clk_0       :         in  std_logic; 
			hs,vs       :         out std_logic; --��ͬ������ͬ���ź�
			r,g,b       :         out std_logic_vector(2 downto 0);
			----------------------------box--------------------------
			enable : out std_logic;
			finish : in std_logic;
			total : in std_logic_vector(4 downto 0);
			boxes : in std_logic_vector(760 downto 1);
			-----------------------------sram-------------------------
			ready : in std_logic;
			sram_address   :  out std_logic_vector(20 downto 0);
			in_data        :  in  std_logic_vector(31 downto 0);
			-------------------------------sd-------------------------
			sd_choice: out std_logic_vector(1 downto 0)
	  );
end vga640480;

architecture behavior of vga640480 is
	type screen is array(0 to 479) of std_logic_vector(0 to 639);
	signal scr: screen:=(others => (others => '0'));
	
	signal r1,g1,b1   : std_logic_vector(2 downto 0);
	signal hs1,vs1    : std_logic;				
	signal vector_x : std_logic_vector(9 downto 0);		--X����
	signal vector_y : std_logic_vector(8 downto 0);		--Y����
	signal clk_50, clk: std_logic;
	
begin
   clk25 <= clk;
 -----------------------------------------------------------------------
	process(clk_0)	--��50M�����źŶ���Ƶ
	begin
		if(clk_0'event and clk_0='1') then 
			clk_50 <= not clk_50;
		end if;
	end process;
	
	process(clk_50)	--��50M�����źŶ���Ƶ
	begin
		if(clk_50'event and clk_50='1') then 
			clk <= not clk;
		end if;
	end process;
	
 -----------------------------------------------------------------------
	process(clk,reset)	--������������������������
	begin
	  	if reset='0' then
	   	vector_x <= (others=>'0');
		elsif clk'event and clk='1' then
	   	if vector_x=799 then
	    		vector_x <= (others=>'0');
	   	else
	    		vector_x <= vector_x + 1;
	   	end if;
		end if;
	end process;

  -----------------------------------------------------------------------
	 process(clk,reset)	--����������������������
	 begin
	  	if reset='0' then
	   		vector_y <= (others=>'0');
	  	elsif clk'event and clk='1' then
	   		if vector_x=799 then
					if vector_y=524 then
						vector_y <= (others=>'0');
					else
						vector_y <= vector_y + 1;
					end if;
	   		end if;
	  	end if;
	 end process;
 
  -----------------------------------------------------------------------
	 process(clk,reset) --��ͬ���źŲ�����ͬ������96��ǰ��16��
	 begin
		  if reset='0' then
				hs1 <= '1';
		  elsif clk'event and clk='1' then
		   	if vector_x>=656 and vector_x<752 then
					hs1 <= '0';
		   	else
					hs1 <= '1';
		   	end if;
		  end if;
	 end process;
 
 -----------------------------------------------------------------------
	 process(clk,reset) --��ͬ���źŲ�����ͬ������2��ǰ��10��
	 begin
	  	if reset='0' then
	   		vs1 <= '1';
	  	elsif clk'event and clk='1' then
	   		if vector_y>=490 and vector_y<492 then
					vs1 <= '0';
	   		else
					vs1 <= '1';
	   		end if;
	  	end if;
	 end process;
 -----------------------------------------------------------------------
	 process(clk,reset) --��ͬ���ź�����
	 begin
	  	if reset='0' then
	   		hs <= '0';
	  	elsif clk'event and clk='1' then
	   		hs <=  hs1;
	  	end if;
	 end process;

 -----------------------------------------------------------------------
	 process(clk,reset) --��ͬ���ź�����
	 begin
	  	if reset='0' then
	   		vs <= '0';
	  	elsif clk'event and clk='1' then
	   		vs <=  vs1;
	  	end if;
	 end process;
	
 -----------------------------------------------------------------------	
	process(reset, clk, vector_x, vector_y) -- XY���궨λ����
		variable role_x, role_y, mouse_x, mouse_y, brick_x, brick_y, heart_x, heart_y, tmp: integer:=0;
		variable flag, heart_flag: std_logic:= '0'; 
	begin  
		if reset='0' then
				r1 <= (others => '0');
				g1	<= (others => '0');
				b1	<= (others => '0');	
		elsif (clk'event and clk = '1') then		
			if vector_x >= 0 and vector_x < 640 and vector_y >= 0 and vector_y < 480 then
					role_x:= conv_integer(vector_x) - conv_integer(rx);
					role_y:= conv_integer(vector_y) - conv_integer(ry);
					mouse_x:= conv_integer(vector_x) - conv_integer(mx);
					mouse_y:= conv_integer(vector_y) - conv_integer(my);
					flag:= '0';
--					if  (mouse_x >= 0 and mouse_x < 48) and (mouse_y >= -48 and mouse_y < 0) then
--						rom_brush_address<=conv_std_logic_vector((mouse_y + 48) * 48 + mouse_x, 12);
--						if rom_brush_q /= "111111111" then
--							flag:= '1';
--							r1<=rom_brush_q(8 downto 6);
--							g1<=rom_brush_q(5 downto 3);
--							b1<=rom_brush_q(2 downto 0);
--						end if;
--					end if;
					if heart = "111" then
						sd_choice<= "01";
						if ready = '1' then
							sram_address<=conv_std_logic_vector(conv_integer(vector_y) * 640 + conv_integer(vector_x) + 2, 21);
							r1<=in_data(31 downto 29);
							g1<=in_data(28 downto 26);
							b1<=in_data(25 downto 23);
						else
							r1<="000";
							g1<="000";
							b1<="000";
						end if;
					else
						if flag = '0' then
							heart_flag:= '0';
							for i in 1 to 10 loop
								if i <= conv_integer(heart) then
									if vector_y >= 20 and vector_y < 52 and vector_x >= (i - 1) * 32 + 20 and vector_x < (i - 1) * 32 + 52 then 
										heart_flag:= '1';
										heart_x:= conv_integer(vector_x) - ((i - 1) * 32 + 20);
										heart_y:= conv_integer(vector_y) - 20;
									end if;
								end if;
							end loop;
							if heart_flag = '1' then
								rom_heart_address<=conv_std_logic_vector(heart_y * 32 + heart_x, 12);
								if rom_heart_q /= "111111111" then
									flag:= '1';
									r1<=rom_heart_q(8 downto 6);
									g1<=rom_heart_q(5 downto 3);
									b1<=rom_heart_q(2 downto 0);
								end if;
							end if;
						end if;
						
						if flag = '0' then
							if (role_x >= -32 and role_x < 32) and (role_y >= -64 and role_y < 0) then
								rom_role_address<=conv_std_logic_vector((role_y + 64) * 64 + role_x + 32, 12);
								if rom_role_q /= "111111111" then
									flag:= '1';
									r1<=rom_role_q(8 downto 6);
									g1<=rom_role_q(5 downto 3);
									b1<=rom_role_q(2 downto 0);
								end if;	
							end if;
						end if;
						
						if flag = '0' then
							tmp:= 761;
							for i in 1 to 20 loop
								tmp:= tmp - 38;
								if i <= conv_integer(total) then
									if vector_x >= boxes(tmp + 37 downto tmp + 28) and vector_x <= boxes(tmp + 18 downto tmp + 9) and 480 - vector_y >= boxes(tmp + 27 downto tmp + 19) and 480 - vector_y <= boxes(tmp + 8 downto tmp) then
										flag:= '1';
										brick_x:= conv_integer(vector_x) - conv_integer(boxes(tmp + 37 downto tmp + 28));
										brick_y:= 480 - conv_integer(vector_y) - conv_integer(boxes(tmp + 27 downto tmp + 19));
									end if;
								end if;
							end loop;
							if flag = '1' then
								rom_box_address<=conv_std_logic_vector((brick_y mod 64) * 64 + (brick_x mod 64), 12);
								r1<=rom_box_q(8 downto 6);
								g1<=rom_box_q(5 downto 3);
								b1<=rom_box_q(2 downto 0);
							else
								sd_choice<= "00";
								if ready = '1' then
									sram_address<=conv_std_logic_vector(conv_integer(vector_y) * 640 + ((conv_integer(vector_x) + conv_integer(lx)) mod 640) + 2, 21);
									r1<=in_data(31 downto 29);
									g1<=in_data(28 downto 26);
									b1<=in_data(25 downto 23);
								else
									r1<="000";
									g1<="000";
									b1<="000";
								end if;
							end if;
						end if;
					end if;
			else
				r1<="000";
				g1<="000";
				b1<="000";
			end if;
		end if;		 
	end process;	

	-----------------------------------------------------------------------
	process (hs1, vs1, r1, g1, b1)	--ɫ������
	begin
		if vector_x > 0 and vector_x < 640 and vector_y > 0 and vector_y < 480 then
			r	<= r1;
			g	<= g1;
			b	<= b1;
		else
			r	<= (others => '0');
			g	<= (others => '0');
			b	<= (others => '0');
		end if;
	end process;
	
	
	process(clk)
	begin
		if vector_y = 500 and vector_x = 700 then
			enable<= '0';
		elsif vector_y = 510 and vector_x = 720 then
			enable<= '1';
		end if;
	end process;
end behavior;

