library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
	constant moveNext : signed(15 downto 0) := to_signed(4, 16); 
	
	signal currentAddress : std_logic_vector(15 downto 0);
begin
	
	nextAdress : process(reset_n, clk, en)
	begin
		if(reset_n = '0') then
			-- active low reset 
			currentAddress <= (others => '0');	
		else
			if(rising_edge(clk) and en='1') then
				if(add_imm = '1') then
					-- branch 
					currentAddress <= (std_logic_vector(signed(currentAddress) + signed(imm)));
				elsif(sel_imm = '1') then
					-- call (imm16 field shifted to the left by 2) and jmpi 
					currentAddress <= imm(13 downto 0) & "00";
				elsif(sel_a = '1') then
					-- callr (takes value from register a) and jmp
					currentAddress <= a;
				else
					-- fetch 2
					currentAddress <= (std_logic_vector(signed(currentAddress) + moveNext));
				end if;
			end if;			
		end if;
	end process;
	
	
	affectationProcess : process(currentAddress)
	begin
		-- output the address (must always be a valid address, this way the 2 least bits are set to 0)
		addr <= (31 downto 16 => '0') & currentAddress(15 downto 2) & "00";
	end process;	
end synth;
