library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_unit is
    port(
        a  : in  std_logic_vector(31 downto 0);
        b  : in  std_logic_vector(4 downto 0);
        op : in  std_logic_vector(2 downto 0);
        r  : out std_logic_vector(31 downto 0)
    );
end shift_unit;

architecture synth of shift_unit is
	signal s_leastbits_ofB : unsigned(4 downto 0);
	signal replacementBit : std_logic;
begin

  shift_rotate : process (op)
		variable v : std_logic_vector(31 downto 0); 
	begin
	
		v := a;
		
		for i in 0 to 4 loop
			if (b(i) = '1') then
				case op is	
					----------------------------------------- LEFT -------------------------------------
					-- "000" : rotate left (incoming bits are the out-coming bits : circular shift)
					when "000" => v := v(31 - 2**i downto 0) & v(31 downto 31 + 1 - 2**i);	--seems to be correct
					
					-- "010" : shift left logical (incoming bits are 0)	
					when "010" => v :=  v(31 - 2**i downto 0) & ((2**i - 1 downto 0) => '0'); --seems to be correct
					
					----------------------------------------- RIGHT -------------------------------------
					-- "001" : rotate right (incoming bits are the out-coming bits : circular shift)
					when "001" => v := v(2**i - 1 downto 0) & v(31 downto 2**i); --seems to be correct
						
					-- "011" : shift right logical (incoming bits are 0)
					when "011" => v := ((31 downto 31 - 2**i + 1) => '0') & v(31 downto 2**i); --seems to be correct
					
					-- "111" : shift right arithmetic (incoming bits are 0 but the sign is conserved)
					when "111" => v := v(31) & ((30 downto 30 + 1 - 2**i) => '0') & v(30 downto 2**i); -- what in this cases ??? 
				end case;
			end if;
		end loop;
		
		-- assign the result 
		r <= v; 
		
	end process shift_rotate;
end synth;
