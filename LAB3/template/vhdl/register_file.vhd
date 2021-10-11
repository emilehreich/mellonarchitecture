library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    port(
        clk    : in  std_logic;
        aa     : in  std_logic_vector(4 downto 0);
        ab     : in  std_logic_vector(4 downto 0);
        aw     : in  std_logic_vector(4 downto 0);
        wren   : in  std_logic;
        wrdata : in  std_logic_vector(31 downto 0);
        a      : out std_logic_vector(31 downto 0);
        b      : out std_logic_vector(31 downto 0)
    );
end register_file;

architecture synth of register_file is

  --creating an array of std_logic_vectors type of size 32 to represent the register register_file
  type registers is array(0 to 31) of std_logic_vector(31 downto 0);

  signal s_register : registers := (others => (others => '0')); -- an array of registers
  signal s_a : std_logic_vector(31 downto 0);
  signal s_b : std_logic_vector(31 downto 0);

begin

  --asynchronous process for reading in register file
  reading : process(aa, ab, s_register, wren)
  begin
    if wren = '0' then
      s_a <= s_register(to_integer(unsigned(aa)));
      s_b <= s_register(to_integer(unsigned(ab)));
    end if;
  end process;

  --output assignement
  assignement : process(s_a, s_b)
  begin
    a <= s_a;
    b <= s_b;
  end process;

  --synchronous process for writing in register register_file
  writing : process(clk)
  begin

    -- if rising edge
    if rising_edge(clk) then
      if(wren = '1') then
        -- register 0 stays 0 vs other reads data
        case aw is
          when "00000" => s_register(0) <= (Others => '0');
          when Others => s_register(to_integer(unsigned(aw))) <= wrdata;
        end case;
      end if;
    end if;

  end process;

end synth;
