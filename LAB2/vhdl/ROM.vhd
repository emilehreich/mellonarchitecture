library ieee;
use ieee.std_logic_1164.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is

  signal s_q, s_rddata : std_logic_vector(31 downto 0);

  --ROM Block component
  component ROM_Block is
    port
    (
      address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
      clock		: IN STD_LOGIC  := '1';
      q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
  end component;

begin

  --instantiation of a ROM_Block
  rom : ROM_Block
  port map(
    address => address,
    clock => clk,
    q => s_q
  );

  --reading process
  r : process(clk)
  begin
    if rising_edge(clk) then
      if read = '1' then
        s_rddata <= s_q;
      end if;
    end if;
  end process;

  --output logic with tristate buffer
  o : process(clk)
  begin
    if rising_edge(clk) then
      if cs = '1' then
        rddata <= s_rddata;
      else
        rddata <= (others => 'Z');
      end if;
    end if;
  end process;

end synth;
