library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;


architecture synth of RAM is
	-- combination of SRAM to build RAM type 1024 * 4line for 1 word (1B line)
	type arrayOfSram is array(0 to 1023) of std_logic_vector(31 downto 0);
	signal RAM : arrayOfSram := (others => (others => '0'));

	-- "at the rising edge, the selected module must save the address, and the read and cs signal"
	signal s_target : std_logic_vector(9 downto 0);
	signal s_readNout : std_logic := '0';

  --flag
  signal s_flag : std_logic := '1';

begin

	-- synchronous reading process with 1 clock cycle latency
	requireReading : process(clk)
	begin
		if(rising_edge(clk)) then
			-- store the ask for read and desired address
			if(cs='1' and read='1') then
				s_readNout <= '1';
				s_target <= address;
      else
        s_readNout <= '0';
      end if;
		end if;
	end process;

  --output
  assign : process(s_readNout, s_target)
  begin
    if (s_readNout = '1') then
      rddata <=  RAM(to_integer(unsigned(s_target)));
    else
      rddata <= (others => 'Z');
    end if;
  end process;

	-- synchronous write without latency : modify memory value
	writting : process(clk)
	begin
		if(rising_edge(clk)) then
			if(write = '1' and cs = '1') then
        RAM(to_integer(unsigned(address))) <= wrdata;
			end if;
		end if;
	end process;
end synth;
