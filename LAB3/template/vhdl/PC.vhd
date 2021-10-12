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
	constant moveNext : unsigned(15 downto 0) := to_unsigned(4, 16); 
	
	signal currentAddress : std_logic_vector(15 downto 0);
begin
	
	nextAdress : process(reset_n, clk, en)
	begin
		if(reset_n = '0') then	--active low (perform its function when its
								--logic level is 0)
			currentAddress <= (others => '0');	
		else
			if(rising_edge(clk) and en='1') then
				currentAddress <= (std_logic_vector(unsigned(currentAddress) + moveNext));
			end if;			
		end if;
	end process;
	
	
	affectationProcess : process(currentAddress)
	begin
		-- must be a valid address => two least significant bits
	    -- should remains at '0'
		addr <= (31 downto 16 => '0') & currentAddress(15 downto 2) & "00";
	end process;	
end synth;
