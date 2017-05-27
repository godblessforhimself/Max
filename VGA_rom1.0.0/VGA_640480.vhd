library	ieee;
use		ieee.std_logic_1164.all;
use		ieee.std_logic_unsigned.all;
use		ieee.std_logic_arith.all;

entity vga640480 is
	 port(
			rx,ry,mx,my :         in std_logic_vector(9 downto 0);                   --人物，鼠标坐标

			address,	c_address	:		    out	std_logic_vector(11 DOWNTO 0);
			reset       :         in  std_logic;
			clk25:		    out std_logic; 
			q, c_q  	   :		    in std_logic_vector(8 downto 0);
			clk_0       :         in  std_logic; 
			hs,vs       :         out std_logic; --��ͬ������ͬ���ź�
			r,g,b       :         out std_logic_vector(2 downto 0)

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
		variable role_x, role_y, mouse_x, mouse_y: integer:=0;
		variable flag: std_logic:= '0'; 
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
					if  (mouse_x >= 0 and mouse_x < 48) and (mouse_y >= -48 and mouse_y < 0) then
						c_address<=conv_std_logic_vector((mouse_y + 48) * 48 + mouse_x, 12);
						if c_q /= "111111111" then
							flag:= '1';
							r1<=c_q(2 downto 0);
							g1<=c_q(5 downto 3);
							b1<=c_q(8 downto 6);
						end if;
					end if;
					
					if flag = '0' then
						if (role_x >= -32 and role_x < 32) and (role_y >= -32 and role_y < 32) then
							address<=conv_std_logic_vector((role_y + 32) * 64 + role_x + 32, 12);
							if q = "111111111" then
								r1<="000";
								g1<="110";
								b1<="000";
							else
								r1<=q(2 downto 0);
								g1<=q(5 downto 3);
								b1<=q(8 downto 6);
							end if;	
						else
							r1<="000";
							g1<="110";
							b1<="000";
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

end behavior;

